-- Optional real render-markdown UI test. No downloads, user configuration, or saved fixtures.
-- DEEPWHITE_MARKDOWN=/path/to/render-markdown.nvim [DEEPWHITE_TREESITTER=/path/to/nvim-treesitter/runtime] \
--   nvim --headless -u NONE -i NONE -n -l tests/markdown.lua
-- Requires installed markdown, markdown_inline and lua parsers; DEEPWHITE_PARSERS may point to
-- another runtime directory containing parser/*.so. Neovim 0.12.6 provides these parsers itself.
local markdown = vim.env.DEEPWHITE_MARKDOWN
assert(
    markdown and vim.fn.filereadable(markdown .. '/plugin/render-markdown.lua') == 1,
    'Set DEEPWHITE_MARKDOWN to render-markdown.nvim'
)
local child = vim.fn.jobstart({ vim.v.progpath, '--embed', '-u', 'NONE', '-i', 'NONE', '-n' }, { rpc = true })
local function call(method, ...) return vim.rpcrequest(child, method, ...) end
local function lua(code, ...) return call('nvim_exec_lua', code, { ... }) end
local function wait_for(code)
    assert(vim.wait(4000, function() return lua(code) end, 10), 'Timed out: ' .. code)
end
local function eq(actual, expected)
    assert(vim.deep_equal(actual, expected), 'expected ' .. vim.inspect(expected) .. ', got ' .. vim.inspect(actual))
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
local function sample(row, text) return lua('return visible_cell(...)', row, text) end
local function expected(fg, bg, style)
    return lua(
        [[
        local fg, bg, style = ...
        local c = require('deepwhite.colors').get_colors(require('deepwhite.config').options)
        return { fg = tonumber(c[fg]:sub(2), 16), bg = tonumber(c[bg]:sub(2), 16),
            bold = style == 'bold', underline = style == 'underline' }
    ]],
        fg,
        bg,
        style
    )
end
local function readable(cell, minimum)
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
    local ratio = (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05)
    assert(
        ratio >= minimum,
        string.format('Rendered contrast %.4f is below %.1f: %s', ratio, minimum, vim.inspect(cell))
    )
end
local function render()
    lua [[
        rendered = false
        require('render-markdown').render({ buf = vim.api.nvim_get_current_buf() })
    ]]
    wait_for 'return rendered'
end

local ok, err = xpcall(function()
    call('nvim_ui_attach', 100, 42, { rgb = true })
    lua(
        [=[
        local root, markdown, treesitter, parsers = ...
        if treesitter then
            assert(vim.fn.isdirectory(treesitter .. '/queries/markdown') == 1,
                'DEEPWHITE_TREESITTER must contain queries/markdown (use nvim-treesitter/runtime)')
            vim.opt.runtimepath:prepend(treesitter)
        end
        if parsers then vim.opt.runtimepath:prepend(parsers) end
        vim.opt.runtimepath:prepend(markdown)
        vim.opt.runtimepath:prepend(root)
        for _, lang in ipairs { 'markdown', 'markdown_inline', 'lua' } do
            assert(pcall(vim.treesitter.language.add, lang), 'An installed ' .. lang .. ' parser is required')
        end
        vim.o.laststatus, vim.o.showtabline, vim.o.showmode = 0, 0, false
        vim.o.swapfile = false
        vim.wo.wrap = false
        _G.win = vim.api.nvim_get_current_win()
        -- Enable inspection before redraw; sample only the ordinary window on the default grid.
        vim.api.nvim__inspect_cell(1, 0, 0)
        _G.screen_cell = function(row, col)
            local attr = vim.api.nvim__inspect_cell(1, row - 1, col - 1)[2]
            local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
            return { fg = attr.foreground or normal.fg, bg = attr.background or normal.bg,
                bold = attr.bold == true, underline = attr.underline == true }
        end
        _G.screen_line = function(row)
            vim.cmd 'redraw!'
            local p = vim.fn.screenpos(win, row, 1)
            assert(p.row > 0, 'Expected a visible buffer row: ' .. row)
            local text, columns = '', {}
            for col = p.col, math.min(vim.o.columns, p.col + vim.api.nvim_win_get_width(win) - 1) do
                local char = vim.fn.screenstring(p.row, col)
                columns[#text + 1] = col
                text = text .. char
            end
            return text, columns, p.row
        end
        _G.visible_cell = function(row, text)
            local line, columns, screenrow = screen_line(row)
            local start = assert(line:find(text, 1, true), 'Missing visible text ' .. text .. ': ' .. line)
            return screen_cell(screenrow, columns[start])
        end
        _G.mark = function(row, group)
            local ns = assert(vim.api.nvim_get_namespaces()['render-markdown.nvim'])
            for _, item in ipairs(vim.api.nvim_buf_get_extmarks(0, ns, { row - 1, 0 }, { row - 1, -1 }, { details = true })) do
                local def = item[4]
                if def.hl_group == group then return def end
                for _, chunk in ipairs(def.virt_text or {}) do
                    local groups = type(chunk[2]) == 'table' and chunk[2] or { chunk[2] }
                    if vim.tbl_contains(groups, group) then return def, chunk[1] end
                end
            end
            error('Expected real plugin decoration ' .. group .. ' at row ' .. row)
        end
        _G.render_options = {
            code = { conceal_delimiters = false, language = false, border = 'none' },
            heading = { setext = false }, html = { comment = { conceal = false } },
            latex = { enabled = false }, patterns = { markdown = { disable = true } },
            on = { render = function() _G.rendered = true end, clear = function() _G.cleared = true end },
        }
        require('deepwhite').setup({ low_blue_light = false })
        vim.cmd 'colorscheme deepwhite'
        require('render-markdown').setup(render_options)
        vim.cmd 'runtime plugin/render-markdown.lua'
        vim.bo.filetype = 'markdown'
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {
            '# Heading one', '## Heading two', '### Heading three', '#### Heading four',
            '##### Heading five', '###### Heading six', '',
            'Plain [Example link](https://example.com) and `inline_code`.', '',
            '- ordinary item', '- [ ] pending item', '- [x] completed item', '',
            '> quoted text', '', '| Name | Value |', '| ---- | ----- |', '| alpha | beta |', '',
            '```lua', '-- Comment inside code', 'local value = "paper"', '```', '',
            'Setext heading', '--------------', '', '<!-- visible comment -->', '', 'cursor anchor',
        })
        vim.api.nvim_win_set_cursor(win, { 30, 0 })
        vim.treesitter.start(0, 'markdown')
    ]=],
        vim.fn.getcwd(),
        markdown,
        vim.env.DEEPWHITE_TREESITTER,
        vim.env.DEEPWHITE_PARSERS
    )

    for _, cold in ipairs { false, true } do
        local label = cold and 'cold' or 'warm'
        lua(
            [[
            require('deepwhite').setup({ low_blue_light = ... })
            vim.cmd 'colorscheme deepwhite'
            vim.api.nvim_win_set_cursor(win, { 30, 0 })
        ]],
            cold
        )
        render()
        check(label .. ' six headings remain bold and readable without diff backgrounds', function()
            for row, text in ipairs {
                'Heading one',
                'Heading two',
                'Heading three',
                'Heading four',
                'Heading five',
                'Heading six',
            } do
                lua('mark(...)', row, 'RenderMarkdownH' .. row .. 'Bg')
                local cell = sample(row, text)
                eq(cell, expected('base0', 'base7', 'bold'))
                readable(cell, 4.5)
            end
        end)
        check(label .. ' actual link icon and label remain underlined and inline code distinct', function()
            local icon = lua "local _, icon = mark(8, 'RenderMarkdownLink'); return icon"
            local cell = sample(8, 'Example link')
            eq(cell, expected('base0', 'base7', 'underline'))
            readable(cell, 4.5)
            readable(sample(8, icon), 3)
            lua "mark(8, 'RenderMarkdownCodeInline')"
            cell = sample(8, 'inline_code')
            eq(cell, expected('base0', 'base8'))
            readable(cell, 4.5)
        end)
        check(label .. ' list and checked states use readable text and distinct markers', function()
            for row, text in pairs { [10] = 'ordinary item', [11] = 'pending item', [12] = 'completed item' } do
                readable(sample(row, text), 4.5)
            end
            local icons = lua [[
                local _, bullet = mark(10, 'RenderMarkdownBullet')
                local _, unchecked = mark(11, 'RenderMarkdownUnchecked')
                local _, checked = mark(12, 'RenderMarkdownChecked')
                return { bullet, unchecked, checked }
            ]]
            assert(icons[2] ~= icons[3], 'Checkbox states must differ by shape, not color alone')
            readable(sample(10, icons[1]), 3)
            eq(sample(11, icons[2]), expected('base0', 'base7'))
            eq(sample(12, icons[3]), expected('comment', 'base7'))
            readable(sample(12, icons[3]), 3)
        end)
        check(label .. ' quote and real table decorations remain readable', function()
            local quote = lua "local _, icon = mark(14, 'RenderMarkdownQuote1'); return icon"
            readable(sample(14, quote), 3)
            readable(sample(14, 'quoted text'), 4.5)
            lua "mark(16, 'RenderMarkdownTableHead'); mark(18, 'RenderMarkdownTableRow')"
            eq(sample(16, 'Name'), expected('base0', 'base7', 'bold'))
            eq(sample(18, 'alpha'), expected('base0', 'base7'))
            for _, row in ipairs { 15, 16, 17, 18, 19 } do
                readable(sample(row, row == 15 and '┌' or row == 17 and '├' or row == 19 and '└' or '│'), 3)
            end
        end)
        check(label .. ' Lua comment on code background and original fences remain readable', function()
            lua "mark(21, 'RenderMarkdownCode'); mark(22, 'RenderMarkdownCode')"
            eq(sample(21, 'Comment inside code'), expected('comment', 'base8'))
            readable(sample(21, 'Comment inside code'), 4.5)
            eq(sample(22, 'local'), expected('base0', 'base8'))
            readable(sample(22, 'paper'), 4.5)
            readable(sample(20, '```lua'), 4.5)
            readable(sample(23, '```'), 4.5)
            readable(sample(25, 'Setext heading'), 4.5)
            readable(sample(26, '--------------'), 3)
            readable(sample(28, '<!-- visible comment -->'), 4.5)
        end)
        check(label .. ' insert mode removes rendered code background and normal mode restores it', function()
            lua 'cleared = false'
            call('nvim_input', 'i')
            wait_for "return vim.fn.mode() == 'i' and cleared"
            eq(sample(21, 'Comment inside code'), expected('comment', 'base7'))
            call('nvim_input', '<Esc>')
            wait_for "return vim.fn.mode() == 'n'"
            render()
            eq(sample(21, 'Comment inside code'), expected('comment', 'base8'))
        end)
        check(label .. ' theme reload and module setup preserve default links and background overrides', function()
            lua [[
                vim.cmd 'colorscheme deepwhite'
                require('render-markdown').setup(render_options)
                local links = {
                    RenderMarkdownCode = 'ColorColumn', RenderMarkdownCodeInline = 'RenderMarkdownCode',
                    RenderMarkdownLink = '@markup.link.label.markdown_inline',
                    RenderMarkdownChecked = '@markup.list.checked', RenderMarkdownTableHead = '@markup.heading',
                }
                for name, target in pairs(links) do
                    assert(vim.api.nvim_get_hl(0, { name = name }).link == target, name .. ' lost default link')
                end
                for i = 1, 6 do
                    assert(vim.api.nvim_get_hl(0, { name = 'RenderMarkdownH' .. i .. 'Bg' }).link == 'Bold')
                end
            ]]
            render()
            eq(sample(1, 'Heading one'), expected('base0', 'base7', 'bold'))
            eq(sample(21, 'Comment inside code'), expected('comment', 'base8'))
        end)
    end
end, debug.traceback)
vim.fn.jobstop(child)
vim.fn.jobwait({ child }, 2000)
if not ok then
    print('FAIL render-markdown UI integration\n' .. err)
    vim.cmd 'cquit 1'
end
print(string.format('RESULT: %d render-markdown UI checks passed, %d failed', passed, failed))
if failed > 0 or passed == 0 then vim.cmd 'cquit 1' end
vim.cmd 'qa!'
