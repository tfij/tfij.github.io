---
layout: post
title: When use and when not to use default methods in Java interfaces
tags: [tech, java, design]
short: false
seo:
    type: TechArticle
---

Java 8 introduces many new useful features; unfortunately, it also leads to new misunderstandings and antipatterns being observed every day.
One of these mistakes is the incorrect use of default methods in interfaces.

I have noticed that programmers often implement default methods with an implementation that is valid only for some production subclasses or even for none of them (a default implementation is used only in tests).
For example, a default method might return an empty string or an empty list, and all production subclasses override it.

The general rule for using default methods in interfaces is similar to the principle governing the use of implemented methods in abstract classes.
The default implementation should be appropriate for all subtypes. For example:

1. Since Java 8, the [List](https://docs.oracle.com/javase/8/docs/api/java/util/List.html) class has a `sort` method.
   Its implementation is valid for all subtypes, but subtypes like `SingletonList` or `SynchronizedList` override this implementation.

2. If you create an interface `Car` with a method `getName`, it is OK to create a default implementation that returns the string `"Car"`.
   This implementation is valid for the `Ford` class, which implements the `Car` interface.
   However, the `getName` method may be overridden to return a string containing the car model, such as `"Ford " + model`.

Default methods are powerful tools when used with lambda expressions and [functional interfaces](https://docs.oracle.com/javase/8/docs/api/java/lang/FunctionalInterface.html).
They are also very useful when you would like to add methods to an interface in a library code and preserve backward compatibility.
However, default methods should never provide invalid behavior.
