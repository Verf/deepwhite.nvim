"""Parse checked-in extras and validate their documented color-only layouts.

Run: python3 tests/extras_formats.py (Python 3.11+ and PyYAML required).
These are serialized-format checks, not terminal application/GUI certification.
"""
import configparser
import json
import math
from pathlib import Path
import plistlib
import re
import tomllib
import unittest

import yaml

EXTRA = Path(__file__).resolve().parents[1] / "extra"
NAMES = "black red green yellow blue magenta cyan white".split()


def hex_color(value):
    if not isinstance(value, str) or not re.fullmatch(r"#[0-9a-fA-F]{6}", value):
        raise ValueError(f"Expected #RRGGBB, got {value!r}")
    return value.upper()


def contrast(foreground, background):
    def luminance(color):
        rgb = [int(hex_color(color)[i:i + 2], 16) / 255 for i in (1, 3, 5)]
        rgb = [v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4 for v in rgb]
        return sum(v * weight for v, weight in zip(rgb, (0.2126, 0.7152, 0.0722)))
    a, b = sorted((luminance(foreground), luminance(background)))
    return (b + 0.05) / (a + 0.05)


def toml(name):
    with (EXTRA / name).open("rb") as source:
        return tomllib.load(source)


def simple_lines(name):
    return [line.strip() for line in (EXTRA / name).read_text().splitlines()
            if line.strip() and not line.lstrip().startswith(("#", "!"))]


