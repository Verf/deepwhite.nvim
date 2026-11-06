<p align="center">
  <h2 align="center">DeepWhite</h2>
</p>

![screenshot](screenshot/screenshot1.png)

## About

DeepWhite is a light colorscheme inspired by [flatwhite-syntax](https://github.com/biletskyy/flatwhite-syntax) and [elegant-emacs](https://github.com/rougier/elegant-emacs).

## Requirements

- Neovim 0.7 or newer and a truecolor terminal. The existing minimum version is unchanged;
  this update was tested on Neovim 0.12.6, not the full historical version range.
- A terminal with undercurl support is recommended for diagnostic underlines.

## Installation

With lazy.nvim, configure the theme **before** loading it:

```lua
{
    'Verf/deepwhite.nvim',
    lazy = false,
    priority = 1000,
    opts = {
        low_blue_light = false,
        terminal_colors = false,
    },
    config = function(_, opts)
        require('deepwhite').setup(opts)
        vim.cmd [[colorscheme deepwhite]]
    end,
}
```

With packer.nvim:

```lua
use {
    'Verf/deepwhite.nvim',
    config = function()
        require('deepwhite').setup({ low_blue_light = false })
        vim.cmd [[colorscheme deepwhite]]
    end,
}
```

No `setup()` call is needed if you want the defaults: `:colorscheme deepwhite` is enough.

## Configuration

Defaults (use this directly if you do not configure the theme through your plugin manager):

```lua
require('deepwhite').setup({
    low_blue_light = false,
    terminal_colors = false,
    on_colors = function(colors) end,
    on_highlights = function(groups, colors) end,
})
vim.cmd [[colorscheme deepwhite]]
```

- `low_blue_light`: use a neutral/cooler `#FAFAFA` background instead of the warm `#FAF2EB`.
  This compensates for an **external** warm filter such as f.lux; it does not reduce blue light itself
  or provide a medical eye-care guarantee.
- `terminal_colors`: opt in to setting `vim.g.terminal_color_0` through `vim.g.terminal_color_15`.
  The default is **false**, which leaves all existing values untouched. Disabling it later does not
  restore or clear previously set values. Enable it before opening terminal buffers; existing ones
  may need to be reopened. ANSI white slots deliberately use dark foregrounds for readability on light backgrounds.
  This controls terminals inside Neovim only; the files in `extra/` have not been regenerated.
- `on_colors(colors)`: mutate a fresh palette after the background option is applied, before groups
  and terminal colors are generated. Original `base*`, `light_*` and `bright_*` colors remain available.
- `on_highlights(groups, colors)`: mutate or replace group definitions before they are applied.
  Use the same attributes as `nvim_set_hl`. Both hooks mutate their arguments; return values are ignored.

`setup()` incrementally updates the previous options; omitted options, including callbacks, are retained.
Calling `setup()` or `setup({})` alone does not reload the theme. Apply changes with
`:colorscheme deepwhite`. To remove a previous callback, replace it with an empty function.
Boolean options require booleans and hooks require functions; invalid types report an error without updating options.

### Color and highlight overrides

The warm paper and pastel syntax backgrounds are preserved. These foreground roles are designed for
information that must remain readable on either background:

| Palette key | Default | Main use |
| --- | --- | --- |
| `comment` | `#66635D` | Comments, inlay hints, line numbers |
| `warning` | `#A64B00` | Warnings, orange information accents |
| `hint` | `#006E73` | Diagnostic hints, cyan information accents |
| `success` | `#216F21` | OK diagnostics, green information accents |
| `yellow_fg` | `#806000` | Yellow brackets and icons, ANSI yellow |
| `git_add` | `#216F21` | GitSigns and MiniDiff added signs |
| `git_change` | `#A64B00` | GitSigns and MiniDiff changed signs |
| `git_delete` | `#A60000` | GitSigns and MiniDiff deleted signs |

`git_*` roles are initialized before `on_colors` runs. They are independent values, not live aliases:
if a callback changes `warning` and should also affect Git changes, set `git_change` explicitly.
Likewise, change `comment` rather than `base3` to customize the comment foreground.

```lua
require('deepwhite').setup({
    on_colors = function(colors)
        colors.comment = '#595855'
        colors.warning = '#884400'
        colors.git_change = colors.warning
    end,
    on_highlights = function(groups, colors)
        groups.Comment.italic = true
        -- Replace a linked group instead of adding attributes alongside its link.
        groups.DiagnosticWarn = { fg = colors.warning, bold = true }
    end,
})
vim.cmd [[colorscheme deepwhite]]
```

A `link` takes precedence over other attributes, following Neovim's native semantics.
For example, use `groups.Comment = { link = 'Type' }` to link a group, or replace a linked group
with `{ fg = '#123456' }` to give it its own color. Hooks run on each theme load; lualine's theme
module also evaluates `on_colors` when imported. Keep callbacks focused on modifying their arguments.
Callback errors include the hook name and traceback and occur before the active highlights are cleared.

The default informative foregrounds target a contrast ratio of at least 4.5:1; critical Git signs target
at least 3:1. Tests cover both normal backgrounds, the MiniDiff change overlay, and comments on CursorLine.
Decorative whitespace is intentionally subtle. These are design targets, not a blanket accessibility
certification for all plugins, terminal filters or user overrides.

### mini.nvim navigation

DeepWhite styles mini.pick and mini.files without loading or configuring them. Set up the modules
in your own configuration as usual; no extra theme option is needed.

| Element | Appearance |
| --- | --- |
| Current picker item / file explorer row | Soft gray background and bold text |
| Marked picker items | Existing pale orange background plus underline |
| Query matches | Deep teal and bold, including on current or marked items |
| Picker preview region | Pale cyan background, dark text, bold and underline |
| Directories | Deep teal and bold; fallback directory icons use the same style |
| Ordinary files | Normal readable foreground |
| Inactive titles / picker border information | Muted but readable foreground |
| Focused file explorer title | Dark and bold |
| File explorer with pending edits | Warning-colored border, distinct from ordinary navigation |

Row highlights leave the foreground unset, preserving query matches and file icon colors.
When an item is both current and marked, bold text and underline distinguish it from other marked items.
Icons supplied by mini.icons keep their own category colors.

This does not replace MiniPick's `source.show`: its default renderer does not expose separate highlight
ranges for the directory prefix and basename of a path. Path segmentation, custom truncation, mappings,
window sizes and file operations remain under your mini.nvim configuration's control.

### Statusline and tabline

```lua
require('lualine').setup({
    options = { theme = 'deepwhite' },
})
require('barbar').setup({
    icons = { filetype = { custom_colors = true } },
})
```

The lualine theme no longer changes `fillchars`. If you want the previous horizontal-line decoration,
opt in yourself:

```lua
vim.opt_global.fillchars:append { stl = '─', stlnc = '─' }
vim.opt_local.fillchars:append { stl = '─', stlnc = '─' }
```

The screenshots illustrate the layout; they predate the readable-foreground adjustments above.

- lualine theme

![screenshot](screenshot/lualine.png)

- barbar theme

![screenshot](screenshot/barbar.png)

## Tests

From the repository root, using a recent Neovim (verified on 0.12.6):

```sh
nvim --headless -u NONE -i NONE -n -l tests/run.lua
```

No test framework or plugin installation is needed. The runner checks theme loading, resolved highlights,
configuration and hook behavior, lualine option isolation, Windows Terminal color slots, and contrast ratios.
A failure exits with a nonzero status. To run an affected test in isolation:

```sh
DEEPWHITE_TEST='lualine preserves' nvim --headless -u NONE -i NONE -n -l tests/run.lua
```

An optional integration test uses **real mini.pick and mini.files modules** in an embedded Neovim
with an attached UI. Point it at your mini.nvim runtime directory (no automatic downloads):

```sh
DEEPWHITE_MINI=/path/to/mini.nvim nvim --headless -u NONE -i NONE -n -l tests/mini.lua
```

It checks composed screen styles for current/marked/matching items, a preview region, directory columns
and a pending-edit border on both backgrounds, plus module/theme load order. It creates temporary
fixtures, never synchronizes file operations, and does not read your Neovim configuration.
Validated with Neovim 0.12.6 and mini.nvim commit
[`a321b535c75c`](https://github.com/nvim-mini/mini.nvim/tree/a321b535c75ca88ba7fddfd8eb5b583fbda50dd6).
These checks do not certify the rendering of your terminal's fonts or Nerd Font icons; the UI test uses
ASCII file prefixes to avoid requiring a particular font.

See [the audit and optimization plan](docs/AUDIT.md) for the original findings and remaining work.

## Q & A

#### Which statusline and tabline are you using?

Now: [mini.statusline](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-statusline.md) and [mini.tabline](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-tabline.md)

Previous:

<details>
<summary>customizd heirline</summary>
    
```lua
{
    'rebelot/heirline.nvim',
    opts = function(_, opts)
        vim.opt.fillchars:append { eob = ' ', stl = '─', stlnc = '─' }
        local conditions = require 'heirline.conditions'
        local utils = require 'heirline.utils'
        local Align = { provider = '%=', hl = 'Normal' }
        local Space = { provider = '───', hl = 'Normal' }
        local Git = {
            condition = conditions.is_git_repo,
            init = function(self)
                self.status_dict = vim.b.gitsigns_status_dict
                self.has_changes = self.status_dict.added ~= 0
                    or self.status_dict.removed ~= 0
                    or self.status_dict.changed ~= 0
            end,
            hl = 'Normal',
            Space,
            { -- git branch name
                provider = function(self)
                    return '  ' .. self.status_dict.head
                end,
                hl = { bold = true },
            },
            {
                provider = function(self)
                    local count = self.status_dict.added or 0
                    return count > 0 and (' +' .. count)
                end,
            },
            {
                provider = function(self)
                    local count = self.status_dict.removed or 0
                    return count > 0 and (' -' .. count)
                end,
            },
            {
                provider = function(self)
                    local count = self.status_dict.changed or 0
                    return count > 0 and (' ~' .. count)
                end,
            },
            {
                condition = function(self)
                    return self.has_changes
                end,
                provider = ' ',
            },
        }
        local FileFormat = {
            provider = function()
                local enc = (vim.bo.fenc ~= '' and vim.bo.fenc) or vim.o.enc
                local fmt = vim.bo.fileformat
                return ' ' .. enc .. '[' .. fmt .. '] '
            end,
            hl = 'Normal',
        }
        local Ruler = {
            provider = ' %l/%L | %c/%-2{virtcol("$") - 1} ',
            hl = 'Normal',
        }
        -- statusline
        local DefaultStatusline = {
            Git,
            Align,
            FileFormat,
            Ruler,
            Space,
        }
        local InactiveStatusline = {
            condition = conditions.is_not_active,
            Align,
        }
        local SpecialStatusline = {
            condition = function()
                return conditions.buffer_matches {
                    buftype = { 'nofile', 'prompt', 'help', 'quickfix' },
                    filetype = { '^git.*', 'fugitive' },
                }
            end,
            Align,
        }
        opts.statusline = {
            fallthrough = false,
            SpecialStatusline,
            InactiveStatusline,
            DefaultStatusline,
        }
        -- tabline
        local TablineFileName = {
            provider = function(self)
                local filename = self.filename
                filename = filename == '' and '[No Name]' or vim.fn.fnamemodify(filename, ':t')
                return filename
            end,
        }
        local TablineFileNameBlock = {
            init = function(self)
                self.filename = vim.api.nvim_buf_get_name(self.bufnr)
            end,
            hl = function(self)
                if self.is_active then
                    return 'TabLineSel'
                else
                    return 'TabLine'
                end
            end,
            { provider = ' ' },
            TablineFileName,
            { provider = ' ' },
        }
        local BufferLine = utils.make_buflist(TablineFileNameBlock)
        local Tabpage = {
            provider = function(self)
                return '%' .. self.tabnr .. 'T ' .. self.tabpage .. ' %T'
            end,
            hl = function(self)
                if not self.is_active then
                    return 'TabLineSel'
                else
                    return 'TabLine'
                end
            end,
        }
        local TabPages = {
            condition = function()
                return #vim.api.nvim_list_tabpages() >= 2
            end,
            utils.make_tablist(Tabpage),
        }
        opts.tabline = { BufferLine, Align, TabPages }
    end,
}
</details>
