local M = {}

M.options = {
    low_blue_light = false,
    terminal_colors = false,
    on_colors = function(colors) end,
    on_highlights = function(groups, colors) end,
}

function M.setup(options)
    if options == nil then return end
    assert(type(options) == 'table', 'deepwhite.nvim: setup options must be a table')
    for name, expected in pairs {
        low_blue_light = 'boolean',
        terminal_colors = 'boolean',
        on_colors = 'function',
        on_highlights = 'function',
    } do
        if options[name] ~= nil then
            assert(type(options[name]) == expected, 'deepwhite.nvim: ' .. name .. ' must be a ' .. expected)
        end
    end
    M.options = vim.tbl_deep_extend('force', M.options, options)
end

return M
