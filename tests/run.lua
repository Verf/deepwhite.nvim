-- Run from the repository root (including Neovim 0.7):
-- nvim --headless -u NONE -i NONE -n -c 'luafile tests/run.lua' -c 'cquit 1'
-- Set DEEPWHITE_TEST to a test-name substring to run an affected test in isolation.
vim.opt.runtimepath:prepend(vim.fn.getcwd())

local theme = require 'deepwhite'
local config = require 'deepwhite.config'
local defaults = vim.deepcopy(config.options)
local filter = vim.env.DEEPWHITE_TEST
local passed, failed = 0, 0
local has_captures = vim.fn.has('nvim-0.8') == 1

local function eq(actual, expected)
    assert(vim.deep_equal(actual, expected), 'expected ' .. vim.inspect(expected) .. ', got ' .. vim.inspect(actual))
end

local function hl(name)
    if vim.api.nvim_get_hl then
        return vim.api.nvim_get_hl(0, { name = name, link = false, create = false })
    end
    -- Neovim 0.7/0.8 use long color keys and can return a non-string sentinel for an empty group.
    local result, keys = {}, { foreground = 'fg', background = 'bg', special = 'sp' }
    for key, value in pairs(vim.api.nvim_get_hl_by_name(name, true)) do
        if type(key) == 'string' then result[keys[key] or key] = value end
    end
    -- The old API omits Normal's colors (also through links); query the resolved GUI definition.
    local id = vim.fn.synIDtrans(vim.fn.hlID(name))
    for key, attr in pairs { fg = 'fg#', bg = 'bg#', sp = 'sp#' } do
        local value = vim.fn.synIDattr(id, attr, 'gui')
        if value:sub(1, 1) == '#' then result[key] = tonumber(value:sub(2), 16) end
    end
    return result
end

local function hex(value) return tonumber(value:sub(2), 16) end
local function colors() return require('deepwhite.colors').get_colors(config.options) end

local function test(name, fn)
    if filter and not name:find(filter, 1, true) then return end
    local ok, err = xpcall(function()
        vim.cmd 'messages clear'
        theme.setup(defaults)
        vim.cmd 'colorscheme deepwhite'
        fn()
    end, debug.traceback)
    if ok then
        passed = passed + 1
        print('PASS ' .. name)
    else
        failed = failed + 1
        print('FAIL ' .. name .. '\n' .. err)
    end
end

test('theme load emits no warnings', function()
    eq(vim.fn.execute('messages'), '')
end)

test('capture overrides follow runtime support without warnings', function()
    theme.setup {
        on_highlights = function(groups)
            groups['@deepwhite.test'] = { fg = '#112233' }
            groups.DeepwhiteCaptureLink = { link = '@type' }
        end,
    }
    vim.cmd 'messages clear'
    vim.cmd 'colorscheme deepwhite'
    eq(vim.fn.execute('messages'), '')
    if has_captures then
        eq(hl('@deepwhite.test').fg, hex('#112233'))
        eq(hl('DeepwhiteCaptureLink'), hl('@type'))
    else
        eq(vim.fn.hlexists('@deepwhite.test'), 0)
        eq(vim.fn.hlexists('DeepwhiteCaptureLink'), 0)
    end
end)

test('default load', function()
    eq(vim.g.colors_name, 'deepwhite')
    eq(vim.o.background, 'light')
    eq(vim.o.termguicolors, true)
    eq(hl('Normal').fg, hex('#1A1918'))
    eq(hl('Normal').bg, hex('#FAF2EB'))
end)

test('mini diff keeps soft deletion background', function()
    eq(hl('MiniDiffOverDelete').bg, hex(colors().light_red))
end)

test('mini diff delegates changed spans and buffer context to module defaults', function()
    local groups = require('deepwhite.scheme').get_groups(colors())
    for _, name in ipairs { 'MiniDiffOverChange', 'MiniDiffOverChangeBuf', 'MiniDiffOverContextBuf' } do
        eq(groups[name], nil)
    end
    eq(hl('DiffText').fg, hex(colors().base0))
    eq(hl('DiffText').bg, hex(colors().diff_text))
    eq(hl('MiniDiffOverContext').bg, hex(colors().light_orange))
end)

