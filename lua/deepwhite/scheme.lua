local M = {}

function M.get_groups(c)
	return {
		Normal = { fg = c.base0, bg = c.base7 },
		NormalFloat = { link = "Normal" },
		NonText = { fg = c.base3 },

		SpecialKey = { fg = c.blue },
		Directory = { link = "SpecialKey" },

		Title = { fg = c.base0, bold = true },

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
		Folded = {},

		Cursor = { bg = c.base2 },
		TermCursor = { link = "Cursor" },
		CursorLine = { bg = c.base6 },
		CursorColumn = { link = "CursorLine" },

		ColorColumn = { bg = c.light_yellow },

		MoreMsg = { fg = c.cyan },
		ModeMsg = { fg = c.blue },
		ErrorMsg = { fg = c.base7, bg = c.red },
		WarningMsg = { fg = c.base7, bg = c.orange },

		DiffAdd = { fg = c.green },
		DiffChange = { fg = c.orange },
		DiffDelete = { fg = c.red },

		Comment = { fg = c.base3 },
		Constant = { fg = c.base0, bg = c.light_blue }, -- String Character Number Boolean Float
		String = { fg = c.base0, bg = c.light_green },
		Identifier = { fg = c.base0 },
		Delimiter = { link = "Identifier" },
		Statement = { fg = c.base0, bg = c.light_orange }, -- Conditional Repeat Label Operator Keyword Exception
		Operator = { link = "Identifier" },
		PreProc = { link = "Question" }, -- Include Define Macro PreCondit
		Type = { fg = c.pink }, -- StorageClass Structure Typedef
		Special = { link = "SpecialKey" }, -- SpecialChar Tag Delimiter SpecialComment Debug
		Function = { link = "Identifier" },
		Underlined = { underline = true },
		Ignore = { fg = c.base7 },
		Error = { link = "ErrorMsg" },
		Todo = { fg = c.green },

		MatchParen = { fg = c.red, underline = true },

		-- Plugins
		-- Lspsaga
		RenameNormal = { link = "Normal" },

		-- Treesittere
		["@variable"] = { link = "Identifier" },
		["@variable.builtin"] = { link = "Type" },
		["@variable.parameter"] = { link = "Identifier" },
		["@variable.member"] = { link = "Identifier" },

		["@constant"] = { link = "Constant" },
		["@constant.builtin"] = { link = "Type" },
		["@constant.macro"] = { link = "Define" },

		["@module"] = { link = "Include" },
		["@module.builtin"] = { link = "Include" },
		["@label"] = { link = "Label" },

		["@string"] = { link = "String" },
		["@string.documentation"] = { link = "String" },
		["@string.regexp"] = { link = "String" },
		["@string.escape"] = { link = "SpecialChar" },
		["@string.special"] = { link = "SpecialChar" },
		["@string.special.symbol"] = { link = "Identifier" },
		["@string.special.path"] = { link = "Underlined" },
		["@string.special.url"] = { link = "Underlined" },

		["@character"] = { link = "Character" },
		["@character.special"] = { link = "SpecialChar" },

		["@boolean"] = { link = "Boolean" },
		["@number"] = { link = "Number" },
		["@number.float"] = { link = "Float" },

		["@type"] = { link = "Type" },
		["@type.builtin"] = { link = "Type" },
		["@type.qualifier"] = { link = "Type" },
		["@type.definition"] = { link = "Typedef" },

		["@attribute"] = { link = "PreProc" },
		["@property"] = { link = "Identifier" },

		["@function"] = { link = "Function" },
		["@function.builtin"] = { link = "Special" },
		["@function.call"] = { link = "Special" },
		["@function.macro"] = { link = "Macro" },

		["@function.method"] = { link = "@function" },
		["@function.method.call"] = { link = "@function.call" },

		["@constructor"] = { link = "Identifier" },
		["@operator"] = { link = "Operator" },

		["@keyword"] = { link = "Keyword" },
		["@keyword.coroutine"] = { link = "Keyword" },
		["@keyword.function"] = { bg = c.light_purple },
		["@keyword.operator"] = { link = "Operator" },
		["@keyword.import"] = { link = "Include" },
		["@keyword.storage"] = { link = "Keyword" },
		["@keyword.repeat"] = { link = "Repeat" },
		["@keyword.return"] = { link = "Keyword" },
		["@keyword.debug"] = { link = "Debug" },
		["@keyword.exception"] = { link = "Exception" },

		["@keyword.conditional"] = { link = "Conditional" },
		["@keyword.conditional.ternary"] = { link = "Conditional" },
		["@keyword.directive"] = { link = "PreProc" },
		["@keyword.directive.define"] = { link = "PreProc" },

		["@punctutation.delimiter"] = { link = "Delimiter" },
		["@punctutation.bracket"] = { link = "Delimiter" },
		["@punctutation.special"] = { link = "Delimiter" },

		["@comment"] = { link = "Comment" },
		["@comment.documentation"] = { link = "Comment" },

		["@comment.warning"] = { link = "WarningMsg" },
		["@comment.error"] = { link = "Error" },
		["@comment.todo"] = { link = "Todo" },
		["@comment.note"] = { link = "SpecialComment" },

		["@markup.strong"] = { bold = true },
		["@markup.emphasis"] = { italic = true },
		["@markup.underline"] = { underline = true },
		["@markup.strike"] = { strikethrough = true },

		["@markup.heading"] = { link = "Title" },
		["@markup.heading.gitcommit"] = { link = "@spell" },

		["@markup.quote"] = { link = "Comment" },
		["@markup.math"] = { link = "Special" },
		["@markup.environment"] = { link = "Macro" },

		["@markup.link"] = { link = "Underlined" },
		["@markup.link.label"] = { link = "SpecialChar" },
		["@markup.link.url"] = { link = "Keyword" },

		["@markup.raw"] = { link = "SpecialComment" },
		["@markup.raw.block"] = {},

		["@markup.list"] = { link = "Identifier" },
		["@markup.list.checked"] = { link = "Comment" },
		["@markup.list.unchecked"] = { link = "Identifier" },

		["@tag"] = { link = "Label" },
		["@tag.delimiter"] = { link = "Delimiter" },
		["@tag.attribute"] = { link = "Identifier" },

		["@diff.plus"] = { link = "DiffAdd" },
		["@diff.minus"] = { link = "DiffDelete" },
		["@diff.delta"] = { link = "DiffChange" },

		-- lsp
		DiagnosticError = { fg = c.red },
		DiagnosticHint = { fg = c.base3 },
		DiagnosticInfo = { fg = c.blue },
		DiagnosticOk = { fg = c.green },
		DiagnosticUnderlineError = { sp = c.red, undercurl = true },
		DiagnosticUnderlineHint = { sp = c.base3, undercurl = true },
		DiagnosticUnderlineInfo = { sp = c.blue, undercurl = true },
		DiagnosticUnderlineOk = { sp = c.green, undercurl = true },
		DiagnosticUnderlineWarn = { sp = c.orange, undercurl = true },
		DiagnosticWarn = { fg = c.orange },
		-- lsp highlights
		["@lsp.type.class"] = { link = "@type" },
		["@lsp.type.decorator"] = { link = "@function" },
		["@lsp.type.enum"] = { link = "@type" },
		["@lsp.type.enumMember"] = { link = "@constant" },
		["@lsp.type.function"] = { link = "@function.call" },
		["@lsp.type.interface"] = { link = "@type" },
		["@lsp.type.macro"] = { link = "@macro" },
		["@lsp.type.method"] = { link = "@function.call" },
		["@lsp.type.namespace"] = { link = "@namespace" },
		["@lsp.type.parameter"] = { link = "@parameter" },
		["@lsp.type.property"] = { link = "@property" },
		["@lsp.type.struct"] = { link = "@structure" },
		["@lsp.type.type"] = { link = "@type" },
		["@lsp.type.variable"] = { link = "@variable" },
		["@lsp.typemod.class.defaultLibrary"] = { link = "@type.builtin" },
		["@lsp.typemod.enum.defaultLibrary"] = { link = "@type.builtin" },
		["@lsp.typemod.enumMember.defaultLibrary"] = { link = "@constant.builtin" },
		["@lsp.typemod.function.declaration"] = { link = "@function" },
		["@lsp.typemod.function.defaultLibrary"] = { link = "@function.builtin" },
		["@lsp.typemod.keyword.async"] = { link = "@keyword.coroutine" },
		["@lsp.typemod.macro.defaultLibrary"] = { link = "@function.builtin" },
		["@lsp.typemod.method.defaultLibrary"] = { link = "@function.builtin" },
		["@lsp.typemod.method.declaration"] = { link = "@function" },
		["@lsp.typemod.operator.injected"] = { link = "@operator" },
		["@lsp.typemod.string.injected"] = { link = "@string" },
		["@lsp.typemod.type.defaultLibrary"] = { link = "@type.builtin" },
		["@lsp.typemod.variable.defaultLibrary"] = { link = "@variable.builtin" },
		["@lsp.typemod.variable.injected"] = { link = "@variable" },

		-- rainbow
		TSRainbowRed = { fg = c.red },
		TSRainbowOrange = { fg = c.orange },
		TSRainbowYellow = { fg = c.yellow },
		TSRainbowGreen = { fg = c.green },
		TSRainbowCyan = { fg = c.cyan },
		TSRainbowBlue = { fg = c.blue },
		TSRainbowViolet = { fg = c.purple },

		-- rainbow-delimiters
		RainbowDelimiterRed = { fg = c.red },
		RainbowDelimiterYellow = { fg = c.yellow },
		RainbowDelimiterBlue = { fg = c.blue },
		RainbowDelimiterOrange = { fg = c.orange },
		RainbowDelimiterGreen = { fg = c.green },
		RainbowDelimiterViolet = { fg = c.purple },
		RainbowDelimiterCyan = { fg = c.cyan },

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

		-- mini.deps
		MiniDepsChangeAdded = { fg = c.green },
		MiniDepsChangeRemoved = { fg = c.orange },
		MiniDepsHint = { fg = c.base3 },
		MiniDepsInfo = { fg = c.base0 },
		MiniDepsTitle = { fg = c.base0, bold = true },
		MiniDepsTitleError = { fg = c.red, bold = true },
		MiniDepsTitleSame = { fg = c.blue, bold = true },
		MiniDepsTitleUpdate = { fg = c.green, bold = true },

		-- mini.diff
		MiniDiffSignAdd = { bg = c.light_green },
		MiniDiffSignChange = { bg = c.light_orange },
		MiniDiffSignDelete = { bg = c.light_red },
		MiniDiffOverAdd = { bg = c.light_green },
		MiniDiffOverChange = { bg = c.light_orange },
		MiniDiffOverContext = { bg = c.light_cyan },
		MiniDiffOverDelete = { bg = c.light_red },

		-- mini.files
		MiniFilesBorder = { link = "WinSeparator" }, -- border of regular windows.
		MiniFilesBorderModified = { link = "DiffChange" }, -- border of windows showing modified buffer.
		MiniFilesDirectory = { link = "SpecialKey" }, -- text and icon representing directory.
		MiniFilesFile = { link = "Identifier" }, -- text representing file.
		MiniFilesNormal = { link = "Normal" }, -- basic foreground/background highlighting.
		MiniFilesTitle = { link = "Comment" }, -- title of regular windows.
		MiniFilesTitleFocused = { link = "PreProc" }, -- title of focused window.

		-- mini.jump2d
		MiniJump2dSpot = { fg = c.red, bold = true },
		MiniJump2dSpotAhead = { fg = c.orange },

		-- mini.statusline
		MiniStatuslineModeNormal = { bg = c.light_purple },
		MiniStatuslineModeInsert = { bg = c.light_green },
		MiniStatuslineModeVisual = { bg = c.light_cyan },
		MiniStatuslineModeReplace = { bg = c.light_orange },
		MiniStatuslineModeCommand = { bg = c.light_red },
		MiniStatuslineModeOther = { bg = c.light_blue },
		MiniStatuslineInactive = { fg = c.base3 },

		-- mini.starter
		MiniStarterHeader = { fg = c.base0 },
		MiniStarterFooter = { fg = c.base3 },
		MiniStarterItemPrefix = { fg = c.red },

		-- mini.tabline
		MiniTablineCurrent = { fg = c.base7, bg = c.base0 },
		MiniTablineVisible = { link = "MiniTablineCurrent" },
		MiniTablineHidden = { fg = c.base0, bg = c.base7 },
		MiniTablineModifiedCurrent = { fg = c.orange, bg = c.base0 },
		MiniTablineModifiedVisible = { link = "MiniTablineModifiedCurrent" },
		MiniTablineModifiedHidden = { fg = c.orange, bg = c.base7 },

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

		-- Diffview
		DiffviewDiffAdd = { bg = c.light_green },
		DiffviewDiffDelete = { bg = c.light_red },
		DiffviewDiffChange = { bg = c.light_orange },

		-- modicator.nvim
		NormalMode = { link = "Normal" },
		InsertMode = { bold = True },
		VisualMode = { link = "Visual" },
		CommandMode = { link = "NormalMode" },
		ReplaceMode = { fg = c.red },
		SelectMode = { link = "VisualMode" },
		TerminalMode = { link = "NormalMode" },
		TerminalNormalMode = { link = "NormalMode" },
	}
end

return M
