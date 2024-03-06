---
layout: post
title: Optional as a Field and what are you going to do to me about it?
tags: [tech, java]
short: false
publishedAt:
  site: detektywi.it
  url: https://detektywi.it/2018/08/optional-jako-pole-i-co-mi-zrobisz/
  title: Optional jako pole i co mi zrobisz? [Polish]
seo:
  type: TechArticle
---

It's been quite some time since the introduction of the `Optional` class in JDK&nbsp;8.
A lot has been written about where and how to use it, what constitutes good practice, and what doesn't.
An example of this can be found in the [Optional Anti-Patterns](https://docs.oracle.com/javase/8/docs/api/java/util/Optional.html) article.
But does it all make sense?

I agree with many of the arguments presented there.
However, I wanted to challenge the prohibition on using `Optional` as a class field and passing them as constructor parameters.
`Optional` doesn't protect us from `NullPointerExceptions`;
nothing shields us from foolishness because Java allows returning `null` regardless of the method signature.
Therefore, `Optional` is only useful in conjunction with a consistent convention that spans the entire project.
This convention makes it unnecessary to review the code of the called method, read comments,
or consult documentation to know whether we need to handle nulls.
If we see that there's no `Optional` in the method signature, we can assume that the method always returns a value;
otherwise, we need to handle the absence of a value.
Beautiful! This makes our code more obvious.

## Optional as a Class Field

So why not use `Optional` as a class field? There are several arguments against it.
Firstly, IntelliJ IDEA suggests that you shouldn't do it, and it's a common interpretation.

![message from intellij about incorrect use of optional](/assets/articles/2018-08-19-Optional-as-field/optionalFieldInIdea.webp)

This warning leads us to the second reason – `Optional` is not `Serializable`.
Personally, this argument doesn't convince me because I can't recall a situation in recent projects
where I needed to implement the `Serializable` interface.
Moreover, when discussing `Optional`, I'm referring to the concept, not a specific implementation.
In situations where you need to implement the Serializable interface, you can use an alternative version from a library,
such as [`Option`](https://static.javadoc.io/io.vavr/vavr/0.9.2/io/vavr/control/Option.html) from the vavr library.
The third argument is that "Optional wasn't designed for this".
Similarly, computers weren't designed for entertainment, but millions of people spend hours playing computer games every day.
Fourthly, there's a performance overhead associated with wrapping fields in `Optional`.
However, in all the projects I've developed, this overhead was never an issue,
and optimizations related to removing `Optional` would be at the bottom of the list of bottlenecks.
The fifth argument I [found](https://klolo.github.io/blog/2017/08/05/jak-uzywac-optional/) is the observation that something like
this looks weak in DTO objects:

```java
private Optional<HashMap<String, Integer>> data;
```

This probably arises when objects are mutable and have setters.
When we create DTOs as immutable objects where all fields are set in the constructor, such situations occur significantly less frequently.
However, when they do occur, there's some semantic justification when something else represents an empty map versus the absence of a map.
Regardless, if my field is of type `Optional`, I don't need to place any annotations, comments, or other nullability markers.
Referring to the field immediately lets me know whether I need to handle nulls.
It's the same well-performing rule when referring to public methods.

## Optional as a Method Argument

Alright, what about the second topic, which is the prohibition on using `Optional`s in method parameters?
Let's assume we have the following Client class:

```java
class Client {
    String getFirstName() { ... }
    Optional<String> getSecondName() { ... }
    String getLastName() { ... }
    ...
}
```

What if we want to rewrite this class into another?
Why would we need to do that?
Well, if we care about module isolation to limit coupling, especially to avoid cycles, 
rewriting one class into another is a fairly common practice.
Similarly, if we're creating a facade for some API.
Of course, we usually don't rewrite everything one-to-one.
Sometimes we skip some fields, take values from several objects, or perform some transformation.
In this case, to keep the example simple, I'll limit it to a straightforward transfer of fields.

I hope everyone now sees the justification for transferring data from one class to another.
So what will it look like when there are no `optional`s in the method arguments?
There are two options.
First, we can try passing null:

```java
new User(client.getFirstName(),
    client.getSecondName().orElse(null),
    client.getLastName())
```

That `orElse(null)` looks terrifying to me!
Such a monster might haunt me at night.
The second approach could be preparing two constructors:

```java
if (client.getSecondName().isPresent()) {
    new User(client.getFirstName(),
        client.getSecondName().get(),
        client.getLastName())
} else {
    new User(client.getFirstName(), client.getLastName())
}
```

or in a fluent API style without `Optional::get()`:

```java
client.getSecondName()
    .map(secondName ->
        new User(client.getFirstName(),
            secondName,
            client.getLastName()))
    .orElse(new User(client.getFirstName(), client.getLastName()))
```

Regardless of the format, both approaches are daunting.
So let's try not to give up `Optional` in method arguments.
How would that look?

```java
new User(client.getFirstName(),
    client.getSecondName(),
    client.getLastName())
```

I have no doubt that this looks the best.

## Message for today

Finally, the question arises: should I use `Optional`s everywhere?
Use them wherever it makes sense.
If a class hierarchy makes sense, create one, but don't create it just because you don't want to have a field of type `Optional`.
If two constructors make the class API more user-friendly, create two constructors,
but don't create them just because you don't want to have an `Optional` argument.
Don't blindly follow the slogans "use it here, don't use it there".
Have solid arguments why `Optional` shouldn't appear in a specific place.
For me, the convention that a data type always carries information about the absence of a value is a clean,
consistent convention that minimizes errors related to `NullPointerExceptions`.