-- These names are not valid highlight groups on Neovim 0.7.
if has_captures then
    for _, row in ipairs {
        { '@lsp.type.macro', '@constant.macro' },
        { '@lsp.type.namespace', '@module' },
        { '@lsp.type.parameter', '@variable.parameter' },
        { '@lsp.type.struct', '@type' },
    } do
        test(row[1] .. ' link', function()
            assert(hl(row[2]).fg, 'syntax target must have a foreground')
            eq(hl(row[1]), hl(row[2]))
        end)
    end
end

for _, name in ipairs { 'FloatShadow', 'FloatShadowThrough' } do
    test(name .. ' background', function()
        eq(hl(name).bg, hex(colors().base0))
        eq(hl(name).blend, name == 'FloatShadow' and 80 or 100)
        eq(hl(name).fg, nil)
    end)
end

test('cold background reload', function()
    theme.setup { low_blue_light = true }
    vim.cmd 'colorscheme deepwhite'
    eq(hl('Normal').bg, hex('#FAFAFA'))
end)

test('theme switch and repeated load', function()
    theme.setup { low_blue_light = true }
    vim.cmd 'colorscheme deepwhite'
    theme.setup { low_blue_light = false }
    vim.cmd 'colorscheme default'
    vim.cmd 'colorscheme deepwhite'
    local first = hl('Normal')
    eq(first.bg, hex('#FAF2EB'))
    vim.cmd 'colorscheme deepwhite'
    eq(hl('Normal'), first)
end)

test('lualine preserves fillchars', function()
    local before = { global = vim.opt_global.fillchars:get(), local_value = vim.opt_local.fillchars:get() }
    local ok, err = pcall(function()
        vim.opt_global.fillchars = { stl = '-', stlnc = '=' }
        vim.opt_local.fillchars = { stl = '_', stlnc = '.' }
        local expected_global = vim.opt_global.fillchars:get()
        local expected_local = vim.opt_local.fillchars:get()
        package.loaded['lualine.themes.deepwhite'] = nil
        local lualine = require 'lualine.themes.deepwhite'
        assert(lualine.normal.a.fg and lualine.normal.a.bg, 'lualine must return a theme')
        eq(vim.opt_global.fillchars:get(), expected_global)
        eq(vim.opt_local.fillchars:get(), expected_local)
    end)
    vim.opt_global.fillchars = before.global
    vim.opt_local.fillchars = before.local_value
    if not ok then error(err, 0) end
end)

test('visual selection uses a readable foreground instead of retaining muted syntax', function()
    eq(hl('Visual').fg, hex(colors().base0))
    eq(hl('Visual').bg, hex(colors().base5))
end)

test('codediff gutters follow shared Git foreground roles', function()
    for _, row in ipairs {
        { 'CodeDiffGutterInsert', 'GitSignsAdd' }, { 'CodeDiffGutterDelete', 'GitSignsDelete' },
        { 'CodeDiffGutterInsertNumber', 'GitSignsAdd' }, { 'CodeDiffGutterDeleteNumber', 'GitSignsDelete' },
    } do
        eq(hl(row[1]), hl(row[2]))
        eq(hl(row[1]).bg, nil)
    end
    theme.setup { on_colors = function(c) c.git_add = '#123456' end }
    vim.cmd 'colorscheme deepwhite'
    eq(hl('CodeDiffGutterInsert').fg, hex('#123456'))
    eq(hl('CodeDiffGutterInsertNumber').fg, hex('#123456'))
end)

test('standard syntax and deprecated completion', function()
    eq(hl('StorageClass'), hl('Type'))
    eq(hl('CmpItemAbbrDeprecated').strikethrough, true)
    eq(hl('CmpItemAbbrDeprecated').bg, nil)
end)

test('setup incrementally updates options without reloading', function()
    local callback = function(c) c.comment = '#123456' end
    theme.setup { low_blue_light = true, on_colors = callback }
    theme.setup { terminal_colors = true }
    eq(config.options.low_blue_light, true)
    eq(config.options.terminal_colors, true)
    eq(config.options.on_colors, callback)
    local before = hl('Normal')
    theme.setup()
    theme.setup {}
    eq(config.options.on_colors, callback)
    eq(hl('Normal'), before)
    vim.cmd 'colorscheme deepwhite'
    eq(hl('Normal').bg, hex('#FAFAFA'))
    eq(hl('Comment').fg, hex('#123456'))
end)

