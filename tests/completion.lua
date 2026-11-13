-- Optional UI test: DEEPWHITE_MINI=/path/to/mini.nvim nvim --headless -u NONE -i NONE -n -l tests/completion.lua
-- Uses real mini.completion and Neovim LSP with an in-memory response fixture, not an external language server.
local mini = vim.env.DEEPWHITE_MINI
assert(mini and vim.fn.filereadable(mini .. '/lua/mini/completion.lua') == 1, 'Set DEEPWHITE_MINI to mini.nvim')
local child = vim.fn.jobstart({ vim.v.progpath, '--embed', '-u', 'NONE', '-i', 'NONE', '-n' }, { rpc = true })
local function call(method, ...) return vim.rpcrequest(child, method, ...) end
local function lua(code, ...) return call('nvim_exec_lua', code, { ... }) end
local function wait_for(code)
    if vim.wait(3000, function() return lua(code) end, 10) then return end
    local state = lua [[
        local win = actions and actions.info
        return { mode = vim.fn.mode(), completion = vim.fn.complete_info(), requests = requests,
            pending_resolve = pending_resolve ~= nil,
            info_highlight = win and vim.api.nvim_win_is_valid(win) and vim.wo[win].winhighlight or 'no info window' }
    ]]
    error('Timed out: ' .. code .. '\n' .. vim.inspect(state))
end
local function eq(actual, expected)
    assert(vim.deep_equal(actual, expected), 'expected ' .. vim.inspect(expected) .. ', got ' .. vim.inspect(actual))
end
local function input(keys) call('nvim_input', keys) end
local passed = 0
local function pass(name)
    passed = passed + 1
    print('PASS ' .. name)
end

