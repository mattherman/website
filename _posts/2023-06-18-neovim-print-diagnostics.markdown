---
layout: post
title:  "Printing Diagnostics in Neovim"
date:   2023-06-18 21:44:00 -0500
categories: [programming]
tags: [programming neovim lua]
---

I'm starting to understand what is so great about the extensibility of (Neo)Vim.

The language server support built into Neovim will display diagnostic messages (errors, warnings, etc.) as a hovering tooltip to the right of the line where they occur. This is normally perfectly fine, but if you have a long line or message it will result in the message being cut off.

![diagnostic messages displayed inline](/assets/neovim-print-diagnostics/diagnostics_before.png)

I wasn't able to figure out how to view the message when that happens. It doesn't seem to let you scroll to the right. There is probably some way to see them or to force them to be displayed elsewhere (for example, below the line), but I decided to use it as an opportunity to work with the Neovim API again.

We can retrieve the diagnostics for the current buffer using `vim.diagnostic.get(0)` and display them to the user with `vim.notify(...)`. First we'll handle the case where there are no diagnostics:

```
local diagnostics = vim.diagnostic.get(0)
if (not diagnostics or #diagnostics == 0) then
    vim.notify("No issues found", vim.log.levels.INFO)
    return
end
```

The log level passed to `vim.notify` affects how Neovim displays the message.

If there are diagnostics, we want to display them. I'm not sure how the order of the diagnostics table is determined, but we probably want to show them in line number order:

```
local function by_line_num (a, b)
    return a.lnum < b.lnum
end
...
table.sort(diagnostics, by_line_num)
```

Finally we build up a table of formatted messages, concatenate them, and display them as an error with `vim.notify`:
```
local messages = { "" }
local sev_text = {
    [vim.diagnostic.severity.ERROR] = "Error",
    [vim.diagnostic.severity.WARN] = "Warning"
}
for _, d in ipairs(diagnostics) do
    local sev = sev_text[d.severity] or "Info"
    table.insert(messages, sev..": "..d.message.." ["..d.lnum..":"..d.col.."]")
end
vim.notify(table.concat(messages, "\n"), vim.log.levels.ERROR)
```

The full function looks like this:
```
local function print_diagnostics()
    local function by_line_num (a, b)
        return a.lnum < b.lnum
    end

    local diagnostics = vim.diagnostic.get(0)
    if (not diagnostics or #diagnostics == 0) then
        vim.notify("No issues found", vim.log.levels.INFO)
        return
    end

    table.sort(diagnostics, by_line_num)
    local messages = { "" }
    local sev_text = {
        [vim.diagnostic.severity.ERROR] = "Error",
        [vim.diagnostic.severity.WARN] = "Warning"
    }
    for _, d in ipairs(diagnostics) do
        local sev = sev_text[d.severity] or "Info"
        table.insert(messages, sev..": "..d.message.." ["..d.lnum..":"..d.col.."]")
    end
    vim.notify(table.concat(messages, "\n"), vim.log.levels.ERROR)
end
```

Using that function we can view all diagnostic messages for a buffer at the same time.

![diagnostic messages displayed with vim.notify](/assets/neovim-print-diagnostics/diagnostics_after.png)

It is incredibly powerful to be able to interact with your editor programatically. I think there is some risk that it becomes an infinite number of yaks to shave, but so far I've enjoyed using the Neovim API for tasks like this.
