-- Optional real MiniDiff UI test; no Git operations, disk fixtures, or user config.
-- Uses experimental cell inspection on the default grid (no floating windows); verified on Neovim 0.12.6.
-- DEEPWHITE_MINI=/path/to/mini.nvim nvim --headless -u NONE -i NONE -n -l tests/diff.lua
local mini = vim.env.DEEPWHITE_MINI
assert(mini and vim.fn.filereadable(mini .. '/lua/mini/diff.lua') == 1, 'Set DEEPWHITE_MINI to mini.nvim')
local child = vim.fn.jobstart({ vim.v.progpath, '--embed', '-u', 'NONE', '-i', 'NONE', '-n' }, { rpc = true })
local function call(method, ...) return vim.rpcrequest(child, method, ...) end
local function lua(code, ...) return call('nvim_exec_lua', code, { ... }) end
local function eq(actual, expected)
    assert(vim.deep_equal(actual, expected), 'expected ' .. vim.inspect(expected) .. ', got ' .. vim.inspect(actual))
end
local function wait_for(code)
    assert(vim.wait(3000, function() return lua(code) end, 10), 'Timed out: ' .. code)
end
local function input(keys) call('nvim_input', keys) end
local passed = 0
local function check(name, fn)
    if vim.env.DEEPWHITE_TEST and not name:find(vim.env.DEEPWHITE_TEST, 1, true) then return end
    local ok, err = xpcall(fn, debug.traceback)
    assert(ok, name .. '\n' .. tostring(err))
    passed = passed + 1
    print('PASS ' .. name)
end
local function fixture(ref, text, linematch)
    lua([[
        local ref, text, linematch = ...
        MiniDiff.disable(0)
        vim.wo.cursorline = false
        vim.diagnostic.reset(diag_ns, 0)
        vim.api.nvim_buf_clear_namespace(0, syntax_ns, 0, -1)
        vim.b.minidiff_config = { options = { linematch = linematch } }
        local text, ref = vim.deepcopy(text), vim.deepcopy(ref)
        local cursor_row = #text
        table.insert(text, '--- reference cells ---')
        table.insert(ref, '--- reference cells ---')
        _G.ref_rows = {}
        for _, key in ipairs(ref_keys) do
            table.insert(text, 'X')
            table.insert(ref, 'X')
            ref_rows[key] = #text
        end
        vim.api.nvim_buf_set_lines(0, 0, -1, false, text)
        local ns = vim.api.nvim_create_namespace('DeepwhiteDiffReferences')
        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
        for key, row in pairs(ref_rows) do
            local name = 'DeepwhiteDiffReference' .. key
            vim.api.nvim_set_hl(0, name, ref_defs[key])
            vim.api.nvim_buf_set_extmark(0, ns, row - 1, 0, { end_col = 1, hl_group = name })
        end
        vim.api.nvim_win_set_cursor(0, { cursor_row, 0 })
        vim.fn.winrestview({ topline = 1 })
        _G.updated = false
        MiniDiff.set_ref_text(0, ref)
        MiniDiff.toggle_overlay(0)
    ]], ref, text, linematch or 60)
    wait_for('return updated and #MiniDiff.get_buf_data(0).hunks > 0')
end
local function sample(row, col)
    return lua('return cell(main_win, ...)', row, col)
end
local function reference(name)
    return lua('return cell(main_win, ref_rows[...], 1)', name)
end
local function virtual(row, col)
    return lua([[
        local row, col = ...
        vim.cmd 'redraw'
        local p = vim.fn.screenpos(main_win, row, col)
        return screen_style(p.row - 1, p.col)
    ]], row, col)
end

