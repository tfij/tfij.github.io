---
layout: post
title: Micro-monolith anti-pattern
tags: [tech, micro-monolith, microservices, monolith, architecture, design, patterns, anti-patterns]
short: false
seo:
    type: TechArticle
---

Microservice-based architecture gains popularity every day.
This approach has many advantages.
The most important advantages include independent deployments, shortened and simplified deployment pipelines, limited communication between teams, and technology freedom.
These core advantages support the quick delivery of new features and organization scalability - allows for doubling the number of teams without a significant increase in cross-team communication overhead.
Microservices, of course, also bring a lot of challenges.
The wrong approach can ruin all microservices' benefits.
It can also transform the architecture into some kind of rotten architecture, which I call a distributed monolith or the **micro-monolith anti-pattern**.  
The following situations are symptoms of the anti-pattern occurrence:

- The implementation of a new feature requires changing many services developed by many teams.
- It's impossible to deploy a single service (it is required to synchronize the deployment of many services).
- A requirement of a specific framework for all services.

This article discusses the micro-monolith anti-pattern and the dangers that come with it.

## Micro-monolith on the frontend level

Designing the frontend in a microservice-based system is one of the main challenges.
According to agile methodology, a team should be cross-functional and be able to deliver an entire feature themselves.
Thus, it seems natural not to create a single service responsible for the whole frontend—such an approach is a short road to a frontend monolith.
The frontend team is involved in every change and becomes a bottleneck.

Instead, each team should provide a piece of frontend suitable for the domain they build.
That piece of frontend can be placed in a separate service or together with the backend—it is irrelevant.
It is essential to concentrate the responsibility for the entire feature in a single team.

However, even if each microservice provides a fragment of the frontend, it is possible to build the micro-monolith anti-pattern.
If services provide modules (e.g., AngularJS modules) that are combined in one SPA (Single-page application),
then a monolith on the frontend appears.
To deploy a single change, it is required to build the whole frontend app, which is a single deploy unit.
Moreover, there is a trade-off between the teams' technological independence and web-perf to be resolved what is a big topic.

The solution for managing the frontend in the microservices-based architecture should be selected carefully.
Most popular ones have both advantages and disadvantages, causing a lot of place for trade-offs.
You can try either SPA per bounded context or build a page from fragments (using, e.g., ESI tags).
At [Allegro](http://allegro.pl), to solve a problem with the frontend, we designed our own solution.
The solution supports:

- An integration of many services on any page,
- Teams' independence — teams create their own frontend components,
- Technology freedom — each component can be developed in different technology (there are limitations due to web-perf but the architecture allows for mixing technologies),
- Non-technical users, using components and services, can prepare a new page in a few minutes (e.g. marketing department creates several advertising campaign pages per day).

More about this approach can be found at [Allegro.tech](http://allegro.tech/2016/03/Managing-Frontend-in-the-microservices-architecture.html).

## Micro-monolith on the services level

The macro architecture of a system should limit the impact on each microservice.
Similarly, the architecture of each microservice should not affect the macro architecture.
This leads to the general conclusion that microservices should be as independent as possible.
It is in conflict with standardization — more independence means less standardization.
For example, if the whole system is based on [Akka](http://akka.io) framework and the only way to integrate a new service
with others is to use Akka, it smells like a micro-monolith.
In this case, teams lose their technological freedom.
Also, there is no way to migrate the system step by step to other technology.
To prevent such drawbacks, Akka should be limited to a single service or a few services maintained by one team.

Another dangerous decision is to use a lib for reusing code.
This is particularly bad if the lib contains domain logic.
Again, in this case teams are devoid of technological independence.
Moreover, domain modification requires teams synchronization and changes in many services (even if it is limited to updating lib version).
Abandoning a DRY (don't repeat yourself) principle for independence should be considered.
The recommended solution is to code repetition or to spawn a new microservice instead of the lib.
If libs contain utils or support infrastructure, there should always be an alternative to integrate without such libs.

However, as discussed in [Microservices and modularization](/2017/01/08/Microservices-and-modularization.html),
high coupling is not characteristic of the monolith by its definition — it’s a reflection of ignorance.
A microservice having a huge number of connections to other services doesn't have to be a micro-monolith.
It is certainly bad design and can lead to a micro-monolith.
Such architecture forces to versioning frequently changed endpoints or synchronous services deploy.
The first solution is laborious.
The second one means that a micro-monolith is created—frequent and fast deployment is gone.
In both solutions, teams have to spend a lot of time communicating with each other, refactoring is more complex, and so on.

## Micro-monolith on the database level

It is common to refactor a Monolith into Microservices.
Usually, the domain is well-known and services may have clearly designated bounded contexts.

Unfortunately, in that case, the most difficult task is refactoring and splitting the monolith database (especially RDBMS).
Eventually, microservices should access data from their own database or from other services.
The shared database hidden behind some kind of ACL (anti-corruption layer) is a short-term solution.
Any modification of the database model requires team synchronization and potentially changing many services, which should be abandoned.
A shared database as a long term solution is another example of a micro-monolith anti-pattern.

The similar difficulty appears while refactoring microservices (fortunately on a small scale) when 
e.g., functionality is moved from one microservice to another or when a new microservice is spawned.
In most cases, it is easier to split the logic than the data.

## Tests VS micro-monolith

Even if microservices are split and separated well, an improper approach to the deploy pipeline may push you into the micro-monolith anti-pattern.
The challenge is to test the entire system.
It doesn't help that there are a lot of code repositories, technology stacks, configurations, etc.

Shared tests across the entire system may be a bottleneck of a deploy pipeline, limiting frequent deployments.
Instead of that, integration tests of microservices should be moved to each microservice.
Each service should be tested with own dependent services.
To achieve that, it is tempting to prepare a reference environment with all production services.
Microservices are tested by many teams using that single reference env.
Unfortunately, due to parallel tests, such an env is not a good solution for isolated testing of microservices.
Those tests are plainly brittle and should be limited.

Recommended tools are stubs (e.g. wiremock), well-defined contracts and Consumer-Driven Contracts (CDC).
You can consider to use envirement per team where each team can define own environment.
Building such environments to be effective also in terms of costs is quite a challenge.
[Test Pyramid](http://martinfowler.com/bliki/TestPyramid.html) principle should be extended and apply in microservice-based architecture.
Each service should have its own pyramid as well as the entire system.

![Test pyramids in microservice-based architecture](/assets/articles/2017-01-30-Micro-monolith-Anti-pattern/test-pyramids.svg)
