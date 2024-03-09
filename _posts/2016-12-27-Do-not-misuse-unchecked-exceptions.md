---
layout: post
title: Don't misuse unchecked exceptions
tags: [tech, java, error-handling, Functional-programming]
short: false
seo:
    type: TechArticle
---

In its early days, Java made extensive use of checked exceptions.
However, the tendency of programmers to avoid dealing with checked exceptions led to a shift towards unchecked exceptions.
This approach often results in neglecting proper error handling and obscuring side effects.
Furthermore, exception handling is not checked at the compilation level.

In many cases, programmers do not thoroughly read documentation, especially regarding the throwing of unchecked exceptions.
It's typical to find no documentation at all, leaving developers with little guidance.
Typically, error handling involves catching either [Exception](https://docs.oracle.com/javase/8/docs/api/java/lang/Exception.html)
or [RuntimeException](https://docs.oracle.com/javase/8/docs/api/java/lang/RuntimeException.html) at the controller tier.
Handling of specific exceptions is only added in the appropriate positions when failure cases are discovered during testing or in production environments.

However, failures such as IO errors or invalid input received from users are not exceptional in many scenarios.
In such cases, an error is often considered a successful result.

## In Practice

Unfortunately, my team recently encountered a much more complex situation.
The entire codebase relied heavily on [CompletableFuture](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html), which can complete exceptionally.
This led to cumbersome double error handling, such as:

```java
CompletableFuture<Content> render() {
    try {
        return doSomething()
            .exceptionally(ex -> handleError(ex));
    } catch (Exception ex) {
        return CompletableFuture.completedFuture(handleError(ex));
    }
}
```

To make matters worse, some methods had comments like:

```
/**
 * never returns a CompletedExceptionally CF
 */
```

This should be interpreted as "never returns a CompletableFuture completed exceptionally due to a business problem", because there can still be errors like OutOfMemoryError that cannot be handled.
As mentioned earlier, programmers often neglect documentation.
Such code comments did not prevent the appearance of redundant error handling using exceptionally, which couldn't be called.

Last but not least, the majority of Java 8 functional interfaces such as Supplier, Function, BiFunction, etc., do not allow checked exceptions to be thrown.
Consequently, we couldn't use that approach with CompletableFuture.

## Refactoring

To improve our code quality, we refactored the code in two steps.
The first step was simple: we introduced a rule that a method returning CompletableFuture doesn't throw any exceptions - exceptions are caught as early as possible and mapped to failure futures.
This eliminated wrapping calls of methods returning CompletableFuture in try-catch.
In the second step, we drew inspiration from patterns in other languages.

Functional programming treats the successful execution of an operation on par with errors.
In Scala, to indicate the possibility of an error, functions may return `Either` and `Try` classes from the standard library, or `\/` and `Validation` from the scalaz library.
A similar approach is used in Go, where the convention is that the last element of a tuple returned by a function contains information about the error.

We decided to use a similar class to `\\/`, named `Result`, to represent the result of an operation, which can either be successful or failed.
Sample code for this class is available on my GitHub - [Result](https://github.com/tfij/result).

In the new version of our service code, exceptions are only thrown when invariants are violated, indicating a bug in the code.

## Conclusion

By replacing the traditional practice of throwing unchecked exceptions with a return type that explicitly informs whether an error has occurred,
we were able to improve the readability of the code and reduce the number of errors.
It also simplified code refactoring.