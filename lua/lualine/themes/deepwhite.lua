local config = require("deepwhite.config")
local colors = require("deepwhite.colors").get_colors(config.options)

--[[--Why do we have to do this?--
  You might think we could do the following:

    vim.opt.fillchars:append({ stl = "─", stlnc = "─" })

  However, this has a problem: it will update both the local and global values
  of fillchar, and in particular, the local value will override the global
  value.

  To avoid this behavior, we have to explicitly specify the scope---local or
  global---when setting an option value.
]]
function set_option_safe(name, setter)
    for scope in {"local", "global"} do
        local scoped_value = vim.api.nvim_get_option_value(name, {scope = scope})
        vim.api.nvim_set_option_value(name, setter(scoped_value), { scope = scope })
    end
end
set_option_safe("fillchars", function (fcs) { stl = "─", stlnc = "─", table.unpack(fcs) } end)

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
