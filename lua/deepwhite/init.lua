local config = require 'deepwhite.config'
local M = {}

function M.setup(opts) config.setup(opts) end

function M.load()
    if vim.version().minor < 7 then
        vim.notify_once 'deepwhite.nvim: you must use neovim 0.7 or higher'
        return
    end
    vim.cmd [[hi clear]]

    vim.g.colors_name = 'deepwhite'
    vim.o.background = 'light'
    vim.o.termguicolors = true

    local colors = require('deepwhite.colors').get_colors(config.options)
    local groups = require('deepwhite.scheme').get_groups(colors)

    local non_linked_groups = {}
    local linked_groups = {}

    for gname, gdef in pairs(groups) do
        if gdef.link then
            table.insert(linked_groups, { name = gname, definition = gdef })
        else
            table.insert(non_linked_groups, { name = gname, definition = gdef })
        end
    end

    for _, group in ipairs(non_linked_groups) do
        vim.api.nvim_set_hl(0, group.name, group.definition)
    end

    for _, group in ipairs(linked_groups) do
        vim.api.nvim_set_hl(0, group.name, group.definition)
    end
end

return M
