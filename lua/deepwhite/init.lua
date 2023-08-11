local scheme = require("deepwhite.scheme")
local M = {}

function M.load()
    vim.cmd [[hi clear]]

	vim.g.colors_name = "deepwhite"
	vim.o.background = "light"
	vim.o.termguicolors = true

	for name, val in pairs(scheme) do
		vim.api.nvim_set_hl(0, name, val)
	end
end

return M
