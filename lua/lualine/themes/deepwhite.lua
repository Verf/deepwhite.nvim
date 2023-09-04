local config = require("deepwhite.config")
local colors = require("deepwhite.colors").get_colors(config.options)
vim.opt.fillchars:append({ stl = "─", stlnc = "─" })

return {
	visual = {
		a = { fg = colors.base7, bg = colors.base0, gui = "bold" },
		b = { fg = colors.base0, bg = colors.base7 },
		c = { fg = colors.base0, bg = colors.base7 },
	},
	replace = {
		a = { fg = colors.base7, bg = colors.base0, gui = "bold" },
		b = { fg = colors.base0, bg = colors.base7 },
		c = { fg = colors.base0, bg = colors.base7 },
	},
	inactive = {
		a = { fg = colors.base7, bg = colors.base0, gui = "bold" },
		b = { fg = colors.base0, bg = colors.base7 },
		c = { fg = colors.base0, bg = colors.base7 },
	},
	normal = {
		a = { fg = colors.base7, bg = colors.base0, gui = "bold" },
		b = { fg = colors.base0, bg = colors.base7 },
		c = { fg = colors.base0, bg = colors.base7 },
	},
	insert = {
		a = { fg = colors.base7, bg = colors.base0, gui = "bold" },
		b = { fg = colors.base0, bg = colors.base7 },
		c = { fg = colors.base0, bg = colors.base7 },
	},
}
