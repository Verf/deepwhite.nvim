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

		Cursor = { bg = c.base2 },
		TermCursor = { link = "Cursor" },
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
		["@keyword.function"] = { bg = c.light_purple },
		["@keyword.operator"] = { link = "Keyword" },

		["@constructor"] = { link = "Identifier" },

		["@function.call"] = { link = "Special" },
		["@method.call"] = { link = "Special" },

		["@type.builtin"] = { link = "Type" },
		["@constant.builtin"] = { link = "Type" },
		["@variable.builtin"] = { link = "Type" },
		["@function.builtin"] = { link = "Type" },

		["@text.title.gitcommit"] = { link = "@spell" },

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

		-- mini.jump2d
		MiniJump2dSpot = { fg = c.orange, bold = true },
		MiniJump2dDim = { link = "Comment" },

		-- barbar
		BufferCurrent = { link = "TabLineSel" },
		BufferCurrentIndex = { link = "TabLineSel" },
		BufferCurrentMod = { fg = c.orange },
		BufferCurrentSign = { fg = c.base7 },
		BufferCurrentTarget = { fg = c.red },
		BufferInactive = { link = "TabLine" },
		BufferInactiveIndex = { link = "TabLine" },
		BufferInactiveMod = { link = "BufferCurrentMod" },
		BufferInactiveSign = { link = "BufferCurrentSign" },
		BufferInactiveTarget = { link = "BufferCurrentTarget" },
		BufferVisible = { link = "BufferInactive" },
		BufferVisibleIndex = { link = "BufferInactiveIndex" },
		BufferVisibleMod = { link = "BufferInactiveMod" },
		BufferVisibleSign = { link = "BufferInactiveSign" },
		BufferVisibleTarget = { link = "BufferInactiveTarget" },
		BufferTabpages = { link = "TabLine" },
		BufferTabpageFill = { link = "TabLine" },
		BufferOffset = { link = "TabLineSel" },
		BufferScrollArrow = { link = "TabLineSel" },

		-- noice.nvim
		NoiceCmdlinePopupTitle = { fg = c.base0, bold = true },
		NoiceCmdlinePopupBorder = { fg = c.base0 },

		-- Neogit
		NeogitDiffAdd = { bg = c.light_green },
		NeogitDiffAddHighlight = { link = "NeogitDiffAdd" },
		NeogitDiffDelete = { bg = c.light_red },
		NeogitDiffDeleteHighlight = { link = "NeogitDiffDelete" },
		NeogitHunkHeader = { link = "NeogitHunkHeaderHighlight" },
	}
end

return M
