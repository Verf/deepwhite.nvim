local M = {}

M.config = {
	low_blue_light = true,
}

function M.setup(config)
	M.config = vim.tbl_deep_extend("force", M.config, config or {})
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

	local groups = require("deepwhite.scheme").get_groups()

	for name, val in pairs(groups) do
		vim.api.nvim_set_hl(0, name, val)
	end
end

return M
