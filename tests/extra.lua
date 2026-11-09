-- Readers for the checked-in extra-file layouts, not general TOML/YAML parsers.
-- Keep core tests dependency-free; native JSON/TOML/YAML parsing can be checked separately.
local M = {}
local root = 'extra/'
local function numbered(values)
    local result = { foreground = values.foreground, background = values.background, ansi = {} }
    for i = 0, 15 do result.ansi[i + 1] = assert(values['color' .. i], 'Missing color' .. i) end
    return result
end

M.terminals = {
    Kitty = function()
        local values = {}
        for _, line in ipairs(vim.fn.readfile(root .. 'deepwhite_kitty.conf')) do
            local key, value = line:match('^([%w_]+)%s+(#%x+)%s*$')
            if key then values[key] = value end
        end
        return numbered(values)
    end,
    Xresources = function()
        local values = {}
        for _, line in ipairs(vim.fn.readfile(root .. 'deepwhite_xresources.Xresources')) do
            local key, value = line:match('^%*([%w_]+):%s*(#%x+)%s*$')
            if key then values[key] = value end
        end
        return numbered(values)
    end,
    WezTerm = function()
        local values, section = {}, nil
        for _, line in ipairs(vim.fn.readfile(root .. 'deepwhite_wezterm.toml')) do
            section = line:match('^%[([^%]]+)%]$') or section
            if section == 'colors' then
                local key, value = line:match([[^([%w_]+)%s*=%s*["'](#%x+)["']%s*$]])
                if key then values[key] = value end
                local list, contents = line:match('^(ansi)%s*=%s*%[(.*)%]%s*$')
                if not list then list, contents = line:match('^(brights)%s*=%s*%[(.*)%]%s*$') end
                if list then
                    values[list] = {}
                    for color in contents:gmatch('#%x+') do table.insert(values[list], color) end
                    assert(#values[list] == 8, list .. ' must have eight colors')
                end
            end
        end
        local result = { foreground = values.foreground, background = values.background, ansi = {} }
        for _, list in ipairs { 'ansi', 'brights' } do
            for _, color in ipairs(assert(values[list], 'Missing ' .. list)) do table.insert(result.ansi, color) end
        end
        return result
    end,
    ['Windows Terminal'] = function()
        local values = vim.fn.json_decode(table.concat(vim.fn.readfile(root .. 'deepwhite_windows_terminal.json'), '\n'))
        local result = { foreground = values.foreground, background = values.background, ansi = {} }
        for _, key in ipairs {
            'black', 'red', 'green', 'yellow', 'blue', 'purple', 'cyan', 'white',
            'brightBlack', 'brightRed', 'brightGreen', 'brightYellow', 'brightBlue', 'brightPurple', 'brightCyan', 'brightWhite',
        } do
            local color = assert(values[key], 'Missing ' .. key)
            table.insert(result.ansi, color)
        end
        return result
    end,
}

function M.vivid()
    local result, section, style = { colors = {}, styles = {} }, nil, nil
    for _, line in ipairs(vim.fn.readfile(root .. 'vivid_themes_deepwhite.yml')) do
        local indent, key, value = line:match('^(%s*)([%w_-]+):%s*(.-)%s*$')
        if key then
            if #indent == 0 then
                section, style = key, nil
            elseif section == 'colors' then
                local hex = assert(value:match("^'(%x+)'"), 'Expected quoted vivid color: ' .. line)
                assert(#hex == 6, 'Expected six-digit vivid color: ' .. line)
                result.colors[key] = '#' .. hex
            elseif #indent == 2 then
                style = section .. '.' .. key
                result.styles[style] = {}
            elseif #indent == 4 and (key == 'foreground' or key == 'background') then
                assert(style, 'Expected vivid style before ' .. line)
                result.styles[style][key] = value
            end
        end
    end
    return result
end

return M
