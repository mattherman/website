---
layout: post
title:  "Finalizers in C#"
date:   2017-12-16 14:55:00 -0500
categories: [programming]
tags: [c#, garbage collection, programming]
---

Similar to how programmers can use constructors to initialize an object, C# provides the concept of finalizers for cleaning them up. A finalizer declaration looks very similar to a constructor except it begins with a special `~` syntax and cannot take any arguments.

{% highlight csharp %}
class MyClass
{
    ~MyClass()
    {
        // cleanup
    }
}
{% endhighlight %}

The purpose of finalizers is to perform additional cleanup related to the destruction of an object. Generally in C# the runtime will handle allocating and freeing memory, but if an object has any unmanaged resources (e.g. file handles, sockets, etc.) it will need to clean up after itself. The runtime is unable to do it automatically since it is not managing those native resources. Since most C# programmers do not find themselves dealing with unmanaged resources often, they usually do not need to implement a finalizer.

# Finalizers and Garbage Collection

It is impossible to call an object's finalizer directly. An object that provides a finalizer will be marked so that the garbage collector knows it requires a finalizer call. Once that object is no longer referenced the next run of the garbage collector will move it to the finalizer (f-reachable) queue. Objects without a finalizer are not added to this queue since they can be collected immediately. In addition, the object will be moved to the next "generation" of the managed heap. 

The .NET garbage collector organizes objects into sets known as generations. All objects are created in Generation 0 and are moved up a generation each time they survive collection and collections run less frequently on the higher generations. This allows the garbage collector to focus on the most short-lived objects and free their memory more frequently.

After some time on the finalizer queue, a thread (separate from the main GC thread) will process items in the queue and call their finalizer. Each finalizer will implicitly call the finalizer of its base class so finalization occurs in an inheritance hierarchy chain from child to parent. After this point, the object will be removed from the queue and be available for removal on the next garbage collection. 

It's unclear why the finalizer queue is processed on a thread separate from the garbage collector but sources online seem to imply it is for performance issues. This seems reasonable since a garbage collection requires a pause of the application.

# Deterministic Cleanup with `Dispose`

Since it is unknown when the finalizer will be executed the language provides another mechanism for deterministic release of resources. The `IDisposable` interface provides a `Dispose` method that can be called on an object explicitly to perform the cleanup that a finalizer would normally provide. A very common pattern for implementing `IDisposable` looks like this:

{% highlight csharp %}
public MyClass : IDisposable
{
    private bool disposed = false;

    ~MyClass()
    {
        Dispose(false);
    }

    public void Dispose()
    {
        Dispose(true);
        GC.SuppressFinalize(this);
    }

    protected virtual void Dispose(bool disposing)
    {
        if (disposed)
            return;

        if (disposing)
        {
            // cleanup managed resources
        }

        // cleanup unmanaged resources

        disposed = true;
    }
}
{% endhighlight %}

The public `Dispose` method will be called by any consumers attempting to clean up an instance of `MyClass`. This will in turn call the protected helper `Dispose(bool)` which will perform the actual cleanup. This method has a few guards in it. First, a flag is checked in order to prevent disposal of the same resources more than once. Second, the value of `disposing` will determine whether to clean up managed resources (e.g. other objects that implement `IDisposable`) in addition to the unmanaged ones. When it is called from the publicly-exposed `Dispose` that flag is set to true since it should clean up all resources the object owns. However, when it is called from the finalizer `disposing` is set to `false`. If the finalizer is being called, the managed resources this object has may have already been destroyed and disposing of them again may cause issues.

The last part to point out is the call to `GC.SuppressFinalize(this)` at the end of `Dispose`. Since all of the resources have been manually cleaned up, there is no reason for the finalizer to run at a later time. `SuppressFinalize` will mark the object as not needing to execute a finalizer, allowing it to be cleaned up by the garbage collector without first waiting in the finalizer queue that was mentioned earlier.

# The `using` Statement

Another benefit to implementing the `IDisposable` interface is the `using` statement. In order to ensure disposable objects get cleaned up properly a `try`/`finally` would need to be used.

{% highlight csharp %}
void MyMethod()
{
    try
    {
        var foo = new MyDisposableClass();
        // do something
    }
    finally
    {
        foo.Dispose();
    }
}
{% endhighlight %}

The language provides the `using` statement as a helpful piece of syntactic sugar to simplify this.

{% highlight csharp %}
void MyMethod()
{
    using (var foo = new MyDisposableClass())
    {
        // do something
    }
}
{% endhighlight %}

Everything in the `using` block will be wrapped in an implicit `try`/`finally` and disposed of before exiting the statement.

Most of the time programmers will not need to implement `IDisposable` themselves. A `Dispose` method (and finalizer) is only necessary when the class contains resources that are not managed by the runtime or contains other managed objects that implement `IDisposable`. While implementing this pattern is rare, it is important to understand when it is necessary in order to ensure that resources that are no longer needed get cleaned up properly.

# Additional Reading
* [Finalizers (Destructors)][destructors]
* [System.Object.Finalize][object-finalize]
* [Garbage Collection Fundamentals][gc]

[object-finalize]: https://docs.microsoft.com/en-us/dotnet/api/system.object.finalize?view=netframework-4.8
[destructors]: https://docs.microsoft.com/en-us/dotnet/csharp/programming-guide/classes-and-structs/destructors
[gc]: https://docs.microsoft.com/en-us/dotnet/standard/garbage-collection/fundamentals