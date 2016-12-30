---
layout: post
title: When use and when not to use default methods in Java interfaces
tags: [tech, java, default methods, inheritance]
short: false
category: post
---

Java 8 supplies a lot new useful features, unfortunately also new misunderstandings and antipatterns are observed every day.
One of that mistake is a wrong use of default method in interfaces.

I noticed that programmers implement default methods with an implementation valid only for some production 
subclasses or even for non of them (a default implementation is used only in tests). 
For example, a default method returns empty string or empty list and all production subclasses override it.

The general rule of the use default methods in interface is similar to the principle governing the use of implemented 
method in abstract class.
Default implementation should be a proper for all subtypes, for example:

1. Since Java 8 [List](https://docs.oracle.com/javase/8/docs/api/java/util/List.html) class has a `sort` method. 
Its implementation is valid for all subtypes, but subtypes like `SingletonList` or `SynchronizedList` override 
this implementation.

2. If you create an interface `Car` with method `getName` it is OK to create default implementation which return string `"Car"`.
This implementation is valid for `Ford` class which implement interface `Car`. However, `getName` method may by override
to return string contains car model like ex. `"Ford " + model`.

Default methods are powerful tools if they used with lambda expressions and 
[functional interfaces](https://docs.oracle.com/javase/8/docs/api/java/lang/FunctionalInterface.html). 
They are also very useful when you would like to add methods to interface in a lib code and preserve backward compatibility.
However, default methods should never provide an invalid behavior.
