-- Optional real-plugin UI checks; no downloads, user configuration, or saved fixtures.
-- DEEPWHITE_MULTICURSOR=/path/to/multicursor.nvim DEEPWHITE_WHICHKEY=/path/to/which-key.nvim \
--   [DEEPWHITE_MINI=/path/to/mini.nvim] nvim --headless -u NONE -i NONE -n -l tests/workflow.lua
-- Set DEEPWHITE_TEST to a test-name substring. Requires modern Neovim; verified on 0.12.6.
local multicursor, whichkey, mini = vim.env.DEEPWHITE_MULTICURSOR, vim.env.DEEPWHITE_WHICHKEY, vim.env.DEEPWHITE_MINI
for name, path in pairs { DEEPWHITE_MULTICURSOR = multicursor or '', DEEPWHITE_WHICHKEY = whichkey or '' } do
    assert(path ~= '' and vim.fn.isdirectory(path .. '/lua') == 1, 'Set ' .. name .. ' to the plugin runtime')
end
if mini then
    assert(vim.fn.filereadable(mini .. '/lua/mini/cmdline.lua') == 1, 'DEEPWHITE_MINI must contain mini.cmdline')
end
local child = vim.fn.jobstart({ vim.v.progpath, '--embed', '-u', 'NONE', '-i', 'NONE', '-n' }, { rpc = true })
local function call(method, ...) return vim.rpcrequest(child, method, ...) end
local function lua(code, ...) return call('nvim_exec_lua', code, { ... }) end
local function input(keys) call('nvim_input', keys) end
local function wait_for(code)
    assert(vim.wait(3000, function() return lua(code) end, 10), 'Timed out: ' .. code)
end
local function eq(actual, expected)
    assert(vim.deep_equal(actual, expected), 'expected ' .. vim.inspect(expected) .. ', got ' .. vim.inspect(actual))
end
local function contrast(cell)
    local function luminance(rgb)
        local function linear(v)
            v = v / 255
            return v <= 0.04045 and v / 12.92 or ((v + 0.055) / 1.055) ^ 2.4
        end
        return 0.2126 * linear(math.floor(rgb / 65536))
            + 0.7152 * linear(math.floor(rgb / 256) % 256)
            + 0.0722 * linear(rgb % 256)
    end
    local a, b = luminance(cell.fg), luminance(cell.bg)
    return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05)
end
local function readable(cell, minimum)
    local ratio = contrast(cell)
    assert(
        ratio >= minimum,
        string.format('Rendered contrast %.4f is below %.1f: %s', ratio, minimum, vim.inspect(cell))
    )
end
local passed, failed = 0, 0
local function check(name, fn)
    if vim.env.DEEPWHITE_TEST and not name:find(vim.env.DEEPWHITE_TEST, 1, true) then return end
    local ok, err = xpcall(fn, debug.traceback)
    if ok then
        passed = passed + 1
        print('PASS ' .. name)
    else
        failed = failed + 1
        print('FAIL ' .. name .. '\n' .. err)
    end
