# External terminal themes

The generated presets cover **Kitty, WezTerm, Windows Terminal, Xresources,
Ghostty, Alacritty, Rio, Warp, foot and iTerm2**, plus vivid's `LS_COLORS` theme.
The expansion includes newer terminals and established alternatives; it is not a
popularity ranking or a claim to cover every terminal emulator.

All terminal presets share the default warm background (`#FAF2EB`), foreground
and ANSI slots 0–15 from `lua/deepwhite/colors.lua`. Nominal ANSI white slots are
intentionally dark so foreground text stays readable on a light background.
`low_blue_light`, `terminal_colors` and user callbacks do not rewrite these files.

The generator writes only repository extras, not your terminal configuration.
The presets contain colors, not fonts, shell commands, shortcuts or window layout.
Leave opacity at its opaque/default setting to reproduce the background faithfully.
Contrast tests cover foregrounds against the default background, not arbitrary ANSI
pairs, dim/faint text, reverse video, transparency or terminal color transformations.

## Generate and check

From the repository root, with Lua 5.1+ or LuaJIT:

```sh
lua scripts/generate_extras.lua
lua scripts/generate_extras.lua --check
```

Neovim versions supporting `-l` can run the same script without a separate Lua CLI:

```sh
nvim --headless -u NONE -i NONE -n -l scripts/generate_extras.lua --check
```

Normal mode updates only out-of-date files. `--check` is read-only, reports missing
or stale files and exits nonzero. There are no templates to install and no runtime
plugin dependencies. The script reads the pure default palette directly, without
loading Neovim configuration or executing `on_colors` / `on_highlights`.

Do not edit generated files in `extra/`. Change shared colors in the Lua palette;
change application-specific fields or vivid's category mapping in the generator.
The existing Windows Terminal cursor shade, WezTerm indexed colors 16/17 and tab
settings remain application-specific. Vivid retains its three intentional tints:
`base8=#FAF4F0`, `light_yellow=#FAFAC8`, `light_cyan=#C8FAFA`, and its own file mapping.

## Existing tools

| Tool | Generated file | Installation |
| --- | --- | --- |
| Kitty | `deepwhite_kitty.conf` | Add `include /absolute/path/to/deepwhite_kitty.conf` to your Kitty config |
| WezTerm | `deepwhite_wezterm.toml` | Put it in a color-scheme directory and select `color_scheme = 'deepwhite'` |
| Windows Terminal | `deepwhite_windows_terminal.json` | Add the object to the `schemes` array, then select `deepwhite` for a profile; do not replace the entire settings file |
| Xresources | `deepwhite_xresources.Xresources` | Merge it into your Xresources, e.g. `xrdb -merge /absolute/path/to/deepwhite_xresources.Xresources` |
| vivid | `vivid_themes_deepwhite.yml` | Use `vivid generate /absolute/path/to/vivid_themes_deepwhite.yml` to generate `LS_COLORS` |

## Ghostty

Copy `extra/deepwhite_ghostty.conf` to
`${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/themes/deepwhite` (create `themes/` if
needed), then set this in your Ghostty configuration:

```ini
theme = deepwhite
```

Current Ghostty uses `config.ghostty`; existing `config` files are also supported.
On macOS, the Application Support configuration location is supported as well.
Alternatively, `theme` accepts the absolute path to the generated file without
copying it. Reload Ghostty's configuration after changing the theme. Options in
your main configuration can override theme colors.

