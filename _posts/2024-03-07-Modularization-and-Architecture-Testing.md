---
layout: post
title: Modularization and Architecture Testing
tags: [tech, testing, java, design, architecture]
short: false
description: Modularization in projects is one of the key techniques that allows for maintaining code readability, scalability, and ease of maintenance.
  As projects evolve, especially those with a larger scope, it becomes an important element ensuring order and transparency in the code structure.
  However, as the project progresses and new changes are introduced, and developers come and go, it's easy to forget the initial architecture assumptions.
  Automated tests come to the rescue.
image: /assets/articles/2024-03-07-Modularization-and-Architecture-Testing/module-size.png
image-alt: The illustration shows a technical drawing of solids symbolizing modules with marked dimensions
publishedAt:
  site: detektywi.it
  url: https://detektywi.it/2024/03/modularyzacja-i-testy-architektury/
  title: Modularyzacja i testy architektury [Polish]
seo:
  type: TechArticle
---

> The art of programming is the art of organizing complexity; mastering multitude & avoiding its chaos as effectively as possible.
>
> -- <cite>Edsger W. Dijkstra</cite>

Modularization in projects is one of the key techniques that allows for maintaining code readability, scalability, and ease of maintenance.
As projects evolve, especially those with a larger scope, it becomes an important element ensuring order and transparency in the code structure.
However, as the project progresses and new changes are introduced, and developers come and go, it's easy to forget the initial architecture assumptions.
Automated tests come to the rescue.
But what should we test and how should we do it?
Without solid tests, we cannot ensure that our modular structure meets the goals we set for ourselves.

## What to Test

Certain aspects of modules, such as inter-module dependencies and cycles in the Java language, can be tested using [ArchUnit](https://www.archunit.org/).
However, this library does not solve all problems.
Let's take a closer look at two other particularly important cases:

### 1. Uniform Distribution of Code

When we have many modules but one of them contains a significant majority of the code, modularization loses its meaning.
For example, if we have 15 modules and one of them contains 80% of the code, we cannot speak of real modularization because almost all the code is contained in one module.
This is a situation that needs to be eliminated through automated testing of module size.

### 2. Some Modules Should Be Especially Small

It is also important to ensure that individual modules are small and stable in terms of the changes introduced (how often we make the module changes).
For example, a "commons" module should be small and contain general functionality that is often used in various parts of the project.
If this module becomes too large, it can lead to problems with managing and modifying the code.
Of course, this is an approximation, as it is more important to minimize the module interface and maintain its stability in terms of changes, which does not necessarily mean minimizing the module size.

## How to Test

Because the issues described above are very important to me, I decided to verify them in tests.
The implementation can be very simple and involve counting lines of code in packages.
To my surprise, I did not find a ready-made tool that would allow me to quickly check the size of modules.

So I prepared a Java library that allows testing the size of modules - [module-size-calculator](https://github.com/tfij/module-size-calculator).
This library enables analyzing the size of modules in a project based on the number of lines of code (LOC).

Just define the dependency

```xml
<dependency>
    <groupId>pl.tfij</groupId>
    <artifactId>module-size-calculator</artifactId>
    <version>1.0.0</version>
</dependency>
```

From now on, we can write tests like

```java
ProjectSummary projectSummary = ModuleSizeCalculator.project("src/main/java")
    .withModule("com.example.module1")
    .withModule("com.example.module2")
    .analyze()
    .verifyEachModuleRelativeSizeIsSmallerThan(0.3)
    .verifyModuleRelativeSizeIsSmallerThan("com.example.commons", 0.1);
```

The library allows for various assertions of module size, and if something has not been foreseen, a classic JUnit assertion can be written based on the generated report.
The library also allows you to generate a report in the form of a [Mermaid pie chart](https://mermaid.js.org/syntax/pie.html), which can then be included, for example, in documentation.

For more details and examples, visit [GitHub](https://github.com/tfij/module-size-calculator).

## Message for Today

Modularization is a key aspect of the project. Test it to ensure it does not fade over time.
