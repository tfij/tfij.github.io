---
layout: post
title: The Dark Sides of the Open-Closed Principle
tags: [tech, design, clean-code]
short: false
customExcerpt: The Open-Closed Principle, described in SOLID, ensures project flexibility, but does it always lead to optimal, future-ready code?
  It sounds promising - open for extension, closed for modification.
  Let's take a closer look.
coverImage:
  url: /assets/articles/2024-01-25-The-Dark-Sides-of-the-Open-Closed-Principle/overengineering.jpg
  alt: The illustration shows a tangled arrow as a metaphor for overengineering
publishedAt:
  site: detektywi.it
  url: https://detektywi.it/2024/01/mroczne-strony-open-closed-principle/
  title: Mroczne strony Open-Closed Principle [Polish]
seo:
  type: TechArticle
---

> Simplicity is the goal.
>
> -- <cite>Sean Parent, Menlo Innovations</cite>

The [Open-Closed Principle](https://en.wikipedia.org/wiki/Open%E2%80%93closed_principle), described in [SOLID](https://pl.wikipedia.org/wiki/SOLID),
ensures project flexibility, but does it always lead to optimal, future-ready code?
It sounds promising - open for extension, closed for modification.
Let's take a closer look.

## Overengineering in Light of Open-Closed

The Open-Closed Principle seems like a reasonable approach.
By designing our code to easily add new features without modifying existing code, we become prepared for unexpected changes and project expansions.
However, is this always necessary?
This is where the problem of overengineering arises.

Overengineering is when our code is more complicated than necessary to prepare for changes and scenarios that may never occur.
It's like building a bridge in the desert, hoping it might someday be useful as a trade corridor.

Anticipating potential, but unknown, changes can lead to excessive code abstraction.
Additional layers, interfaces, and structures intended to provide flexibility introduce unnecessary complexity.
Additional complexity is introduced to avoid touching individual pieces of code in the future.
It is the fear of future change that drives overengineering.
Fear stemming from poor-quality code.

## Proper Engineering

Instead of focusing on creating code that is ready for every eventuality, it is worth concentrating on proper engineering.
**Rather than avoiding changes, let's focus on creating code that is easy to change**.
High-quality code, clean code, automated testing, modularization, high cohesion, etc. - these are the foundations that make our code flexible without unnecessary abstractions.

Engineering should focus on creating solutions that are simple and efficient.
For example, when you have one discount calculation algorithm, you don't need to implement the [strategy pattern](https://en.wikipedia.org/wiki/Strategy_pattern) thinking,
"maybe someday we'll have a second algorithm, and it will be easy to replace".
This is overengineering entirely consistent with the open-closed principle.
If the code is of good quality, introducing abstractions when needed shouldn't be a problem.

## Message for Today

Handle the Open-Closed Principle with care.
Code should be easy to modify, not necessarily prepared for specific, uncertain changes.
