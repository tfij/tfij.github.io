---
layout: post
title: About How Introducing Clean Code Tripled Memory Usage
tags: [tech, java, design, performance, quality, clean-code]
short: false
customExcerpt: This post is a brief story of how good intentions can lead to disaster when forgetting about JVM's internal mechanisms and how,
  once again, Kent Beck's approach - "Make it work, Make it right, Make it fast" - came into play.
coverImage:
  url: /assets/articles/2022-03-10-About-How-Introducing-Clean-Code-Tripled-Memory-Usage/clean-code-vs-performance.png
  alt: A  Formatting string emerging from a code block
publishedAt:
  site: detektywi.it
  url: https://detektywi.it/2022/03/o-tym-jak-wprowadzajac-clean-code-trzykrotnie-zwiekszylem-zuzycie-pamieci/
  title: O tym jak wprowadzając clean code trzykrotnie zwiększyłem zużycie pamięci [Polish]
seo:
  type: TechArticle
---

> Most papers in computer science describe how their author learned what someone else already knew.
> 
> -- <cite>Peter Landin</cite>

This post is a brief story of how good intentions can lead to disaster when forgetting about JVM's internal mechanisms and how, once again, Kent Beck's approach - "Make it work, Make it right, Make it fast" - came into play.

## Ugly Code to Refactor

Recently, I stumbled upon a rather unreadable piece of code.
Below, I present its essence:

```java
private Map<String, Map<String, Set<String>>> map = new HashMap<>();

void put(String a, String b, String c) {
    map.putIfAbsent(a, new HashMap<>());
    map.get(a).putIfAbsent(b, new HashSet<>());
    map.get(a).get(b).add(c);
}
    
boolean contains(String a, String b, String c) {
    return map.getOrDefault(a, new HashMap<>())
        .getOrDefault(b, new HashSet<>())
        .contains(c);
}
```

Of course, in the original code, methods weren't as separated, the class had a few hundred lines, and everything was much more tangled.
After several refactoring steps, I replaced `Map<String, Map<String, Set<String>>>` with `Set<Key>`, resulting in something like:

```java
private Set<Key> set = new HashSet();

void put(String a, String b, String c) {
    set.add(new Key(a, b, c));
}

boolean contains(String a, String b, String c) {
    return set.contains(new Key(a, b, c));
}

record Key(String a, String b, String c) { }
```

I name variables in the example as `a`, `b`, `c`, etc., to avoid introducing domain intricacies.

Satisfied with the results, I deployed the change.
After a few minutes, I checked the service metrics, and there was a huge spike in memory usage.
Luckily, the deployment wasn't on the production environment.

## What Went Wrong?

It turned out that the new data structure consumed several times more memory.
But that's not all - it's not a small collection; it stores millions of elements.
The collection in the original version weighed around 400MB, while in the "improved" one, it was about 1100MB.

The increase in memory usage in this case stems from the mechanism of creating and storing Strings in the JVM.
Java has several optimizations on strings.
In particular, string literals go into the string pool in memory and can be reused multiple times, e.g.,

```java
String x = "Lorem ipsum";
String y = "Lorem " + "ipsum";
System.out.println(x.equals(y)); // prints true
System.out.println(x == y);      // prints true
```

This isn't true for strings that aren't literals, e.g.,

```java
int i = 0;
String x = "Lorem ipsum" + i;
String y = "Lorem ipsum" + i/2;
System.out.println(x.equals(y));  // prints true
System.out.println(x == y);       // prints false
```

One can force adding a string to the string pool using the [`intern()`](https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/lang/String.html#intern()) method,
but this solution has its nuances and, in my opinion, can lead to errors.
This solution may also result in other memory issues.

The described behavior of strings makes the implementation with `Map` significantly more memory efficient in my case.
The map holds a reference, which provides noticeable gains when there are many entries with the same key.
Additionally, in the described case, the strings were quite long - consisting of several dozen characters.

## Deeper Problem Analysis

To better understand what's happening in the JVM, consider the following example:

```java
map.computeIfAbsent(new String("a"), x -> new HashSet<>()).put(new String("b1"));
map.computeIfAbsent(new String("a"), x -> new HashSet<>()).put(new String("b2"));
```

After executing the first line of code, the following strings will be created:

- "a" – a literal that can be cleaned up by GC
- "b1"– a literal that can be cleaned up by GC
- `new String("a")` – as a key, the map holds a reference to this object
- `new String("b1")` – value in the set – the set holds a reference to this object, and the map holds a reference to the set.

After executing the second line of code, the following strings will be created:

- "a" – a literal that can be cleaned up by GC
- "b2" – a literal that can be cleaned up by GC
- `new String("a")` – may be cleaned up by GC because `equals` will be called on the string when adding to the map, and such a key already exists
- `new String("b2")` – value in the set – the set holds a reference to this object, and the map holds a reference to the set.

As a result, we keep only three strings in memory - no duplicates.

For a change, let's consider a version with a set and an aggregating object:

```java
set.add(new Key(new String("a"), new String("b1")));
set.add(new Key(new String("a"), new String("b2")));
```

After executing the first line, the following strings will be created:

- "a" – a literal that can be cleaned up by GC
- "b1" – a literal that can be cleaned up by GC
- `new String("a")` – value in the Key object – Key holds a reference to this object, and the set holds references to Key
- `new String("b1")` – value in the Key object – Key holds a reference to this object, and the set holds references to Key

After executing the second line, the following strings will be created:

- "a" – a literal that can be cleaned up by GC
- "b2" – a literal that can be cleaned up by GC
- `new String("a")` – value in the Key object – Key holds a reference to this object, and the set holds references to Key
- `new String("b2")` – value in the Key object – Key holds a reference to this object, and the set holds references to Key

As a result, we keep four strings in memory that cannot be deleted by GC – **the `new String("a")` instance is stored twice**.

## How I Solved the Problem

For performance reasons, I decided to stick with the map of map.
However, I encapsulated the whole ugliness of a set in a map within a map into a separate class:

```java
static class MultiDeepMap<K1, K2, V> {

    private Map<K1, Map<K2, Set<V>>> map = new HashMap<>();

    void put(K1 key1, K2 key2, V value) {
        map.computeIfAbsent(key1, it -> new HashMap<>())
                .computeIfAbsent(key2, it -> new HashSet<>())
                .add(value);
    }

   boolean contains(String key1, String key2, String value) {
        return map.getOrDefault(key1, new HashMap<>())
                .getOrDefault(key2, new HashSet<>())
                .contains(value);
    }
}
```

With such an API, we have a clear way of adding and checking if something has been added to the map:

```java
map.put("a", "b", "c");
map.contains("a", "b", "c");
```

To increase code readability, you can get rid of the habit of typing everything as a string, the jargon known as String Typing, by wrapping strings in classes/records and replacing:

```java
MultiDeepMap<String, String, String>
```

with:

```java
MultiDeepMap<A, B, C>
```

In my case, this resulted in a roughly 10% increase in memory usage for this collection.
All measurements were performed on Open JDK 17.0.1.

## Message for Today

It's not enough to know the internal mechanisms of the JVM.
You also need to remember them at the right time, especially during the daily maintenance of the code.
