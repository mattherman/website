---
layout: post
title:  "Running Local Models with Ollama and OpenCode"
date:   2026-10-04 11:10:00 -0500
categories: [programming]
tags: [programming ai llms]
---

# Introduction 

In general, I'm not interested in using coding agents for programming in my free time. I already use them every day at my job and I miss the craft of writing code by hand so I try to avoid AI when I'm off the clock. However, I am also curious about local LLMs. If LLMs and AI agents are going to be our future, I'd prefer to see that future be untethered from the AI labs and mandatory subscriptions. I don't think it is reliable or frugal to rely on a third-party API for something that is becoming so ubiquitous.

The goals of this exploration were to get an open model running locally on my laptop with decent enough performance that I could use it with the [OpenCode](https://opencode.ai) agent harness. I have a Lenovo ThinkPad with an AMD Ryzen processor, 64 GB of RAM, and an integrated GPU. It also has a Neural Processing Unit (NPU), but I don't think it works with my Debian setup currently, so the models would likely run entirely on the CPU. For agentic coding, that means I need a model that will fit in memory and be "smart" enough to handle tool calls well. Speed is important, but I am willing to wait a bit longer if the agent is completing the task autonomously. Secondary goals were to be able to run a model for general chat and access it from my phone for privacy and independence from the major providers. For that use case, speed is much more important since it would involve multi-turn conversations with the agent. Tool calls are also less important.

# Finding the right model

To run local models, the standard choice seems to be [Ollama](https://ollama.com). I installed Ollama and had it install OpenCode for me. This gave me a default list of models to choose from and the only local option was some Gemma 4 model. I chose that and waited for it to download - it was around 19 GB. Once that was finished and running in OpenCode I sent some simple prompts. It was very slow. Too slow. Even little things like "Tell me a joke" were taking >15 seconds to respond. I would need to play around with a few different models before I found a good fit for my hardware. I also realized that Ollama had installed an old 1.x version of OpenCode so I uninstalled that version and installed the latest 2.x.

The next model I tried was `qwen2.5-coder:7b` at the suggestion of Gemini. This one was much smaller. Testing out chat with `ollama run ...` gave me very quick responses, but when I tried using it in OpenCode I ran into issues. It seemed like I was receiving raw tool call output back without the agent being able to execute the tools. Reading the OpenCode docs it seems like they suggest a context window of at least 64k. By default, Ollama runs a model with only 4k of context. Worse, the model I was using seemed to be limited to a 32k context window. Apparently, it could be extended through some other methods, but if I relied on the default model in Ollama it was stuck. I also read that the `7b` model had relatively poor tool call ability to begin with which was not helping. I tried upgrading to the `14b` version but that had the same 32k limit. During this time, I tried various suggestions from Gemini to override the context window in both Ollama and OpenCode before realizing that the model was the inherent limit.

A little more Gemini-assisted research resulted in a suggestion to try the `qwen3` family instead. They jhad larger context available and were hopefully stronger at agentic coding. I went a bit bigger this time with `qwen3-coder:30b`. I was skeptical since the Gemma `19b` model I had tried earlier was so slow, but apparently something about the Qwen model made it so the larger number of weights had less impact on speed. After downloading another couple dozen GB of model weights, I finally got tool calls to work successfully in OpenCode. I pinned context to 64k in my `opencode.jsonc` configuration file to control resource usage. The model required around 28 GB of memory to load which meant about half of my laptop's memory is in-use whenever I run the model. It was still much slower than what I'm used to with a frontier model in Claude Code, but for something running entirly on my hardware it seemed usable.

For general chat, I also installed the `qwen3:14b` model. It is about half the size so it is much faster and decently intelligent. With both models running at the same time, a large portion of my available memory is used up. Thankfully, Ollama will tear down a model after a few minutes if it isn't in use so I would likely only run a single model at most times.

# Exposing Ollama to other devices

Ollama runs an OpenAI-compatible API on your computer that all sorts of tools can interact with over HTTP. Exposing this outside of my laptop would allow me to access the models remotely. I already use [Tailscale](https://tailscale.com) to be able to SSH to connect privately between my devices and servers so it seemed like a natural fit. To make that work, I needed to configure Ollama to listen on my laptop's tailscale IP address.

Since Ollama runs as a `systemd` service on my laptop, I had to edit the service definition with `systemctl edit ollama.service` and add the following configuration block:

```ini
[Service]
Environment="OLLAMA_HOST=<tailscale_ip_addr>:11434"
```

To apply the changes, `systemctl daemon-reload` and `systemctl restart ollama.service`.

After doing so, I realized that OpenCode could no longer find my model and running `ollama` commands also seemed to have lost it. A quick search showed that I would have to tell each of those to find it on the new host as well. This was a little annoying and I could have hosted it on `0.0.0.0:11434` to avoid it, but that meant it would be accessible to any device on my network which I was trying to avoid. To fix this issue I updated my `opencode.jsonc` to point to the new host:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "ollama/qwen3-coder:30b",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama",
      "options": {
        "baseURL": "http://<tailscale_ip_addr>:11434/v1"
      }
    }
  }
}

```

That change allowed OpenCode to find my Ollama service and models. A similar update to my `config.fish` to `set -gx OLLAMA_HOST "<tailscale_ip_addr>:11434"` fixed the issue with the `ollama` CLI as well.

# Mobile chat with Off Grid

After investigating a few options for Ollama-compatible chat clients on Android, I landed on [Off Grid AI](https://getoffgridai.co/). It had a clean interface and easy configuration. Normally, it would find Ollama running on your network automatically, but because I was hosting it on my Tailnet, I had to manually configure it.

After it detected my available models, I had it default to `qwen3:14b` and started chatting. The experience was a little frustrating. When it worked, the conversation felt similar to any other one with Gemini or Claude, albeit slower. However, a lot of chats resulted in errors. I think most of that came down to bad tool calls. When I asked a question like "what is the weather like tomorrow in Milwaukee?" it would show that it tried to use various web search tools and then fail. Eventually it gave up and posted some links I could follow to check the weather, but failed to fetch them itself.

# Conclusion

Overall, the setup was pretty straightforward. The majority of my trouble was around finding a model that ran well on my device and getting past the confusion over context windows. I think where I landed would be good enough for some simpler agentic coding, but I'll have to try it on some real tasks before I'm able to say for sure. The amount of memory used by the models makes it a little prohibitive to do other resource-intensive work on my laptop at the same time. I also plan to continue trying to use chat through Off Grid and see if I can get it to behave more reliably. A larger model may be necessary to avoid tool calling errors.
