-- Optional real CodeDiff renderer/UI checks. No Git operations, downloads, or user configuration.
-- DEEPWHITE_CODEDIFF=/path/to/codediff.nvim nvim --headless -u NONE -i NONE -n -l tests/codediff.lua
-- Requires the plugin's native diff library to be installed already. Set DEEPWHITE_TEST to filter checks.
local codediff = vim.env.DEEPWHITE_CODEDIFF
assert(codediff and vim.fn.filereadable(codediff .. '/lua/codediff/init.lua') == 1,
    'Set DEEPWHITE_CODEDIFF to codediff.nvim')
local child = vim.fn.jobstart({ vim.v.progpath, '--embed', '-u', 'NONE', '-i', 'NONE', '-n' }, { rpc = true })
local function call(method, ...) return vim.rpcrequest(child, method, ...) end
local function lua(code, ...) return call('nvim_exec_lua', code, { ... }) end
local function eq(actual, expected)
    assert(vim.deep_equal(actual, expected), 'expected ' .. vim.inspect(expected) .. ', got ' .. vim.inspect(actual))
end
local function readable(cell, minimum)
    local function luminance(rgb)
        local function linear(v)
            v = v / 255
            return v <= 0.04045 and v / 12.92 or ((v + 0.055) / 1.055) ^ 2.4
        end
        return 0.2126 * linear(math.floor(rgb / 65536))
            + 0.7152 * linear(math.floor(rgb / 256) % 256) + 0.0722 * linear(rgb % 256)
    end
    local a, b = luminance(cell.fg), luminance(cell.bg)
    local ratio = (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05)
    assert(ratio >= minimum, string.format('Rendered contrast %.4f is below %.1f: %s', ratio, minimum, vim.inspect(cell)))
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
local function fixture(original, modified, comments)
    lua('fixture(...)', original, modified, comments == true)
end
local function sample(side, row, col) return lua('return cell(windows[...], select(2, ...))', side, row, col) end
local function color(key) return lua('return tonumber(palette[...]:sub(2), 16)', key) end
local function recipe()
    -- Exactly the public configuration documented in README; no post-setup highlight patches.
    lua([[
        require('codediff').setup({ highlights = {
            line_delete = '#FAE1E1', char_insert = 'DiffText', char_delete = 'DiffText',
        } })
    ]])
end

