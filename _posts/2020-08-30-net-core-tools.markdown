---
layout: post
title:  ".NET Core Tools"
date:   2020-08-30 15:13:00 -0600
categories: [programming, gamedev]
tags: [programming, tools, dotnet]
---

Beginning with .NET Core 2.1, developers are able to easily create and distribute ".NET Core Tools". These tools are simply .NET console applications that are delivered as a special form of NuGet package. Due to how simple they are to create it is a great way to share small applications and tools with your fellow developers.

# Creating .NET Core Tools

Creating a new .NET Core tool is as simple as creating a new console app, adding a few lines to the project file, and packaging the project. To begin, create you console application using `dotnet new console`. Update the generated project to do whatever you like (or just leave the default "Hello World!" implementation) and then add the following to the `PropertyGroup` node in your project's `.csproj`:

{% highlight csharp %}
<PackAsTool>true</PackAsTool>
<ToolCommandName>hello-world</ToolCommandName>
{% endhighlight %}

The `PackAsTool` element is what signifies that this should be packaged as a tool rather than a regular NuGet package. The `ToolCommandName` lets you optionally specify the command that should be used to run the tool. If it is not provided, it will default to the project name. As these tools are still NuGet packages you will likely want to also provide the usual NuGet metadata like an ID, version, etc. It's important that you choose an ID that avoids any naming collisions if you're publishing this to the public nuget.org repository.

The final steps are to build your project with `dotnet build` and then package it using `dotnet pack`. From there, all you need to do is upload it to a NuGet repository in order to make it available for others to install.

# Using .NET Core Tools

Once the tool is packaged and published, users are able to install it using `dotnet tool install -g <tool_name>`. The `-g` switch will install the package globally. This adds the command to the machine's path and allows it to be run anywhere by simply executing the appropriate command, like `hello-world`. 

Starting in .NET Core 3.1, the SDK also supports installing tools locally to a project. This allows you to install different versions of the same tool in different workspaces. Local tools rely on a manifest file in the project which can be used to restore/install all the tools necessary for that project. Local tools must be run via `dotnet tool run <command_name>`.

Before installing any tools make sure you trust the author and have reviewed the source if possible. These tools are not sandboxed or restricted in any way so it is vital that you know what you are installing. To uninstall a tool you can use the `dotnet tool uninstall <tool_name>` command. If the tool was installed globally, be sure to include the `-g` switch.

# Additional Reading
* [.NET Core tools][tools]
* [Create a .NET Core tool][create-tools]

[tools]: https://docs.microsoft.com/en-us/dotnet/core/tools/global-tools
[create-tools]: https://docs.microsoft.com/en-us/dotnet/core/tools/global-tools-how-to-create