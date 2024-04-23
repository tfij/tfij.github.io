---
layout: post
title: Documentation is not a Requirement
tags: [tech, architecture, documentation, quality, development-process]
short: false
description: In this post, I'd like to present my three-point approach to tasks and problems related to documentation.
image: /assets/articles/2023-06-29-Documentation-is-not-a-Requirement/documentation.png
image-alt: The illustration shows a man trying to support piles of documents that are about to fall
publishedAt:
  site: detektywi.it
  url: https://detektywi.it/2023/06/dokumentacja-nie-jest-wymaganiem/
  title: Dokumentacja nie jest wymaganiem [Polish]
seo:
  type: TechArticle
---

> There's no sense in being precise when you don't even know what you're talking about.
> 
> -- <cite>John van Neumann</cite>

In my professional life, I've encountered guidelines stating that "every system must have documentation" many times.
Typically, based on such formulated requirements, someone from the team would prepare a document called documentation.
Often, it was a forced document that didn't change anything in terms of the system's usability and didn't make anything easier.

In this post, I'd like to present my three-point approach to tasks and problems related to documentation.

## Firstly, determine what problem the documentation is supposed to solve

The IT community often perceives documentation creation as a necessary requirement that few people want to fulfill.
The most important task of documentation, i.e., achieving a goal or solving a problem, is not recognized.
Without considering the goal, we prepare a document that is supposed to address all issues of all stakeholders, if it addresses any at all.

Let's consider some example goals and problems that documentation is supposed to address:

1. The system architecture is complex and difficult to explain.
2. Onboarding time for project employees is long, and we want to shorten it.
3. The Ops team is struggling with deploying software prepared by developers.
4. Other teams complain about integration with our library.

Documentation can potentially be a solution to all these problems.
However, let's take a closer look at them, leading us to the second point.

## Secondly, consider whether the problem can be solved differently than through documentation

Creating documentation often seems like a remedy for a variety of problems, but it might be worth finding and eliminating their source instead of applying a plaster in the form of an additional document.

If the architecture is complex (problem 1), instead of writing extensive documentation explaining all intricacies, it's better to spend time simplifying the architecture to make it more understandable.

If onboarding time for employees is long (problem 2), it's worth considering why.
Is it due to poor code quality, non-compliance with standards, lack of code modularity?
All these cases can be addressed differently than with documentation, while simplifying the lives of all code users.

If deploying the system by the Ops team is a challenge (problem 3), instead of preparing deployment specifications, DevOps practices can be applied.
Instead of introducing exotic deployment methods, the company may have a standard that can be applied.
You can consider to apply 'you build it, you run it' approach.

If library usage is the problem (problem 4), it's worth working on the API.
First and foremost, check if the library has a clearly defined API, if it's easy to use, and if methods and types are unambiguous.

## Thirdly, choose the appropriate form of documentation

I wouldn't want to be misunderstood; I'm not against the written word.
Often, creating documentation is the best way to address many problems.
However, it's worth considering its form.
For describing a framework that other teams will integrate with, a tutorial might be best, while a tutorial won't work for describing that framework for developers who are developing it.
[Architectural Decision Records (ADRs)](https://adr.github.io/) can be used to describe architectural decisions.
Different cases require different forms of documentation.
Sometimes we'll need many different forms in a single system.

The same goes for diagrams.
If a diagram isn't understandable without someone describing it, it probably presents too many concepts at once and should be split into several simpler ones.

## Message for Today

If someone asks you to prepare documentation, before you do anything, ask what problem we are solving and solve it in the right way.
