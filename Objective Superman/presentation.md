
# [fit] Objective Superman
![](assets/IMG_0721.jpg)

---

# Have you ever seen something similar?
![left fit](assets/IMG_0714.jpg)

```objectivec
// NSMutableDictionary *counters, id key

if (!counters[key]) {
	counters[key] = @1;
} else {
	NSUInteger i = [counters[key] integerValue];
	counters[key] = @(i + 1);
}

NSInteger count = [counters[key] integerValue];
```

---

# We can do better!
![right fit](assets/IMG_0713.jpg)

```objectivec
// NSCountedSet *counters, id key

[counters addObject:key];

NSUInteger count = [counters countForObject:key];
```

---

# When the scheiße hits the fan

![left fit](assets/IMG_0704.jpg)

* How often did you use `NSCountedSet`?

---

# When the scheiße hits the fan

![left fit](assets/IMG_0704.jpg)

* How often did you use `NSCountedSet`?
* Know what is there at your disposal.

---

# When the scheiße hits the fan

![left fit](assets/IMG_0704.jpg)

* How often did you use `NSCountedSet`?
* Know what is there at your disposal.
* Right tool for the job.

---

# When the scheiße hits the fan

![left fit](assets/IMG_0704.jpg)

* How often did you use `NSCountedSet`?
* Know what is there at your disposal.
* Right tool for the job.
* :poop: hits the fan = :scream_cat:

---

# When the scheiße hits the fan

![left fit](assets/IMG_0704.jpg)

* How often did you use `NSCountedSet`?
* Know what is there at your disposal.
* Right tool for the job.
* :poop: hits the fan = :smirk_cat:

---

# Runtime 101:
# Swizzling

^ Who've done swizzling?

---

# The way to swizzle

As done by those fine gentleman:

* Mike Ash: "Method Replacement for Fun and Profit"[^1]
* Jonathan "Wolf" Rentzsch: `JRSwizzle`[^2]

[^1]: https://www.mikeash.com/pyblog/friday-qa-2010-01-29-method-replacement-for-fun-and-profit.html but make sure to read the comments

[^2]: https://github.com/rentzsch/jrswizzle

---

# The way to swizzle

```objectivec
@implementation UIViewController (EveryDayImSwizzling)

+ (void)load {
    [UIViewController jr_swizzleMethod:@selector(viewDidLoad)
                            withMethod:@selector(xyz_viewDidLoad)
                                 error:nil];
}

- (void)xyz_viewDidLoad {
	NSLog(@"I was here");
	[self xyz_viewDidLoad];
}

@end
```

---

# The right way to swizzle[^3]

* Each method has implicit `id` & `_cmd`
* Calling original method through `-xyz_viewDidLoad`
* Read about other people suffering[^4]

[^3]: http://blog.newrelic.com/2014/04/16/right-way-to-swizzle/

[^4]: http://petersteinberger.com/blog/2014/a-story-about-swizzling-the-right-way-and-touch-forwarding

---

# [fit] Demo :scream_cat:

---

# Swizzling tips

* Don’t forget to prefix: `xyz_`
* Calling original method: `[self xyz_swizzledMethod]`
* If swizzling initialisers, help compiler with ARC semantics by adding `__attribute__((objc_method_family(init)))`[^5]
* The right way to swizzle: functions or blocks, remember `_cmd`.

[^5]: http://clang.llvm.org/docs/AttributeReference.html#objc-method-family

---

# Runtime 102:
# Properties inspection[^6]

[^6]: Ivars, too. Remember ivars?

---

# Properties introspection: cool stuff.

* List all the properties: name / type.
* Type, even if `nil` or incorrect type.
* Accessors (`readonly`, `copy`, `getter=isHidden`…).
* Applications: automatic parsing, validation, IOC etc.

---

# Properties introspection: Mantle[^7]

* Reduces amount of boilerplate
* Serialization to JSON, Core Data, XML :see_no_evil:
* Tons of convenience for dates, enums, URLs etc
* Validation
* Copying / coding

[^7]: https://github.com/Mantle/Mantle

---

# [fit] Demo :octopus:

---

# Properties introspection tips

* Does not include properties from superclasses, `while`-loop that class chain!
* Automatic parsing is dangerous (just like self-driving cars).
* Assigning through KVC, always check for `readonly`.
* Did you call me lazy?

---

# Runtime 103:
# Dynamic class creation

---

# Dynamic class creation

* Just like a regular subclassing.
* Leave no trace: class does not exist in assembly.
* Dynamically assemble class on the fly.
* Simulate multiple inheritance.

---

# [fit] Demo :chicken:

---

# Dynamic class creation

* UIKit & Foundation use it twice.
* Seems like a very esoteric exercise.
* You want to know it's there when you need it.
* When do you need it?

---

# Runtime graduation:
# Let's build KVO

---

#