//
//  InstancesManager.m
//  Leaks
//
//  Created by Sash Zats on 2/12/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

#import "LeaksInspector.h"

#import "_LeaksInspectorContext.h"

#include <objc/objc-api.h>
#include <objc/runtime.h>
#include <malloc/malloc.h>
#include <mach/mach.h>
#include <sys/sysctl.h>


#define ROUND_TO_MULTIPLE(num, multiple) ((num) && (multiple) ? (num) + (multiple) - 1 - ((num) - 1) % (multiple) : 0)

static Class _IIClassIfValid(void *isa) {
    static NSHashTable *classesSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // these options should make -[NSHashTable containsObject:] compare
        // pointers only which means if we get a garbage pointer we won't crash
        // on -isEqual: or -hash or something like that
        classesSet = [NSHashTable hashTableWithOptions:NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality];

        unsigned int classCount = 0;
        Class *classList = objc_copyClassList(&classCount);
        
        for (unsigned int i = 0; i < classCount; ++i) {
            Class class = classList[i];
            [classesSet addObject:class];
        }
        
        free(classList);
    });
    
    return [classesSet containsObject:(__bridge Class)isa] ? (__bridge Class)isa : NULL;
}

static BOOL _IIBeagleIsKnownUnsafeClass(Class aClass) {
    NSString *className = NSStringFromClass(aClass);
    if (!className) return YES;

    static NSSet *names;
    static NSSet *prefixes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        names = [NSSet setWithObjects:
            @"_NSZombie_", @"__ARCLite__", @"__NSCFCalendar", @"__NSCFTimer", @"NSCFTimer",
            @"__NSMessageBuilder", @"__NSGenericDeallocHandler", @"NSAutoreleasePool",
            @"NSPlaceholderNumber", @"NSPlaceholderMutableString", @"NSPlaceholderString", @"NSPlaceholderValue",
            @"Object", @"VMUArchitecture", @"NSKeyValueObservationInfo",
        nil];
        prefixes = [NSSet setWithObjects:
            @"__NSPlaceholder", @"_NSPlaceholder", @"__NSBlock",
        nil];
    });
    
    // Exact matches
    if ([names containsObject:className]) return YES;

    // Prefixes
    for (NSString *prefix in prefixes) {
        if ([className hasPrefix:prefix]) {
            return YES;
        }
    }
    
    return NO;
}


static kern_return_t IIReadMemory(task_t task, vm_address_t remote_address, vm_size_t size, void **local_memory) {
    *local_memory = (void*)remote_address;
    return KERN_SUCCESS;
}


static size_t _IIBeagleSizeRoundedToNearestMallocRangeAllocationSize(size_t size) {
    
    //these next defines are from the last known malloc source: https://www.opensource.apple.com/source/Libc/Libc-825.40.1/gen/magazine_malloc.c (10.8.5) ( See : http://openradar.io/15365352 )
#define SHIFT_TINY_QUANTUM      4 // Required for AltiVec
#define	TINY_QUANTUM           (1 << SHIFT_TINY_QUANTUM)
    
#ifdef __LP64__
#define NUM_TINY_SLOTS          64	// number of slots for free-lists
#else
#define NUM_TINY_SLOTS          32	// number of slots for free-lists
#endif
    
    //these next ones are extracted from inlined logic spread throughout magazine_malloc.c (think tiny)
#define SMALL_THRESHOLD            ((NUM_TINY_SLOTS - 1) * TINY_QUANTUM)
#define LARGE_THRESHOLD			 (15 * 1024)
#define LARGE_THRESHOLD_LARGEMEM	(127 * 1024) //if greater than 1GB of ram, large uses this define
    
    
    static size_t _largeThreshold = LARGE_THRESHOLD;
    
    static dispatch_once_t _largeThresholdOnceToken;
    dispatch_once(&_largeThresholdOnceToken, ^{
        
        uint64_t	memsize = 0;
        size_t	uint64_t_size = sizeof(memsize);
        sysctlbyname("hw.memsize", &memsize, &uint64_t_size, 0, 0);
        
        if (memsize >= (1024*1024*1024)) {
            _largeThreshold = LARGE_THRESHOLD_LARGEMEM;
        }
        
    });
    
    
    if (size <= SMALL_THRESHOLD){
        //tiny; 16 bytes allocation
        return ROUND_TO_MULTIPLE(size, 16);
    } else if (size <= _largeThreshold){
        //small; 512 bytes allocation
        return ROUND_TO_MULTIPLE(size, 512);
    }
    
    //large; 4096 bytes allocation
    return ROUND_TO_MULTIPLE(size, 4096);
    
}

