---
layout: post
title: Additional Checks in Checkstyle
tags: [tech, java, design, quality, clean-code]
short: false
coverImage:
  url: /assets/articles/2022-10-13-Additional-Checks-in-Checkstyle/formatting.webp
  alt: A  Formatting string emerging from a code block
publishedAt:
  site: detektywi.it
  url: https://detektywi.it/2022/10/dodatkowe-checki-w-checkstyle/
  title: Dodatkowe checki w checkstyle [Polish]
seo:
  type: TechArticle
---

[Checkstyle](https://checkstyle.sourceforge.io/) is a powerful library that not only allows standardizing code formatting in a project but also catching some program errors
(e.g., whether the equals method is implemented along with the hashCode method) and code design issues (e.g., maximum method size or cyclomatic complexity).

I consider tools for static code analysis extremely useful.
It's worth using them, even if they sometimes make life a bit harder.
Ultimately, with their help, the code of the application is better.
I've also noticed that many people are more receptive to feedback on code formatting from a machine than from another person, and any potential annoyance is directed towards the computer.

## Custom Rules

It turns out that it's quite easy to add custom rules to Checkstyle.
By this, I mean writing your own check and using it in your own project.
Adding a check to the main library is a completely different story.
It can take years from submitting the idea and presenting the Proof of concept (PoC) to the merge!

## Checkstyle in My Project

In the project I'm working on, it often happened (several times a month) that the rule for formatting method parameters was violated – whether parameters were in one line or each in a separate line.
The code looked something like this:

```java
public int fun(int a, int b,
    int c) {
...    
}
```

After a few times, when I mentioned this during code reviews, I decided to set the appropriate rule in Checkstyle.
Unfortunately, it turned out that there was no such rule.
From searching the internet, through GitHub issues, I came to my own library.

## Custom Library with Rules

The library currently contains four checks related to method and constructor parameters both in their declaration and when called.
Using it is simple, just add the library as a dependency to the plugin.
Below is an example for Gradle Kotlin DSL:

```kotlin
plugins {
    java
    checkstyle
}

dependencies {
    checkstyle("pl.tfij:check-tfij-style:1.2.1")
}
```

Then add the checks to the Checkstyle configuration:

```xml
<module name="MethodParameterAlignment"/>
<module name="MethodParameterLines"/>
<module name="MethodCallParameterAlignment"/>
<module name="MethodCallParameterLines">
    <property name="ignoreMethods" value="Map.of"/>
</module>
```

Formatting errors, such as those mentioned above, are caught during the project build stage, and I no longer have to mention them during code reviews.

More details on GitHub: [https://github.com/tfij/check-tfij-style](https://github.com/tfij/check-tfij-style)

## Message for Today

Use static code analysis.
I also hope that the checks from my library will be useful to you.