---
layout: post
title: Micro-monolith anti-pattern
tags: [tech, micro-monolith, microservices, monolith, architecture, design, patterns, anti-patterns]
short: false
seo:
    type: TechArticle
---

Microservice-base architecture gains in popularity every day.
This approach has many advantages.
The most important are independent deployments, shortened and simplified deploy pipeline, 
limiting communication between teams and technology freedom.
That core advantages support quick delivery of new features.
Microservices, of course, bring also a lot of challenges.
Wrong approach to these can ruin the benefits of microservices.
It's also transform an architecture in some kind of a rotten architecture which I call distributed monolith or **micro-monolith anti-pattern**.
Symptoms of that anti-patter are following situations:

- An implementation of a new feature requires changing of many services developed by many teams.
- It's impossible to deploy single service (it is required to synchronize deploy of many services).
- A requirement of a specific framework for all services.

This article discuses micro-monolith anti-pattern and dangers which come with that.

# Micro-monolit on the frontend level

Design frontend in microservise-base system is one of the main challenge.
According to agile methodology, a team should be cross-functional and be able to deliver entire feature themselves.
Thus, it seems natural not to create single service responsible for whole frontend
- such approach is a short road to frontend monolith.
The frontend team is involved in every change and becomes a bottleneck.

Instead, each team should provide a piece of frontend suitable for a domain they build.
That piece of frontend can be placed in separate service or together with the backend - it is irrelevant.
It is essential to concentrate the responsibility for the entire feature in a single team.

However, even if each microservice provides fragment of frontend, it is possible to build micro-monolith anti-pattern.
If services provide modules (e.g. AngularJS modules) which are combined in one SPA (Single-page application),
then monolith on frontend appears.
To deploy a single change it is required to build whole frontend app, which is single deploy unit.
Teams also lose they technological independence.

The solution for managing frontend in the microservices-base architecture should be selected carefully.
Most popular ones have both advantages and disadvantages, cause a lot place for trade-offs.
You can try either SPA per bounded context or build page from fragments (using e.g. ESI tags).
In [allegro](allegro.pl) to solve a problem with frontend, we designed our own solution. The solution supports

- an integration of many services at any page,
- teams independence - teams create their own frontend components,
- technology freedom - each components can by developed in different technology,
- non-technical users, using components and services, can prepare a new page in few minutes (marketing department creates several advertising campaign pages per day).

More about this approach can be find at [allegro.tech](http://allegro.tech/2016/03/Managing-Frontend-in-the-microservices-architecture.html).

# Micro-monolit on the services level

Macro architecture of a system should limit impact to each microservice.
Similarly, architecture of each microservice should not affect to macro architecture.
This leads to a general conclusion that microservices should be as independent as it is possible.
It is in conflict with standardization - more independence means less standardization.
For example, if whole system is based on [akka](http://akka.io) framework and the only way to integrate new service 
with others is to use the akka, it smells like a micro-monolith.
In this case, teams lost they technological freedom.
Also, there is no way to migrate system step by step to other technology.
To prevent such drawbacks, akka should be limited to a single service or few services maintained by one team.

Another dangerous decision is to use a lib for reusing code.
This is particularly bad if the lib contains domain logic.
Again, in this case teams are devoid of technological independence.
Moreover, domain modification requires teams synchronization and changes in many services (even if it is limited to update lib version).
Abandoning a DRY (don't repeat yourself) principle for independence should be considered.
The recommended solution is to code repetition or to spawn a new microservice instead of the lib.
If libs contain utils or support infrastructure, there should be always an alternative to integrate without such libs.

However, how itwas discussed [Microservices and modularization](/2017/01/08/Microservices-and-modularization.html),
high coupling is not characteristic of the monolith by its definition - it’s a reflection of ignorance.
A microservise having a huge number of connections to other services, doesn't have to be micro-monolith.
It is certainly bed design and can lead to micro-monolith.
Such architecture forces to versioning frequently changed endpoints or synchronous services deploy.
The first solution is laborious.
The second one means that micro-monolith is created - frequent and fast deployment is gone.
In both solutions teams have to spend lot of time to communicate each other, refactoring is more complex, and so on.

# Micro-monolit on the database level

It is common to refactor a Monolith into Microservices.
Usually the domain is well known and services may have clearly designated bounded contexts.

Unfortunately, in that case, the most difficult task is to refactoring and spiting the monolith database (especially RDBMS).
Eventually, misroservices should access data from their own database or from other services.
The shared database hidden behind some kind of ACL (anti-corruption layer) is a short term solution.
Any modification of database model requires teams synchronization and potentially changing of many services, what should be abandoned.
Shared database is another example of a micro-monolit anti-pattern.

The similar difficulty appears while refactoring of microservices (fortunately on a small scale) when 
e.g. functionality is moved from one microservice to another or when new misroservice is spawned.
In most cases it is easier to split the logic than the data.

# Tests VS micro-monolith

Even if microservices are split and separated well, improper approach to deploy pipeline may push you into the micro-monolith anti-pattern.
The challenge is to test the entire system.
It doesn't help that there are a lot of code repositories, technology stacks, configurations etc.

Shared tests across the entire system may be a bottleneck of a deploy pipeline what limits frequent deployments. 
Instate of that, integration tests of microservices should be move to each microservice.
Each service should be tested with all depended services.
To achieve that, it is tempting to prepare reference environment with all production services.
Microservices are tested by many teams using that single reference env.
Unfortunately, due to parallel tests, such env is not a good solution for isolated testing of microservices.
That tests are plainly brittle and should be limited.

Recommended tools are stubs and Consumer-Driven Contracts (CDC).
[Test Pyramid](http://martinfowler.com/bliki/TestPyramid.html) principle should be extended and apply in microservice-base architecture.
Each service should has its own pyramid as well as the entire system.

![Test pyramids in microservice-base architecture](/assets/articles/2017-01-30-Micro-monolith-Anti-pattern/test-pyramids.svg "Test pyramids in microservice-base architecture")

Tests of the entire system, base on a reference env, shouldn't focus on responsibility of any single microservice. 
Instead, they should focus on testing business processes crossing many services.
That test should be prepared by team collaboration and its running should not take more then few minutes.

A reversal of the cone may cause monolith-like prolonged deploy pipeline, slows down deployments and limits their frequently.

# Today's message

Many ideas that are intended to solve a problem generate even greater.
Focus on the goals of microservice-base architecture and keep in mind what are the reasons for applying it.
Micro-monolith anti-pattern is lying in wait on many steps.