test('invalid config types do not change options', function()
    local before = vim.deepcopy(config.options)
    for _, invalid in ipairs { false, 'light', 1 } do
        local ok, err = pcall(theme.setup, invalid)
        eq(ok, false)
        assert(err:find('deepwhite.nvim: setup options must be a table', 1, true), err)
        eq(config.options, before)
    end
    for key, value in pairs {
        low_blue_light = 'yes', terminal_colors = 1, on_colors = {}, on_highlights = false,
    } do
        local ok, err = pcall(theme.setup, { [key] = value })
        eq(ok, false)
        assert(err:find('deepwhite.nvim: ' .. key .. ' must be a ', 1, true), err)
        eq(config.options, before)
    end
end)

test('first load from dark background runs hooks once', function()
    vim.cmd 'colorscheme default'
    vim.o.background = 'dark'
    local trace = {}
    theme.setup {
        on_colors = function() trace[#trace + 1] = 'colors' end,
        on_highlights = function() trace[#trace + 1] = 'highlights' end,
    }
    vim.cmd 'colorscheme deepwhite'
    eq(trace, { 'colors', 'highlights' })
    eq(vim.g.colors_name, 'deepwhite')
    eq(vim.o.background, 'light')
end)

test('color and highlight hooks order and reload', function()
    local trace = {}
    theme.setup {
        low_blue_light = true,
        on_colors = function(c)
            eq(c.base7, '#FAFAFA')
            trace[#trace + 1] = 'colors'
            c.base0 = '#202122'
            c.warning = '#884400'
            c.git_change = c.warning
        end,
        on_highlights = function(groups, c)
            trace[#trace + 1] = 'highlights'
            eq(groups.Normal.fg, '#202122')
            eq(groups.WarningMsg.fg, '#884400')
            groups.Comment = { fg = c.warning, italic = true }
            groups.DiagnosticWarn = { fg = '#773300', bold = true }
            groups.DeepwhiteTest = { link = 'Comment' }
        end,
    }
    for _ = 1, 2 do
        trace = {}
        vim.cmd 'colorscheme deepwhite'
        eq(trace, { 'colors', 'highlights' })
        eq(hl('Normal').fg, hex('#202122'))
        eq(hl('Comment').fg, hex('#884400'))
        eq(hl('Comment').italic, true)
        eq(hl('DeepwhiteTest'), hl('Comment'))
        eq(hl('DiagnosticWarn').fg, hex('#773300'))
        eq(hl('DiagnosticWarn').bold, true)
        eq(hl('GitSignsChange').fg, hex('#884400'))
    end
end)

test('highlight hook honors link replacement and removal', function()
    theme.setup {
        on_highlights = function(groups)
            groups.Comment = { link = 'Type' }
            groups.DiagnosticHint = {}
        end,
    }
    vim.cmd 'colorscheme deepwhite'
    eq(hl('Comment'), hl('Type'))
    eq(hl('DiagnosticHint'), {})
end)

for _, hook in ipairs { 'on_colors', 'on_highlights' } do
    test(hook .. ' error preserves active highlights', function()
        local normal = hl('Normal')
        vim.api.nvim_set_hl(0, 'DeepwhiteSentinel', { fg = '#123456' })
        theme.setup { [hook] = function() error('callback failed deliberately') end }
        local ok, err = pcall(vim.cmd, 'colorscheme deepwhite')
        eq(ok, false)
        assert(err:find('deepwhite.nvim: ' .. hook .. ' failed:', 1, true), err)
        assert(err:find('callback failed deliberately', 1, true), err)
        assert(err:find('stack traceback', 1, true), err)
        eq(hl('Normal'), normal)
        eq(hl('DeepwhiteSentinel').fg, hex('#123456'))
    end)
end

test('lualine uses color hook without highlight side effects', function()
    local highlights_called = false
    theme.setup {
        on_colors = function(c) c.base7 = '#FFFFFF' end,
        on_highlights = function() highlights_called = true end,
    }
    package.loaded['lualine.themes.deepwhite'] = nil
    local lualine = require 'lualine.themes.deepwhite'
    eq(lualine.normal.b.bg, '#FFFFFF')
    eq(highlights_called, false)
end)

test('terminal colors are opt-in and false leaves user values intact', function()
    eq(defaults.terminal_colors, false)
    for i = 0, 15 do vim.g['terminal_color_' .. i] = '#123456' end
    vim.cmd 'colorscheme deepwhite'
    for i = 0, 15 do eq(vim.g['terminal_color_' .. i], '#123456') end
    theme.setup { terminal_colors = true }
    vim.cmd 'colorscheme deepwhite'
    theme.setup { terminal_colors = false }
    vim.g.terminal_color_3 = '#ABCDEF'
    local previous = vim.g.terminal_color_2
    vim.cmd 'colorscheme deepwhite'
    eq(vim.g.terminal_color_2, previous)
    eq(vim.g.terminal_color_3, '#ABCDEF')
end)

test('terminal ANSI slots follow overridden palette', function()
    theme.setup {
        terminal_colors = true,
        on_colors = function(c) c.hint = '#005566' end,
    }
    vim.cmd 'colorscheme deepwhite'
    local c = colors()
    local expected = {
        c.base0, c.red, c.success, c.yellow_fg, c.blue, c.purple, '#005566', c.base1,
        c.comment, c.red, c.success, c.yellow_fg, c.blue, c.purple, '#005566', c.base0,
    }
    for i, value in ipairs(expected) do eq(vim.g['terminal_color_' .. (i - 1)], value) end
    eq(hl('DiagnosticHint').fg, hex('#005566'))
end)

test('paper and pastel backgrounds are preserved', function()
    for _, row in ipairs {
        { 'Normal', '#FAF2EB' }, { 'ColorColumn', '#FAF6EB' }, { 'CursorLine', '#E6E4DF' },
        { 'Constant', '#D4D4FA' }, { 'String', '#D4FAD4' }, { 'Statement', '#FAE1C8' },
        { '@keyword.function', '#EDD4FA' }, { 'Visual', '#CCCBC6' },
        { 'DiffAdd', '#AFFAAF' }, { 'DiffChange', '#FAD4AF' }, { 'DiffDelete', '#FAAFAF' },
    } do
        if row[1]:sub(1, 1) ~= '@' or has_captures then eq(hl(row[1]).bg, hex(row[2])) end
    end
end)

test('native completion match accent preserves selection background', function()
    eq(hl('PmenuMatch').fg, hex(colors().hint))
    eq(hl('PmenuMatch').bold, true)
    eq(hl('PmenuMatch').bg, nil)
    eq(hl('PmenuMatchSel'), hl('PmenuMatch'))
    eq(hl('PmenuSel').bg, hex(colors().base6))
end)

test('mini completion delegates to native highlight defaults', function()
    local groups = require('deepwhite.scheme').get_groups(colors())
    for _, name in ipairs {
        'MiniCompletionActiveParameter', 'MiniCompletionDeprecated', 'MiniCompletionInfoBorderOutdated',
    } do
        eq(groups[name], nil)
    end
    eq(hl('LspSignatureActiveParameter').underline, true)
    eq(hl('DiagnosticDeprecated').strikethrough, true)
end)

test('mini navigation current and marked states', function()
    local c = colors()
    eq(hl('MiniPickMatchCurrent'), hl('MiniFilesCursorLine'))
    eq(hl('MiniPickMatchCurrent').bg, hex(c.base6))
    eq(hl('MiniPickMatchCurrent').bold, true)
    eq(hl('MiniPickMatchMarked').bg, hex(c.light_orange))
    eq(hl('MiniPickMatchMarked').underline, true)
    for _, name in ipairs { 'MiniPickMatchCurrent', 'MiniPickMatchMarked', 'MiniFilesCursorLine' } do
        eq(hl(name).fg, nil)
    end
end)

test('mini picker match and prompt accents', function()
    eq(hl('MiniPickMatchRanges').fg, hex(colors().hint))
    eq(hl('MiniPickMatchRanges').bold, true)
    eq(hl('MiniPickMatchRanges').bg, nil)
    eq(hl('MiniPickPromptCaret'), hl('MiniPickPromptPrefix'))
    eq(hl('MiniPickPromptCaret').fg, hex(colors().hint))
    eq(hl('MiniPickPrompt').fg, hex(colors().base0))
    eq(hl('MiniPickPreviewRegion').bg, hex(colors().light_cyan))
    eq(hl('MiniPickPreviewRegion').underline, true)
end)

test('mini files hierarchy and pending edit warning', function()
    eq(hl('MiniFilesBorderModified'), hl('DiagnosticWarn'))
    eq(hl('MiniFilesTitle').fg, hex(colors().comment))
    eq(hl('MiniFilesTitleFocused').fg, hex(colors().base0))
    eq(hl('MiniFilesTitleFocused').bold, true)
    eq(hl('MiniPickIconDirectory'), hl('MiniFilesDirectory'))
    eq(hl('MiniFilesDirectory').bold, true)
    eq(hl('MiniFilesFile'), hl('NormalFloat'))
end)

test('mini navigation honors user overrides', function()
    theme.setup {
        on_colors = function(c) c.hint = '#005566' end,
        on_highlights = function(groups) groups.MiniFilesTitleFocused = { fg = '#112233' } end,
    }
    vim.cmd 'colorscheme deepwhite'
    eq(hl('MiniPickMatchRanges').fg, hex('#005566'))
    eq(hl('MiniFilesDirectory').fg, hex('#005566'))
    eq(hl('MiniPickIconDirectory'), hl('MiniFilesDirectory'))
    eq(hl('MiniFilesTitleFocused').fg, hex('#112233'))
end)

local function luminance(rgb)
    local r = math.floor(rgb / 65536) / 255
    local g = math.floor(rgb / 256) % 256 / 255
    local b = rgb % 256 / 255
    local function linear(v) return v <= 0.04045 and v / 12.92 or ((v + 0.055) / 1.055) ^ 2.4 end
    return 0.2126 * linear(r) + 0.7152 * linear(g) + 0.0722 * linear(b)
end

local function contrast(fg, bg)
    local a, b = luminance(fg), luminance(bg)
    return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05)
end

local function readable(name, minimum)
    local group, normal = hl(name), hl('Normal')
    local ratio = contrast(group.fg or normal.fg, group.bg or normal.bg)
    assert(ratio >= minimum, string.format('%s contrast %.4f is below %.1f', name, ratio, minimum))
end

for _, cold in ipairs { false, true } do
    local background = cold and 'cold' or 'warm'
    test(background .. ' informative text contrast >= 4.5', function()
        theme.setup { low_blue_light = cold }
        vim.cmd 'colorscheme deepwhite'
        for _, name in ipairs {
            'Normal', 'Comment', '@comment', 'LineNr', 'LspInlayHint', 'LspCodeLens',
            'WarningMsg', 'Tag', 'DiagnosticError', 'DiagnosticWarn', 'DiagnosticInfo', 'DiagnosticHint', 'DiagnosticOk',
            'DiagnosticVirtualTextWarn', 'DiagnosticVirtualLinesHint', 'DiagnosticFloatingOk',
            'DiffText', 'Visual', 'MiniHipatternsHack', 'Substitute', 'RainbowDelimiterYellow',
            'CmpItemAbbr', 'CmpItemKindSnippet', 'CmpItemKindKeyword', 'NotifyWARNTitle', 'DapUISource',
        } do
            if name:sub(1, 1) ~= '@' or has_captures then readable(name, 4.5) end
        end
        local ratio = contrast(hl('Comment').fg, hl('CursorLine').bg)
        assert(ratio >= 4.5, 'comments on CursorLine must remain readable')
    end)
    test(background .. ' mini diff overlay text contrast >= 4.5', function()
        theme.setup { low_blue_light = cold }
        vim.cmd 'colorscheme deepwhite'
        for _, name in ipairs { 'MiniDiffOverAdd', 'MiniDiffOverDelete', 'MiniDiffOverContext', 'DiffText' } do
            readable(name, 4.5)
        end
    end)
    test(background .. ' native completion and float contrast >= 4.5', function()
        theme.setup { low_blue_light = cold }
        vim.cmd 'colorscheme deepwhite'
        for _, name in ipairs {
            'Pmenu', 'NormalFloat', 'FloatBorder', 'LspSignatureActiveParameter', 'DiagnosticFloatingWarn',
        } do
            readable(name, 4.5)
        end
        for _, name in ipairs { 'PmenuMatch', 'PmenuMatchSel' } do
            for _, bg in ipairs { hl('Pmenu').bg, hl('PmenuSel').bg } do
                local ratio = contrast(hl(name).fg, bg)
                assert(ratio >= 4.5, string.format('%s contrast %.4f is below 4.5', name, ratio))
            end
        end
    end)
    test(background .. ' mini navigation contrast >= 4.5', function()
        theme.setup { low_blue_light = cold }
        vim.cmd 'colorscheme deepwhite'
        for _, name in ipairs {
            'MiniPickBorderText', 'MiniPickPrompt', 'MiniPickPromptCaret', 'MiniPickPromptPrefix',
            'MiniPickMatchRanges', 'MiniPickPreviewRegion', 'MiniFilesTitle', 'MiniFilesTitleFocused',
            'MiniFilesDirectory', 'MiniFilesBorderModified',
        } do
            readable(name, 4.5)
        end
        for _, row in ipairs { 'MiniPickMatchCurrent', 'MiniPickMatchMarked', 'MiniFilesCursorLine' } do
            for _, text in ipairs { 'MiniPickNormal', 'MiniPickMatchRanges', 'MiniFilesDirectory' } do
                local ratio = contrast(hl(text).fg, hl(row).bg)
                assert(ratio >= 4.5, string.format('%s on %s contrast %.4f is below 4.5', text, row, ratio))
            end
        end
    end)
    test(background .. ' critical signs contrast >= 3', function()
        theme.setup { low_blue_light = cold }
        vim.cmd 'colorscheme deepwhite'
        for _, kind in ipairs { 'Add', 'Change', 'Delete' } do
            readable('GitSigns' .. kind, 3)
            eq(hl('GitSigns' .. kind), hl('MiniDiffSign' .. kind))
        end
        for _, name in ipairs {
            'MiniIconsCyan', 'MiniIconsGreen', 'MiniIconsOrange', 'MiniIconsYellow',
            'WhichKeyIconCyan', 'WhichKeyIconGreen', 'WhichKeyIconYellow',
            'CodeDiffGutterInsert', 'CodeDiffGutterDelete', 'CodeDiffGutterInsertNumber', 'CodeDiffGutterDeleteNumber',
        } do
            readable(name, 3)
        end
    end)
    test(background .. ' ANSI text contrast >= 4.5', function()
        theme.setup { low_blue_light = cold, terminal_colors = true }
        vim.cmd 'colorscheme deepwhite'
        for i = 0, 15 do
            local ratio = contrast(hex(vim.g['terminal_color_' .. i]), hl('Normal').bg)
            assert(ratio >= 4.5, string.format('ANSI slot %d contrast %.4f is below 4.5', i, ratio))
        end
    end)
end

local extras = dofile('tests/extra.lua')
for _, name in ipairs { 'Kitty', 'WezTerm', 'Windows Terminal', 'Xresources' } do
    test(name .. ' ANSI slots', function()
        local data, c = extras.terminals[name](), colors()
        eq(data.foreground, c.base0)
        eq(data.background, c.base7)
        eq(data.ansi, require('deepwhite.colors').get_terminal_colors(c))
    end)
    test(name .. ' extra ANSI contrast >= 4.5', function()
        local data = extras.terminals[name]()
        eq(#data.ansi, 16)
        for slot, value in ipairs(data.ansi) do
            local ratio = contrast(hex(value), hex(data.background))
            assert(ratio >= 4.5, string.format('%s ANSI slot %d contrast %.4f is below 4.5', name, slot - 1, ratio))
        end
    end)
end

test('vivid readable roles follow theme', function()
    local vivid, c = extras.vivid(), colors()
    for _, role in ipairs { 'hint', 'success', 'warning' } do eq(vivid.colors[role], c[role]) end
    for name, role in pairs {
        symlink = 'hint', executable_file = 'success', fifo = 'warning',
        block_device = 'warning', character_device = 'warning',
    } do
        eq(vivid.styles['core.' .. name].foreground, role)
    end
    eq(vivid.styles['core.setuid'].foreground, 'base7')
    eq(vivid.styles['core.setuid'].background, 'red')
end)

test('vivid explicit text styles contrast >= 4.5', function()
    local vivid = extras.vivid()
    for name, style in pairs(vivid.styles) do
        if style.foreground or style.background then
            local fg = assert(vivid.colors[style.foreground or 'base0'], 'Missing vivid foreground for ' .. name)
            local bg = assert(vivid.colors[style.background or 'base7'], 'Missing vivid background for ' .. name)
            local ratio = contrast(hex(fg), hex(bg))
            assert(ratio >= 4.5, string.format('%s contrast %.4f is below 4.5', name, ratio))
        end
    end
end)

if not has_captures then print('NOTE: @ capture/semantic highlights require Neovim 0.8+ and are not applied on 0.7') end
print(string.format('RESULT: %d passed, %d failed', passed, failed))
if passed + failed == 0 then
    print('No tests matched DEEPWHITE_TEST')
    vim.cmd 'cquit 2'
elseif failed > 0 then
    vim.cmd 'cquit 1'
else
    vim.cmd 'qa!'
end