Sources: [official custom-theme guide](https://ghostty.org/docs/features/theme),
[configuration locations and reload behavior](https://ghostty.org/docs/config).

## Alacritty

Copy `extra/deepwhite_alacritty.toml` somewhere convenient, e.g.
`~/.config/alacritty/themes/deepwhite.toml`. Merge its path into the existing import
array in your `alacritty.toml`:

```toml
[general]
import = ["~/.config/alacritty/themes/deepwhite.toml"]
```

Keep your other imports; settings in the main config override imported values.
This targets the current TOML format, not the legacy YAML configuration. Windows
normally uses `%APPDATA%\alacritty\alacritty.toml`; use a path valid on your system.

Source: [official configuration reference](https://alacritty.org/config-alacritty.html).

## Rio

Copy `extra/deepwhite_rio.toml` to `themes/deepwhite.toml` inside your Rio configuration
directory. Then set this at the **top level** of Rio's `config.toml`:

```toml
theme = "deepwhite"
```

Default configuration directories are `~/.config/rio` on macOS,
`${XDG_CONFIG_HOME:-$HOME/.config}/rio` on Linux, and
`%USERPROFILE%\AppData\Local\rio` on Windows. `RIO_CONFIG_HOME` overrides the directory.
If you keep the generated filename instead, select `theme = "deepwhite_rio"`.

The theme uses Rio's flat `[colors]` table, `light-*` bright colors and current
`tabs` / `tabs-active` navigation fields. To use the theme's selected-text color,
leave `ignore-selection-foreground-color` disabled in the main config. Main-config
`[colors]` entries do not replace colors supplied by an active Rio theme.

Sources: [official color fields](https://rioterm.com/docs/default-colors),
[official configuration/loader implementation](https://github.com/raphamorim/rio/blob/main/rio-backend/src/config/mod.rs).

## Warp

Copy `extra/deepwhite_warp.yaml` into your platform's custom-theme directory:

| Platform | Directory |
| --- | --- |
| macOS | `~/.warp/themes/` |
| Linux | `${XDG_DATA_HOME:-$HOME/.local/share}/warp-terminal/themes/` |
| Windows | `%APPDATA%\warp\Warp\data\themes\` |

Choose **DeepWhite** in **Settings → Appearance → Themes**, or use **Open Theme
Picker**. The preset declares `details: lighter` and includes all normal/bright
ANSI colors. It does not set a background image or window opacity.

**Warp's documented custom-theme format has no separate selection foreground or
background fields.** Its accent color is not an exact substitute for the shared
selection gray, so no unsupported selection keys are emitted.

Source: [official custom-theme specification and installation](https://docs.warp.dev/terminal/appearance/custom-themes/).

## foot

This preset targets **foot 1.26+** and uses `[colors-light]`. Copy
`extra/deepwhite_foot.ini` to a path such as `~/.config/foot/themes/deepwhite.ini`.
Merge these settings into the `[main]` section of your `foot.ini`:

```ini
[main]
include=~/.config/foot/themes/deepwhite.ini
initial-color-theme=light
```

Do not replace unrelated main settings or includes. foot requires an absolute
include path or one beginning with `~/`. The file uses prefixless RGB values;
its `cursor` pair is text color followed by cursor background.

Do not rename the section to `[colors]`: foot 1.28 removed that deprecated name.
The preset leaves the dark slot and theme-switching shortcuts under your control.

Sources: [official foot.ini manual](https://codeberg.org/dnkl/foot/src/branch/master/doc/foot.ini.5.scd),
[1.28 release notes](https://codeberg.org/dnkl/foot/releases/tag/1.28.0).

## iTerm2

Import `extra/deepwhite.itermcolors` through **Settings → Profiles → Colors → Color
Presets… → Import…**, then select **deepwhite** for the intended profile. No fixed
installation directory is required. If separate light/dark colors are enabled,
apply it to the intended light slot.

The XML plist specifies sRGB color space, opaque alpha, cursor text and selection
colors. Enable **Use custom color for selected text** to use the exported selected
foreground. Context-aware cursor color and Minimum Contrast can transform the
exported values; leave those transformations disabled when comparing exact colors.
Window transparency is a separate setting, not controlled by color alpha.

Sources: [official preset import and color settings](https://iterm2.com/documentation-preferences-profiles-colors.html),
[official preset/color structure](https://github.com/gnachman/iTerm2/blob/master/plists/ColorPresets.plist).

## Validation boundary

Core regressions compare every generated file with fresh output from the Lua
palette, and test missing/stale-file detection and read-only check mode on both
supported core test versions. Serialized formats are also parsed independently:

```sh
# Python 3.11+; PyYAML is a development-only dependency (verified with 6.0.1).
python3 -m pip install PyYAML==6.0.1
python3 tests/extras_formats.py
```

JSON, TOML, plist and INI use Python's standard parsers; YAML uses PyYAML. Tests
check ANSI slot semantics, cursor/selection ordering, supported field names and
foreground contrast. Original extras retained their parsed settings when moved to
generation. These checks are **not** a claim that each terminal's application
binary, GUI, fonts, renderer or all historical configuration versions were tested.
