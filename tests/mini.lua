-- Optional real-module UI test. Set DEEPWHITE_MINI to a mini.nvim runtime directory.
-- No downloads or changes to the user's config; all file edits are unsaved temporary fixtures.
local mini = vim.env.DEEPWHITE_MINI
assert(mini and vim.fn.filereadable(mini .. '/lua/mini/pick.lua') == 1, 'Set DEEPWHITE_MINI to mini.nvim')
assert(vim.fn.filereadable(mini .. '/lua/mini/files.lua') == 1, 'mini.files is required')
local root, fixture = vim.fn.getcwd(), vim.fn.tempname()
vim.fn.mkdir(fixture .. '/src/a-long-directory-name', 'p')
vim.fn.mkdir(fixture .. '/docs', 'p')
local lines = { '-- A temporary preview fixture', 'local alpha = "paper and pastel"', 'return alpha' }
for _, name in ipairs { 'alpha-one.lua', 'alpha-two.lua', 'alpha-three.lua' } do
    vim.fn.writefile(lines, fixture .. '/src/' .. name)
end
vim.fn.writefile(lines, fixture .. '/src/a-long-directory-name/alpha-long.lua')

local child = vim.fn.jobstart({ vim.v.progpath, '--embed', '-u', 'NONE', '-i', 'NONE', '-n' }, { rpc = true })
local function call(method, ...) return vim.rpcrequest(child, method, ...) end
local function lua(code, ...) return call('nvim_exec_lua', code, { ... }) end
local function wait_for(code)
    assert(vim.wait(3000, function() return lua(code) end, 10), 'Timed out: ' .. code)
end
local function input(keys) call('nvim_input', keys) end
local function eq(actual, expected)
    assert(vim.deep_equal(actual, expected), 'expected ' .. vim.inspect(expected) .. ', got ' .. vim.inspect(actual))
end
local passed = 0
local function pass(name)
    passed = passed + 1
    print('PASS ' .. name)
end

