local M = {}

M.options = {
    low_blue_light = false,
}

function M.setup(options)
	M.options = vim.tbl_deep_extend('force', M.options, options or {})
end

return M
