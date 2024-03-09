---
layout: post
title: Quick introduction to Java 9 modularization
tags: [tech, java, modularization]
short: false
seo:
    type: TechArticle
---

The new version of Java is fast approaching.
The official release is scheduled for the 27th of July 2017.
However, you can already use the early access version to play with the new features.
In this post, I'd like to quickly introduce the modularization of Java 9.

## Modularization by example

Modularization really matters, nonetheless, there is no space in this brief post to discuss all its features in detail.
So let's quickly start with an example of module definition.
Each module in Java 9 requires a `module-info.java` file containing the module descriptor.
The content of an exemplary `module-info.java` is illustrated below:

```
module module.name {                                   # 1
    exports package.name.a;                            # 2
    exports package.name.b to other.module.name.a;     # 3
    requires other.module.name.b;                      # 4
}
```

This short example presents the basic module descriptor syntax.
Let's analyze it line by line.

### Module name
The first line contains the `module` keyword followed by the module name - `module.name` in the given example.
Module naming convention is similar to package convention - reversed domain notation, e.g., `com.organization.project`.

### Module API
The second line declares that classes from `package.name.a` may be accessible for other modules.
The module descriptor can export multiple packages, each on a separate line.

### Restricted API
Line #3 declares that the package `package.name.b` is accessible only for `other.module.name.a`.
This functionality should be used carefully as it breaks the rule that a module knows only its dependent modules.
It also increases coupling of modules.

### Module dependency
The last line contains information about the module dependencies.
In the provided example, the module `module.name` depends on the `other.module.name.b` module and has access to its exported packages.

## Rules of modularization
Modules in Java 9 provide strong encapsulation and, together with the standard access modifiers (public, protected, *default*, private), make modularization powerful.
I'd like to mention some restrictions and facilities that come with modularization.

Firstly, cycles between modules (on the compilation level) are prohibited.
It's a limitation, but no one should cry because of that.
Cycles, in general, are a sign of bad design.

Secondly, even if module encapsulation is controlled on compile and runtime level, you can break it using the reflection API and freely use debug tools.

Thirdly, all modules have an implicit dependency on the `java.base` module, and it doesn't have to be specified in the module descriptor.
The implicit dependency on `java.base` is similar to the implicit import of `java.lang.String` class.

Fourthly, due to backward compatibility, every class not placed in the modules goes to the *unnamed module*.
That module has a dependency on all other modules and has access to the packages which they exported.
It's important that not exported packages are not accessible.
Since Java 9, some APIs are marked as internal and are unavailable from regular packages.
If you compile code using such packages in Java 8 and try to use it with Java 9, you'll get a runtime error.

## Message for Today
It’s time to get your hands dirty by writing your first Java 9 module.
I've prepared the simplest example to help you start.
It's available on my GitHub: [Java 9 modules - the simplest example](https://github.com/tfij/Java-9-modules---the-simplest-example).
