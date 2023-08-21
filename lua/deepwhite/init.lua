local config = require("deepwhite.config")
local M = {}

function M.setup(opts)
	config.setup(opts)
end

function M.load()
	if vim.version().minor < 7 then
		vim.notify_once("deepwhite.nvim: you must use neovim 0.7 or higher")
		return
	end
	vim.cmd([[hi clear]])

	vim.g.colors_name = "deepwhite"
	vim.o.background = "light"
	vim.o.termguicolors = true

	local colors = require("deepwhite.colors").get_colors(config.options)
	local groups = require("deepwhite.scheme").get_groups(colors)

	for name, val in pairs(groups) do
		vim.api.nvim_set_hl(0, name, val)
	end
end

return M