end
local function fixture(lines, syntax)
    input '<Esc>'
    wait_for "return vim.fn.mode() == 'n'"
    local marks = {}
    for row, group in pairs(syntax or {}) do
        marks[#marks + 1] = { row = row, group = group }
    end
    lua('mc.clearCursors(); fixture(...)', lines, marks)
end
local function sample(row, col) return lua('return float_attr(main_win, ...)', row, col) end
local function rendered(row, col, reference)
    eq(sample(row, col), lua('return refs[...]', reference))
    return lua('return ref_styles[...]', reference)
end
local function add_cursors()
    input '<F6><F6><F6>'
    wait_for 'return mc.numCursors() == 4 and mc.numEnabledCursors() == 4'
end
local function selected_fixture(syntax)
    fixture({ 'alpha beta alpha', 'anchor' }, syntax)
    input 'v$<F9>'
    wait_for "return vim.fn.mode() == 'v' and mc.numCursors() == 2 and has_mark('MultiCursorVisual', 1)"
end
local function show_whichkey()
    -- which-key waits in getcharstr(): use input, not a synchronous request to show().
    input '<F12>'
    wait_for 'return wk_window() ~= nil'
end
local function hide_whichkey()
    input '<Esc>'
    wait_for 'return wk_window() == nil'
end

local ok, err = xpcall(function()
    call('nvim_ui_attach', 100, 36, { rgb = true })
    lua(
        [[
        local root, multicursor, whichkey, mini = ...
        vim.opt.runtimepath:prepend(root)
        for _, path in ipairs { multicursor, whichkey } do vim.opt.runtimepath:append(path) end
        if mini then vim.opt.runtimepath:append(mini) end
        vim.o.laststatus, vim.o.showtabline, vim.o.showmode = 0, 0, false
        vim.o.swapfile = false
        vim.wo.wrap, vim.wo.signcolumn = false, 'yes:1'
        vim.g.mapleader = ' '
        _G.main_win = vim.api.nvim_get_current_win()
        _G.syntax_ns = vim.api.nvim_create_namespace('DeepwhiteWorkflowSyntax')
        _G.ref_ns = vim.api.nvim_create_namespace('DeepwhiteWorkflowReferences')
        require('deepwhite').setup({ low_blue_light = false })
        vim.cmd 'colorscheme deepwhite'
        if mini then
            require('mini.icons').setup()
            require('mini.cmdline').setup({ delay = 10 })
        end
        _G.mc = require('multicursor-nvim')
        mc.setup()
        vim.keymap.set({ 'n', 'x' }, '<F6>', function() mc.lineAddCursor(1) end)
        vim.keymap.set({ 'n', 'x' }, '<F7>', mc.disableCursors)
        vim.keymap.set('n', '<F8>', mc.enableCursors)
        vim.keymap.set('x', '<F9>', function() mc.matchCursors('alpha') end)
        vim.keymap.set('n', '<F10>', function() mc.operator({ pattern = 'alpha', wordBoundary = true }) end)
        _G.wk = require('which-key')
        wk.setup({ preset = 'modern', delay = 250, icons = { mappings = false },
            triggers = { { '<auto>', mode = 'nso' } } })
        wk.add({
            { '<leader>g', group = '+Git' },
            { '<leader>gd', function() end, desc = 'Diff fixture' },
            { '<leader>gf', group = '+Find' },
            { '<leader>gff', function() end, desc = 'Find fixture' },
            { '<leader>gs', function() end, desc = 'Show fixture' },
        })
        vim.keymap.set('n', '<F12>', function() wk.show({ keys = '<leader>g', mode = 'n' }) end)
        -- screenattr() includes floating windows. Compare rendered references, not opaque ID values.
        -- Do not enable experimental hlstate inspection: provenance makes equal-looking IDs differ.
        _G.mark_at = function(group, row)
            local ns = vim.api.nvim_get_namespaces()['multicursor-nvim']
            for _, item in ipairs(vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, { details = true })) do
                if item[2] == row - 1 and item[4].hl_group == group then return item end
            end
        end
        _G.has_mark = function(group, row) return mark_at(group, row) ~= nil end
        _G.fixture = function(lines, syntax)
            vim.api.nvim_buf_clear_namespace(0, syntax_ns, 0, -1)
            vim.api.nvim_buf_clear_namespace(0, ref_ns, 0, -1)
            local c = require('deepwhite.colors').get_colors(require('deepwhite.config').options)
            _G.palette = c
            local defs = {
                plain = { fg = c.base0, bg = c.base7 }, muted = { fg = c.comment, bg = c.base7 },
                bold = { fg = c.base0, bg = c.base7, bold = true },
                -- Match the native defaults' internal flag as well as their visible style.
                cursor_plain = { reverse = true, default = true },
                cursor_string = { fg = c.base0, bg = c.light_green, reverse = true, default = true },
                cursor_comment = { fg = c.comment, reverse = true, default = true },
                preview = { fg = c.base0, bg = c.light_orange },
            }
            _G.ref_styles = {}
            for key, def in pairs(defs) do
                local fg = tonumber((def.fg or c.base0):sub(2), 16)
                local bg = tonumber((def.bg or c.base7):sub(2), 16)
                if def.reverse then fg, bg = bg, fg end
                ref_styles[key] = { fg = fg, bg = bg }
            end
            lines = vim.deepcopy(lines)
            local rows = {}
            for _, key in ipairs(vim.fn.sort(vim.tbl_keys(defs))) do
                lines[#lines + 1], rows[key] = 'X', #lines + 1
            end
            vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
            for _, mark in ipairs(syntax or {}) do
                vim.api.nvim_buf_set_extmark(0, syntax_ns, mark.row - 1, 0, {
                    end_col = #lines[mark.row], hl_group = mark.group, priority = 100,
                })
            end
            for key, row in pairs(rows) do
                local name = 'DeepwhiteWorkflowReference' .. key
                vim.api.nvim_set_hl(0, name, defs[key])
                vim.api.nvim_buf_set_extmark(0, ref_ns, row - 1, 0, { end_col = 1, hl_group = name })
            end
            vim.api.nvim_win_set_cursor(main_win, { 1, 0 })
            vim.fn.winrestview({ topline = 1 })
            vim.cmd 'redraw!'
            _G.refs = {}
            for key, row in pairs(rows) do
                local p = vim.fn.screenpos(main_win, row, 1)
                refs[key] = vim.fn.screenattr(p.row, p.col)
            end
            -- Float borders/titles use UI composition, not a buffer's Normal background.
            vim.api.nvim_set_hl(0, 'DeepwhiteWorkflowFrame', { fg = c.base0 })
            local buf = vim.api.nvim_create_buf(false, true)
            local win = vim.api.nvim_open_win(buf, false, { relative = 'editor', row = 0, col = 85,
                width = 10, height = 1, style = 'minimal', border = 'single',
                title = { { 'Ref', 'DeepwhiteWorkflowFrame' } } })
            vim.wo[win].winhighlight = 'FloatBorder:DeepwhiteWorkflowFrame'
            vim.cmd 'redraw!'
            local p = vim.fn.screenpos(win, 1, 1)
            refs.border = vim.fn.screenattr(p.row, p.col - 1)
            refs.title = vim.fn.screenattr(p.row - 1, p.col)
            vim.api.nvim_win_close(win, true)
            vim.api.nvim_buf_delete(buf, { force = true })
        end
        _G.wk_window = function()
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                local buf = vim.api.nvim_win_get_buf(win)
                if vim.bo[buf].filetype == 'wk' then
                    for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
                        if line:find('Diff fixture', 1, true) then return win end
                    end
                end
            end
        end
        _G.float_attr = function(win, row, col)
            vim.cmd 'redraw!'
            local p = vim.fn.screenpos(win, row, col)
            assert(p.row > 0 and p.col > 0, 'Expected a visible float cell')
            return vim.fn.screenattr(p.row, p.col)
        end
        _G.wk_attr = function(group)
            local win = assert(wk_window())
            local buf = vim.api.nvim_win_get_buf(win)
            for _, item in ipairs(vim.api.nvim_buf_get_extmarks(buf, -1, 0, -1, { details = true })) do
                if item[4].hl_group == group then return float_attr(win, item[2] + 1, item[3] + 1) end
            end
            error('Expected a real which-key decoration: ' .. group)
        end
        _G.frame_attrs = function(win, title)
            vim.cmd 'redraw!'
            local row, col = unpack(vim.api.nvim_win_get_position(win))
            -- With a border, get_position() is the outer top-left corner.
            local result = { border = vim.fn.screenattr(row + 2, col + 1) }
            local line = ''
            for x = col + 1, col + vim.api.nvim_win_get_width(win) + 2 do
                line = line .. vim.fn.screenstring(row + 1, x)
            end
            -- Titles may contain wide icons: locate the ASCII title directly on the screen.
            for x = col + 1, col + vim.api.nvim_win_get_width(win) + 2 do
                local text = ''
                for i = 0, #title - 1 do text = text .. vim.fn.screenstring(row + 1, x + i) end
                if text == title then result.title = vim.fn.screenattr(row + 1, x); return result end
            end
            error('Missing float title: ' .. title .. ' in ' .. line)
        end
        _G.peek_window = function()
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.wo[win].winhighlight:find('MiniCmdlinePeekNormal', 1, true) then return win end
            end
        end
    ]],
        vim.fn.getcwd(),
        multicursor,
        whichkey,
        mini
    )
    wait_for "return require('which-key.config').loaded"

    for _, cold in ipairs { false, true } do
        local label = cold and 'cold' or 'warm'
        lua("require('deepwhite').setup({ low_blue_light = ... }); vim.cmd 'colorscheme deepwhite'", cold)
        check(label .. ' multicursor enabled cursors invert plain, pastel and comment cells readably', function()
            fixture({ 'alpha word', 'alpha word', 'alpha word', 'anchor' }, { [2] = 'String', [3] = 'Comment' })
            local underlying = { sample(1, 1), sample(2, 1), sample(3, 1) }
            add_cursors()
            for row, reference in ipairs { 'cursor_plain', 'cursor_string', 'cursor_comment' } do
                eq(lua("return has_mark('MultiCursorCursor', ...)", row), true)
                local cell = rendered(row, 1, reference)
                readable(cell, 4.5)
                assert(sample(row, 1) ~= underlying[row], 'Additional cursor must differ from its underlying text')
                eq(sample(row, 2), underlying[row])
            end
        end)
        check(label .. ' multicursor disabled cursors remain visible and signs distinguish state', function()
            fixture({ 'alpha word', 'alpha word', 'alpha word', 'anchor' }, { [2] = 'String', [3] = 'Comment' })
            add_cursors()
            local active = { sample(1, 1), sample(2, 1), sample(3, 1) }
            local sign = lua [[
                vim.cmd 'redraw!'
                local p = vim.fn.screenpos(main_win, 1, 1)
                return vim.fn.screenstring(p.row, p.col - 2)
            ]]
            input '<F7>'
            wait_for 'return not mc.cursorsEnabled() and mc.numDisabledCursors() == 4'
            for row = 1, 3 do
                eq(lua("return has_mark('MultiCursorDisabledCursor', ...)", row), true)
                -- Same color is intentional upstream; dotted vs solid signs distinguish state.
                eq(sample(row, 1), active[row])
                readable(rendered(row, 1, ({ 'cursor_plain', 'cursor_string', 'cursor_comment' })[row]), 4.5)
            end
            local disabled_sign = lua [[
                vim.cmd 'redraw!'
                local p = vim.fn.screenpos(main_win, 1, 1)
                return vim.fn.screenstring(p.row, p.col - 2)
            ]]
            assert(sign ~= '' and disabled_sign ~= '' and sign ~= disabled_sign, 'Enabled/disabled signs must differ')
            input '<F8>'
            wait_for 'return mc.cursorsEnabled() and mc.numEnabledCursors() == 4 and mc.numDisabledCursors() == 0'
            eq(sample(1, 1), active[1])
        end)
        check(label .. ' multicursor actual operator match preview follows Search without hiding syntax', function()
            fixture({ 'alpha word', 'alpha word', 'alpha word', 'anchor' }, { [2] = 'String', [3] = 'Comment' })
            local underlying = { sample(1, 8), sample(2, 8), sample(3, 8) }
            input '<F10>'
            wait_for [[
                for _, match in ipairs(vim.fn.getmatches()) do
                    if match.group == 'MultiCursorMatchPreview' then return true end
                end
                return false
            ]]
            for row = 1, 3 do
                readable(rendered(row, 2, 'preview'), 4.5)
                eq(sample(row, 8), underlying[row])
            end
            input '<Esc>'
            wait_for 'return #vim.fn.getmatches() == 0'
            eq(sample(3, 2), underlying[3])
        end)
        check(label .. ' which-key modern keys, groups, descriptions, separators and frame survive reload', function()
            fixture { 'anchor' }
            for iteration = 1, 2 do
                show_whichkey()
                eq(lua "return require('which-key.config').options.icons.mappings", false)
                for group, reference in pairs {
                    WhichKey = 'plain',
                    WhichKeyDesc = 'plain',
                    WhichKeySeparator = 'muted',
                    WhichKeyGroup = 'bold',
                } do
                    eq(lua('return wk_attr(...)', group), lua('return refs[...]', reference))
                end
                eq(
                    lua "return frame_attrs(wk_window(), '+Git')",
                    lua 'return { border = refs.border, title = refs.title }'
                )
                -- Exact rendered-reference equality above establishes the actual colors; check their contrast.
                readable(lua 'return ref_styles.plain', 4.5)
                readable(lua 'return ref_styles.muted', 4.5)
                hide_whichkey()
                if iteration == 1 then lua "vim.cmd 'colorscheme deepwhite'; fixture({ 'anchor' })" end
            end
        end)
        if mini then
            check(label .. ' mini.cmdline actual range peek keeps comment, line number and frame readable', function()
                fixture { 'anchor' }
                lua [[
                    local lines = {}
                    for row = 1, 80 do lines[row] = row == 60 and '-- Peek comment' or ('line ' .. row) end
                    vim.api.nvim_buf_clear_namespace(0, ref_ns, 0, -1)
                    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
                    vim.api.nvim_buf_set_extmark(0, syntax_ns, 59, 0, {
                        end_col = #lines[60], hl_group = 'Comment', priority = 100,
                    })
                    vim.api.nvim_win_set_cursor(main_win, { 1, 0 })
                ]]
                input ':60'
                wait_for 'return peek_window() ~= nil'
                eq(lua 'return float_attr(peek_window(), 60, 4)', lua 'return refs.muted')
                readable(lua 'return ref_styles.muted', 4.5)
                eq(
                    lua "return frame_attrs(peek_window(), 'Peek')",
                    lua 'return { border = refs.border, title = refs.title }'
                )
                eq(
                    lua [[
                    vim.cmd 'redraw!'
                    local p = vim.fn.screenpos(peek_window(), 60, 1)
                    assert(vim.fn.screenstring(p.row, p.col - 3) == '6'
                        and vim.fn.screenstring(p.row, p.col - 2) == '0', 'Expected actual peek line number 60')
                    return vim.fn.screenattr(p.row, p.col - 3)
                ]],
                    lua 'return refs.muted'
                )
                input '<Esc>'
                wait_for 'return peek_window() == nil'
            end)
        end
    end
    -- Inspect selections last: enabling experimental hlstate adds provenance to attribute IDs,
    -- which must not affect the earlier float/reference comparisons. Read actual colors here so
    -- a legitimate foreground fix can satisfy the contrast test without changing its expectation.
    lua [[
        _G.selection_colors = function(row, col)
            if not inspecting then
                vim.api.nvim__inspect_cell(1, 0, 0)
                inspecting = true
            end
            vim.cmd 'redraw!'
            local p = vim.fn.screenpos(main_win, row or 1, col or 3)
            local attr = vim.api.nvim__inspect_cell(1, p.row - 1, p.col - 1)[2]
            local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
            local fg, bg = attr.foreground or normal.fg, attr.background or normal.bg
            if attr.reverse then fg, bg = bg, fg end
            return { fg = fg, bg = bg }
        end
    ]]
    for _, cold in ipairs { false, true } do
        local label = cold and 'cold' or 'warm'
        lua("require('deepwhite').setup({ low_blue_light = ... }); vim.cmd 'colorscheme deepwhite'", cold)
        check(label .. ' multicursor actual match selections inherit Visual in enabled and disabled states', function()
            selected_fixture()
            local selected = lua 'return selection_colors()'
            eq(selected.bg, lua 'return tonumber(palette.base5:sub(2), 16)')
            readable(selected, 4.5)
            input '<F7>'
            wait_for "return not mc.cursorsEnabled() and has_mark('MultiCursorDisabledVisual', 1)"
            local disabled = lua 'return selection_colors()'
            eq(disabled, selected)
            readable(disabled, 4.5)
        end)
        check(label .. ' multicursor selected comments meet informative-text contrast target', function()
            selected_fixture { [1] = 'Comment' }
            local active = lua 'return { secondary = selection_colors(), primary = selection_colors(1, 14) }'
            input '<F7>'
            wait_for "return not mc.cursorsEnabled() and has_mark('MultiCursorDisabledVisual', 1)"
            local disabled = lua 'return { secondary = selection_colors(), primary = selection_colors(1, 14) }'
            local ratios = {
                active_secondary = contrast(active.secondary),
                active_primary = contrast(active.primary),
                disabled_secondary = contrast(disabled.secondary),
                disabled_primary = contrast(disabled.primary),
            }
            for _, ratio in pairs(ratios) do
                assert(ratio >= 4.5, 'Selected comment contrast is below 4.5: ' .. vim.inspect(ratios))
            end
        end)
    end
end, debug.traceback)
vim.fn.jobstop(child)
vim.fn.jobwait({ child }, 2000)
if not ok then
    print('FAIL workflow UI setup\n' .. err)
    vim.cmd 'cquit 1'
end
if not mini then print 'NOTE: mini.icons and mini.cmdline checks require DEEPWHITE_MINI' end
print(string.format('RESULT: %d workflow UI checks passed, %d failed', passed, failed))
if passed + failed == 0 then
    print 'No tests matched DEEPWHITE_TEST'
    vim.cmd 'cquit 2'
elseif failed > 0 then
    vim.cmd 'cquit 1'
else
    vim.cmd 'qa!'
end
