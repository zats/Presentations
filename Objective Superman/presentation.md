
# [fit] Objective Superman
![](http://static.comicvine.com/uploads/original/11118/111188772/4202204-7119712926-Super.jpg)

---

# `$ whoami`
![inline](assets/wml.png)

### iOS Champion @ [wondermall.com](https://wondermall.com)

^ E-commerce platform.

^ iOS developer in a full-stack developers company.

^ This is my only chance to talk to people who know iOS.

---

# Looks familiar?
![left](assets/IMG_0714.jpg)

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

^ Everyone probably seen or written code similar to this

---

# We can do better!
![right](assets/IMG_0713.jpg)

```objectivec
// NSCountedSet *counters, id key

[counters addObject:key];

NSUInteger count = [counters countForObject:key];
```

^ But hey, there is a better alternative!

---

# When the scheiße hits the fan
![left](assets/IMG_0704.jpg)

* How often did you use `NSCountedSet`?
* Know what is there at your disposal.
* :poop: hits the fan = :smirk_cat:

---

# Swizzling
![](http://cdn1.smosh.com/sites/default/files/ftpuploads/bloguploads/superpowers-suck-invulnerability2.jpg)

^ Who've done swizzling?

^ Hi, my name is Sash and I swizzle.

---

# The way to swizzle
![right](assets/IMG_0709.jpg)

As done by those fine gentleman:

* Mike Ash: "Method Replacement for Fun and Profit"[^1]
* Jonathan "Wolf" Rentzsch: `JRSwizzle`[^2]

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
![right](assets/IMG_0710.jpg)

* Each method has implicit `id` & `_cmd`
* Calling original method through `-xyz_viewDidLoad`
* Read about other people suffering[^4]

---

# [fit] Demo :scream_cat:

---

# Swizzling tips
![left](assets/IMG_0718.jpg)

* Prefix: `xyz_`
* Calling original method: `[self xyz_swizzleMe]`
* If swizzling initialisers, hint ARC semantics by adding `__attribute__((objc_method_family(init)))`[^5]
* The right way to swizzle: functions or blocks, remember `_cmd`.

---

# Properties inspection[^6]
![](http://application.denofgeek.com/pics/film/superman/3a.jpg)

---

# Properties introspection: cool stuff.

![right](assets/IMG_0717.jpg)

* List all the properties: name / type.
* Type, even if `nil` or incorrect type.
* Accessors (`readonly`, `copy`, `getter=isHidden`…).
* Applications: automatic parsing, validation, IOC[^7] etc.

---

# Properties introspection: Mantle[^8]
![left](assets/IMG_0711.jpg)

* Reduces amount of boilerplate
* Serialize to JSON, CoreData, XML :see_no_evil:
* Deserialize dates, enums, URLs etc.
* Validation.
* `NSCopying` and `NSCoding`.

---

# [fit] Demo :octopus:

---

# Properties introspection tips
![right](assets/IMG_0709.jpg)

* Does not include properties from superclasses, `while`-loop that class chain!
* Automatic parsing is dangerous (just like self-driving cars).
* Assigning through KVC, always check for `readonly`.
* Did you call me lazy?

---

# Dynamic class creation
![](http://digitalart.io/wp-content/uploads/2013/06/man_of_steel_wallpaper_superman_movie_06.jpg)

---

# Dynamic class creation
![left](assets/IMG_0719.jpg)

* Just like a regular subclassing.
* Leave no trace: class does not exist in assembly.
* Dynamically assemble class on the fly.
* Simulate multiple inheritance.

---

# [fit] Demo :chicken:

---

# Dynamic class creation: tips
![right](assets/IMG_0721.jpg)

* UIKit & Foundation use it twice. Twice!
* Seems like a very esoteric exercise.
* You want to know it's there when you need it.
* When do you need it?

---

# Let's build KVO
![](assets/X-Ray_Vision.jpg)

---

# Let's build KVO
![left](assets/IMG_0707.jpg)

* We want to know when any given property is set
* What a coincidence, we just learned everything we need!
	* Create a custom subclass.
	* Swizzle setter for specified property.
	* Set our subclass as observed object class.

---

# [fit] Demo :cow:

---

# Let's build KVO
![right](assets/IMG_0715.jpg)

* Curiosity
* KVO for getter
* KVO for collections
* Inject side effects into setters and getters of all subclasses of a certain class, e.g. `createdAt`, `updatedAt`, `lastAccessedAt`

---

# Conclusion
![right](assets/IMG_0720.jpg)

* `<objc/runtime.h>` `!=` App Store.
* I say, test it, Mantle is a production grade code.
* Swizzling to patch UIKit gotchas![^9]
* Objective-C runtime is its own kryptonite.
* "Wax on, wax off" – it comes together, when you need it.

---

# Thank you
![](http://ia.media-imdb.com/images/M/MV5BMTUyMTIxNzE1M15BMl5BanBnXkFtZTgwOTU0ODQ4MTE@._V1_SX640_SY720_.jpg)

* This talk and demos [github.com](https://github.com/zats/Presentations/tree/master/Objective Superman)
* Objective-C runtime [opensource.apple.com](http://opensource.apple.com/source/objc4/objc4-646/)
* [twitter.com/zats](https://twitter.com/zats)
* [github.com/zats](https://github.com/zats)
* [tinder.com/zats](http://seriously/what?are=you&thinking=about)




[^1]: https://www.mikeash.com/pyblog/friday-qa-2010-01-29-method-replacement-for-fun-and-profit.html

[^2]: https://github.com/rentzsch/jrswizzle

[^3]: http://blog.newrelic.com/2014/04/16/right-way-to-swizzle/

[^4]: http://petersteinberger.com/blog/2014/a-story-about-swizzling-the-right-way-and-touch-forwarding

[^5]: http://clang.llvm.org/docs/AttributeReference.html#objc-method-family

[^6]: Ivars, too. Remember ivars?

[^7]: https://github.com/tomersh/AppleGuice

[^8]: https://github.com/Mantle/Mantle

[^9]: http://petersteinberger.com

[^10]: http://www.unicode.org/reports/tr51/#Diversity