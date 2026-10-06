---
layout: post
title:  "Installing Noctalia and Niri on Debian 13"
date:   2026-10-05 22:39:00 -0500
categories: [computing]
tags: [computing linux]
---

I was recently introduced to the [niri](https://github.com/niri-wm/niri) window manager by Mat Duggan's article [_Make tmux the OS_](https://matduggan.com/what-does-my-dream-os-ui-look-like/). It is a tiling window manager that scrolls horizontally while splitting workspaces vertically. It feels similar to what I'm used to with multiple workspaces on MacOS so I thought I'd give it a try on my ThinkPad.

Since niri is only the window manager, you need some sort of "shell" to put it in in order to get all the other goodies you expect like a status bar, launcher, etc. One of the recommended shells is [Noctalia](https://noctalia.dev). I liked the look of it so I went with that one.

First, I installed Noctalia using the instructions for Debian [here](https://docs.noctalia.dev/noctalia/getting-started/installation/?section=debian#debian):

* `wget https://pkg.noctalia.dev/deb/nickh-archive-keyring.deb && sudo dpkg -i nickh-archive-keyring.deb`
* `sudo wget -O /etc/apt/sources.list.d/noctalia-trixie.sources https://pkg.noctalia.dev/deb/noctalia-trixie.sources`
* `sudo apt update && sudo apt install noctalia`

Next, I installed niri, which was a little more complex since it is not yet packaged for Debian so I had to build it from source. There are instructions for [building it for development](https://niri-wm.github.io/niri/Getting-Started.html#building) in the docs which mostly worked for me.

I tried installing the development dependencies with the following command:
```
sudo apt install gcc clang libudev-dev libgbm-dev libxkbcommon-dev \
libegl1-mesa-dev libwayland-dev libinput-dev libdbus-1-dev \
libsystemd-dev libseat-dev libpipewire-0.3-dev libpango1.0-dev \
libdisplay-info-dev
```

However, I ended up getting an error about not being able to fetch `glibc`. In the hope that the build would work anyway, I continued by installing `rustup` and `cargo build --release`, but got errors about missing packages.

I was able to successfully install the packages I needed with the following command:
```
sudo apt install --no-install-recommends rustup gcc clang \
libudev-dev libgbm-dev libxkbcommon-dev libegl1-mesa-dev \
libwayland-dev libinput-dev libdbus-1-dev libsystemd-dev \
libseat-dev libpipewire-0.3-dev libpango1.0-dev libdisplay-info-dev
```

After that, `cargo build --release` built successfully.

I wanted to install it as an actual package so I ran `cargo deb` to create the package and `sudo dpkg -i target/debian/niri_26.4.0-1_amd64.deb` to install it. That initially failed because it expected `alacritty` and `fuzzel` to be installed. I tried installing those afterwards, but `apt install` gave me errors about further dependencies.

To fix that issue I uninstalled niri, installed the dependencies, and reinstalled niri:
```
sudo dpkg --remove niri
sudo apt install alacritty fuzzel
sudo dpkg -i target/debian/niri_26.4.0-1_amd64.deb
```

The last thing I needed to do was configure niri to use Noctalia. To do that I edited `~/.config/niri/config.kdl` and added the following at the bottom of the file:
```
spawn-at-startup "noctalia"
```

After that I was able to log out, choose niri, and log back in to a working install of Noctalia and niri.
