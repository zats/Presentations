autoscale: true

# [fit] `NSFWObjective-C`

---

# `/me`

![inline](https://pbs.twimg.com/profile_images/594752146970574849/NWv5jejI.jpg) ![inline](http://a5.mzstatic.com/us/r30/Purple7/v4/95/43/cf/9543cf13-eb78-b07d-809c-83682f499554/icon175x175.jpeg)

> Wondermall

---

# `/me`

```objectivec
if ([me isKindOfClass:[MetallurgicalEngineer class]]) {
    // I know how to melt metal
    if ([me isKindOfClass:[Designer class]]) {
    // Can tell difference between Arial and San Francisco
        if ([me isKindOfClass:[FlashDeveloper]]) {
            // "Skip Flash Intro"
            if ([me isKindOfClass:[ObjectiveCDeveloper]]) {
                // ♥️
                if let me = self as? SwiftDeveloper {
                    // I'm here
```


---

# [fit] `NSFWObjective-C`

^ Let me tell you a story. It should sound familiar to you.

---

# [fit] `NSFWObjective-C`

![inline](http://cdn.smosh.com/sites/default/files/bloguploads/simpsons-fire.gif)

^ This is what my talk is about

^ Doing things, that are not, strictly speaking, safe for work.

^ Sometimes, just because someone said it is not possible.

^ It is not always the pretties code, but it allows you to explore the runtime boundaries better.

---

# [fit] `#import <objc/runtime.h>`

^ let's begin

---

# [fit] Creating classes at runtime

^ This is just a warm up. How to simulate multiple inheritance.

---

What is it good for?[^1]

* Encapsulate functionality.
* Multiple inheritance.
* Build the class from the blocks.
* Temporary functionality to existent instances using `object_setClass`.

[^1]: War

^ - Just like a regular `class.m`
- This is something unholy. 
- If both inheritance and incapsulation failed you. Pallets classes: Button behaviour, checkbox behaviour, drag-n-drop behaviour.
- Add a temporary functionality. Leave no trace. Class must be a sublcass of instance. This is the technique KVO uses.

---

# Creating classes at runtime
## Demo

^ This is how I'm going to tell bed time stories to my kids, using Xcode and breakpoints

---

# Creating classes at runtime
## Next step: assembling classes.

```objectivec
[factory buildClassNamed:@"MyHero" usignBlock:^(ClassBuilder *myHero){
    [myHero copyMethod:@selector(flight) 
             fromClass:[Superman class]];
    
    [myHero copyMethod:@selector(voice) 
             fromClass:[Batman class]];

    [myHero copyMethod:@selector(retainCount) 
             fromClass:[Aquaman class]];

}];
```

^ Because you should never use `retainCount` in production code!

---

# Creating classes at runtime
## Slightly more useful

```objectivec
[factory buildClassNamed:@"CheckboxButton" usignBlock:^(ClassBuilder *button){
    [button copyMethod:@selector(touchUpInside) 
             fromClass:[CheckboxBehaviour class]];

    [button copyMethod:@selector(touchDownInside) 
             fromClass:[SoundLibrary click]];

    [button copyMethod:@selector(appearance) 
             fromClass:[UITheme checkboxAppearance]];
}];
```

^ A more applicable version: something similar to WPF I guess.

---

# KVO

^ I'm sure everyone is familiar with this techinque.

^ For both setters & getters

---

# KVO
## Demo

---

# KVO
## Preparing dynamic subclass

```objectivec
Class originalCls = object_getClass(target);
NSString *clsName = [NSString stringWithFormat:@"Xray_%@", originalCls];
Class cls = objc_allocateClassPair(originalCls, clsName.UTF8String, 0);
class_addMethod(cls, @selector(class), imp_implementationWithBlock(^(id self){
    return originalCls;
}), "#16@0:8");
objc_registerClassPair(cls);
object_setClass(target, cls);
```

^ It's used as:
1. Marker during runtime.
2. Encapsulation of modified behaviour: reset the class to clean up.

---

# KVO

```objectivec
SEL setterSEL = [self _setterForKey:key];
IMP originalIMP = [self _originalImpForSelector:setterSEL];
class_addMethod(cls, setterSEL, ^(id self, id value){
    originalIMP(self, setterSEL, newValue);
    handle(self, key, newValue);
}, setterSignature);
```

^ Several things to point out:
- `_setterForKey:` inspects property attribute `"S"` for custom setter, falling back onto standard `set<Key>:` scheme.
- Use `__weak` / `__strong` to avoid retain cycles in observer block.
- `if (!class_addMethod)` to take care of observing same key several times.
- Getter is exactly the same.

---

# KVO

Where to take it from here:

1. Match KVO's will / did change observation & old and new values.
1. `-(BOOL)shouldSet<Key>…` observer: whether new value is valid.
1. `-(void)transformValue:forKey:` allows to modify getter on the fly
1. Decrypt the value of property upon access by certain classes.

---

# KVO
## Summary

* Create you private subclass.
* Swizzle setter and getter, calling original implementation along with `handler`.
* Change instance class to your private subclass.
* Restore when after last `handler` removed.
* For a proper thread-safe KVO, [FBKVOController](http://github.com/facebook/kvocontroller).


---

# Toll-Free Bridging

^ A brief recap of what is TFB

---

# Toll-Free Bridging

* Bridge between `CoreFoundation` and `Foundation`.
* Many C APIs are still not matched with Objective-C ones.
* Cocoa optimization: vending private subclasses of `NSArray` before it was cool.
* Not possible to have your own[^3]

[^3]: https://mikeash.com/pyblog/friday-qa-2010-01-22-toll-free-bridging-internals.html

^ What is TFB?

^ Allows `CFStringRef` to be used where `NSString` is expected.

^ cough * NSHipster * cough

^ Finally, Cocoa loves to vend private classes, so you can run it through your method without even known about it.

^ The techonology is a solution to all the legacy code that Apple had before NeXTStep came and rewrote everything.

---

# Implementing Toll-Free Bridging
## Demo

^ 
1. Show CF class usage.
1. Show Objective-C class usage.
1. Unit test where Objective-C is used instead of CF.

---

# Toll-Free Bridging
## Counting members

```objectivec
CF_EXPORT CFIndex CFBinaryHeapGetCountOfValue(
	CFBinaryHeapRef heap, 
	const void *value
);

@interface BinaryHeap (Counting)

- (NSUInteger)countForObject:(id)object;

@end
```

---

# Toll-Free Bridging
## Counting members (CoreFoundation)

```objectivec
CFIndex CFBinaryHeapGetCountOfValue(CFBinaryHeapRef heap, const void *value) {
    CFComparisonResult(*compare)(const void *, const void *, void *);
    compare = heap->_callbacks.compare;
	CFIndex cnt = 0;
    for (CFIndex idx = 0; idx < CFBinaryHeapGetCount(heap); idx++) {
		const void *item = heap->_buckets[idx]._item;
		if ((value == item) || (heap->compare && 
		    (heap->compare(value, item, info) == kCFCompareEqualTo))) {
		    cnt++;
		}
    }
    return cnt;
}
```

^ Slightly simplified version of CFLite.

---

# Toll-Free Bridging
## Counting members (CoreFoundation)

```objectivec
CFIndex CFBinaryHeapGetCountOfValue(CFBinaryHeapRef heap, const void *value) {
    if (CFGetTypeID(heap) != CFBinaryHeapGetTypeID()) {
        return [(__bridge BinaryHeap *)heap countForObject:(__bridge id)value];
    }
    // ...
    return cnt;
}
```

^ This implementation might seem a bit dumpbed down for you, but if you pass an unexpected type to any CF function, you will get an error message `unrecognized selector sent to instance`

---

# Toll-Free Bridging
## C-functions swizzling

```objectivec
origGetCountOfValue = dlsym(RTLD_DEFAULT, "CFBinaryHeapGetCountOfValue");

rebind_symbols((struct rebinding[1]){
    {"CFBinaryHeapGetCountOfValue", replGetCountOfValue}
}, 1);

CFIndex replGetCountOfValue(CFBinaryHeapRef heap, void *value) {
    if (CFGetTypeID(heap) != CFBinaryHeapGetTypeID()) {
        return [(__bridge BinaryHeap *)heap countForObject:(__bridge id)value];
    }
    return origGetCountOfValue(heap, value);
}
```

^ `rebind_symbols` is a fishhook – swizzling of C functions.

---

# Toll-Free Bridging
## Counting members (Objective-C)

```objectivec
- (NSUInteger)countForObject:(id)object {
    NSUInteger count = 0;
    for (NSUInteger i = 0; i < self.count; ++i) {
        if ([self.buckets[i] isEqual:object]) {
            count++;
        }
    }
    return count;
}
```

^ Same thing in Objective-C

^ You can imagine Swift version..


---

# Toll-Free Bridging
## Counting members (Objective-C)

```objectivec
- (NSUInteger)countForObject:(id)object {
    if (CFGetTypeID((CFTypeRef)self) == CFBinaryHeapGetTypeID()) {
        return CFBinaryHeapGetCountOfValue((CFBinaryHeapRef)self, 
        								   (void *)object);
    }
    
    // ...
    return count;
}
```

---

# Toll-Free Bridging
## Bridging

```objectivec
CFBinaryHeapRef cfHeap = ...
[(__bridge BinaryHeap *)cfHeap count]; // bang!

_CFRuntimeBridgeClasses(CFBinaryHeapGetTypeID(), 
                        "BinaryHeap");
```

---

# Toll-Free Bridging
## `isa`

```objectivec
// objc4-646
@interface NSObject <NSObject> {
    Class isa OBJC_ISA_AVAILABILITY;
    // ...
}

// CF-1151.16
typedef struct __CFRuntimeBase {
    uintptr_t _cfisa;
    // ...
} CFRuntimeBase;
```

^ This is an interface for `NSObject`

^
As you can see, first bit of C
Plus CF-`struct`s match Objective-C object `struct`'s first field which is `isa`.
`isa` class stores all the information runtime needs for message sending.

--- 

# Toll-Free Bridging
## Summary

* Create you class, matching CF-API.
* In each method check if `self` is not a CF-counterpart.
* Swizzle CF-functions[^fh], call Objective-C method if 1<sup>st</sup> argument is not CF.
* Establish the bridging relationship between CF and Objective-C classes.
* One Objective-C counterpart for both mutable and immutable CF structures. `_NSCFArray` is actually a mutable array.

[^fh]: http://github.com/facebook/fishhook

---

# Creating protocols at runtime

---

# Creating protocol at runtime
## Setup

```objectivec
const char *protocolName = ProtocolNameForClass(cls).UTF8String;
Protocol *protocol = objc_allocateProtocol(protocolName);
protocol_addProtocol(protocol, @protocol(JSExport));
// ...
```

^ This is simple: 
1. Generate the name from the class name
2. Register protocol almost like class

--- 

# Creating protocol at runtime
## Protocol-hierarchy

```objectivec
Protocol *ExportClass(Class cls) {
    Protocol *protocol = objc_allocateProtocol(protocolName);
    // ...
    Class superclass = class_getSuperclass(cls);
    ExportClass(superclass);
    protocol_addProtocol(protocol, ProtocolForClass(superclass));
    // ...
}
```

^ Because protocol doesn't know of our plans to recreate class hierarchy, we have to recreate protocol hierarchy manually.
Function will go and recursively create all superclasses protocols first to make sure by the time we deal with out `cls`, all "super-protocols" are already registered.

--- 

# Creating protocol at runtime
## Instance methods

```objectivec
unsigned int count;
Method *methods = class_copyMethodList(object_getClass(cls), &count);
for (unsigned int i = 0; i < count; ++i) {
    Method method = methods[i];
    struct objc_method_description *desc = method_getDescription(method);
    const char *name = desc->name;
    const char *types = desc->types;
    protocol_addMethodDescription(protocol, name, types, YES, NO);
}
```

^ This is fairly boring, we do the same for class, instance methods & properties.
The only difference is that we store method type signatures (only argument types).
Let's see what for…

---

# Creating protocol at runtime
## Registering protocol

```objectivec
objc_registerProtocol(protocol);
class_addProtocol(cls, protocol);
```

^ No runtime check if you actually implement protocol methods.

---

# Creating protocols at runtime
## Eating Xcode's lunch

![inline](http://www.gamedots.mx/media/gd/pizzapanza.gif)

---

# Creating protocols at runtime
## Extended method types

```objectivec
unsigned int count;
Method *methods = class_copyMethodList(object_getClass(cls), &count);
for (unsigned int i = 0; i < count; ++i) {
    Method method = methods[i];
    [signatures addObject:@(method_getDescription(method)->types)];
}

protocol_t *myProtocol = (__bridge protocol_t *)protocol;
for (NSUInteger i = 0; i < signatures.count; ++i) {
    const char *signature = signatures[i].UTF8String;
    myProtocol->extendedMethodTypes[i] = signature;
}
```

^ This is where the magic happens. Normally this section is generated by compiler by inspecting types. Or empty for dynamic protocols.
We can not get actual argument, but introspection is enough for private runtime mehtod that will inspect it later on.

---

# Creating protocols at runtime
## Demo

* How is it different from react-native?
* No way to destroy protocol created at runtime.
* Random code execution without recompiling.
* Downloading a scripted walk-through.
* Working around production bugs.
* JSPatch is another take on random code execution through JS - Objective-C bridge [https://github.com/bang590/JSPatch](https://github.com/bang590/JSPatch)

^ You don't have to write your app in JS for it to work.

---

# One more thing…

---

![inline](http://i.stack.imgur.com/Q1FGg.png)

---

# twitter: **@zats**
# github: **github.com/zats**
# email: **sash@zats.io**
# icq: **5559218**

<!-- ![inline](https://pbs.twimg.com/media/CGX3KUtUgAAJDuC.jpg:large) -->
