---
layout: post
title: Quick introduction to Java 9 modularization
tags: [tech, java, modularization]
short: false
seo:
    type: TechArticle
---

The new version of the Java is fast approaching.
The official release is scheduled for the 27 of July 2017.
However, you can already use the early access version to play with the new features.
In this post, I'd like to quickly introduce the modularization of the Java 9.

# Modularization by example

Modularization does really matter, nonetheless there is no space in this brief post to discuss all its features in details.
So let's quickly start with example of module definition. 
Each module in Java 9 require `module-info.java` file containing the module descriptor.
Content of exemplary `module-info.java` is illustrated below:

```
module module.name {                                   # 1
    exports package.name.a;                            # 2
    exports package.name.b to other.module.name.a;     # 3
    requires other.module.name.b;                      # 4
}
```

This short example presents the basic module descriptor syntax.
Let's analyze it line by line.

## Module name
The first line contains `module` keyword followed by module name - `module.name` in given example.
Module naming convention is similar to package convention - reversed domain notation, eg `com.organization.project`.

## Module API
The second line declares that classes from a `package.name.a` may be accessible for other modules.
Module descriptor can export multiple packages, each on a separate line.

## Restricted API
Line #3 declares that package `package.name.b` is accessible only for `other.module.name.a`.
This functionality should be use carefully, it brakes the rule that module knows only depended modules.
It's also increases coupling of modules.

## Module dependency
In the last line contains the information about the module dependencies.
In the provided example the module `module.name` depends on `other.module.name.b` module and has access to its exported packages.

# Rules of modularization
Modules in Java 9 provide strong encapsulation and together with the standard access modifiers (public, protected, *default*, private) make modularization powerful.
I'd like to mention about some restriction and facilities which come with modularization.

Firstly, cycles between modules (on compilation level) are prohibited. 
It's a limitation but no one should cry because of that. 
Cycles in general are sign of a bad design.

Secondly, even if module encapsulation is controlled on compile and runtime level, you can brake it using reflection API and freely use debug tools.

Thirdly, all modules have an implicit dependency to `java.base` module and it doesn't have to be specified in module descriptor.
The implicit dependency on `java.base` is similar to implicit import of `java.lang.String` class.

Fourthly, due to backward compatibility, every class not placed in the modules goes to *unnamed module*.
That module has dependency to all other modules and has access to the packages which they exported.
It's important that not exported packages are not accessible.
Since Java 9 some APIs are marked as internal and are unavailable from regular packages.
If you compile code using such packages in Java 8 and try to use it with Java 9, you'll get runtime error. 

# Today's message
It’s time to get your hands dirty by writing your first Java 9 module.
I prepare the simplest example to help you to start.
It's available at my githab: [Java 9 modules - the simplest example](https://github.com/tfij/Java-9-modules---the-simplest-example).
