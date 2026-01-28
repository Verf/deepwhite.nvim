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
        TabLine = { fg = c.base7, bg = c.base0 }, -- Tab pages line, not active tab page label.
        TabLineFill = { fg = c.base0, bg = c.base7 }, -- Tab pages line, where there are no labels.
        TabLineSel = { fg = c.base0, bg = c.base7 }, -- Tab pages line, active tab page label.
        Title = { fg = c.base0, bold = true }, -- Titles for output from ":set all", ":autocmd" etc.
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

        PreProc = { link = 'Question' }, -- generic Preprocessor
        Include = { link = 'Question' }, -- preprocessor #include
        Define = { link = 'Question' }, -- preprocessor #define
        Macro = { link = 'Question' }, -- same as Define
        PreCondit = { link = 'Question' }, -- preprocessor #if, #else, #endif, etc.

        Type = { fg = c.pink }, -- int, long, char, etc.
        Storage = { link = 'Type' }, --lass static, register, volatile, etc.
        Structure = { link = 'Type' }, --struct, union, enum, etc.
        Typedef = { link = 'Type' }, -- a typedef

        Special = { link = 'SpecialKey' }, -- any special symbol
        SpecialChar = { link = 'SpecialKey' }, -- special character in a constant
        Tag = { link = 'SpecialKey' }, -- you can use CTRL-] on this
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
        ['@variable.builtin'] = { link = 'Special' }, -- built-in variable names (e.g. `this`, `self`)
        ['@variable.parameter'] = { link = 'Identifier' }, -- parameters of a function
        ['@variable.parameter.builtin'] = { link = 'Special' }, -- special parameters (e.g. `_`, `it`)
        ['@variable.member'] = { link = 'Identifier' }, -- object and struct fields

        ['@constant'] = { link = 'Constant' }, -- constant identifiers
        ['@constant.builtin'] = { link = 'Constant' }, -- built-in constant values
        ['@constant.macro'] = { link = 'Macro' }, -- constants defined by the preprocessor

        ['@module'] = { link = 'Structure' }, -- modules or namespaces
        ['@module.builtin'] = { link = 'Structure' }, -- built-in modules or namespaces
        ['@label'] = { link = 'Label' }, -- `GOTO` and other labels (e.g. `label:` in C), including heredoc labels

        ['@string'] = { link = 'String' }, -- string literals
        ['@string.documentation'] = { link = 'Comment' }, -- string documenting code (e.g. Python docstrings)
        ['@string.regexp'] = { link = 'SpecialChar' }, -- regular expressions
        ['@string.escape'] = { link = 'SpecialChar' }, -- escape sequences
        ['@string.special'] = { link = 'SpecialChar' }, -- other special strings (e.g. dates)
        ['@string.special.symbol'] = { link = 'Identifier' }, -- symbols or atoms
        ['@string.special.path'] = { link = 'Underlined' }, -- filenames
        ['@string.special.url'] = { link = 'Underlined' }, -- URIs (e.g. hyperlinks)

        ['@character'] = { link = 'Character' }, -- character literals
        ['@character.special'] = { link = 'SpecialChar' }, -- special characters (e.g. wildcards)

        ['@boolean'] = { link = 'Boolean' }, -- boolean literals
        ['@number'] = { link = 'Number' }, -- numeric literals
        ['@number.float'] = { link = 'Float' }, -- floating-point number literals

        ['@type'] = { link = 'Type' }, -- type or class definitions and annotations
        ['@type.builtin'] = { link = 'Type' }, -- built-in types
        ['@type.definition'] = { link = 'Typedef' }, -- identifiers in type definitions (e.g. `typedef <type> <identifier>` in C)

        ['@attribute'] = { link = 'Macro' }, -- attribute annotations (e.g. Python decorators, Rust lifetimes)
        ['@attribute.builtin'] = { link = 'Macro' }, -- builtin annotations (e.g. `@property` in Python)
        ['@property'] = { link = 'Identifier' }, -- the key in key/value pairs

        ['@function'] = { link = 'Function' }, -- function definitions
        ['@function.builtin'] = { link = 'Special' }, -- built-in functions
        ['@function.call'] = { link = 'Function' }, -- function calls
        ['@function.macro'] = { link = 'Macro' }, -- preprocessor macros

        ['@function.method'] = { link = 'Function' }, -- method definitions
        ['@function.method.call'] = { link = 'Function' }, -- method calls

        ['@constructor'] = { link = 'Special' }, -- constructor calls and definitions
        ['@operator'] = { link = 'Operator' }, -- symbolic operators (e.g. `+`, `*`)

        ['@keyword'] = { link = 'Keyword' }, -- keywords not fitting into specific categories
        ['@keyword.coroutine'] = { link = 'Keyword' }, -- keywords related to coroutines (e.g. `go` in Go, `async/await` in Python)
        ['@keyword.function'] = { link = 'Storage' }, -- keywords that define a function (e.g. `func` in Go, `def` in Python)
        ['@keyword.operator'] = { link = 'Operator' }, -- operators that are English words (e.g. `and`, `or`)
        ['@keyword.import'] = { link = 'Include' }, -- keywords for including or exporting modules (e.g. `import`, `from` in Python)
        ['@keyword.type'] = { link = 'Structure' }, -- keywords describing namespaces and composite types (e.g. `struct`, `enum`)
        ['@keyword.modifier'] = { link = 'Storage' }, -- keywords modifying other constructs (e.g. `const`, `static`, `public`)
        ['@keyword.repeat'] = { link = 'Repeat' }, -- keywords related to loops (e.g. `for`, `while`)
        ['@keyword.return'] = { link = 'Statement' }, -- keywords like `return` and `yield`
        ['@keyword.debug'] = { link = 'Debug' }, -- keywords related to debugging
        ['@keyword.exception'] = { link = 'Exception' }, -- keywords related to exceptions (e.g. `throw`, `catch`)

        ['@keyword.conditional'] = { link = 'Conditional' }, -- keywords related to conditionals (e.g. `if`, `else`)
        ['@keyword.conditional.ternary'] = { link = 'Operator' }, -- ternary operator (e.g. `?`, `:`)

        ['@keyword.directive'] = { link = 'PreProc' }, -- various preprocessor directives and shebangs
        ['@keyword.directive.define'] = { link = 'Define' }, -- preprocessor definition directives

        ['@punctuation'] = { link = 'Identifier' }, -- punctuation
        ['@punctuation.delimiter'] = { link = 'Identifier' }, -- delimiters (e.g. `;`, `.`, `,`)
        ['@punctuation.bracket'] = { link = 'Identifier' }, -- brackets (e.g. `()`, `{}`, `[]`)
        ['@punctuation.special'] = { link = 'SpecialChar' }, -- special symbols (e.g. `{}` in string interpolation)

        ['@comment'] = { link = 'Comment' }, -- line and block comments
        ['@comment.documentation'] = { link = 'Comment' }, -- comments documenting code

        ['@comment.error'] = { link = 'Error' }, -- error-type comments (e.g. `ERROR`, `FIXME`, `DEPRECATED`)
        ['@comment.warning'] = { link = 'Todo' }, -- warning-type comments (e.g. `WARNING`, `FIX`, `HACK`)
        ['@comment.todo'] = { link = 'Todo' }, -- todo-type comments (e.g. `TODO`, `WIP`)
        ['@comment.note'] = { link = 'SpecialComment' }, -- note-type comments (e.g. `NOTE`, `INFO`, `XXX`)

        ['@markup.strong'] = { link = 'SpecialChar' }, -- bold text
        ['@markup.italic'] = { link = 'SpecialChar' }, -- italic text
        ['@markup.strikethrough'] = { link = 'Comment' }, -- struck-through text
        ['@markup.underline'] = { link = 'Underlined' }, -- underlined text (only for literal underline markup!)

        ['@markup.heading'] = { link = 'Structure' }, -- headings, titles (including markers)
        ['@markup.heading.1'] = { link = 'Structure' }, -- top-level heading
        ['@markup.heading.2'] = { link = 'Structure' }, -- section heading
        ['@markup.heading.3'] = { link = 'Structure' }, -- subsection heading
        ['@markup.heading.4'] = { link = 'Structure' }, -- and so on
        ['@markup.heading.5'] = { link = 'Structure' }, -- and so forth
        ['@markup.heading.6'] = { link = 'Structure' }, -- six levels ought to be enough for anybody

        ['@markup.quote'] = { link = 'Comment' }, -- block quotes
        ['@markup.math'] = { link = 'Special' }, -- math environments (e.g. `$ ... $` in LaTeX)

        ['@markup.link'] = { link = 'Underlined' }, -- text references, footnotes, citations, etc.
        ['@markup.link.label'] = { link = 'SpecialChar' }, -- link, reference descriptions
        ['@markup.link.url'] = { link = 'Underlined' }, -- URL-style links

        ['@markup.raw'] = { link = 'String' }, -- literal or verbatim text (e.g. inline code)
        ['@markup.raw.block'] = { link = 'String' }, -- literal or verbatim text as a stand-alone block

        ['@markup.list'] = { link = 'SpecialChar' }, -- list markers
        ['@markup.list.checked'] = { link = 'SpecialChar' }, -- checked todo-style list markers
        ['@markup.list.unchecked'] = { link = 'SpecialChar' }, -- unchecked todo-style list markers

        ['@diff.plus'] = { link = 'Added' }, -- added text (for diff files)
        ['@diff.minus'] = { link = 'Removed' }, -- deleted text (for diff files)
        ['@diff.delta'] = { link = 'Changed' }, -- changed text (for diff files)

        ['@tag'] = { link = 'Tag' }, -- XML-style tag names (e.g. in XML, HTML, etc.)
        ['@tag.builtin'] = { link = 'Tag' }, -- builtin tag names (e.g. HTML5 tags)
        ['@tag.attribute'] = { link = 'Identifier' }, -- XML-style tag attributes
        ['@tag.delimiter'] = { link = 'Identifier' }, -- XML-style tag delimiters

        -- vim.lsp
        LspReferenceText = { bg = c.light_purple }, -- Used for highlighting "text" references
        LspReferenceRead = { link = 'LspReferenceText' }, -- Used for highlighting "read" references
        LspReferenceWrite = { link = 'LspReferenceText' }, -- Used for highlighting "write" references
        LspReferenceTarget = { link = 'LspReferenceText' }, -- Used for highlighting reference targets (e.g. in a hover range)
        LspInlayHint = { link = 'Comment' }, -- Used for highlighting inlay hints (make them subtle like comments)
        LspCodeLens = { link = 'Comment' }, -- Used to color the virtual text of the codelens.
        LspCodeLensSeparator = { link = 'Comment' }, -- Used to color the separator between two or more code lenses.
        LspSignatureActiveParameter = { link = 'LspReferenceText' }, -- Used to highlight the active parameter in the signature help.

        ['@lsp.type.class'] = { link = 'Structure' }, -- Identifiers that declare or reference a class type
        ['@lsp.type.comment'] = { link = 'Comment' }, -- Tokens that represent a comment
        ['@lsp.type.decorator'] = { link = 'Function' }, -- Identifiers that declare or reference decorators and annotations
        ['@lsp.type.enum'] = { link = 'Structure' }, -- Identifiers that declare or reference an enumeration type
        ['@lsp.type.enumMember'] = { link = 'Constant' }, -- Identifiers that declare or reference an enumeration property, constant, or member
        ['@lsp.type.event'] = { link = 'Identifier' }, -- Identifiers that declare an event property
        ['@lsp.type.function'] = { link = 'Function' }, -- Identifiers that declare a function
        ['@lsp.type.interface'] = { link = 'Structure' }, -- Identifiers that declare or reference an interface type
        ['@lsp.type.keyword'] = { link = 'Keyword' }, -- Tokens that represent a language keyword
        ['@lsp.type.macro'] = { link = 'Macro' }, -- Identifiers that declare a macro
        ['@lsp.type.method'] = { link = 'Function' }, -- Identifiers that declare a member function or method
        ['@lsp.type.modifier'] = { link = 'Storage' }, -- Tokens that represent a modifier
        ['@lsp.type.namespace'] = { link = 'Structure' }, -- Identifiers that declare or reference a namespace, module, or package
        ['@lsp.type.number'] = { link = 'Number' }, -- Tokens that represent a number literal
        ['@lsp.type.operator'] = { link = 'Operator' }, -- Tokens that represent an operator
        ['@lsp.type.parameter'] = { link = 'Identifier' }, -- Identifiers that declare or reference a function or method parameters
        ['@lsp.type.property'] = { link = 'Identifier' }, -- Identifiers that declare or reference a member property, member field, or member variable
        ['@lsp.type.regexp'] = { link = 'String' }, -- Tokens that represent a regular expression literal
        ['@lsp.type.string'] = { link = 'String' }, -- Tokens that represent a string literal
        ['@lsp.type.struct'] = { link = 'Structure' }, -- Identifiers that declare or reference a struct type
        ['@lsp.type.type'] = { link = 'Type' }, -- Identifiers that declare or reference a type that is not covered above
        ['@lsp.type.typeParameter'] = { link = 'Type' }, -- Identifiers that declare or reference a type parameter
        ['@lsp.type.variable'] = { link = 'Identifier' }, -- Identifiers that declare or reference a local or global variable

        ['@lsp.mod.abstract'] = { link = 'Storage' }, -- Types and member functions that are abstract
        ['@lsp.mod.async'] = { link = 'Keyword' }, -- Functions that are marked async
        ['@lsp.mod.declaration'] = { link = 'Identifier' }, -- Declarations of symbols
        ['@lsp.mod.defaultLibrary'] = { link = 'Special' }, -- Symbols that are part of the standard library
        ['@lsp.mod.definition'] = { link = 'Identifier' }, -- Definitions of symbols, for example, in header files
        ['@lsp.mod.deprecated'] = { link = 'Error' }, -- Symbols that should no longer be used
        ['@lsp.mod.documentation'] = { link = 'SpecialComment' }, -- Occurrences of symbols in documentation
        ['@lsp.mod.modification'] = { link = 'Identifier' }, -- Variable references where the variable is assigned to
        ['@lsp.mod.readonly'] = { link = 'Constant' }, -- Readonly variables and member fields (constants)
        ['@lsp.mod.static'] = { link = 'Storage' }, -- Class members (static members)

        -- vim.diagnostic
        DiagnosticError = { fg = c.red },
        DiagnosticWarn = { fg = c.orange },
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

        -- Plugins
        -- Mini Animate
        MiniAnimateCursor = { link = 'Cursor' },
        MiniAnimateNormalFloat = { link = 'NormalFloat' },

        -- Mini Clue
        MiniClueBorder = { link = 'FloatBorder' },
        MiniClueDescGroup = { link = 'Title' }, -- Group names (e.g. "+lsp")
        MiniClueDescSingle = { link = 'NormalFloat' }, -- Normal descriptions
        MiniClueNextKey = { link = 'SpecialKey' }, -- The key to press
        MiniClueNextKeyWithPostkeys = { link = 'WarningMsg' }, -- Keys that need more keys
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
        MiniCompletionActiveParameter = { underline = true },
        MiniCompletionDeprecated = { link = 'Comment', strikethrough = true },
        MiniCompletionInfoBorderOutdated = { link = 'Error' },

        -- Mini Cursorword
        MiniCursorword = { underline = true }, -- Subtle highlight for word under cursor
        MiniCursorwordCurrent = { link = 'Cursor' }, -- Or leave empty to just show cursor

        -- Mini Deps
        MiniDepsChangeAdded = { link = 'Added' },
        MiniDepsChangeRemoved = { link = 'Removed' },
        MiniDepsHint = { link = 'Comment' },
        MiniDepsInfo = { link = 'Special' },
        MiniDepsMsgBreaking = { link = 'ErrorMsg' },
        MiniDepsPlaceholder = { link = 'Comment' },
        MiniDepsTitle = { link = 'Title' },
        MiniDepsTitleError = { link = 'ErrorMsg' },
        MiniDepsTitleSame = { link = 'Comment' },
        MiniDepsTitleUpdate = { link = 'Added' },

        -- Mini Diff
        MiniDiffOverAdd = { link = 'DiffAdd' }, -- Background highlight for added text
        MiniDiffOverChange = { link = 'DiffChange' }, -- Background highlight for changed text
        MiniDiffOverChangeBuf = { link = 'MiniDiffOverChange' },
        MiniDiffOverContext = { link = 'CursorLine' },
        MiniDiffOverContextBuf = { link = 'CursorLine' },
        MiniDiffOverDelete = { link = 'DiffDelete' }, -- Background highlight for deleted text
        MiniDiffSignAdd = { bg = c.light_green }, -- Darker green for the sign column symbol
        MiniDiffSignChange = { bg = c.light_orange }, -- Orange for change symbol
        MiniDiffSignDelete = { bg = c.light_red }, -- Red for delete symbol

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

        -- Mini Jump
        MiniJump = { link = 'IncSearch' }, -- Background highlight for jump target
        MiniJump2dDim = { fg = c.base4 }, -- Dimmed text
        MiniJump2dSpot = { fg = c.red, bold = true },
        MiniJump2dSpotAhead = { fg = c.blue, bg = c.base6 },
        MiniJump2dSpotUnique = { fg = c.orange, bold = true },

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
        MiniPickPrompt = { link = 'Title' }, -- The prompt text ("> ")
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
        MiniStarterHeader = { link = 'Title' }, -- Big header
        MiniStarterInactive = { link = 'Comment' },
        MiniStarterItem = { link = 'Normal' },
        MiniStarterItemBullet = { link = 'Delimiter' },
        MiniStarterItemPrefix = { link = 'WarningMsg' }, -- Shortcut key
        MiniStarterQuery = { link = 'Special' },
        MiniStarterSection = { link = 'Special' }, -- Group headers

        -- Mini Statusline
        MiniStatuslineModeNormal = { fg = c.base0, bg = c.light_purple, bold = true }, -- Strong contrast
        MiniStatuslineModeInsert = { fg = c.base0, bg = c.light_green, bold = true },
        MiniStatuslineModeVisual = { fg = c.base0, bg = c.light_cyan, bold = true },
        MiniStatuslineModeReplace = { fg = c.base0, bg = c.light_orange, bold = true },
        MiniStatuslineModeCommand = { fg = c.base0, bg = c.light_red, bold = true },
        MiniStatuslineModeOther = { fg = c.base0, bg = c.light_blue, bold = true },

        MiniStatuslineDevinfo = { link = 'Normal' },
        MiniStatuslineFileinfo = { link = 'Normal' },
        MiniStatuslineFilename = { link = 'Normal' },

        MiniStatuslineInactive = { link = 'Comment' },

        -- Mini Surround
        MiniSurround = { link = 'IncSearch' }, -- Highlight surrounding chars

        -- Mini Tabline
        MiniTablineCurrent = { link = 'TabLineSel' },
        MiniTablineVisible = { link = 'TabLineSel' },
        MiniTablineHidden = { link = 'TabLine' },
        MiniTablineModifiedCurrent = { fg = c.base0, bg = c.base7, bold = true, italic = true },
        MiniTablineModifiedHidden = { link = 'MiniTablineModifiedCurrent' },
        MiniTablineModifiedVisible = { fg = c.base7, bg = c.base0, italic = true },
        MiniTablineFill = { link = 'TabLineFill' },
        MiniTablineTabpagesection = { link = 'Search' },
        MiniTablineTrunc = { link = 'Comment' },

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

        CmpItemKindText = { fg = c.base0 },
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
    }
end

return M
