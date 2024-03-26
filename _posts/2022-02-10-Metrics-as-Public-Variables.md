---
layout: post
title: Metrics as Public Variables, Is it Bad?
tags: [tech, java, design, observability, spring-framework]
short: false
customExcerpt: On this blog, I sometimes touch upon taboo subjects like in post *Optional as a Field and what are you going to do to me about it?*
  This time, it's about static public variables.
  Much has already been said about the harm their usage has inflicted on the world.
  In this post, I'd like to analyze a specific case of their usage, namely metrics...
coverImage:
  url: /assets/articles/2022-02-10-Metrics-as-Public-Variables/metrics.png
  alt: The illustration shows a terrified person surrounded by charts, metrics and terms such as metrics, public variables, getter and setter
publishedAt:
  site: detektywi.it
  url: https://detektywi.it/2022/02/metryki-jako-zmienne-publiczne-czy-to-zle/
  title: Metryki jako zmienne publiczne, czy to złe? [Polish]
seo:
  type: TechArticle
---

> Global state is evil until proven otherwise.
> 
> -- <cite>Martin Fowler</cite>

On this blog, I sometimes touch upon taboo subjects like in post [Optional as a Field and what are you going to do to me about it?](/2018/08/19/Optional-as-a-field-and-what-are-you-going-to-do-to-me-about-it.html).
This time, it's about static public variables.
Much has already been said about the harm their usage has inflicted on the world.
In this post, I'd like to analyze a specific case of their usage, namely metrics.

## Metrics, Metrics Everywhere

In the [Mierz logi na zamiary](https://detektywi.it/2019/07/mierz-logi-na-zamiary/) (bite off more than you can measure) post by Bartek Gałek, he described how important metrics are.
Collecting metrics is also very straightforward.
In the Spring framework, all you need to do is inject `MeterRegistry`...

Well, yes, just inject `MeterRegistry`.
But does everything in my code have to be a Bean just to collect metrics?
If I want to collect metrics in a POJO, do I have to create a factory that will be a Bean and set the `MeterRegistry` in the POJO instance?

Of course NOT!
After all, if you want to log something, you don't inject a logger (at least I haven't encountered that).
Instead, you use a static instance and log whatever and wherever you want.
I assume that logs and metrics are not that distant from each other.
So let's try to apply a similar approach to metrics.

## Global Variables Come to the Rescue

In the simplest approach, we could just create a class with a public static field holding an instance of `MeterRegistry`.
We would initialize this field at the start of the application and then use it freely.
Below is a slightly more elaborate implementation, where the mutator has package visibility and the accessor is public.

```java
public class MeterRegistryHolder {
    private static MeterRegistry aMeterRegistry;
    
        static void init(MeterRegistry meterRegistry) {
            aMeterRegistry = meterRegistry;
        }
    
        public static MeterRegistry meterRegistry() {
            return aMeterRegistry;
        }
    }
```

```java
@Configuration
public class MeterRegistryHolderInitializer {
    MeterRegistryHolderInitializer(MeterRegistry meterRegistry) {
        MeterRegistryHolder.init(meterRegistry);
    }
}
```

This implementation is very simple yet provides immense flexibility for adding metrics in the code.

If you need several instances of `MeterRegistry` because, for example, you send metrics to different places, you can extend the `MeterRegistryHolder` class to hold multiple instances.

For convenience, you can add a static import for `MeterRegistryHolder.meterRegistry`.
The code will remain largely unchanged.
Instead of `meterRegistry.counter()`, it will be `meterRegistry().counter()`.

You can also use the [Metrics](https://javadoc.io/doc/io.micrometer/micrometer-core/latest/io/micrometer/core/instrument/Metrics.html) class from `Micrometer`.
It has a much more extensive API through which, although we don't have access to the `MetricRegistry` object, we have a range of methods for generating metric instances associated with the global `MetricRegistry`.

## Limitations

Global variables are not without reason infamous.
Below are two limitations of the discussed approach to keep in mind.

If you need to test metrics, you can achieve this by setting Spy/Mock in `MeterRegistryHolder`
or initialize it by [SimpleMeterRegistry](https://www.javadoc.io/doc/io.micrometer/micrometer-core/1.0.6/io/micrometer/core/instrument/simple/SimpleMeterRegistry.html).
However, note that in this case, metric tests should not be run concurrently.

Also, note that in this implementation, we do not control the order in which beans are initialized and when `MeterRegistryHolder` will be initialized.
Therefore, if you try to collect metrics during application context initialization, the `meterRegistry` reference may be empty.
In such a situation, you can either expand the `MeterRegistryHolder` (I have prepared a sample implementation on [GitHub](https://github.com/tfij/MeterRegistryHolder)) or resort to the old proven injection.
A simple implementation of `MeterRegistryHolder` can be used for everything that happens after the context is initialized.

I'm not assuming that this approach will work in all cases.
In my recent projects, it worked great, providing a lot of freedom for adding metrics.

## Message for Today

Give global variables a chance (especially when you limit their variability to the package scope).
