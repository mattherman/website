---
layout: post
title:  "Finalizers in C#"
date:   2017-12-16 14:55:00 -0500
categories: [programming]
tags: [c#, garbage collection, programming]
---

https://docs.microsoft.com/en-us/dotnet/api/system.object.finalize?view=netframework-4.8
https://docs.microsoft.com/en-us/dotnet/csharp/programming-guide/classes-and-structs/destructors
https://docs.microsoft.com/en-us/dotnet/standard/garbage-collection/fundamentals

- Objects with finalizers will be marked for finalization (how is this done? separate queue?)
- During GC, if an object with a finalizer is determined to be inaccessible (garbage) it will be moved to the finalizer (`f-reachable`) queue
- The object itself will be moved up a generation, this can cause it to survive even longer
- A separate thread is responsible for calling the finalizer and removing it from the f-reachable queue but this happens non-deterministically
- Once the object is removed from f-reachable it will be available for collection on the next GC cycle
- Implementing `Dispose` lets you clean up objects more deterministically
