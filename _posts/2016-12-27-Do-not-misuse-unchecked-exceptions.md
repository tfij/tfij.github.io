---
layout: post
title: Don't misuse unchecked exceptions
tags: [tech, java, error handling, CompletableFuture, Functional programming]
short: false
seo:
    type: TechArticle
---

In its early days, Java has a wide uses of checked exceptions. 
However, lazy nature of programmers triggered trend to abandonment checked exceptions to unchecked exceptions.
This approach causes negligence an error handling and hiding side effects.
Additionally exceptions catching is not checked at compilation level.

Lazy programmers don't read a documentation, in particular information about throwing unchecked exceptions.
Usually the way of errors handling is limited to catching [Exception](https://docs.oracle.com/javase/8/docs/api/java/lang/Exception.html)
or [RuntimeException](https://docs.oracle.com/javase/8/docs/api/java/lang/RuntimeException.html) on the controller tier.
Handling of specific exceptions is added in the proper positions when failure cases are detected on QA or prod env.

However, there is nothing exceptional in IO failure or invalid input received from user.
In such situations an error is commonly a successful result.

# In practice

Unfortunately, my team last case was much more complex. The whole code based on 
[CompletableFuture](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html)
which can be completed exceptionally.
This caused a horrible double error handling, like e.g.

```java
CompletableFuture<Content> render() {
    try {
        return doSomthing()
            .exceptionally(ex -> handleError(ex));
    } catch (Exception ex) {
        return CompletableFuture.completedFuture(handleError(ex));
    }
}
```

As if that was not enough, some methods had comments like

```
/**
 * never returns a CompletedExceptionally CF
 */
```

What should be read as *"never returns a CompletedExceptionally CF cause by business problem"* because there can still be an
error like [OutOfMemoryError](https://docs.oracle.com/javase/8/docs/api/java/lang/OutOfMemoryError.html)
and there's nothing you can do about it.
As I mentioned previously, programmers don't read documentation. Such code comments 
didn't prevent appearance a redundant error handling using `exceptionally`, which couldn't be called. 

Last but not least, the majority of Java 8 functional interfaces like 
[Supplier](https://docs.oracle.com/javase/8/docs/api/java/util/function/Supplier.html), 
[Function](https://docs.oracle.com/javase/8/docs/api/java/util/function/Function.html), 
[BiFunction](https://docs.oracle.com/javase/8/docs/api/java/util/function/BiFunction.html) 
etc. don't allow to throw checked exceptions.
Because of that we couldn't use that approach with `CompletableFuture`.

# Refactoring

To improve the quality of our life we refactored the code in two steps. 
The first was very simple - we introduced the rule that method returned CompletableFuture doesn't throw any exception - 
the exception are caught as early as possible and mapped to failure future.
At the second step we derived the patterns of other languages.

Functional programming treats successful execution of an operation on a par with errors.
In Scala to show the possibility of occurring error, functions may return 
[Either](http://www.scala-lang.org/api/2.12.0/scala/util/Either.html) and
[Try](http://www.scala-lang.org/api/2.12.0/scala/util/Try.html) classes from standard library or
[\\/](https://oss.sonatype.org/service/local/repositories/releases/archive/org/scalaz/scalaz_2.12/7.2.8/scalaz_2.12-7.2.8-javadoc.jar/!/scalaz/$bslash$div.html) 
and [Validation](http://scalaz.github.io/scalaz/scalaz-2.9.1-6.0.4/doc/scalaz/Validation.html) from scalaz lib.
A similar approach is in [go lang](https://golang.org/). 
The convention says that the last element of a tuple returned by a function contains an information about the error.

We decided to use similar class to `\\/` and named it `Result` as a result of some operation (which can be either successful or failed). 
The sample code of this class is available on my github - [Result](https://github.com/tfij/result).

In a new version of the code, exceptions are thrown only when invariants are broken, 
which means that there is a bug in the code.

# Conclusion

Replacing the classic throwing unchecked exceptions, by returning type that explicitly informs whether an 
error has occurred, allowed us to improve a readability of the code and reduce a number of errors.
It also facilitated a code refactoring.