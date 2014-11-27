
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

# Runtime 101

---

# Swizzling

^ Who've done swizzling?

---

# The way to swizzle

As done by those fine gentleman:

* Mike Ash: "Method Replacement for Fun and Profit" [^1]<sup>,</sup> [^2]
* Jonathan "Wolf" Rentzsch: `JRSwizzle` [^3]

[^1]: https://www.mikeash.com/pyblog/friday-qa-2010-01-29-method-replacement-for-fun-and-profit.html

[^2]: Make sure to read the comments!

[^3]: https://github.com/rentzsch/jrswizzle

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

# The right way to swizzle [^4]

* Each method has implicit `id` & `_cmd`
* Calling original method through `-xyz_viewDidLoad`
* Read about other people suffering [^5]

[^4]: http://blog.newrelic.com/2014/04/16/right-way-to-swizzle/

[^5]: http://petersteinberger.com/blog/2014/a-story-about-swizzling-the-right-way-and-touch-forwarding

---