static void _IIZoneIntrospectionEnumeratorFindInstancesCallback(task_t task, void *baton, unsigned type, vm_range_t *ranges, unsigned count) {
    _LeaksInspectorContext *context = (__bridge _LeaksInspectorContext *)baton;
    if (context.stop){
        return;
    }
    
    for (unsigned i = 0; i < count; i++) {
        vm_range_t *range =  &ranges[i];
        
        size_t size = range->size;
        
        //make sure range is big enough to contain an an instance of an object
        if (size < class_getInstanceSize([NSObject class])){
            continue;
        }
        
        //assume that ivars are pointer sized, allowing us to index into ivar territory
        uintptr_t *ivarPointers = (uintptr_t *)range->address;
        
#if defined(__arm64__)
        //MAGIC: for arm64 tagged isa pointers : (http://www.sealiesoftware.com/blog/archive/2013/09/24/objc_explain_Non-pointer_isa.html)
        //Note: We can't use object_getClass directly because we have no idea if the pointer is actually to an object or not at this point in time.
        extern uint64_t objc_debug_isa_class_mask WEAK_IMPORT_ATTRIBUTE;
        
        uint64_t taggedPointerMask;
        if (objc_debug_isa_class_mask == 0x0){
            //fall back to 0x00000001fffffff8 as of 19th May 2014; Not ABI stable..
            taggedPointerMask = 0x00000001fffffff8;
        } else {
            taggedPointerMask = objc_debug_isa_class_mask;
        }
        
        void * isa = (void *)(ivarPointers[0] & taggedPointerMask);
        
#elif (defined(__i386__) || defined(__x86_64__) || defined(__arm__))
        //regular stuff, on these known arcs.
        void * isa = (void *)ivarPointers[0];
#else
        //unknown arch. we need to be updated depending on whether or not the arch uses tagged isa pointers
#error Unknown architecture. We don't know if tagged isa pointers are used, therefore we can't continue.
#endif
        
        Class matchedClass = _IIClassIfValid(isa);
        
        if (!matchedClass || _IIBeagleIsKnownUnsafeClass(matchedClass)) {
            continue;
        }
        
        //sanity check the zone size, making sure that it's the correct size for the classes instance size
        //malloc operates as per: http://www.cocoawithlove.com/2010/05/look-at-how-malloc-works-on-mac.html
        //therefore we need to round needed size to nearest quantum allocation size before comparing it to the ranges size
        
        size_t rounded = _IIBeagleSizeRoundedToNearestMallocRangeAllocationSize(class_getInstanceSize(matchedClass));
        if (rounded != size) continue;
        void *matchedInstance = (void *)range->address;
        
        switch (context.type) {
            case LeaksInspectorTypeEnumeration: {
                BOOL stop = NO;
                context.block(matchedClass, matchedInstance, &stop);
                context.stop = stop;
                if (stop) {
                    return;
                }
                break;
            }
                
            case LeaksInspectorTypeAllResults: {
                [context.results addObject:(__bridge id)matchedInstance];
                break;
            }
        }
    }
}

void _IIBeagleFindInstancesOfClassWithOptionsInternal(leaks_inspector_enumeration_t block, NSHashTable **results, NSPointerFunctionsOptions options) {
    
    //grab the zones in the current process
    vm_address_t *zones = NULL;
    unsigned int count = 0;
    kern_return_t error = malloc_get_all_zones(0, &IIReadMemory, &zones, &count);
    NSCAssert(error == KERN_SUCCESS, @"[RHBeagle] Error: malloc_get_all_zones failed.");
    
    //create our context object
    _LeaksInspectorContext *context;
    if (block) {
        context = [_LeaksInspectorContext contextForEnumerationWithBlock:block];
    } else if (results) {
        context = [_LeaksInspectorContext contextForAllResultsWithOptions:options];
    }
    
    for (unsigned i = 0; i < count; i++) {
        const malloc_zone_t *zone = (const malloc_zone_t *)zones[i];
        if (zone == NULL || zone->introspect == NULL){
            continue;
        }
        
        //for each zone, enumerate using our enumerator callback
        zone->introspect->enumerator(mach_task_self(), (__bridge void *)context, MALLOC_PTR_IN_USE_RANGE_TYPE, zones[i], &IIReadMemory, &_IIZoneIntrospectionEnumeratorFindInstancesCallback);
        if (context.stop) {
            break;
        }
    }
    
    if (results) {
        *results = context.results;
    }
}


@implementation LeaksInspector

- (NSHashTable *)allInstancesWithOptions:(NSPointerFunctionsOptions)options {
    NSHashTable *results;
    _IIBeagleFindInstancesOfClassWithOptionsInternal(nil, &results, options);
    return results;
}

- (void)enumerateAllInstancesUsingBlock:(leaks_inspector_enumeration_t)block {
    _IIBeagleFindInstancesOfClassWithOptionsInternal(block, nil, kNilOptions);
}

@end
