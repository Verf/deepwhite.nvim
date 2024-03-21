local M = {}

function M.get_colors(options)
	local colors = {
		base0 = "#1A1918", -- hsv(30, 8%, 10%)
		base1 = "#595855", -- hsv(45, 4%, 35%)
		base2 = "#807E79", -- hsv(43, 5%, 50%)
		base3 = "#999791", -- hsv(45, 5%, 60%)
		base4 = "#B3B1AD", -- hsv(40, 3%, 70%)
		base5 = "#CCCBC6", -- hsv(50, 3%, 80%)
		base6 = "#E6E4DF", -- hsv(43, 3%, 90%)
		base7 = "#FAF2EB", -- hsv(24, 4%, 98%)

		light_orange = "#FAE1C8", -- hsv(30, 20%, 98%)
		light_yellow = "#FAFAC8", -- hsv(60, 20%, 98%)
		light_cyan = "#C8FAFA", -- hsv(180, 20%, 98%)
		light_green = "#D4FAD4", -- hsv(120, 15%, 98%)
		light_blue = "#D4D4FA", -- hsv(240, 15%, 98%)
		light_purple = "#EDD4FA", -- hsv(280, 15%, 98%)
		light_pink = "#FAD4ED", -- hsv(320, 15%, 98%)
		light_red = "#FAD4D4", -- hsv(360, 15%, 98%)

		orange = "#F27900", -- hsv(30, 100%, 95%)
		yellow = "#F2F200", -- hsv(60, 100%, 95%)
		cyan = "#00A6A6", -- hsv(180, 100%, 65%)
		green = "#00A600", -- hsv(120, 100%, 65%)
		blue = "#0000A6", -- hsv(240, 100%, 65%)
		purple = "#6F00A6", -- hsv(280, 100%, 65%)
		pink = "#A6006F", -- hsv(320, 100%, 65%)
		red = "#A60000", -- hsv(360, 100%, 65%)
	}
	if options.low_blue_light then
		colors.base7 = "#FAFAFA" -- hsv(60, 0%, 98%)
	end
	return colors
end

return M