local ok, err = xpcall(function()
    call('nvim_ui_attach', 100, 36, { rgb = true })
    lua(
        [[
        local root, mini = ...
        vim.opt.runtimepath:prepend(root)
        vim.opt.runtimepath:prepend(mini)
        vim.o.laststatus, vim.o.showtabline, vim.o.showmode = 0, 0, false
        vim.o.completeopt = 'menuone,noselect,noinsert,fuzzy,nosort'
        vim.o.swapfile = false
        require('mini.completion').setup({ delay = { completion = 10^7, info = 80, signature = 20 } })
        vim.bo.completefunc = 'v:lua.MiniCompletion.completefunc_lsp'
        _G.actions, _G.requests = {}, {}
        vim.api.nvim_create_autocmd('User', {
            pattern = { 'MiniCompletionWindowOpen', 'MiniCompletionWindowUpdate' },
            callback = function(args) actions[args.data.kind] = args.data.win_id end,
        })
        _G.float_with = function(text)
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_config(win).relative ~= '' then
                    local buf = vim.api.nvim_win_get_buf(win)
                    for row, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
                        local col = line:find(text, 1, true)
                        if col then return { win = win, row = row, col = col } end
                    end
                end
            end
        end
        _G.cell = function(win, row, col)
            vim.cmd 'redraw'
            local pos = vim.fn.screenpos(win, row, col)
            assert(pos.row > 0 and pos.col > 0, 'Expected a visible cell')
            return vim.fn.screenattr(pos.row, pos.col)
        end
        _G.border_cell = function(win)
            vim.cmd 'redraw'
            local pos = vim.fn.screenpos(win, 1, 1)
            return vim.fn.screenattr(pos.row, pos.col - 1)
        end
        _G.client_id = vim.lsp.start({
            name = 'deepwhite-completion-fixture', root_dir = root,
            cmd = function(dispatchers)
                local id, closing = 0, false
                return {
                    request = function(method, params, callback)
                        id = id + 1
                        requests[method] = (requests[method] or 0) + 1
                        local result
                        if method == 'initialize' then
                            result = { capabilities = {
                                textDocumentSync = 1,
                                completionProvider = { resolveProvider = true },
                                signatureHelpProvider = { triggerCharacters = { '(', ',' } },
                                hoverProvider = true,
                            } }
                        elseif method == 'textDocument/completion' then
                            result = {
                                { label = 'alpha', kind = 3, sortText = '01' },
                                { label = 'alpha_old', kind = 3, sortText = '02', tags = { 1 } },
                                { label = 'alpine', kind = 3, sortText = '03' },
                            }
                        elseif method == 'completionItem/resolve' then
                            result = vim.deepcopy(params)
                            result.documentation = { kind = 'plaintext', value = 'Documentation for ' .. params.label }
                            if params.label == 'alpha_old' then
                                _G.pending_resolve = function() callback(nil, result) end
                                return true, id
                            end
                        elseif method == 'textDocument/signatureHelp' then
                            result = { activeParameter = 1, signatures = { {
                                label = 'alpha(first, second)',
                                parameters = { { label = 'first' }, { label = 'second' } },
                            } } }
                        elseif method == 'textDocument/hover' then
                            result = { contents = { kind = 'plaintext', value = 'Native hover documentation' } }
                        elseif method ~= 'shutdown' then
                            error('Unexpected fixture request: ' .. method)
                        end
                        vim.schedule(function() callback(nil, result) end)
                        return true, id
                    end,
                    notify = function() return true end,
                    is_closing = function() return closing end,
                    terminate = function()
                        closing = true
                        dispatchers.on_exit(0, 0)
                    end,
                }
            end,
        })
        assert(client_id, 'LSP fixture did not start')
    ]],
        vim.fn.getcwd(),
        mini
    )
    wait_for 'return vim.lsp.get_client_by_id(client_id).initialized'

    for _, cold in ipairs { false, true } do
        local label = cold and 'cold' or 'warm'
        lua(
            [[
            require('deepwhite').setup({ low_blue_light = ..., on_highlights = function() end })
            vim.cmd 'colorscheme deepwhite'
            MiniCompletion.setup(MiniCompletion.config)
            _G.palette = require('deepwhite.colors').get_colors(require('deepwhite.config').options)
        ]],
            cold
        )
        local links = lua [[
            local result = {}
            for _, name in ipairs { 'MiniCompletionActiveParameter', 'MiniCompletionDeprecated', 'MiniCompletionInfoBorderOutdated' } do
                result[name] = vim.api.nvim_get_hl(0, { name = name }).link
            end
            return result
        ]]
        eq(links.MiniCompletionActiveParameter, 'LspSignatureActiveParameter')
        eq(links.MiniCompletionDeprecated, 'DiagnosticDeprecated')
        eq(links.MiniCompletionInfoBorderOutdated, 'DiagnosticFloatingWarn')
        pass(label .. ' completion uses upstream default links')

        local refs = lua [[
            local c = palette
            local defs = {
                normal = { fg = c.base0, bg = c.base7 },
                selected = { fg = c.base0, bg = c.base6 },
                match = { fg = c.hint, bg = c.base7, bold = true },
                match_selected = { fg = c.hint, bg = c.base6, bold = true },
                deprecated = { fg = c.base0, bg = c.base6, strikethrough = true },
                deprecated_match = { fg = c.hint, bg = c.base6, bold = true, strikethrough = true },
                active = { fg = c.base0, bg = c.base7, underline = true },
                active_custom = { fg = c.hint, bg = c.base7, bold = true, underline = true },
            }
            local keys = vim.tbl_keys(defs)
            table.sort(keys)
            local text = vim.fn['repeat']({ 'X' }, #keys)
            while #text < 20 do text[#text + 1] = '' end
            vim.api.nvim_buf_set_lines(0, 0, -1, false, text)
            local ns = vim.api.nvim_create_namespace('CompletionReferences')
            vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
            for row, key in ipairs(keys) do
                local name = 'DeepwhiteCompletionReference' .. row
                vim.api.nvim_set_hl(0, name, defs[key])
                vim.api.nvim_buf_set_extmark(0, ns, row - 1, 0, { hl_group = name, end_col = 1 })
            end
            local result = {}
            for row, key in ipairs(keys) do result[key] = cell(vim.api.nvim_get_current_win(), row, 1) end
            for key, color in pairs { border = c.base0, outdated = c.warning } do
                vim.api.nvim_set_hl(0, 'CompletionBorderReference', { fg = color })
                local buf = vim.api.nvim_create_buf(false, true)
                local win = vim.api.nvim_open_win(buf, false, {
                    relative = 'editor', row = 0, col = 85, width = 10, height = 1, border = 'single', style = 'minimal',
                })
                vim.wo[win].winhighlight = 'FloatBorder:CompletionBorderReference'
                result[key] = border_cell(win)
                vim.api.nvim_win_close(win, true)
            end
            vim.api.nvim_win_set_cursor(0, { 15, 0 })
            return result
        ]]
        assert(refs.match ~= refs.normal, 'Rendered reference cells must distinguish matching text')

        input 'ial'
        wait_for "return vim.fn.mode() == 'i'"
        lua 'MiniCompletion.complete_twostage(false, true)'
        wait_for 'return vim.fn.pumvisible() == 1 and #vim.fn.complete_info().items == 3'
        local plain_menu = lua [[
            vim.cmd 'redraw'
            local p = vim.fn.pum_getpos()
            return { vim.fn.screenattr(p.row + 1, p.col + 1), vim.fn.screenattr(p.row + 1, p.col + 3) }
        ]]
        eq(plain_menu[1], refs.match)
        eq(plain_menu[2], refs.normal)
        input '<C-n>'
        wait_for "return vim.fn.complete_info().selected == 0 and float_with('Documentation for alpha') ~= nil"
        local selected_menu = lua [[
            vim.cmd 'redraw'
            local p = vim.fn.pum_getpos()
            return { vim.fn.screenattr(p.row + 1, p.col + 1), vim.fn.screenattr(p.row + 1, p.col + 3) }
        ]]
        eq(selected_menu[1], refs.match_selected)
        eq(selected_menu[2], refs.selected)
        pass(label .. ' native popup distinguishes matches with and without selection')

        local doc = lua [[
            local f = assert(float_with('Documentation for alpha'))
            return { text = cell(f.win, f.row, f.col), border = border_cell(f.win) }
        ]]
        eq(doc.text, refs.normal)
        eq(doc.border, refs.border)
        -- Upstream sorts deprecated candidates after non-deprecated ones, even with sortText.
        input '<C-n><C-n>'
        wait_for [[return pending_resolve ~= nil and vim.wo[actions.info].winhighlight:find('MiniCompletionInfoBorderOutdated', 1, true) ~= nil]]
        eq(lua 'return border_cell(actions.info)', refs.outdated)
        local deprecated = lua [[
            vim.cmd 'redraw'
            local p = vim.fn.pum_getpos()
            local row = p.row + vim.fn.complete_info().selected + 1
            return { vim.fn.screenattr(row, p.col + 1), vim.fn.screenattr(row, p.col + 3) }
        ]]
        eq(deprecated[1], refs.deprecated_match)
        eq(deprecated[2], refs.deprecated)
        lua 'pending_resolve(); pending_resolve = nil'
        wait_for "return float_with('Documentation for alpha_old') ~= nil"
        eq(lua 'return border_cell(actions.info)', refs.border)
        pass(label .. ' deprecated item and stale/resolved documentation use native semantics')
        input '<C-e><Esc>'
        wait_for "return vim.fn.mode() == 'n'"

        lua "vim.api.nvim_buf_set_lines(0, 14, 15, false, { '' }); vim.api.nvim_win_set_cursor(0, { 15, 0 })"
        input 'ialpha('
        wait_for "return float_with('alpha(first, second)') ~= nil"
        local signature = lua [[
            local f = assert(float_with('alpha(first, second)'))
            local line = vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(f.win), f.row - 1, f.row, false)[1]
            return { normal = cell(f.win, f.row, line:find('first', 1, true)),
                active = cell(f.win, f.row, line:find('second', 1, true)), border = border_cell(f.win) }
        ]]
        eq(signature.normal, refs.normal)
        eq(signature.active, refs.active)
        eq(signature.border, refs.border)
        input '<Esc>'
        wait_for "return vim.fn.mode() == 'n'"
        lua [[
            require('deepwhite').setup({ on_highlights = function(groups, c)
                groups.LspSignatureActiveParameter = { fg = c.hint, bold = true, underline = true }
            end })
            vim.cmd 'colorscheme deepwhite'
            vim.api.nvim_buf_set_lines(0, 14, 15, false, { '' })
            vim.api.nvim_win_set_cursor(0, { 15, 0 })
        ]]
        input 'ialpha('
        wait_for "return float_with('alpha(first, second)') ~= nil"
        local custom = lua [[
            local f = assert(float_with('alpha(first, second)'))
            local line = vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(f.win), f.row - 1, f.row, false)[1]
            return cell(f.win, f.row, line:find('second', 1, true))
        ]]
        eq(custom, refs.active_custom)
        pass(label .. ' signature active parameter follows native user override after reload')
        input '<Esc>'
        wait_for "return vim.fn.mode() == 'n'"
        lua "vim.lsp.buf.hover({ border = 'single' })"
        wait_for "return float_with('Native hover documentation') ~= nil"
        local hover = lua [[
            local f = assert(float_with('Native hover documentation'))
            local result = { text = cell(f.win, f.row, f.col), border = border_cell(f.win) }
            vim.api.nvim_win_close(f.win, true)
            return result
        ]]
        eq(hover.text, refs.normal)
        eq(hover.border, refs.border)
        pass(label .. ' native LSP hover shares documentation float styling')
    end
    lua [[
        for _, method in ipairs { 'textDocument/completion', 'completionItem/resolve', 'textDocument/signatureHelp', 'textDocument/hover' } do
            assert((requests[method] or 0) > 0, 'LSP path not exercised: ' .. method)
        end
    ]]
end, debug.traceback)

vim.fn.jobstop(child)
vim.fn.jobwait({ child }, 2000)
if not ok then
    print('FAIL completion UI integration\n' .. err)
    vim.cmd 'cquit 1'
end
print(string.format('RESULT: %d completion UI checks passed', passed))
vim.cmd 'qa!'