local ok, err = xpcall(function()
    call('nvim_ui_attach', 100, 32, { rgb = true })
    lua(
        [[
        local root, mini, fixture = ...
        vim.opt.runtimepath:prepend(root)
        vim.opt.runtimepath:prepend(mini)
        vim.o.laststatus, vim.o.showtabline, vim.o.showmode = 0, 0, false
        vim.o.swapfile = false
        _G.fixture = fixture
        require('mini.pick').setup({ window = { config = { width = 76, height = 12, border = 'single' } } })
        require('mini.files').setup({
            content = { prefix = function(entry) return entry.fs_type == 'directory' and '+ ' or '  ' end },
            options = { use_as_default_explorer = false },
            windows = { preview = true, width_focus = 30, width_nofocus = 18, width_preview = 36 },
        })
        -- screenattr() observes the composed screen, including floating windows.
        -- Compare it with rendered reference cells rather than interpreting its opaque IDs.
        _G.cell = function(win, row, col)
            vim.cmd 'redraw'
            local pos = vim.fn.screenpos(win, row, col)
            assert(pos.row > 0 and pos.col > 0, 'Cell is not visible')
            return vim.fn.screenattr(pos.row, pos.col)
        end
        _G.visible_text_cell = function(win, row, text)
            -- MiniFiles conceals path IDs. screenpos() explicitly ignores conceal columns.
            vim.cmd 'redraw'
            local pos = vim.fn.screenpos(win, row, 1)
            local shown = ''
            for col = pos.col, pos.col + vim.api.nvim_win_get_width(win) - 1 do
                shown = shown .. vim.fn.screenstring(pos.row, col)
            end
            local start = assert(shown:find(text, 1, true), 'Visible text missing: ' .. shown)
            return vim.fn.screenattr(pos.row, pos.col + start - 1)
        end
    ]],
        root,
        mini,
        fixture
    )

    for _, cold in ipairs { false, true } do
        local label = cold and 'cold' or 'warm'
        lua(
            [[
            require('deepwhite').setup({ low_blue_light = ... })
            vim.cmd 'colorscheme deepwhite'
            _G.palette = require('deepwhite.colors').get_colors(require('deepwhite.config').options)
        ]],
            cold
        )
        local refs = lua [[
            local c, defs = palette, {}
            defs.current_marked_plain = { fg = c.base0, bg = c.light_orange, bold = true, underline = true }
            defs.marked_match = { fg = c.hint, bg = c.light_orange, bold = true, underline = true }
            defs.marked_plain = { fg = c.base0, bg = c.light_orange, underline = true }
            defs.normal_match = { fg = c.hint, bg = c.base7, bold = true }
            defs.normal_plain = { fg = c.base0, bg = c.base7 }
            defs.preview = { fg = c.base0, bg = c.light_cyan, bold = true, underline = true }
            defs.directory = { fg = c.hint, bg = c.base6, bold = true }
            local keys = vim.tbl_keys(defs)
            table.sort(keys)
            local buf, win = vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win()
            local ns = vim.api.nvim_create_namespace('DeepwhiteReferences')
            vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.fn['repeat']({ 'X' }, #keys))
            for row, key in ipairs(keys) do
                local name = 'DeepwhiteReference' .. row
                vim.api.nvim_set_hl(0, name, defs[key])
                vim.api.nvim_buf_set_extmark(buf, ns, row - 1, 0, { end_col = 1, hl_group = name })
            end
            vim.bo[buf].modified = false
            vim.cmd 'redraw'
            local result = {}
            for row, key in ipairs(keys) do result[key] = cell(win, row, 1) end
            -- Borders use the UI's default background, not a buffer's Normal composition.
            vim.api.nvim_set_hl(0, 'DeepwhiteBorderReference', { fg = c.warning })
            local border_buf = vim.api.nvim_create_buf(false, true)
            local border_win = vim.api.nvim_open_win(border_buf, false, {
                relative = 'editor', row = 0, col = 85, width = 10, height = 1, border = 'single', style = 'minimal',
            })
            vim.wo[border_win].winhighlight = 'FloatBorder:DeepwhiteBorderReference'
            vim.cmd 'redraw'
            local pos = vim.fn.screenpos(border_win, 1, 1)
            result.border = vim.fn.screenattr(pos.row, pos.col - 1)
            vim.api.nvim_win_close(border_win, true)
            return result
        ]]
        -- Starting after theme loading must not replace the theme's groups with module defaults.
        lua [[
            MiniPick.setup(MiniPick.config)
            MiniFiles.setup(MiniFiles.config)
            assert(vim.api.nvim_get_hl(0, { name = 'MiniPickMatchMarked', link = false }).underline)
        ]]
        pass(label .. ' theme/module load order')

        -- Notify, not request: MiniPick.start waits for the user while still servicing RPC input.
        vim.rpcnotify(
            child,
            'nvim_exec_lua',
            [[
            MiniPick.start({ source = {
                name = 'DeepWhite navigation', cwd = fixture,
                items = {
                    { text = 'src/alpha-one.lua', path = fixture .. '/src/alpha-one.lua', lnum = 2, col = 7, end_col = 12 },
                    { text = 'src/alpha-two.lua', path = fixture .. '/src/alpha-two.lua' },
                    { text = 'src/a-long-directory-name/alpha-long.lua', path = fixture .. '/src/a-long-directory-name/alpha-long.lua' },
                },
            } })
        ]],
            {}
        )
        wait_for 'local s = MiniPick.get_picker_state(); return s ~= nil and not s.is_busy'
        lua "MiniPick.set_picker_query({ 'a', 'l', 'p', 'h', 'a' })"
        wait_for 'return not MiniPick.get_picker_state().is_busy and #MiniPick.get_picker_matches().all == 3'
        lua [[
            MiniPick.set_picker_match_inds({ 1, 2 }, 'marked')
            MiniPick.set_picker_match_inds({ 1 }, 'current')
            MiniPick.refresh()
        ]]
        local rendered = lua [[
            local s = MiniPick.get_picker_state()
            local result = {}
            for row, line in ipairs(vim.api.nvim_buf_get_lines(s.buffers.main, 0, -1, false)) do
                local start = line:find('alpha', 1, true)
                if start then
                    result[#result + 1] = { text = line, plain = cell(s.windows.main, row, 1), match = cell(s.windows.main, row, start) }
                end
            end
            return result
        ]]
        eq(#rendered, 3)
        for _, row in ipairs(rendered) do
            if row.text:find('one.lua', 1, true) then
                eq(row.plain, refs.current_marked_plain)
                eq(row.match, refs.marked_match)
            elseif row.text:find('two.lua', 1, true) then
                eq(row.plain, refs.marked_plain)
                eq(row.match, refs.marked_match)
            else
                eq(row.plain, refs.normal_plain)
                eq(row.match, refs.normal_match)
            end
        end
        pass(label .. ' rendered picker current + marked + matching ranges')

        input '<Tab>'
        wait_for 'local s = MiniPick.get_picker_state(); return s.buffers.preview ~= nil'
        local preview = lua [[
            local s = MiniPick.get_picker_state()
            local buf = vim.api.nvim_win_get_buf(s.windows.main)
            for row, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
                local col = line:find('alpha', 1, true)
                if col and line:find('local', 1, true) then return cell(s.windows.main, row, col) end
            end
            error('Expected preview text not found')
        ]]
        eq(preview, refs.preview)
        pass(label .. ' rendered picker preview region')
        input '<Esc>'
        wait_for 'return not MiniPick.is_picker_active()'

        lua [[
            MiniFiles.open(fixture .. '/src/alpha-one.lua', false)
            MiniFiles.set_branch({ fixture, fixture .. '/src', fixture .. '/src/alpha-one.lua' }, { depth_focus = 2 })
        ]]
        local directory = lua [[
            local s = MiniFiles.get_explorer_state()
            assert(#s.windows == 3, 'Expected parent, focused directory, and preview')
            local focused = vim.api.nvim_get_current_win()
            local focus_hl = vim.wo[focused].winhighlight
            assert(focus_hl:find('FloatTitle:MiniFilesTitleFocused', 1, true))
            assert(vim.wo[s.windows[1].win_id].winhighlight:find('FloatTitle:MiniFilesTitle,', 1, true))
            local directory_cell
            local parent_win = s.windows[1].win_id
            for row, line in ipairs(vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(parent_win), 0, -1, false)) do
                local col = line:find('src', 1, true)
                if col then directory_cell = visible_text_cell(parent_win, row, 'src') end
            end
            assert(directory_cell, 'Directory not shown')
            _G.files_original = vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(focused), 0, -1, false)
            return directory_cell
        ]]
        eq(directory, refs.directory)
        -- Use real input so the module receives its normal TextChanged events.
        input 'Gopending-file.txt<Esc>'
        wait_for [[return vim.wo.winhighlight:find('FloatBorder:MiniFilesBorderModified', 1, true) ~= nil]]
        local border = lua [[
            vim.cmd 'redraw'
            local pos = vim.fn.screenpos(vim.api.nvim_get_current_win(), 1, 1)
            local result = vim.fn.screenattr(pos.row, pos.col - 1)
            -- Restore the original listing before close: there are no filesystem actions to confirm.
            vim.api.nvim_buf_set_lines(0, 0, -1, false, files_original)
            vim.bo.modified = false
            assert(MiniFiles.close(), 'Explorer must close without synchronizing changes')
            return result
        ]]
        eq(border, refs.border)
        eq(vim.fn.filereadable(fixture .. '/src/pending-file.txt'), 0)
        pass(label .. ' rendered files columns, focused directory, and pending-edit border')
    end
end, debug.traceback)

vim.fn.jobstop(child)
vim.fn.jobwait({ child }, 2000)
vim.fn.delete(fixture, 'rf')
if not ok then
    print('FAIL mini UI integration\n' .. err)
    vim.cmd 'cquit 1'
end
print(string.format('RESULT: %d mini UI checks passed', passed))
vim.cmd 'qa!'
