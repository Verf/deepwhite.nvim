std = 'luajit'
read_globals = { 'vim' }
-- The API table is read-only, but option/global values are intentionally mutable.
globals = { 'vim.g', 'vim.o', 'vim.opt_global', 'vim.opt_local' }

-- Start with syntax and global-variable correctness, not a repository-wide style cleanup.
-- 0xx: syntax errors; 1xx: undefined globals, writes to read-only globals, etc.
only = { '0', '1' }
