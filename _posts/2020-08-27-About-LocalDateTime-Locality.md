---
layout: post
title: About LocalDateTime Locality
tags: [tech, java, design]
short: false
description: It ain't what you don't know that gets you into trouble. It's what you know for sure that just ain't so. -- Will Rogers
image: /assets/articles/2020-08-27-About-LocalDateTime-Locality/solar-clock.jpg
image-alt: The illustration shows a sundial showing three o'clock
publishedAt:
  site: detektywi.it
  url: https://detektywi.it/2020/08/o-lokalnosci-localdatetime/
  title: O lokalności LocalDateTime [Polish]
seo:
  type: TechArticle
---

> It ain't what you don't know that gets you into trouble. It's what you know for sure that just ain't so.
> 
> -- <cite>Will Rogers</cite>

## The Basics Senior Developers Might Not Know

We all know how crucial good naming conventions for variables, functions, classes, and everything we work with are.
One of the popular techniques of refactoring is renaming.
Programmers spend a considerable amount of time brainstorming names.
Therefore, one would expect every name to make sense and be correct, and when it's not, we should be able to change it.

Unfortunately, life is cruel!
Even in the Java standard library, there's a stench.
Let's take a look at the [LocalDateTime](https://docs.oracle.com/javase/8/docs/api/java/time/LocalDateTime.html) class.
What is this class?
The name suggests that it holds a local date.
That's the kind of response I hear in job interviews (if someone remembers what the [java.time](https://docs.oracle.com/javase/8/docs/api/java/time/package-summary.html) API is).

## Local Only in Name

Let's conduct a little experiment then.
I have my computer set to the Polish time zone, which means the following assertion is correct.

```java
assert ZoneId.systemDefault().equals(ZoneId.of("Europe/Warsaw"));
```

If `LocalDateTime` stores the date in the local time zone, to get the current date in another time zone, I should be able to execute the code:

```
ZonedDateTime now = LocalDateTime.now().atZone(ZoneId.of("UTC")));
```

and the following assertion should pass:

```
assert now.equals(ZonedDateTime.now(Clock.system(ZoneId.of("UTC"))));
```

However, the assertion fails.
This is because **`LocalDateTime` has little to do with locality**
Moreover, the same issue applies to `LocalDate`.
If you see the expression

```
ZonedDateTime now = LocalDateTime.now().atZone(ZoneId.of("UTC")));
```

chances are high that it's a bug.
I've fixed such bugs several times already.
They are not easy to detect, especially if creating instances of `LocalDateTime` and converting to `ZonedDateTime` are far apart, for example, in different files.

In fact, the `atZone` method of the `LocalDateTime` class only makes sense when we know the context of creating the instances – we know in which time zone the `LocalDateTime` instance was created.

So, what's happening in `LocalDateTime.now().atZone(ZoneId.of("UTC")))`?
The `LocalDateTime.now()` method returns the current system date and then a given time zone is added to it.
In our case, it's UTC.
As it turns out, this has nothing to do with "now".
The result is "now" shifted by the time zone differences between the system time zone and UTC.

This behavior shouldn't surprise those who read the documentation.

> A date-time without a time-zone in the ISO-8601 calendar system, such as `2007-12-03T10:15:30`.

But why bother reading the documentation when the name explains everything?
The clue lies in the motto above.
As Will Rogers said, *It ain't what you don't know that gets you into trouble. It's what you know for sure that just ain't so.*

Dear reader, I still owe you a correct code example.
Understanding how `LocalDateTime` works, the expression

```
ZonedDateTime now = LocalDateTime.now().atZone(ZoneId.of("UTC"));
```

should be replaced with

```
ZonedDateTime now = ZonedDateTime.now(ZoneId.of("UTC"));
```

## How to Proceed?

We now know that `LocalDateTime` is a misleading, weak name.
So, how to proceed?

Perhaps a better name would be `ZonelessDateTime`, analogous to `ZonedDateTime`?
Alternatively, something like `NoZoneDateTime` or `NotZonedDateTime`.
This name has one drawback.
Generally, a class name should indicate what the object is responsible for, not what it is not.
So maybe just `DateTime`?

If you can come up with a better name (or one of my suggestions fits you), and you're using Kotlin, you can use type aliases:

```
typealias ZonelessDateTime = LocalDateTime
```

I almost forgot, if you can think of a better name, be sure to write to me.

## Message for Today

Finally, my favorite solution: don't use `LocalDateTime` if possible.
