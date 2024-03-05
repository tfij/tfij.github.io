---
layout: post
title: Microservices and modularization
tags: [tech, microservices, monolith, modularization, architecture, design]
short: false
seo:
    type: TechArticle
---

Many times I heard that the microservice-based architecture is a solution of modularization issue.
This is explained by the statement that monolith is a pure evil with the *big ball of mud* architecture.
Microservices, in contrast, are well separated units of business logic.
This biased point of view is visualized by diagrams like

![Bad monolith and good microservices](/assets/articles/2017-01-08-Microservices-and-modularization/bad-monolith-ang-good-microservices.svg "Bad monolith and good microservices")

However, domain-driven design (DDD) appeared when the monoliths were a base solution in software design.
There are no obstacles to build monolith using [bounded contexts](http://martinfowler.com/bliki/BoundedContext.html).
Each bounded context has in general a separated subdomain.
They can also use separated databases - [Polyglot persistence](http://martinfowler.com/bliki/PolyglotPersistence.html) 
approach can be applied to the monolith too.
Finally, context map specifies communication patterns.
Many technologies can be used to modularize the monolith:

- code organization (e.g. packages, namespaces, modules in Java 9),
- build tool modules (e.g. maven submodules or gradle subprojects),
- separated libraries,
- [OSGi](https://www.osgi.org/),
- Java EE (Java EE defined deployment model).

On the other hand, microservices can be split improperly.
Each service can have a lot of dependencies to other services.
Each one doesn't have to encapsulate its domains.
Single subdomain can be diffuse on many services.
In brief, you can do both good or bad microservices, and good or bad monolith.
High coupling is not characteristic of the monolith by its definition - it's a reflection of ignorance.

![Good monolith and bad microservices](/assets/articles/2017-01-08-Microservices-and-modularization/good-monolith-and-bad-microservices.svg "Good monolith and bad microservices")

Microservice-based architecture has many advantages like fault-tolerant (by processes separation), scalability, etc.
Modularization is only one of them.
This architecture type is also much more suit to agile methodology - providing team independence, technology freedom, fast and frequent deployments etc.
However, due to microservices brings also challenges, it should be carefully selected when the goal is a modularization.
In microservice-based architecture, modularization is rather a way to the goal, instead of the goal.
Finally, due to the complexity of distributed systems,
it seems to be more conveniently to refactor *bad monolith* then *bad microservices*.

The biggest advantage of microservices is scaling, not in terms of load but in terms of organization.
The independence of microservices allows for doubling the number of teams without a significant increase in cross-team communication overhead.
This one characteristic sets microservices apart from other popular architectures.
