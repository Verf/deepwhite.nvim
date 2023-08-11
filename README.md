<p align="center">
  <h2 align="center">DeepWhite</h2>
</p>

![screenshot](screenshot/screenshot1.png)

## About

DeepWhite is a light colorscheme inspired by [flatwhite-syntax](https://github.com/biletskyy/flatwhite-syntax) and [elegant-emacs](https://github.com/rougier/elegant-emacs).

## Installation

```lua
-- for packer.nvim
use {
    'Verf/deepwhite.nvim',
    config = function()
        vim.cmd [[colorscheme deepwhite]]
    end,
}

-- for lazy.nvim
{
    'Verf/deepwhite.nvim',
    lazy = false,
    priority = 1000,
    config = function()
        vim.cmd [[colorscheme deepwhite]]
    end,
}
```