local ok, err = xpcall(function()
    call('nvim_ui_attach', 110, 36, { rgb = true })
    lua([[
        local root, codediff = ...
        vim.opt.runtimepath:prepend(root)
        vim.opt.runtimepath:append(codediff)
        vim.env.VSCODE_DIFF_NO_AUTO_INSTALL = '1'
        vim.o.laststatus, vim.o.showtabline, vim.o.showmode = 0, 0, false
        vim.o.swapfile = false
        _G.buffers, _G.windows = {}, {}
        buffers.original, windows.original = vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win()
        vim.cmd 'vnew'
        buffers.modified, windows.modified = vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win()
        for _, win in pairs(windows) do
            vim.wo[win].wrap, vim.wo[win].number = false, true
            vim.wo[win].signcolumn, vim.wo[win].numberwidth = 'yes:2', 3
        end
        vim.api.nvim__inspect_cell(1, 0, 0)
        _G.screen_cell = function(row, col)
            local attr = vim.api.nvim__inspect_cell(1, row - 1, col - 1)[2]
            local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
            return { fg = attr.foreground or normal.fg, bg = attr.background or normal.bg,
                bold = attr.bold == true }
        end
        _G.cell = function(win, row, col)
            vim.cmd 'redraw!'
            local p = vim.fn.screenpos(win, row, col)
            assert(p.row > 0 and p.col > 0, 'Expected a visible diff cell')
            return screen_cell(p.row, p.col)
        end
        _G.fixture = function(original, modified, comments)
            local ns = vim.api.nvim_create_namespace('DeepwhiteCodeDiffSyntax')
            for side, lines in pairs { original = original, modified = modified } do
                local buf = buffers[side]
                vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
                if comments then
                    for row, line in ipairs(lines) do
                        if line:sub(1, 2) == '--' then
                            vim.api.nvim_buf_set_extmark(buf, ns, row - 1, 0, {
                                end_col = #line, hl_group = 'Comment', priority = 50,
                            })
                        end
                    end
                end
                vim.api.nvim_win_set_cursor(windows[side], { #lines, 0 })
            end
            local result = require('codediff.core.diff').compute_diff(original, modified)
            require('codediff.ui.core').render_diff(buffers.original, buffers.modified, original, modified, result)
            _G.rendered_groups = {}
            for _, buf in pairs(buffers) do
                for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buf,
                    require('codediff.ui.highlights').ns_highlight, 0, -1, { details = true })) do
                    rendered_groups[mark[4].hl_group] = true
                end
            end
        end
    ]], vim.fn.getcwd(), codediff)

    for _, cold in ipairs { false, true } do
        local label = cold and 'cold' or 'warm'
        lua([[
            require('deepwhite').setup({ low_blue_light = ..., on_highlights = function() end })
            vim.cmd 'colorscheme deepwhite'
            _G.palette = require('deepwhite.colors').get_colors(require('deepwhite.config').options)
            require('codediff.config').options = vim.deepcopy(require('codediff.config').defaults)
            require('codediff').setup({})
        ]], cold)
        check(label .. ' default line and word diff retain distinct backgrounds and readable plain text', function()
            fixture({ 'anchor', 'mode = old_value', 'tail' }, { 'anchor', 'mode = new_value', 'tail' })
            local original, modified = sample('original', 2, 1), sample('modified', 2, 1)
            eq(original.bg, color('diff_delete_bg'))
            eq(modified.bg, color('diff_add_bg'))
            for _, side in ipairs { 'original', 'modified' } do
                local changed = sample(side, 2, 8)
                assert(changed.bg ~= sample(side, 2, 1).bg, 'Changed span must differ from line context')
                readable(changed, 4.5)
                readable(sample(side, 2, 1), 4.5)
            end
            eq(lua('return rendered_groups.CodeDiffCharInsert and rendered_groups.CodeDiffCharDelete'), true)
        end)
        check(label .. ' documented recipe keeps comment contexts and changed spans readable', function()
            recipe()
            fixture({ 'anchor', '-- mode = old_value', 'tail' }, { 'anchor', '-- mode = new_value', 'tail' }, true)
            for _, side in ipairs { 'original', 'modified' } do
                local context, changed = sample(side, 2, 1), sample(side, 2, 11)
                eq(context.fg, color('comment'))
                eq(changed, { fg = color('base0'), bg = color('diff_text'), bold = false })
                readable(context, 4.5)
                readable(changed, 4.5)
            end
        end)
        check(label .. ' documented recipe covers whole comment additions and deletions', function()
            recipe()
            fixture({ 'anchor', 'tail' }, { 'anchor', '-- added comment', 'tail' }, true)
            eq(lua('return rendered_groups.CodeDiffLineInsert'), true)
            readable(sample('modified', 2, 4), 4.5)
            fixture({ 'anchor', '-- deleted comment', 'tail' }, { 'anchor', 'tail' }, true)
            eq(lua('return rendered_groups.CodeDiffLineDelete'), true)
            readable(sample('original', 2, 4), 4.5)
        end)
        check(label .. ' optional gutter signs and line numbers use readable semantic foregrounds', function()
            lua("require('codediff').setup({ diff = { gutter_signs = { insert_text = '+', delete_text = '-' } } })")
            fixture({ 'anchor', 'old value', 'tail' }, { 'anchor', 'new value', 'tail' })
            for side, role in pairs { original = 'git_delete', modified = 'git_add' } do
                local cells = lua([[
                    local win = windows[...]
                    vim.cmd 'redraw!'
                    local p = vim.fn.screenpos(win, 2, 1)
                    -- Two sign slots and a three-cell number column precede buffer text.
                    assert(vim.fn.screenstring(p.row, p.col - 2) == '2', 'Expected actual changed-line number')
                    return { screen_cell(p.row, p.col - 2), screen_cell(p.row, p.col - 7) }
                ]], side)
                for _, cell in ipairs(cells) do
                    eq(cell.fg, color(role))
                    readable(cell, 3)
                end
            end
        end)
        check(label .. ' native links and documented customization survive theme reload and setup', function()
            recipe()
            lua([[
                require('deepwhite').setup({ on_highlights = function(groups)
                    groups.DiffText = { fg = '#112233', bg = '#EEDDCC', bold = true }
                end })
                vim.cmd 'colorscheme deepwhite'
                require('codediff').setup({})
                for _, name in ipairs { 'CodeDiffCharInsert', 'CodeDiffCharDelete' } do
                    local actual = vim.api.nvim_get_hl(0, { name = name, link = false })
                    assert(actual.fg == 0x112233 and actual.bg == 0xEEDDCC and actual.bold)
                end
                for name, target in pairs {
                    CodeDiffStatusAdded = 'DiagnosticOk', CodeDiffStatusDeleted = 'DiagnosticError',
                    CodeDiffConflictSignAccepted = 'GitSignsAdd', CodeDiffConflictSignRejected = 'GitSignsDelete',
                } do
                    assert(vim.api.nvim_get_hl(0, { name = name }).link == target, name .. ' lost native link')
                end
            ]])
            fixture({ 'anchor', '-- old value', 'tail' }, { 'anchor', '-- new value', 'tail' }, true)
            eq(sample('modified', 2, 4), { fg = 0x112233, bg = 0xEEDDCC, bold = true })
        end)
    end
end, debug.traceback)
vim.fn.jobstop(child)
vim.fn.jobwait({ child }, 2000)
if not ok then print('FAIL CodeDiff UI setup\n' .. err); vim.cmd 'cquit 1' end
print(string.format('RESULT: %d CodeDiff UI checks passed, %d failed', passed, failed))
if failed > 0 or passed == 0 then vim.cmd 'cquit 1' end
vim.cmd 'qa!'
