# External terminal themes

The generated presets cover **Kitty, WezTerm, Windows Terminal, Xresources,
Ghostty, Alacritty, Rio, Warp, foot and iTerm2**, plus vivid's `LS_COLORS` theme.
The expansion includes newer terminals and established alternatives; it is not a
popularity ranking or a claim to cover every terminal emulator.

All terminal presets share the default warm background (`#FAF2EB`), foreground
and ANSI slots 0–15 from `lua/deepwhite/colors.lua`. The editor can pair dark text
with pastel background accents; a terminal preset cannot assign such pairs to
each kind of application output. Its foreground palette is therefore designed
independently for text on one background, sharing DeepWhite's character rather
than exact editor hues, saturation or RGB values.

Moderated saturation replaces near-pure RGB foregrounds. Amber yellow, blue-cyan,
and a magenta shifted away from blue distinguish the ANSI roles. All 16 slots
are distinct, and each bright variant is lighter than its normal counterpart.
The six chromatic pairs differ by at least 6 CIE L* points (perceptual lightness
on a 0–100 scale). Hue and saturation can also change between normal and bright;
not every bright color is pushed to the same contrast boundary. Editor highlights
stay unchanged. Nominal ANSI white slots use neutral grays (`#454545` / `#505050`);
bright black uses `#4C4C4C`, with no brown tint.

On both warm and neutral backgrounds, default body text and neutral ANSI slots
0/7/8/15 retain at least 7:1 contrast. Chromatic slots target at least 4.5:1.
This user-approved role-based balance replaces the previous uniform 7:1 target
so colors can be brighter without weakening body-text readability.
Color checks preserve broad ANSI hue roles and HSV saturation between 35% and
90%, rather than the former editor-relative hue/saturation limits. Different
chromatic roles have Delta E 76 >= 25 separation, including mixed normal/bright
usage. These are regression guards, not visual-style or color-vision certification
or a requirement for equal brightness. Warm paper and dark body text remain.
`low_blue_light`, `terminal_colors` and user callbacks do not rewrite these files.
Applications supplying their own RGB truecolors do not follow ANSI palette changes.

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
The Windows Terminal cursor shade, terminal tabs, borders and selection settings
are retained. WezTerm indexed color 16 and Warp's accent follow normal terminal
blue; WezTerm indexed color 17 remains the background. Kitty URLs use normal green.
Vivid uses normal terminal colors for directories, executables and links.
Sockets/doors use pink (`#9D4479` from `terminal_pink`), and devices/FIFOs use
orange (`#98521B` from `terminal_warning`). The categories remain, with adapted
foregrounds rather than original editor values or shared ANSI purple/yellow. Vivid targets 7:1 for body text and 4.5:1 for colored
text/styles (including light text on the setuid red background). Its category
mapping and three intentional tints remain: `base8=#FAF4F0`, `light_yellow=#FAFAC8`,
`light_cyan=#C8FAFA`.

## Compare in your terminal

After loading/reloading the generated preset, run this small scene with Python 3.
It uses ANSI slots (not explicit RGB or bold), so it exercises the active terminal
palette. Compare normal/bright text at your usual font size, especially green/cyan
and blue/magenta. Keep the same terminal, font, size and opacity between versions;
record those versions/settings when reporting visual feedback.

```sh
python3 - <<'PY'
names = 'black red green yellow blue magenta cyan white'.split()
for label, start in [('normal', 30), ('bright', 90)]:
    print(label + ':')
    for i, name in enumerate(names):
        print(f'\x1b[{start + i}m  {name:7}  AaBb 012345  []{{}} /path/to/file\x1b[0m')
print('\x1b[32mPASS\x1b[0m build  \x1b[33mWARN\x1b[0m retry  '
      '\x1b[31mFAIL\x1b[0m tests  \x1b[36mINFO\x1b[0m connected')
print('\x1b[34msrc/\x1b[0m  \x1b[35mpackage\x1b[0m  '
      '\x1b[36mlink -> target\x1b[0m  \x1b[32mrun.sh\x1b[0m')
PY
```

The scene does not modify your configuration. Numeric checks and this scene are
not a substitute for checking actual application output with your font/renderer.

## Existing tools

| Tool | Generated file | Installation |
| --- | --- | --- |
| Kitty | `deepwhite_kitty.conf` | Add `include /absolute/path/to/deepwhite_kitty.conf` to your Kitty config |
| WezTerm | `deepwhite_wezterm.toml` | Put it in a color-scheme directory and select `color_scheme = 'deepwhite'` |
| Windows Terminal | `deepwhite_windows_terminal.json` | Add the scheme or replace the existing `deepwhite` entry; see the steps below |
| Xresources | `deepwhite_xresources.Xresources` | Merge it into your Xresources, e.g. `xrdb -merge /absolute/path/to/deepwhite_xresources.Xresources` |
| vivid | `vivid_themes_deepwhite.yml` | Use `vivid generate /absolute/path/to/vivid_themes_deepwhite.yml` to generate `LS_COLORS` |

### Windows Terminal

Open **Settings → Open JSON file** and locate the `schemes` array. On a fresh installation,
add the object from `extra/deepwhite_windows_terminal.json` and select `deepwhite` for the profile.

When upgrading, replace the object whose `name` is `deepwhite` instead of appending a duplicate.
Windows Terminal can keep the first object with a given name, so appending the new preset may leave
an older one in use. Keep the profile's `colorScheme` reference (including a light/dark pair if you
use one), your other schemes, and the rest of `settings.json` intact. If you customized the scheme
itself, carry those overrides into the replacement. Explicit profile colors can still override the scheme.

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
