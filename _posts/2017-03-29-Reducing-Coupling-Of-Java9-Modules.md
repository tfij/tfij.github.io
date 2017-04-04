---
layout: post
title: Reducing coupling of Java 9 modules
tags: [tech, java, modularization]
short: false
seo:
    type: TechArticle
---

In a [Quick introduction to Java 9 modularization](/2017/03/11/Quick-Introduction-to-Java9-Modularization.html) article I quickly introduce the basic concept of a Java 9 modularization.
Now is the time to improve modules design.
In this article we will focus on reducing modules coupling.

Following [Dependency inversion principle](https://en.wikipedia.org/wiki/Dependency_inversion_principle) which states that

1. High-level modules should not depend on low-level modules. Both should depend on abstractions.
2. Abstractions should not depend on details. Details should depend on abstractions.

There should be a possibility to declare that module depend on some API, not an implementation.

Fortunately, Java 9 introduces the concept of services - a module can register an implementation of an interface as a service.
The other modules can consume this service.
To take advantage of this solution at least three modules are required: a client code, a module with API and a module with implementation.
The following example presents consuming of a service in `module-info.java` (a client code):

```
module pl.tfij.java9modules.app {
    requires pl.tfij.java9modules.greetings.api;
    uses pl.tfij.java9modules.greetings.Greeting;
}
```

A module `pl.tfij.java9modules.app` depends on `pl.tfij.java9modules.greetings.api` API, not its implementation.
To access the implementation of `Greeting` class just use `ServiceLoader`  class:

```
ServiceLoader<Greeting> services = ServiceLoader.load(Greeting.class);
```

Notwithstanding, to run such code you have to provide required implementation in other module.
A module that provides a service (module with implementation) declares module descriptor like:

```
module pl.tfij.java9modules.greetings.standard {
    requires pl.tfij.java9modules.greetings.api;
    provides pl.tfij.java9modules.greetings.Greeting
        with pl.tfij.java9modules.greetings.standard.StandardGreeting;
}
```

You can provide many modules and run code with many implementations.
Just put them all on the module path.

To complete the example, a trivial `module-info.java` file from module with API is presented below:

```
module pl.tfij.java9modules.greetings.api {
    exports pl.tfij.java9modules.greetings;
}
```

In this way, the coupling of modules is reduced - High-level modules depend on abstractions, not on low-level modules.
The full example of the code is at my github: [Java-9-modules---reducing-coupling-of-modules](https://github.com/tfij/Java-9-modules---reducing-coupling-of-modules).