class ExtrasFormats(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.windows = json.loads((EXTRA / "deepwhite_windows_terminal.json").read_text())
        keys = ["purple" if name == "magenta" else name for name in NAMES]
        cls.ansi = [hex_color(cls.windows[key]) for key in keys]
        cls.ansi += [hex_color(cls.windows["bright" + key.title()]) for key in keys]
        cls.fg = hex_color(cls.windows["foreground"])
        cls.bg = hex_color(cls.windows["background"])
        cls.selected = hex_color(cls.windows["selectionBackground"])

    def terminal(self, foreground, background, ansi):
        self.assertEqual(hex_color(foreground), self.fg)
        self.assertEqual(hex_color(background), self.bg)
        self.assertEqual([hex_color(color) for color in ansi], self.ansi)
        for color in [foreground, *ansi]:
            self.assertGreaterEqual(contrast(color, background), 4.5)

    def selection(self, foreground, background):
        self.assertEqual(hex_color(foreground), self.fg)
        self.assertEqual(hex_color(background), self.selected)
        self.assertGreaterEqual(contrast(foreground, background), 4.5)

    def tables(self, normal, bright):
        self.assertEqual(set(normal), set(NAMES))
        self.assertEqual(set(bright), set(NAMES))
        return [table[name] for table in (normal, bright) for name in NAMES]

    def test_windows_terminal(self):
        self.terminal(self.windows["foreground"], self.windows["background"], self.ansi)
        self.assertEqual(self.windows["name"], "deepwhite")
        hex_color(self.windows["cursorColor"])  # Intentional application-specific shade.
        self.selection(self.fg, self.windows["selectionBackground"])

    def test_kitty(self):
        pairs = [line.split(None, 1) for line in simple_lines("deepwhite_kitty.conf")]
        values = dict(pairs)
        self.assertEqual(len(pairs), len(values), "Duplicate Kitty option")
        self.terminal(values["foreground"], values["background"], [values[f"color{i}"] for i in range(16)])
        self.selection(values["selection_foreground"], values["selection_background"])
        self.assertEqual(values["cursor"], self.fg)
        self.assertEqual(values["cursor_text_color"], self.bg)
        for value in values.values():
            hex_color(value)

    def test_wezterm(self):
        data = toml("deepwhite_wezterm.toml")
        colors = data["colors"]
        self.assertEqual(data["metadata"]["name"], "deepwhite")
        self.terminal(colors["foreground"], colors["background"], colors["ansi"] + colors["brights"])
        self.selection(colors["selection_fg"], colors["selection_bg"])
        self.assertEqual([colors[key] for key in ("cursor_bg", "cursor_border", "cursor_fg")],
                         [self.fg, self.fg, self.bg])
        self.assertEqual(colors["indexed"], {"16": self.ansi[4], "17": self.bg})

    def test_xresources(self):
        values = {}
        for line in simple_lines("deepwhite_xresources.Xresources"):
            match = re.fullmatch(r"\*(\w+):\s*(#[0-9a-fA-F]{6})", line)
            self.assertIsNotNone(match, line)
            key, value = match.groups()
            self.assertNotIn(key, values)
            values[key] = value
        self.assertEqual(set(values), {"foreground", "background", *(f"color{i}" for i in range(16))})
        self.terminal(values["foreground"], values["background"], [values[f"color{i}"] for i in range(16)])

    def test_ghostty(self):
        values, palette = {}, {}
        for line in simple_lines("deepwhite_ghostty.conf"):
            key, value = (part.strip() for part in line.split("=", 1))
            target = palette if key == "palette" else values
            if key == "palette":
                index, value = value.split("=", 1)
                key = int(index)
            self.assertNotIn(key, target, "Duplicate Ghostty color")
            target[key] = value
        self.assertEqual(set(values), {"foreground", "background", "cursor-color", "cursor-text",
                                       "selection-foreground", "selection-background"})
        self.assertEqual(set(palette), set(range(16)))
        self.terminal(values["foreground"], values["background"], [palette[i] for i in range(16)])
        self.selection(values["selection-foreground"], values["selection-background"])
        self.assertEqual([values["cursor-color"], values["cursor-text"]], [self.fg, self.bg])

    def test_alacritty(self):
        data = toml("deepwhite_alacritty.toml")
        self.assertEqual(set(data), {"colors"})
        c = data["colors"]
        self.assertEqual(set(c), {"primary", "normal", "bright", "cursor", "vi_mode_cursor", "selection", "search"})
        self.terminal(c["primary"]["foreground"], c["primary"]["background"], self.tables(c["normal"], c["bright"]))
        self.selection(c["selection"]["text"], c["selection"]["background"])
        for key in ("cursor", "vi_mode_cursor"):
            self.assertEqual(c[key], {"text": self.bg, "cursor": self.fg})
        self.assertEqual(set(c["search"]), {"matches", "focused_match"})
        for pair in c["search"].values():
            self.assertEqual(set(pair), {"foreground", "background"})
            self.assertEqual(pair["foreground"], self.fg)
            self.assertGreaterEqual(contrast(pair["foreground"], pair["background"]), 4.5)

    def test_rio(self):
        data = toml("deepwhite_rio.toml")
        self.assertEqual(set(data), {"colors"})
        c = data["colors"]
        search = {f"search-{kind}-{side}" for kind in ("match", "focused-match") for side in ("foreground", "background")}
        self.assertEqual(set(c), set(NAMES) | {f"light-{name}" for name in NAMES} | search |
                         {"foreground", "background", "light-foreground", "cursor", "vi-cursor", "tabs", "tabs-active",
                          "split", "split-active", "selection-foreground", "selection-background"})
        self.terminal(c["foreground"], c["background"], [c[prefix + name] for prefix in ("", "light-") for name in NAMES])
        self.selection(c["selection-foreground"], c["selection-background"])
        for key in ("cursor", "vi-cursor", "tabs-active", "split-active", "light-foreground"):
            self.assertEqual(c[key], self.fg)
        for value in c.values():
            hex_color(value)
        for kind in ("match", "focused-match"):
            self.assertGreaterEqual(contrast(c[f"search-{kind}-foreground"], c[f"search-{kind}-background"]), 4.5)

    def test_warp(self):
        data = yaml.safe_load((EXTRA / "deepwhite_warp.yaml").read_text())
        self.assertEqual(set(data), {"name", "accent", "cursor", "background", "foreground", "details", "terminal_colors"})
        self.assertEqual(data["name"], "DeepWhite")
        self.assertEqual(data["details"], "lighter")
        self.assertEqual(data["accent"], self.ansi[4])
        self.assertEqual(data["cursor"], self.fg)
        colors = data["terminal_colors"]
        self.assertEqual(set(colors), {"normal", "bright"})
        self.terminal(data["foreground"], data["background"], self.tables(colors["normal"], colors["bright"]))

    def test_foot(self):
        ini = configparser.ConfigParser(interpolation=None)
        ini.read(EXTRA / "deepwhite_foot.ini", encoding="utf-8")
        self.assertEqual(ini.sections(), ["colors-light"])
        c = ini["colors-light"]
        self.assertEqual(set(c), {"foreground", "background", "cursor", "selection-foreground", "selection-background"} |
                         {f"{prefix}{i}" for prefix in ("regular", "bright") for i in range(8)})
        def color(value):
            self.assertRegex(value, r"^[0-9A-Fa-f]{6}$")
            return "#" + value
        self.terminal(color(c["foreground"]), color(c["background"]),
                      [color(c[f"{prefix}{i}"]) for prefix in ("regular", "bright") for i in range(8)])
        self.selection(color(c["selection-foreground"]), color(c["selection-background"]))
        self.assertEqual([color(value) for value in c["cursor"].split()], [self.bg, self.fg])

    def test_iterm2(self):
        with (EXTRA / "deepwhite.itermcolors").open("rb") as source:
            data = plistlib.load(source)
        def color(entry):
            self.assertEqual(set(entry), {"Red Component", "Green Component", "Blue Component", "Alpha Component", "Color Space"})
            self.assertEqual(entry["Color Space"], "sRGB")
            self.assertEqual(entry["Alpha Component"], 1.0)
            rgb = [entry[f"{name} Component"] for name in ("Red", "Green", "Blue")]
            for value in [*rgb, entry["Alpha Component"]]:
                self.assertIsInstance(value, float)
                self.assertTrue(math.isfinite(value) and 0 <= value <= 1)
            return "#" + "".join(f"{round(value * 255):02X}" for value in rgb)
        keys = {f"Ansi {i} Color" for i in range(16)} | {"Foreground Color", "Background Color", "Bold Color",
                "Cursor Color", "Cursor Text Color", "Selection Color", "Selected Text Color"}
        self.assertEqual(set(data), keys)
        c = {key: color(value) for key, value in data.items()}
        self.terminal(c["Foreground Color"], c["Background Color"], [c[f"Ansi {i} Color"] for i in range(16)])
        self.selection(c["Selected Text Color"], c["Selection Color"])
        self.assertEqual([c["Bold Color"], c["Cursor Color"], c["Cursor Text Color"]], [self.fg, self.fg, self.bg])

    def test_vivid(self):
        data = yaml.safe_load((EXTRA / "vivid_themes_deepwhite.yml").read_text())
        colors = {key: hex_color("#" + value) for key, value in data["colors"].items()}
        self.assertEqual({key: colors[key] for key in ("base8", "light_yellow", "light_cyan")},
                         {"base8": "#FAF4F0", "light_yellow": "#FAFAC8", "light_cyan": "#C8FAFA"})
        self.assertEqual([colors[key] for key in ("base0", "base7", "base5")], [self.fg, self.bg, self.selected])
        self.assertEqual([colors[key] for key in ("blue", "success", "hint")], [self.ansi[i] for i in (4, 2, 6)])
        def styles(node, path):
            if not isinstance(node, dict):
                return
            if "foreground" in node or "background" in node:
                with self.subTest(style=path):
                    fg, bg = colors[node.get("foreground", "base0")], colors[node.get("background", "base7")]
                    self.assertGreaterEqual(contrast(fg, bg), 4.5)
            for key, value in node.items():
                styles(value, f"{path}.{key}")
        for key, value in data.items():
            if key != "colors":
                styles(value, key)


if __name__ == "__main__":
    unittest.main(verbosity=2)
