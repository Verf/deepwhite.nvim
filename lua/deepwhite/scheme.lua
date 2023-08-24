local M = {}

function M.get_groups(c)
	return {
		Normal = { fg = c.base0, bg = c.base7 },
		NormalFloat = { link = "Normal" },
		NonText = { fg = c.base3 },

		SpecialKey = { fg = c.blue },
		Directory = { link = "SpecialKey" },

		Title = { fg = c.base7, bg = c.base0 },

		IncSearch = { fg = c.base0, bg = c.light_yellow },
		Search = { link = "IncSearch" },
		CurSearch = { link = "IncSearch" },

		LineNr = { fg = c.base3 },
		CursorLineNr = { link = "Normal" },

		Question = { fg = c.base0, bold = true },

		StatusLine = { fg = c.base0, bg = c.base7, bold = true },
		StatusLineNC = { fg = c.base0, bg = c.base7 },

		TabLine = { link = "Normal" },
		TabLineSel = { reverse = true },

		WinSeparator = { fg = c.base0 },

		SignColumn = { link = "LineNr" },
		FoldColumn = { link = "SignColumn" },

		Conceal = { fg = c.base5 },
		SpellBad = { fg = c.base0, undercurl = true },
		SpellCap = { link = "SpellBad" },
		SpellLocal = { link = "SpellBad" },
		SpellRare = { link = "SpellBad" },

		Pmenu = { fg = c.base0, bg = c.base7 },
		PmenuSel = { fg = c.base0, bg = c.base3 },
		PmenuSbar = { bg = c.base0 },
		PmenuThumb = { link = "PmenuSbar" },

		WildMenu = { bg = c.base4 },
		Visual = { bg = c.base5 },
		Folded = { bg = c.light_purple },

		CursorLine = { bg = c.base6 },
		CursorColumn = { link = "CursorLine" },

		ColorColumn = { bg = c.light_yellow },

		ErrorMsg = { fg = c.base7, bg = c.red },
		WarningMsg = { fg = c.base7, bg = c.orange },
		DiffAdd = { fg = c.green },
		DiffChange = { fg = c.orange },
		DiffDelete = { fg = c.red },

		Comment = { fg = c.base3 },
		Constant = { fg = c.base0, bg = c.light_blue }, -- String Character Number Boolean Float
		String = { fg = c.base0, bg = c.light_green },
		Identifier = { fg = c.base0 }, -- Function
		Statement = { fg = c.base0, bg = c.light_orange }, -- Conditional Repeat Label Operator Keyword Exception
		Operator = { link = "Identifier" },
		PreProc = { link = "Question" }, -- Include Define Macro PreCondit
		Type = { fg = c.pink }, -- StorageClass Structure Typedef
		Special = { link = "SpecialKey" }, -- SpecialChar Tag Delimiter SpecialComment Debug
		Underlined = { underline = true },
		Ignore = { fg = c.base7 },
		Error = { link = "ErrorMsg" },
		Todo = { link = "WarningMsg" },

		-- Plugins
		-- LSP
		DiagnosticError = { fg = c.red },
		DiagnosticWarn = { fg = c.orange },
		DiagnosticInfo = { fg = c.blue },
		DiagnosticHint = { fg = c.base3 },
		DiagnosticOk = { fg = c.green },
		DiagnosticUnderlineError = { sp = c.red, undercurl = true },
		DiagnosticUnderlineWarn = { sp = c.orange, undercurl = true },
		DiagnosticUnderlineInfo = { sp = c.blue, undercurl = true },
		DiagnosticUnderlineHint = { sp = c.base3, undercurl = true },
		DiagnosticUnderlineOk = { sp = c.green, undercurl = true },
		-- Lspsaga
		RenameNormal = { link = "Normal" },

		-- Treesittere
		-- syntax
		["@function.call"] = { link = "Special" },
		["@method.call"] = { link = "@function.call" },
		-- rainbow
		TSRainbowRed = { fg = c.red },
		TSRainbowOrange = { fg = c.orange },
		TSRainbowYellow = { fg = c.orange },
		TSRainbowGreen = { fg = c.green },
		TSRainbowCyan = { fg = c.blue },
		TSRainbowBlue = { fg = c.blue },
		TSRainbowViolet = { fg = c.purple },

		-- nvim-notify
		NotifyERRORBorder = { fg = c.base0 },
		NotifyWARNBorder = { fg = c.base0 },
		NotifyINFOBorder = { fg = c.base0 },
		NotifyDEBUGBorder = { fg = c.base0 },
		NotifyTRACEBorder = { fg = c.base0 },
		NotifyERRORTitle = { fg = c.red },
		NotifyWARNTitle = { fg = c.orange },
		NotifyINFOTitle = { fg = c.green },
		NotifyDEBUGTitle = { fg = c.blue },
		NotifyTRACETitle = { fg = c.purple },
		NotifyERRORIcon = { link = "NotifyERRORTitle" },
		NotifyWARNIcon = { link = "NotifyWARNTitle" },
		NotifyINFOIcon = { link = "NotifyINFOTitle" },
		NotifyDEBUGIcon = { link = "NotifyDEBUGTitle" },
		NotifyTRACEIcon = { link = "NotifyTRACETitle" },

		-- nvim-cmp
		CmpItemAbbr = { link = "Comment" },
		CmpItemAbbrDeprecated = { link = "Visual" },
		CmpItemAbbrMatch = { link = "Identifier" },
		CmpItemAbbrMatchFuzzy = { link = "CmpItemAbbrMatch" },

		CmpItemKindText = { fg = c.base0 },
		CmpItemKindSnippet = { fg = c.base2 },
		CmpItemKindConstant = { fg = c.blue },
		CmpItemKindVariable = { fg = c.blue },
		CmpItemKindKeyword = { fg = c.orange },
		CmpItemKindMethod = { fg = c.purple },
		CmpItemKindFunction = { link = "CmpItemKindMethod" },
		CmpItemKindConstructor = { link = "CmpItemKindMethod" },
		CmpItemKindClass = { fg = c.pink },
		CmpItemKindInterface = { link = "CmpItemKindClass" },
		CmpItemKindModule = { link = "CmpItemKindClass" },
		CmpItemKindStruct = { link = "CmpItemKindClass" },

		-- mini.files
		MiniFilesBorder = { link = "WinSeparator" }, -- border of regular windows.
		MiniFilesBorderModified = { link = "DiffChange" }, -- border of windows showing modified buffer.
		MiniFilesDirectory = { link = "SpecialKey" }, -- text and icon representing directory.
		MiniFilesFile = { link = "Identifier" }, -- text representing file.
		MiniFilesNormal = { link = "Normal" }, -- basic foreground/background highlighting.
		MiniFilesTitle = { link = "Comment" }, -- title of regular windows.
		MiniFilesTitleFocused = { link = "PreProc" }, -- title of focused window.
	}
end

return M
