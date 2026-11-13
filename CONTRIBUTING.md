# Contributing to DeepWhite

Keep the theme focused: warm paper or neutral white, readable information,
pastel syntax backgrounds, and no runtime plugin dependencies. Prefer existing
palette roles and native highlight links to new options or integration machinery.

## Development checks

Run commands from the repository root. The theme has no runtime dependencies;
Luacheck, pre-commit and StyLua are development tools only.

### Lua syntax and globals

Install Luacheck (locally verified with 1.1.2). On Debian/Ubuntu, the package is
`lua-check`; with an existing LuaRocks installation, use `luarocks install luacheck`.
Then run the same check as CI:

```sh
luacheck lua colors tests scripts
```

`.luacheckrc` uses LuaJIT's standard globals and declares only Neovim's `vim` as
an additional global. The API table is read-only, with writable `vim.g`, `vim.o`,
`vim.opt_global` and `vim.opt_local` fields for the assignments in this project.
It checks syntax and global-variable diagnostics
(0xx/1xx), including missing palette prefixes such as bare `light_orange`.
Unused-variable and formatting rules are not part of this initial check. Do not
whitelist accidental globals or suppress a diagnostic instead of fixing its cause.

Luacheck does not validate palette table keys, resolved highlight links, or Lua
source embedded in strings in RPC/UI fixtures. Runtime tests remain necessary.

### Core regressions and editor help

Use Neovim 0.7 or newer:

```sh
nvim --headless -u NONE -i NONE -n -c 'luafile tests/run.lua' -c 'cquit 1'
nvim --headless -u NONE -i NONE -n -c 'luafile tests/help.lua' -c 'cquit 1'
```

The final `cquit 1` prevents an uncaught Lua error from being reported as success.
Both runners exit themselves on success. The help check creates tags in a temporary
copy, resolves the documented help topics and checks internal DeepWhite links;
it does not write `doc/tags` into the checkout.

To isolate an affected core test:

```sh
DEEPWHITE_TEST='lualine preserves' nvim --headless -u NONE -i NONE -n \
  -c 'luafile tests/run.lua' -c 'cquit 1'
```

CI runs the core and help checks on Neovim **0.7.0** and the **latest official stable
release**. Do not silently drop the minimum version or disable modern assertions
to make an older version pass. Check a failing test in isolation before rerunning
broader suites, and preserve the exit code when capturing output.

### Optional real-plugin UI checks

See [README: Tests](README.md#tests) for commands and verified plugin revisions.
Point the environment variables at already-installed plugins; tests do not download
plugins or parsers or load your personal configuration. CodeDiff also requires its
native diff library to be installed in advance.

Run the affected UI suite when changing shared highlights or plugin-specific styles.
These tests exercise actual composed screen styles on both backgrounds. Their
modern-Neovim requirements are separate from the core 0.7 compatibility promise.
Experimental UI2, real terminal font rendering and all possible plugin configurations
are not certified by those checks.

### Generated extras

All files in `extra/` are generated from the default Lua palette by
`scripts/generate_extras.lua`; do not hand-edit the outputs. With Lua 5.1+ / LuaJIT:

```sh
lua scripts/generate_extras.lua
lua scripts/generate_extras.lua --check
```

The check command is read-only and fails for missing or stale output. It runs in
CI as well as through core regressions on both Neovim versions. The generator must
not load user options or execute callbacks. Keep application-specific settings and
vivid's intentional background tints explicit in the generator, not in a second
shared palette. See [the terminal guide](docs/TERMINALS.md) for installation and sources.

Independently parse the serialized output with Python 3.11+ and PyYAML (6.0.1 in CI):

```sh
python3 -m pip install PyYAML==6.0.1
python3 tests/extras_formats.py
```

These checks cover JSON/TOML/YAML/INI/plist syntax, exact ANSI slot mappings and
color fields; they are not terminal binary or GUI integration tests.

### Automatic formatting before commits

Install [pre-commit](https://pre-commit.com/) (locally verified with 3.6.2), then
install this repository's Git hook once per checkout:

```sh
pre-commit install --install-hooks
```

`.pre-commit-config.yaml` pins the official `stylua-github` hook to **StyLua 2.6.0**.
It downloads the prebuilt formatter into pre-commit's isolated cache on first use;
no Rust toolchain or system-wide StyLua installation is needed. `.stylua.toml`
defines formatting. All `.lua` files and the root `.luacheckrc` are included.
The formatter uses `--verify` to check that formatting preserves the parsed AST.

During `git commit`, only staged matching files are processed. When formatting
changes a file, the hook stops that commit so you can review and restage it:

```sh
git diff
git add path/to/formatted.lua
git commit
```

The hook does **not** run `git add` for you. pre-commit temporarily stashes unstaged
changes during its staged-file run and restores them afterwards. If it reports a
conflict with an unstaged edit, review the result and follow its message rather
than automatically staging the whole file.

To format/check the complete tracked tree manually, use the same command as CI:

```sh
pre-commit run --all-files --show-diff-on-failure
```

For a newly created file that is not yet tracked, use `pre-commit run --files path/to/new.lua`.
With a standalone StyLua **2.6.0** binary, the equivalent non-writing check is:

```sh
stylua --check --verify lua colors tests scripts .luacheckrc
```

The formatting CI job runs the pinned hook on all tracked files and fails if it
would change them. Keep broad format-only cleanups separate from behavior changes;
do not bypass the hook or add ignore rules to conceal a formatting failure.

## Change and review checklist

- Correctness fixes should include a focused regression that fails before the fix.
- Preserve pastel background accents; do not use them for informative foregrounds.
- Check both warm and neutral backgrounds. Default information text targets 4.5:1
  contrast, critical Git signs 3:1; these are design targets, not blanket certification.
- Prefer a plugin's working default links. Inspect a real UI before adding overrides.
  Do not load/configure a plugin just to style it. If public plugin configuration is
  necessary (as with CodeDiff), document that requirement instead of claiming an
  automatic fix.
- Match README and `doc/deepwhite.txt` when changing options, defaults or behavior.
  Keep `docs/AUDIT.md`'s status summary current without rewriting its original baseline.
- When changing the shared ANSI palette, regenerate `extra/` and run generation,
  core contrast and serialized-format checks. Vivid keeps its own file-category
  mapping and three documented background tints; not every difference is drift.
- For visual changes, use a small reproducible scene and report Neovim, terminal,
  font and relevant plugin versions. Existing screenshots are not proof of current UI.
- State what actually ran and any unverified boundaries. Never weaken tests to pass.

Do not commit generated help tags, downloaded plugins, tool binaries or private
configuration. Keep changes focused and explain compatibility decisions in the PR.