local ok, err = xpcall(function()
    call('nvim_ui_attach', 100, 36, { rgb = true })
    lua([[
        local root, mini = ...
        -- Equal-looking attributes can have different screenattr() IDs: empty default
        -- highlights carry an internal flag. Compare rendered colors/styles instead.
        -- Inspection enables hlstate on first use; initialize it before sampling.
        -- All sampled cells are in the default grid, never floating-window grids.
        vim.api.nvim__inspect_cell(1, 0, 0)
        vim.cmd 'redraw!'
        _G.screen_style = function(row, col)
            local attrs = vim.api.nvim__inspect_cell(1, row - 1, col - 1)[2]
            local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
            attrs.foreground = attrs.foreground or normal.fg
            attrs.background = attrs.background or normal.bg
            return attrs
        end
        vim.opt.runtimepath:prepend(root)
        vim.opt.runtimepath:prepend(mini)
        vim.o.laststatus, vim.o.showtabline, vim.o.showmode = 0, 0, false
        vim.o.swapfile = false
        vim.wo.signcolumn, vim.wo.wrap = 'yes:2', false
        _G.main_win = vim.api.nvim_get_current_win()
        _G.syntax_ns = vim.api.nvim_create_namespace('DeepwhiteDiffSyntax')
        _G.diag_ns = vim.api.nvim_create_namespace('DeepwhiteDiffDiagnostics')
        local diff = require('mini.diff')
        diff.setup({ source = diff.gen_source.none(), view = {
            style = 'sign', signs = { add = '+', change = '~', delete = '-' },
        } })
        vim.api.nvim_create_autocmd('User', { pattern = 'MiniDiffUpdated', callback = function() _G.updated = true end })
        _G.cell = function(win, row, col)
            vim.cmd 'redraw'
            local p = vim.fn.screenpos(win, row, col)
            assert(p.row > 0 and p.col > 0, 'Expected a visible cell')
            return screen_style(p.row, p.col)
        end
    ]], vim.fn.getcwd(), mini)

    for _, cold in ipairs { false, true } do
        local label = cold and 'cold' or 'warm'
        lua([[
            require('deepwhite').setup({ low_blue_light = ..., on_highlights = function() end })
            vim.cmd 'colorscheme deepwhite'
            _G.palette = require('deepwhite.colors').get_colors(require('deepwhite.config').options)
            local c = palette
            _G.ref_defs = {
                plain = { fg = c.base0 },
                add = { fg = c.base0, bg = c.light_green },
                delete = { fg = c.base0, bg = c.light_red },
                context = { fg = c.base0, bg = c.light_orange },
                change = { fg = c.base0, bg = c.diff_text },
                comment = { fg = c.comment },
                cursor = { fg = c.base0, bg = c.base6 },
                selected = { fg = c.base0, bg = c.base5 },
                diagnostic = { fg = c.base0, bg = c.diff_text, sp = c.red, undercurl = true },
                sign_add = { fg = c.git_add },
                sign_change = { fg = c.git_change },
                sign_delete = { fg = c.git_delete },
            }
            _G.ref_keys = vim.tbl_keys(ref_defs)
            table.sort(ref_keys)
        ]], cold)

        check(label .. ' word diff distinguishes changed text from context', function()
            fixture({ 'anchor', '-- mode = old_value', 'tail' }, { 'anchor', '-- mode = new_value', 'tail' })
            -- A real Comment foreground, as produced by syntax/Tree-sitter, below the overlay priority.
            lua([[vim.api.nvim_buf_set_extmark(0, syntax_ns, 1, 0, {
                end_col = 19, hl_group = 'Comment', priority = 100,
            })]])
            local context, changed = sample(2, 1), sample(2, 11)
            assert(not vim.deep_equal(changed, context), 'Current changed span is indistinguishable from its context')
            eq(context, reference('comment'))
            eq(changed, reference('change'))
            eq(virtual(2, 1), reference('context'))
            eq(virtual(2, 11), reference('change'))
        end)

        check(label .. ' add and multiline delete with readable signs', function()
            fixture({ 'anchor', 'tail' }, { 'anchor', 'added line', 'tail' })
            eq(sample(2, 1), reference('add'))
            eq(lua([[
                local p = vim.fn.screenpos(main_win, 2, 1)
                return screen_style(p.row, p.col - 4)
            ]]), reference('sign_add'))
            fixture({ 'anchor', 'deleted one', 'deleted two', 'tail' }, { 'anchor', 'tail' })
            local deleted = lua([[
                vim.cmd 'redraw'
                local p = vim.fn.screenpos(main_win, 2, 1)
                return { screen_style(p.row - 2, p.col), screen_style(p.row - 1, p.col),
                    screen_style(vim.fn.screenpos(main_win, 1, 1).row, p.col - 4) }
            ]])
            eq(deleted, { reference('delete'), reference('delete'), reference('sign_delete') })
            eq(sample(2, 1), reference('plain'))
        end)

        check(label .. ' unequal replacement and empty added line', function()
            fixture({ 'anchor', 'old one', 'old two', 'tail' }, { 'anchor', 'replacement', 'tail' }, 0)
            eq(lua('return MiniDiff.get_buf_data(0).hunks[1].type'), 'change')
            eq(virtual(2, 1), reference('change'))
            eq(sample(2, 1), reference('plain'))
            eq(lua([[
                local p = vim.fn.screenpos(main_win, 2, 1)
                return screen_style(p.row, p.col - 4)
            ]]), reference('sign_change'))
            fixture({ 'anchor', 'tail' }, { 'anchor', '', 'tail' })
            -- hl_eol must expose the addition even when there is no text to color.
            eq(sample(2, 1), reference('add'))
            fixture({ 'anchor', '', 'tail' }, { 'anchor', 'tail' })
            eq(virtual(2, 1), reference('delete'))
        end)

        check(label .. ' cursorline selection and diagnostics compose with word diff', function()
            fixture({ 'anchor', 'mode = old_value', 'tail' }, { 'anchor', 'mode = new_value', 'tail' })
            lua([[vim.wo.cursorline = true; vim.api.nvim_win_set_cursor(0, { 2, 0 })]])
            eq(sample(2, 1), reference('cursor'))
            eq(sample(2, 8), reference('change'))
            lua([[
                vim.diagnostic.set(diag_ns, 0, { {
                    lnum = 1, col = 7, end_lnum = 1, end_col = 10,
                    severity = vim.diagnostic.severity.ERROR, message = 'Fixture diagnostic',
                } }, { underline = true, virtual_text = false, signs = false })
            ]])
            eq(sample(2, 8), reference('diagnostic'))
            lua('vim.diagnostic.reset(diag_ns, 0)')
            input('0v$')
            wait_for("return vim.fn.mode() == 'v'")
            eq(sample(2, 1), reference('selected'))
            eq(sample(2, 8), reference('selected'))
            input('<Esc>')
            wait_for("return vim.fn.mode() == 'n'")
            eq(sample(2, 8), reference('change'))
        end)

        check(label .. ' native defaults and customization survive reload and setup', function()
            lua([[
                local links = {
                    MiniDiffOverChange = 'DiffText', MiniDiffOverChangeBuf = 'MiniDiffOverChange',
                }
                for name, target in pairs(links) do
                    assert(vim.api.nvim_get_hl(0, { name = name }).link == target, name .. ' should inherit ' .. target)
                end
                require('deepwhite').setup({ on_highlights = function(groups)
                    groups.DiffText = { fg = '#112233', bg = '#EEDDCC', bold = true }
                end })
                vim.cmd 'colorscheme deepwhite'
                MiniDiff.setup(MiniDiff.config)
                for name in pairs(links) do
                    assert(vim.deep_equal(vim.api.nvim_get_hl(0, { name = name, link = false }),
                        vim.api.nvim_get_hl(0, { name = 'DiffText', link = false })), name .. ' lost native customization')
                end
                local context = vim.api.nvim_get_hl(0, { name = 'MiniDiffOverContextBuf', link = false })
                assert(vim.deep_equal(context, { default = true }),
                    'Buffer context should retain the empty module default: ' .. vim.inspect(context))
            ]])
        end)
    end
end, debug.traceback)

vim.fn.jobstop(child)
vim.fn.jobwait({ child }, 2000)
if not ok then
    print('FAIL MiniDiff UI integration\n' .. err)
    vim.cmd 'cquit 1'
end
assert(passed > 0, 'No tests matched DEEPWHITE_TEST')
print(string.format('RESULT: %d MiniDiff UI checks passed', passed))
vim.cmd 'qa!'
