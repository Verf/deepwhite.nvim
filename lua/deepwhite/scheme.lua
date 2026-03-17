local M = {}

function M.get_groups(c)
    return {
        -- :help highlight-groups highlight-default
        ColorColumn = { bg = c.base7 }, -- Used for the columns set with 'colorcolumn'.
        Conceal = { fg = c.base5 }, -- Placeholder characters substituted for concealed text (see 'conceallevel').
        CurSearch = { link = 'Search' }, -- Current match for the last search pattern (see 'hlsearch').
        Cursor = { bg = c.base2 }, -- Character under the cursor.
        lCursor = { link = 'Cursor' }, -- Character under the cursor when |language-mapping| is used (see 'guicursor').
        CursorIM = { link = 'Cursor' }, -- Like Cursor, but used when in IME mode. *CursorIM*
        CursorColumn = { bg = c.base6 }, -- Screen-column at the cursor, when 'cursorcolumn' is set.
        CursorLine = { bg = c.base6 }, -- Screen-line at the cursor, when 'cursorline' is set. Low-priority if foreground (ctermfg OR guifg) is not set.
        Directory = { link = 'SpecialKey' }, -- Directory names (and other special names in listings).
        DiffAdd = { bg = c.diff_add }, -- Diff mode: Added line. |diff.txt|
        DiffChange = { bg = c.diff_change }, -- Diff mode: Changed line. |diff.txt|
        DiffDelete = { bg = c.diff_delete }, -- Diff mode: Deleted line. |diff.txt|
        DiffText = { bg = c.diff_text }, -- Diff mode: Changed text within a changed line. |diff.txt|
        EndOfBuffer = { fg = c.base6 }, -- Filler lines (~) after the end of the buffer. By default, this is highlighted like |hl-NonText|.
        TermCursor = { link = 'Cursor' }, -- Cursor in a focused terminal.
        ErrorMsg = { fg = c.red }, -- Error messages on the command line.
        WinSeparator = { fg = c.base0 }, -- Separators between window splits.
        Folded = { fg = c.base3, bg = c.base6 }, -- Line used for closed folds.
        FoldColumn = { link = 'LineNr' }, -- 'foldcolumn'
        SignColumn = { link = 'LineNr' }, -- Column where |signs| are displayed.
        IncSearch = { link = 'Search' }, -- 'incsearch' highlighting; also used for the text replaced with ":s///c".
        Substitute = { link = 'Search' }, -- |:substitute| replacement text highlighting.
        LineNr = { fg = c.base2 }, -- Line number for ":number" and ":#" commands, and when 'number' or 'relativenumber' option is set.
        LineNrAbove = { link = 'LineNr' }, -- Line number for when the 'relativenumber' option is set, above the cursor line.
        LineNrBelow = { link = 'LineNr' }, -- Line number for when the 'relativenumber' option is set, below the cursor line.
        CursorLineNr = { fg = c.base2, bg = c.base6 }, -- Like LineNr when 'cursorline' is set and 'cursorlineopt' contains "number" or is "both", for the cursor line.
        CursorLineFold = { link = 'CursorLineNr' }, -- Like FoldColumn when 'cursorline' is set for the cursor line.
        CursorLineSign = { link = 'CursorLineNr' }, -- Like SignColumn when 'cursorline' is set for the cursor line.
        MatchParen = { fg = c.red, underline = true }, -- Character under the cursor or just before it, if it is a paired bracket, and its match. |pi_paren.txt|
        ModeMsg = { fg = c.blue }, -- 'showmode' message (e.g., "-- INSERT --").
        MsgArea = { link = 'Normal' }, -- Area for messages and command-line, see also 'cmdheight'.
        MsgSeparator = { bg = c.base3 }, -- Separator for scrolled messages |msgsep|.
        MoreMsg = { link = 'ModeMsg' }, -- |more-prompt|
        NonText = { fg = c.base5 }, -- '@' at the end of the window, characters from 'showbreak' and other characters that do not really exist in the text.
        Normal = { fg = c.base0, bg = c.base7 }, -- Normal text.
        NormalFloat = { link = 'Normal' }, -- Normal text in floating windows.
        FloatBorder = { fg = c.base0 }, -- Border of floating windows.
        FloatTitle = { fg = c.base0 }, -- Title of floating windows.
        FloatFooter = { fg = c.base0 }, -- Footer of floating windows.
        NormalNC = { link = 'Normal' }, -- Normal text in non-current windows.
        Pmenu = { fg = c.base0, bg = c.base6 }, -- Popup menu: Normal item.
        PmenuSel = { fg = c.base0, bg = c.base3 }, -- Popup menu: Selected item. Combined with |hl-Pmenu|.
        PmenuKind = { link = 'Pmenu' }, -- Popup menu: Normal item "kind".
        PmenuKindSel = { link = 'PmenuSel' }, -- Popup menu: Selected item "kind".
        PmenuExtra = { link = 'Pmenu' }, -- Popup menu: Normal item "extra text".
        PmenuExtraSel = { link = 'PmenuSel' }, -- Popup menu: Selected item "extra text".
        PmenuSbar = { bg = c.base7 }, -- Popup menu: Scrollbar.
        PmenuThumb = { bg = c.base3 }, -- Popup menu: Thumb of the scrollbar.
        PmenuMatch = { link = 'Pmenu' }, -- Popup menu: Matched text in normal item. Combined with |hl-Pmenu|.
        PmenuMatchSel = { link = 'PmenuSel' }, -- Popup menu: Matched text in selected item. Combined with |hl-PmenuMatch| and |hl-PmenuSel|.
        ComplMatchIns = { link = 'Normal' }, -- Matched text of the currently inserted completion.
        Question = { bold = true }, -- |hit-enter| prompt and yes/no questions.
        QuickFixLine = { bold = true }, -- Current |quickfix| item in the quickfix window. Combined with |hl-CursorLine| when the cursor is there.
        Search = { fg = c.base0, bg = c.light_yellow }, -- Last search pattern highlighting (see 'hlsearch'). Also used for similar items that need to stand out.
        SnippetTabstop = { link = 'Normal' }, -- Tabstops in snippets. |vim.snippet|
        SpecialKey = { fg = c.blue }, -- Unprintable characters: Text displayed differently from what it really is. But not 'listchars' whitespace. |hl-Whitespace|
        SpellBad = { fg = c.base0, undercurl = true }, -- Word that is not recognized by the spellchecker. |spell| Combined with the highlighting used otherwise.
        SpellCap = { link = 'SpellBad' }, -- Word that should start with a capital. |spell| Combined with the highlighting used otherwise.
        SpellLocal = { link = 'SpellBad' }, -- Word that is recognized by the spellchecker as one that is used in another region. |spell| Combined with the highlighting used otherwise.
        SpellRare = { link = 'SpellBad' }, -- Word that is recognized by the spellchecker as one that is hardly ever used. |spell| Combined with the highlighting used otherwise.
        StatusLine = { fg = c.base0, bg = c.base3 }, -- Status line of current window.
        StatusLineNC = { link = 'LineNr' }, -- Status lines of not-current windows.
        StatusLineTerm = { link = 'StatusLine' }, -- Status line of |terminal| window.
        StatusLineTermNC = { link = 'StatusLineNC' }, -- Status line of non-current |terminal| windows.
        TabLine = { fg = c.base0, bg = c.base6 }, -- Tab pages line, not active tab page label.
        TabLineFill = { bg = c.base7 }, -- Tab pages line, where there are no labels.
        TabLineSel = { fg = c.base0, bg = c.base7 }, -- Tab pages line, active tab page label.
        Title = { bold = true }, -- Titles for output from ":set all", ":autocmd" etc.
        Visual = { bg = c.base5 }, -- Visual mode selection.
        VisualNOS = { bg = c.base4 }, -- Visual mode selection when vim is "Not Owning the Selection".
        WarningMsg = { fg = c.orange }, -- Warning messages.
        Whitespace = { fg = c.base5 }, -- "nbsp", "space", "tab", "multispace", "lead" and "trail" in 'listchars'.
        WildMenu = { bg = c.base4 }, -- Current match in 'wildmenu' completion.
        WinBar = { link = 'StatusLine' }, -- Window bar of current window.
        WinBarNC = { link = 'StatusLineNC' }, -- Window bar of not-current windows.

        -- gui
        Menu = { link = 'Pmenu' },
        Scrollbar = { link = 'PmenuSbar' },
        Tooltip = { link = 'Pmenu' },

        -- suggested
        Comment = { fg = c.base3 }, -- any comment

        Constant = { fg = c.base0, bg = c.light_blue }, -- any constant
        String = { fg = c.base0, bg = c.light_green }, -- a string constant: "this is a string"
        Character = { link = 'Constant' }, -- a character constant: 'c', '\n'
        Number = { link = 'Constant' }, -- a number constant: 234, 0xff
        Boolean = { link = 'Constant' }, -- a boolean constant: TRUE, false
        Float = { link = 'Constant' }, -- a floating point constant: 2.3e10
        Identifier = { fg = c.base0 }, -- any variable name
        Function = { link = 'Identifier' }, -- function name (also: methods for classes)

        Statement = { fg = c.base0, bg = c.light_orange }, -- any statement
        Conditional = { link = 'Statement' }, -- if, then, else, endif, switch, etc.
        Repeat = { link = 'Statement' }, -- for, do, while, etc.
        Label = { link = 'Statement' }, -- case, default, etc.
        Operator = { link = 'Identifier' }, -- "sizeof", "+", "*", etc.
        Keyword = { link = 'Statement' }, -- any other keyword
        Exception = { link = 'Statement' }, -- try, catch, throw

        PreProc = { link = 'Identifier' }, -- generic Preprocessor
        Include = { link = 'Identifier' }, -- preprocessor #include
        Define = { link = 'Identifier' }, -- preprocessor #define
        Macro = { link = 'Identifier' }, -- same as Define
        PreCondit = { link = 'Identifier' }, -- preprocessor #if, #else, #endif, etc.

        Type = { fg = c.pink }, -- int, long, char, etc.
        Storage = { link = 'Type' }, -- lass static, register, volatile, etc.
        Structure = { link = 'Type' }, -- struct, union, enum, etc.
        Typedef = { link = 'Type' }, -- a typedef

        Special = { link = 'SpecialKey' }, -- any special symbol
        SpecialChar = { link = 'SpecialKey' }, -- special character in a constant
        Tag = { fg = c.orange }, -- you can use CTRL-] on this
        Delimiter = { link = 'Identifier' }, --character that needs attention
        SpecialComment = { link = 'SpecialKey' }, -- special things inside a comment
        Debug = { link = 'SpecialKey' }, -- debugging statements

        Underlined = { underline = true }, --text that stands out, HTML links

        Ignore = { fg = c.base7 }, -- left blank, hidden  |hl-Ignore|

        Error = { bg = c.light_red }, -- any erroneous construct

        Todo = { bg = c.light_green }, -- anything that needs extra attention; mostly the keywords TODO FIXME and XXX

        Added = { link = 'DiffAdd' }, -- added line in a diff
        Changed = { link = 'DiffChange' }, -- changed line in a diff
        Removed = { link = 'DiffDelete' }, -- removed line in a diff

        -- :help treesitter-highlight-groups
        ['@variable'] = { link = 'Identifier' }, -- various variable names
        ['@variable.builtin'] = { link = 'Type' }, -- built-in variable names (e.g. `this`, `self`)
        ['@variable.parameter'] = { link = 'Identifier' }, -- special parameters (e.g. `_`, `it`)

        ['@constant'] = { link = 'Constant' }, -- constant identifiers
        ['@constant.builtin'] = { link = 'Type' }, -- built-in constant values
        ['@constant.macro'] = { link = 'Macro' }, -- constants defined by the preprocessor

        ['@module'] = { link = 'Include' }, -- modules or namespaces
        ['@module.builtin'] = { link = 'Type' }, -- built-in modules or namespaces
        ['@label'] = { link = 'Label' }, -- `GOTO` and other labels (e.g. `label:` in C), including heredoc labels

        ['@string'] = { link = 'String' }, -- string literals
        ['@string.escape'] = { link = 'SpecialChar' }, -- escape sequences
        ['@string.special'] = { link = 'SpecialChar' }, -- other special strings (e.g. dates)
        ['@string.special.url'] = { bg = c.light_green, underline = true }, -- URIs (e.g. hyperlinks)

        ['@character'] = { link = 'Character' }, -- character literals
        ['@character.special'] = { link = 'SpecialChar' }, -- special characters (e.g. wildcards)

        ['@boolean'] = { link = 'Boolean' }, -- boolean literals
        ['@number'] = { link = 'Number' }, -- numeric literals
        ['@number.float'] = { link = 'Float' }, -- floating-point number literals

        ['@type'] = { link = 'Type' }, -- type or class definitions and annotations
        ['@type.builtin'] = { link = 'Type' }, -- built-in types
        ['@type.definition'] = { link = 'Type' }, -- identifiers in type definitions (e.g. `typedef <type> <identifier>` in C)

        ['@attribute'] = { link = 'Type' }, -- attribute annotations (e.g. Python decorators, Rust lifetimes)
        ['@attribute.builtin'] = { link = 'Type' }, -- builtin annotations (e.g. `@property` in Python)
        ['@property'] = { link = 'Identifier' }, -- the key in key/value pairs

        ['@function'] = { link = 'Function' }, -- function definitions
        ['@function.builtin'] = { link = 'Type' }, -- built-in functions

        ['@function.method'] = { link = '@function' }, -- method definitions

        ['@constructor'] = { link = 'Identifier' }, -- constructor calls and definitions

        ['@operator'] = { link = 'Operator' }, -- symbolic operators (e.g. `+`, `*`)

        ['@keyword'] = { link = 'Keyword' }, -- keywords not fitting into specific categories
        ['@keyword.function'] = { bg = c.light_purple }, -- keywords that define a function (e.g. `func` in Go, `def` in Python)

        ['@punctuation'] = { link = 'Identifier' }, -- punctuation
        ['@punctuation.special'] = { link = 'SpecialChar' }, -- special symbols (e.g. `{}` in string interpolation)

        ['@comment'] = { link = 'Comment' }, -- line and block comments

        ['@comment.error'] = { bg = c.light_red }, -- error-type comments (e.g. `ERROR`, `FIXME`, `DEPRECATED`)
        ['@comment.warning'] = { bg = c.light_orange }, -- warning-type comments (e.g. `WARNING`, `FIX`, `HACK`)
        ['@comment.todo'] = { bg = c.light_cyan }, -- todo-type comments (e.g. `TODO`, `WIP`)
        ['@comment.note'] = { bg = c.light_blue }, -- note-type comments (e.g. `NOTE`, `INFO`, `XXX`)

        ['@markup.strong'] = { link = 'Bold' }, -- bold text
        ['@markup.italic'] = { link = 'Italic' }, -- italic text
        ['@markup.strikethrough'] = { link = 'Strikethrough' }, -- struck-through text
        ['@markup.underline'] = { link = 'Underlined' }, -- underlined text (only for literal underline markup!)

        ['@markup.heading'] = { link = 'Title' }, -- headings, titles (including markers)

        ['@markup.quote'] = { link = 'Identifier' }, -- block quotes
        ['@markup.math'] = { link = 'Special' }, -- math environments (e.g. `$ ... $` in LaTeX)

        ['@markup.link'] = { link = 'Underlined' }, -- text references, footnotes, citations, etc.

        ['@markup.raw'] = { link = 'Identifier' }, -- literal or verbatim text (e.g. inline code)

        ['@markup.list'] = { link = 'Identifier' }, -- list markers
        ['@markup.list.checked'] = { link = 'Comment' }, -- checked todo-style list markers

        ['@diff.plus'] = { link = 'Added' }, -- added text (for diff files)
        ['@diff.minus'] = { link = 'Removed' }, -- deleted text (for diff files)
        ['@diff.delta'] = { link = 'Changed' }, -- changed text (for diff files)

        ['@tag'] = { link = 'Label' }, -- XML-style tag names (e.g. in XML, HTML, etc.)
        ['@tag.builtin'] = { link = 'Type' }, -- builtin tag names (e.g. HTML5 tags)
        ['@tag.attribute'] = { link = 'Identifier' }, -- XML-style tag attributes
        ['@tag.delimiter'] = { link = 'Delimiter' }, -- XML-style tag delimiters

        -- vim.lsp
        LspReferenceText = { bg = c.light_purple }, -- Used for highlighting "text" references
        LspReferenceRead = { link = 'LspReferenceText' }, -- Used for highlighting "read" references
        LspReferenceWrite = { link = 'LspReferenceText' }, -- Used for highlighting "write" references
        LspReferenceTarget = { link = 'LspReferenceText' }, -- Used for highlighting reference targets (e.g. in a hover range)
        LspInlayHint = { link = 'Comment' }, -- Used for highlighting inlay hints (make them subtle like comments)
        LspCodeLens = { link = 'Comment' }, -- Used to color the virtual text of the codelens.
        LspCodeLensSeparator = { link = 'Comment' }, -- Used to color the separator between two or more code lenses.
        LspSignatureActiveParameter = { link = 'LspReferenceText' }, -- Used to highlight the active parameter in the signature help.

        ['@lsp.type.class'] = { link = '@type' },
        ['@lsp.type.decorator'] = { link = '@type' },
        ['@lsp.type.enum'] = { link = '@type' },
        ['@lsp.type.enumMember'] = { link = '@constant' },
        ['@lsp.type.function'] = { link = '@function.call' },
        ['@lsp.type.interface'] = { link = '@type' },
        ['@lsp.type.macro'] = { link = '@macro' },
        ['@lsp.type.method'] = { link = '@function.call' },
        ['@lsp.type.namespace'] = { link = '@namespace' },
        ['@lsp.type.parameter'] = { link = '@parameter' },
        ['@lsp.type.property'] = { link = '@property' },
        ['@lsp.type.struct'] = { link = '@structure' },
        ['@lsp.type.type'] = { link = '@type' },
        ['@lsp.type.variable'] = { link = '@variable' },
        ['@lsp.typemod.class.defaultLibrary'] = { link = '@type.builtin' },
        ['@lsp.typemod.enum.defaultLibrary'] = { link = '@type.builtin' },
        ['@lsp.typemod.enumMember.defaultLibrary'] = { link = '@constant.builtin' },
        ['@lsp.typemod.function.declaration'] = { link = '@function' },
        ['@lsp.typemod.function.defaultLibrary'] = { link = '@function.builtin' },
        ['@lsp.typemod.keyword.async'] = { link = '@keyword.coroutine' },
        ['@lsp.typemod.macro.defaultLibrary'] = { link = '@function.builtin' },
        ['@lsp.typemod.method.defaultLibrary'] = { link = '@function.builtin' },
        ['@lsp.typemod.method.declaration'] = { link = '@function' },
        ['@lsp.typemod.operator.injected'] = { link = '@operator' },
        ['@lsp.typemod.string.injected'] = { link = '@string' },
        ['@lsp.typemod.type.defaultLibrary'] = { link = '@type.builtin' },
        ['@lsp.typemod.variable.defaultLibrary'] = { link = '@variable.builtin' },
        ['@lsp.typemod.variable.injected'] = { link = '@variable' },

        -- vim.diagnostic
        DiagnosticError = { link = 'ErrorMsg' },
        DiagnosticWarn = { link = 'WarningMsg' },
        DiagnosticInfo = { fg = c.blue },
        DiagnosticHint = { fg = c.cyan },
        DiagnosticOk = { fg = c.green },

        DiagnosticVirtualTextError = { link = 'DiagnosticError' },
        DiagnosticVirtualTextWarn = { link = 'DiagnosticWarn' },
        DiagnosticVirtualTextInfo = { link = 'DiagnosticInfo' },
        DiagnosticVirtualTextHint = { link = 'DiagnosticHint' },
        DiagnosticVirtualTextOk = { link = 'DiagnosticOk' },

        DiagnosticVirtualLinesError = { link = 'DiagnosticVirtualTextError' },
        DiagnosticVirtualLinesWarn = { link = 'DiagnosticVirtualTextWarn' },
        DiagnosticVirtualLinesInfo = { link = 'DiagnosticVirtualTextInfo' },
        DiagnosticVirtualLinesHint = { link = 'DiagnosticVirtualTextHint' },
        DiagnosticVirtualLinesOk = { link = 'DiagnosticVirtualTextOk' },

        DiagnosticUnderlineError = { sp = c.red, undercurl = true },
        DiagnosticUnderlineWarn = { sp = c.orange, undercurl = true },
        DiagnosticUnderlineInfo = { sp = c.blue, undercurl = true },
        DiagnosticUnderlineHint = { sp = c.cyan, undercurl = true },
        DiagnosticUnderlineOk = { sp = c.green, undercurl = true },

        DiagnosticFloatingError = { link = 'DiagnosticError' },
        DiagnosticFloatingWarn = { link = 'DiagnosticWarn' },
        DiagnosticFloatingInfo = { link = 'DiagnosticInfo' },
        DiagnosticFloatingHint = { link = 'DiagnosticHint' },
        DiagnosticFloatingOk = { link = 'DiagnosticOk' },
        DiagnosticSignError = { link = 'DiagnosticError' },
        DiagnosticSignWarn = { link = 'DiagnosticWarn' },
        DiagnosticSignInfo = { link = 'DiagnosticInfo' },
        DiagnosticSignHint = { link = 'DiagnosticHint' },
        DiagnosticSignOk = { link = 'DiagnosticOk' },
        DiagnosticDeprecated = { strikethrough = true },
        DiagnosticUnnecessary = { link = 'Comment' },

        -- markdown
        markdownListMarker = { link = 'Identifier' },
        markdownOrderedListMarker = { link = 'Identifier' },

        -- Plugins
        -- Git
        GitStaged = { bg = c.light_green },
        GitModified = { bg = c.light_orange },
        GitDeleted = { bg = c.light_red },
        GitRenamed = { bg = c.light_cyan },
        GitUntracked = { link = 'Normal' },
        GitIgnored = { link = 'Comment' },

        -- Mini Animate
        MiniAnimateCursor = { link = 'Cursor' },
        MiniAnimateNormalFloat = { link = 'NormalFloat' },

        -- Mini Clue
        MiniClueBorder = { link = 'FloatBorder' },
        MiniClueDescGroup = { link = 'Title' },
        MiniClueDescSingle = { link = 'NormalFloat' },
        MiniClueNextKey = { link = 'SpecialKey' },
        MiniClueNextKeyWithPostkeys = { link = 'WarningMsg' },
        MiniClueSeparator = { link = 'WinSeparator' },
        MiniClueTitle = { link = 'FloatTitle' },

        -- Mini Cmdline
        MiniCmdlinePeekBorder = { link = 'FloatBorder' },
        MiniCmdlinePeekLineNr = { link = 'LineNr' },
        MiniCmdlinePeekNormal = { link = 'NormalFloat' },
        MiniCmdlinePeekSep = { link = 'WinSeparator' },
        MiniCmdlinePeekSign = { link = 'SignColumn' },
        MiniCmdlinePeekTitle = { link = 'FloatTitle' },

        -- Mini Completion
        MiniCompletionActiveParameter = { link = 'Underlined' },
        MiniCompletionDeprecated = { link = 'DiagnosticDeprecated' },
        MiniCompletionInfoBorderOutdated = { link = 'DiagnosticFloatingWarn' },

        -- Mini Cursorword
        MiniCursorword = { underline = true }, -- Subtle highlight for word under cursor
        MiniCursorwordCurrent = { link = 'Cursor' }, -- Or leave empty to just show cursor

        -- Mini Deps
        MiniDepsChangeAdded = { link = 'Added' },
        MiniDepsChangeRemoved = { link = 'Removed' },
        MiniDepsHint = { link = 'Comment' },
        MiniDepsInfo = { link = 'Normal' },
        MiniDepsMsgBreaking = { link = 'ErrorMsg' },
        MiniDepsPlaceholder = { link = 'Comment' },
        MiniDepsTitle = { link = 'Title' },
        MiniDepsTitleError = { link = 'ErrorMsg' },
        MiniDepsTitleSame = { link = 'Comment' },
        MiniDepsTitleUpdate = { link = 'Added' },

        -- Mini Diff
        MiniDiffSignAdd = { bg = c.light_green }, -- "add" hunk lines visualization.
        MiniDiffSignChange = { bg = c.light_orange }, -- "change" hunk lines visualization.
        MiniDiffSignDelete = { bg = c.light_red }, -- "delete" hunk lines visualization.
        MiniDiffOverAdd = { link = 'MiniDiffSignAdd' }, -- added buffer text shown in overlay.
        MiniDiffOverChange = { link = 'CursorLine' }, -- changed reference text shown in overlay.
        MiniDiffOverChangeBuf = { link = 'MiniDiffSignChange' }, -- changed buffer text shown in overlay.
        MiniDiffOverContext = { link = 'CursorLine' }, -- context of a change shown in reference overlay.
        MiniDiffOverContextBuf = { link = 'MiniDiffSignChange' }, -- changed buffer text shown in overlay.
        MiniDiffOverDelete = { link = 'MiniDiffSignDelete' }, -- Background highlight for deleted text

        -- Mini Files
        MiniFilesBorder = { link = 'FloatBorder' },
        MiniFilesBorderModified = { link = 'Special' },
        MiniFilesCursorLine = { link = 'CursorLine' },
        MiniFilesDirectory = { link = 'Directory' },
        MiniFilesFile = { link = 'NormalFloat' },
        MiniFilesNormal = { link = 'NormalFloat' },
        MiniFilesTitle = { link = 'FloatTitle' },
        MiniFilesTitleFocused = { link = 'Title' },

        -- Mini Hipatterns
        MiniHipatternsFixme = { fg = c.base7, bg = c.red, bold = true },
        MiniHipatternsHack = { fg = c.base7, bg = c.orange, bold = true },
        MiniHipatternsNote = { fg = c.base7, bg = c.blue, bold = true },
        MiniHipatternsTodo = { link = 'Todo' },

        -- Mini Icons
        MiniIconsAzure = { fg = c.blue },
        MiniIconsBlue = { fg = c.blue },
        MiniIconsCyan = { fg = c.cyan },
        MiniIconsGreen = { fg = c.green },
        MiniIconsGrey = { fg = c.base3 },
        MiniIconsOrange = { fg = c.orange },
        MiniIconsPurple = { fg = c.purple },
        MiniIconsRed = { fg = c.red },
        MiniIconsYellow = { fg = c.orange }, -- Yellow text on light bg is hard to read, mapped to orange

        -- Mini Indentscope
        MiniIndentscopeSymbol = { fg = c.base4 }, -- Subtle vertical line
        MiniIndentscopeSymbolOff = { fg = c.base6 }, -- Very subtle for inactive

        -- Mini Jump & Jump2d
        MiniJump = { fg = c.red, bold = true }, -- Background highlight for jump target
        MiniJump2dSpot = { link = 'MiniJump' }, -- highlighting of jump spot's next step
        MiniJump2dSpotUnique = { link = 'MiniJump' }, -- highlighting of jump spot's next step if it has unique label
        MiniJump2dSpotAhead = { fg = c.orange }, -- highlighting of jump spot's future steps
        MiniJump2dDim = { link = 'Comment' }, -- highlighting of lines with at least one jump spot

        -- Mini Map
        MiniMapNormal = { link = 'Normal' },
        MiniMapSymbolCount = { link = 'Special' },
        MiniMapSymbolLine = { link = 'Title' },
        MiniMapSymbolView = { link = 'CursorLine' }, -- Highlight the view window

        -- Mini Notify
        MiniNotifyBorder = { link = 'FloatBorder' },
        MiniNotifyLspProgress = { link = 'Special' },
        MiniNotifyNormal = { link = 'NormalFloat' },
        MiniNotifyTitle = { link = 'FloatTitle' },

        -- Mini Operators
        MiniOperatorsExchangeFrom = { link = 'IncSearch' }, -- Highlight source to be exchanged

        -- Mini Pick
        MiniPickBorder = { link = 'FloatBorder' },
        MiniPickBorderBusy = { link = 'DiagnosticInfo' },
        MiniPickBorderText = { link = 'FloatTitle' },
        MiniPickCursor = { link = 'Cursor' },
        MiniPickHeader = { link = 'Title' },
        MiniPickIconDirectory = { link = 'Directory' },
        MiniPickIconFile = { link = 'NormalFloat' },
        MiniPickMatchCurrent = { link = 'CursorLine' },
        MiniPickMatchMarked = { link = 'Visual' },
        MiniPickMatchRanges = { link = 'Search' },
        MiniPickNormal = { link = 'NormalFloat' },
        MiniPickPreviewLine = { link = 'CursorLine' },
        MiniPickPreviewRegion = { link = 'IncSearch' },
        MiniPickPrompt = { link = 'Title' },
        MiniPickPromptCaret = { link = 'Cursor' },
        MiniPickPromptPrefix = { link = 'Special' },

        -- Mini Snippets
        MiniSnippetsCurrent = { link = 'Search' },
        MiniSnippetsCurrentReplace = { link = 'IncSearch' },
        MiniSnippetsFinal = { link = 'Special' },
        MiniSnippetsUnvisited = { link = 'SpecialKey' },
        MiniSnippetsVisited = { link = 'Comment' },

        -- Mini Starter
        MiniStarterCurrent = { link = 'CursorLine' },
        MiniStarterFooter = { link = 'Comment' },
        MiniStarterHeader = { link = 'Title' },
        MiniStarterInactive = { link = 'Comment' },
        MiniStarterItem = { link = 'Normal' },
        MiniStarterItemBullet = { link = 'Delimiter' },
        MiniStarterItemPrefix = { link = 'WarningMsg' },
        MiniStarterQuery = { link = 'Special' },
        MiniStarterSection = { link = 'Special' },

        -- Mini Statusline
        MiniStatuslineModeNormal = { fg = c.base0, bg = c.light_purple, bold = true },
        MiniStatuslineModeInsert = { fg = c.base0, bg = c.light_green, bold = true },
        MiniStatuslineModeVisual = { fg = c.base0, bg = c.light_cyan, bold = true },
        MiniStatuslineModeReplace = { fg = c.base0, bg = c.light_orange, bold = true },
        MiniStatuslineModeCommand = { fg = c.base0, bg = c.light_red, bold = true },
        MiniStatuslineModeOther = { fg = c.base0, bg = c.light_blue, bold = true },

        MiniStatuslineDevinfo = { link = 'Normal' },
        MiniStatuslineFilename = { link = 'Normal' },
        MiniStatuslineFileinfo = { link = 'Normal' },

        MiniStatuslineInactive = { fg = c.base3 },

        -- Mini Surround
        MiniSurround = { link = 'IncSearch' }, -- Highlight surrounding chars

        -- Mini Tabline
        MiniTablineCurrent = { link = 'TabLineSel' }, -- buffer is current (has cursor in it).
        MiniTablineVisible = { link = 'TabLine' }, -- buffer is visible (displayed in some window).
        MiniTablineHidden = { link = 'TabLine' }, -- buffer is hidden (not displayed).
        MiniTablineModifiedCurrent = { fg = c.base0, bg = c.base7, bold = true, italic = true }, -- buffer is modified and current.
        MiniTablineModifiedVisible = { fg = c.base0, bg = c.base6, bold = true, italic = true }, -- buffer is modified and visible.
        MiniTablineModifiedHidden = { fg = c.base0, bg = c.base6, bold = true, italic = true }, -- buffer is modified and hidden.
        MiniTablineFill = { link = 'TabLineFill' }, -- unused right space of tabline.
        MiniTablineTabpagesection = { link = 'Search' }, -- section with tabpage information.
        MiniTablineTrunc = { link = 'Comment' }, -- truncation symbols indicating more left/right tabs.

        -- Mini Test
        MiniTestEmphasis = { bold = true },
        MiniTestFail = { fg = c.red, bold = true },
        MiniTestPass = { fg = c.green, bold = true },

        -- Mini Trailspace
        MiniTrailspace = { link = 'Error' },

        -- Lspsaga
        RenameNormal = { link = 'Normal' },

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
        NotifyERRORIcon = { link = 'NotifyERRORTitle' },
        NotifyWARNIcon = { link = 'NotifyWARNTitle' },
        NotifyINFOIcon = { link = 'NotifyINFOTitle' },
        NotifyDEBUGIcon = { link = 'NotifyDEBUGTitle' },
        NotifyTRACEIcon = { link = 'NotifyTRACETitle' },

        -- nvim-cmp
        CmpItemAbbr = { link = 'Comment' },
        CmpItemAbbrDeprecated = { link = 'Visual' },
        CmpItemAbbrMatch = { link = 'Identifier' },
        CmpItemAbbrMatchFuzzy = { link = 'CmpItemAbbrMatch' },

        CmpItemKindText = { link = 'Pmenu' },
        CmpItemKindSnippet = { fg = c.base2 },
        CmpItemKindConstant = { fg = c.blue },
        CmpItemKindVariable = { fg = c.blue },
        CmpItemKindKeyword = { fg = c.orange },
        CmpItemKindMethod = { fg = c.purple },
        CmpItemKindFunction = { link = 'CmpItemKindMethod' },
        CmpItemKindConstructor = { link = 'CmpItemKindMethod' },
        CmpItemKindClass = { fg = c.pink },
        CmpItemKindInterface = { link = 'CmpItemKindClass' },
        CmpItemKindModule = { link = 'CmpItemKindClass' },
        CmpItemKindStruct = { link = 'CmpItemKindClass' },

        -- barbar
        BufferCurrent = { link = 'TabLineSel' },
        BufferCurrentIndex = { link = 'TabLineSel' },
        BufferCurrentMod = { fg = c.orange },
        BufferCurrentSign = { fg = c.base7 },
        BufferCurrentTarget = { fg = c.red },
        BufferInactive = { link = 'TabLine' },
        BufferInactiveIndex = { link = 'TabLine' },
        BufferInactiveMod = { link = 'BufferCurrentMod' },
        BufferInactiveSign = { link = 'BufferCurrentSign' },
        BufferInactiveTarget = { link = 'BufferCurrentTarget' },
        BufferVisible = { link = 'BufferInactive' },
        BufferVisibleIndex = { link = 'BufferInactiveIndex' },
        BufferVisibleMod = { link = 'BufferInactiveMod' },
        BufferVisibleSign = { link = 'BufferInactiveSign' },
        BufferVisibleTarget = { link = 'BufferInactiveTarget' },
        BufferTabpages = { link = 'TabLine' },
        BufferTabpageFill = { link = 'TabLine' },
        BufferOffset = { link = 'TabLineSel' },
        BufferScrollArrow = { link = 'TabLineSel' },

        -- noice.nvim
        NoiceCmdlinePopupTitle = { fg = c.base0, bold = true },
        NoiceCmdlinePopupBorder = { fg = c.base0 },

        -- Neogit
        NeogitDiffAdd = { bg = c.light_green },
        NeogitDiffAddHighlight = { link = 'NeogitDiffAdd' },
        NeogitDiffDelete = { bg = c.light_red },
        NeogitDiffDeleteHighlight = { link = 'NeogitDiffDelete' },
        NeogitHunkHeader = { link = 'NeogitHunkHeaderHighlight' },

        -- Diffview
        DiffviewDiffAdd = { bg = c.light_green },
        DiffviewDiffDelete = { bg = c.light_red },
        DiffviewDiffChange = { bg = c.light_orange },

        -- modicator.nvim
        NormalMode = { link = 'Normal' },
        InsertMode = { bold = true },
        VisualMode = { link = 'Visual' },
        CommandMode = { link = 'NormalMode' },
        ReplaceMode = { fg = c.red },
        SelectMode = { link = 'VisualMode' },
        TerminalMode = { link = 'NormalMode' },
        TerminalNormalMode = { link = 'NormalMode' },

        -- rcarriga/nvim-dap-ui
        DapUIVariable = { link = 'Normal' },
        DapUIValue = { link = 'Normal' },
        DapUIFrameName = { link = 'Normal' },
        DapUIThread = { fg = c.orange },
        DapUIWatchesValue = { link = 'DapUIThread' },
        DapUIBreakpointsInfo = { link = 'DapUIThread' },
        DapUIBreakpointsCurrentLine = { fg = c.orange, bold = true },
        DapUIWatchesError = { link = 'DapUIWatchesEmpty' },
        DapUIBreakpointsDisabledLine = { fg = c.muted },
        DapUISource = { fg = c.iris },
        DapUIBreakpointsPath = { fg = c.cyan },
        DapUIScope = { link = 'DapUIBreakpointsPath' },
        DapUILineNumber = { link = 'DapUIBreakpointsPath' },
        DapUIBreakpointsLine = { link = 'DapUIBreakpointsPath' },
        DapUIFloatBorder = { link = 'DapUIBreakpointsPath' },
        DapUIStoppedThread = { link = 'DapUIBreakpointsPath' },
        DapUIDecoration = { link = 'DapUIBreakpointsPath' },
        DapUIModifiedValue = { fg = c.cyan, bold = true },

        -- fff.nvim
        FFFGitStaged = { link = 'GitStaged' },
        FFFGitModified = { link = 'GitModified' },
        FFFGitDeleted = { link = 'GitDeleted' },
        FFFGitRenamed = { link = 'GitRenamed' },
        FFFGitUntracked = { link = 'GitUntracked' },
        FFFGitIgnored = { link = 'GitIgnored' },
        FFFGitSignStaged = { link = 'GitStaged' },
        FFFGitSignDeleted = { link = 'GitDeleted' },
        FFFGitSignIgnored = { link = 'GitIgnored' },

        -- render-markdown.nvim
        RenderMarkdownH1Bg = { bg = c.light_red },
        RenderMarkdownH2Bg = { bg = c.light_pink },
        RenderMarkdownH3Bg = { bg = c.light_purple },
        RenderMarkdownH4Bg = { bg = c.light_blue },
        RenderMarkdownH5Bg = { bg = c.light_cyan },
        RenderMarkdownH6Bg = { bg = c.light_orange },

        -- markview.nvim
        MarkviewPalette0 = { fg = c.base0, bg = c.base6 },
        MarkviewPalette0Fg = { fg = c.base0 },
        MarkviewPalette0Bg = { bg = c.base6 },
        MarkviewPalette0Sign = { link = 'MarkviewPalette0Fg' },
        MarkviewPalette1 = { fg = c.base0, bg = c.light_red },
        MarkviewPalette1Fg = { fg = c.base0 },
        MarkviewPalette1Bg = { bg = c.light_red },
        MarkviewPalette1Sign = { link = 'MarkviewPalette1Fg' },
        MarkviewPalette2 = { fg = c.base0, bg = c.light_pink },
        MarkviewPalette2Fg = { fg = c.base0 },
        MarkviewPalette2Bg = { bg = c.light_pink },
        MarkviewPalette2Sign = { link = 'MarkviewPalette2Fg' },
        MarkviewPalette3 = { fg = c.base0, bg = c.light_purple },
        MarkviewPalette3Fg = { fg = c.base0 },
        MarkviewPalette3Bg = { bg = c.light_purple },
        MarkviewPalette3Sign = { link = 'MarkviewPalette3Fg' },
        MarkviewPalette4 = { fg = c.base0, bg = c.light_blue },
        MarkviewPalette4Fg = { fg = c.base0 },
        MarkviewPalette4Bg = { bg = c.light_blue },
        MarkviewPalette4Sign = { link = 'MarkviewPalette4Fg' },
        MarkviewPalette5 = { fg = c.base0, bg = c.light_cyan },
        MarkviewPalette5Fg = { fg = c.base0 },
        MarkviewPalette5Bg = { bg = c.light_cyan },
        MarkviewPalette5Sign = { link = 'MarkviewPalette5Fg' },
        MarkviewPalette6 = { fg = c.base0, bg = c.light_orange },
        MarkviewPalette6Fg = { fg = c.base0 },
        MarkviewPalette6Bg = { bg = c.light_orange },
        MarkviewPalette6Sign = { link = 'MarkviewPalette6Fg' },
    }
end

return M
