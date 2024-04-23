---
layout: post
title: "Mental Monolith: End-to-End Tests"
tags: [tech, testing, architecture, microservices, monolith, development-process, communication, team-organization]
short: false
description: In recent years, service architectures, especially microservices, have gained enormous popularity, yet the approach to end-to-end (E2E) testing often remains unchanged.
  We hear that tests verifying the operation of the entire system are crucial in the software development process, especially with distributed architectures.
image: /assets/articles/2023-11-30-Mental-Monolith-End-to-End-Tests/Mental-Monolith.png
image-alt: The illustration shows a head with a large monolith inside it instead of a brain
publishedAt:
  site: detektywi.it
  url: https://detektywi.it/2023/11/monolit-mentalny-testy-e2e/
  title: "Monolit mentalny: Testy E2E [Polish]"
seo:
  type: TechArticle
---

> The most important transformation for most organizations is to enable people and teams to do creative high-quality work. Large scale, incremental change is the key to achieving this.
> 
> -- <cite>David Farey</cite>

In recent years, service architectures, especially microservices, have gained enormous popularity, yet the approach to end-to-end (E2E) testing often remains unchanged.
We hear that tests verifying the operation of the entire system are crucial in the software development process, especially with distributed architectures.
Statements like "We need to prove that the system works as a whole. We used to have a monolith and E2E tests; now we have independent microservices, so E2E tests are even more necessary" arise.

In this post, I use the term E2E tests to refer to tests of the entire system.
These are cases where the test requires running multiple services.
Therefore, for example, front-end tests using a browser don't meet this definition if the backend is a service mock, stub, etc.

## Mental Monolith

Overestimating the importance of whole-system tests is a symptom of monolithic thinking.
When we need to test the system as a whole, it means that key attributes of distributed architecture, such as independence of changes and deployments, haven't been achieved.
Furthermore, deployment independence is ingrained in the definition of microservices.
This statement could end the discussion.
However, let's take a closer look at the negative aspects of E2E tests in microservices.
In the case of a service-oriented architecture, E2E tests not only involve issues of cost, speed, stability, and complexity,
as described in the [testing pyramid](https://martinfowler.com/articles/practical-test-pyramid.html), but they also significantly affect workflow.
Since their purpose is cross-team testing, a team of testers is often created to develop and maintain them.
This solution isn't scalable and introduces delays as work passes through multiple teams—from developers, through testers, to deployment/release.
In another approach, responsibility for E2E tests can be shared by all teams.
In this model, it's common for changes in one service to cause errors in tests and block deployments of another team's service.
In both configurations, having multiple releases per day will be challenging, and their schedule will be susceptible to unpredictable delays.
Development teams will lose independence and spend more time on communication.
Introducing the first E2E test entails a range of problems, such as deciding who will maintain the E2E tests, how they will be run,
how to ensure independence of development teams, and how to maintain deployment independence, etc.

The need for E2E tests may arise from two main reasons.
The first is when we have a solid system with independent services, but the manager is stuck in mental monolith thinking.
They don't understand the concept of independent services with clear boundaries in the form of contracts.
Fear of system stability and reluctance to take responsibility for errors in the event of a failure may also play a role.
In such cases, the solution may be education or even changing the manager.
In extreme cases, however, this may mean a cultural revolution in the company.
The second reason is the state of our architecture, where elements form a distributed monolith and are strongly interconnected.
In this case, it's worth analyzing contracts between services, checking if E2E tests are not the result of abandoning strict contracts in favor of loose ones,
if service APIs are consumed according to the X-as-a-service (XasS) pattern,
or if [consumer-driven contracts](https://martinfowler.com/articles/consumerDrivenContracts.html) have been applied.
Lack of contracts doesn't just mean a lack of endpoint description.
It can be reflected in formulations such as "the system must be run on a pre-production or UAT environment with production data for n days because we can't predict all data cases and event combinations."

If you decide to use E2E tests, make sure they are fast and stable, which is a challenge in itself.
Additionally, introducing the first E2E test will have a significant impact on the entire system.
It will be challenging to determine who will maintain the E2E tests and how they will affect the workflow of all teams.
Therefore, limit their scope only to critical areas of the system and control their number.

## Living Without Whole-System Tests

Similarly to what I wrote in another post, [Documentation is not a Requirement](/2023/06/29/Documentation-is-not-a-Requirement.html), and above, E2E tests are not a requirement either.
Consider what risks we want to minimize and what problems we want to solve with them.
How else can we approach these issues?
Much depends on the context; nevertheless, ultimately, in many cases, we can do without any E2E tests.

The topic of safely deploying independent services is extensive, so I don't intend to discuss it in full here.
Below, I raise a few key issues.

Firstly, define service boundaries through API contracts.
These contracts should be thoroughly tested.
When designing services, it's also worth considering which processes require testing in full and why.
The choice between orchestration and choreography has an impact on testing.
In other words, it's usually easier to test a process managed by a single service because tests can be limited to that one service.

To minimize deployment-related risks, consider using practices such as [blue-green deployment](https://martinfowler.com/bliki/BlueGreenDeployment.html),
[canary release](https://martinfowler.com/bliki/CanaryRelease.html), or [feature flags](https://martinfowler.com/articles/feature-toggles.html).

Ultimately, if the system needs to be tested as a whole, perhaps microservices aren't the best choice; maybe a monolith and monorepo will work better.

## Message for Today

Don't get stuck in mental monolith thinking.
A monolith isn't just an architecture; it's also a way of thinking about a problem.
