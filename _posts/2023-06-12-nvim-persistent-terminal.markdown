---
layout: post
title:  "Creating a Persistent Terminal in Neovim"
date:   2023-06-12 19:40:00 -0500
categories: [programming]
tags: [programming neovim]
---

I've dabbled with using Vim as an editor off and on over the years and it still hasn't quite stuck. Mostly I have just switched to using Vim keybindings in other editors (such as VS Code and JetBrains Rider) since I like how ergonomic and quick they are.

A while back I became familiar with [Neovim](https://neovim.io) and was intrigued by the Lua API it exposes for configuration and plugins. Vimscript always seemed...strange, so it was refreshing to see it use a more popular, general-purpose programming language like Lua. I am once again attempting to learn to use (Neo)Vim and this time I tried my hand at some scripting in Lua.

While learning Lua (by doing the excellent exercises over at [Exercism](https://exercism.org)) I would often want to switch between my editor and another shell to run unit tests or test something in the REPL. I could do that using something like tmux or just separate tabs in my terminal emulator, but I wanted to be able to run the commands without leaving Neovim.

It turns out that Neovim provides the [`:terminal`](https://neovim.io/doc/user/nvim_terminal_emulator.html#terminal-emulator) command which will start your default shell in a new buffer. I quickly created a keymap to run the command, but was disappointed by the workflow. To close the terminal I was running `exit` to exit my shell and then hitting enter to automatically close the buffer.

This quickly became annoying so I checked the docs and saw that I could return to normal mode with `<C-\><C-n>` and then hit `<C-o>` to return to my previous buffer. This worked fine (although desperately needed its own keymap), but whenever I would return to my terminal it would create a brand new shell and buffer instead of reusing the old one.

The terminal is a buffer like any other and will show up if you run `:ls`, but switching between buffers in that way is still slow for me so I wanted to try scripting my solution:
```
function toggle_terminal()
    for i, buffer in ipairs(vim.api.nvim_list_bufs()) do
        local buffer_name = vim.api.nvim_buf_get_name(buffer)
        if (string.sub(buffer_name, 1, 7) == "term://") then
            vim.api.nvim_win_set_buf(0, buffer)
            return
        end
    end
    vim.api.nvim_command(":terminal")
end
```

The function grabs the list of all buffers and looks for the first name that starts with `term://` (the default naming scheme for terminal buffers) and sets the current window to that buffer if it finds one. Otherwise, it runs the `:terminal` command to open a new one. I tried to figure out how to use the `nvim_term_open` function instead of the command, but I couldn't get it to work.

This worked great! The first time I run it Neovim will spin up a new terminal, but after that it will simply switch back to the original terminal with all of my output and history.

So far I've been enjoying Neovim, especially with all of the really nice plugins people have created for it. I have found [telescope](https://github.com/nvim-telescope/telescope.nvim) and [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua) to be really useful. The fact that LSP support is built-in rather than provided by plugins is also nice. The API documentation, which is available online and with the `:help` command, is very detailed, but the thing I've been missing the most has been examples of how to do certain tasks like creating a terminal with `nvim_term_open`. I could dig through the source of other plugins to figure it out, but most are complex enough that finding the specific use case I need is difficult. Overall, it feels like (Neo)Vim is "sticking" a little bit more for me now and may actually become an editor that I use regularly.
