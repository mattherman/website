---
layout: page
title: Projects
permalink: /projects/
---

## Completed Projects 

# [MbDotNet][mbdotnet]

A .NET client library for interacting with the [mountebank][mb] testing tool. Mountebank is a tool that allows you to create "imposters" which act as over-the-wire test doubles which can intercept network requests and return mocked responses. My library is meant to provide an easy way for .NET developers to create and manage these imposters. I've worked on it off and on since February 2016 with a handful of other contributors. It is my first successful open source project having been downloaded over 60 thousand times on [nuget.org][mb-nuget] and being mentioned in _Testing Microservices with Mountebank_ by Brandon Byars (the creator of mountebank).

# [mhgit][mhgit]

A small Git implementation written in Go. I was inspired by similar projects such as [gitlet.js][gitlet] and [pygit][pygit]. This was my first significant Go project and helped me learn more about the language as well as Git internals.

# [akka-wiki-graph][akkawiki]

A Wikipedia crawler and visualization tool built with [Akka.NET][akkanet] in order to learn more about Actors. Using the web interface a user can crawl that page's links and generate a graph of related topics.

# [arduino-simon][arduino-simon]

A simple ["Simon"][simon] game created using an Arduino Mega2560. This was my first electronics project and taught me the basics of how to connect various components and implement the game's simple state machine.

# [DotChat][dotchat]

An IRC client written in C# for a school project my senior year at MSOE.

## In Progress

# [FsLisp][fslisp]

A Lisp interpreter written in F#. This is my first F# project and is especially ambitious since I am attempting to learn Common Lisp at the same time as I implement the interpreter. Although I am using the [FParsec][fparsec] library for parsing in the project, I started off by learning all about parser combinators from Scott Wlaschin's [_F# for fun and profit_][parser] articles. Parsing the AST is complete and the interpreter itself is able to execute a few very simple statements. I am guessing it will be completely rewritten a few times as I learn more about Lisp.

# [chip8][chip8]

A [CHIP-8][chip8-wiki] emulator written in Rust. This is my first Rust project and also my first time attempting to build any sort of emulator. Most of the instructions are implemented, but I am still having issues with the display.

# [MinDb][mindb]

A minimal SQLite-like database written in C# in order to learn more about database internals. This was a topic that I didn't have a great understanding of and figured the best way to learn it would be to attempt to recreate it. This was also my first experience parsing text using a handwritten recursive descent parser. Parsing of queries is complete, but execution is a complete work in progress.


[mbdotnet]: https://github.com/mattherman/MbDotNet
[mb]: https://www.mbtest.org
[mb-nuget]: https://www.nuget.org/packages/MbDotNet

[mhgit]: https://github.com/mattherman/mhgit
[gitlet]: http://gitlet.maryrosecook.com/
[pygit]: https://benhoyt.com/writings/pygit/

[akkawiki]: https://github.com/mattherman/akka-wiki-graph
[akkanet]: https://getakka.net/

[arduino-simon]: https://github.com/mattherman/arduino-simon
[simon]: https://en.wikipedia.org/wiki/Simon_(game)

[dotchat]: https://github.com/mattherman/DotChat

[fslisp]: https://github.com/mattherman/fslisp
[fparsec]: http://www.quanttec.com/fparsec/
[parser]: https://fsharpforfunandprofit.com/posts/understanding-parser-combinators/

[chip8]: https://github.com/mattherman/chip8
[chip8-wiki]: https://en.wikipedia.org/wiki/CHIP-8

[mindb]: https://github.com/mattherman/MinDb