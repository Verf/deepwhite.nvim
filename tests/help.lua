-- Generate help tags outside the checkout and resolve all DeepWhite topics.
-- nvim --headless -u NONE -i NONE -n -c 'luafile tests/help.lua' -c 'cquit 1'
local root = vim.fn.getcwd()
local temp = vim.fn.tempname()
local passed = 0
local ok, err = xpcall(function()
    local lines = vim.fn.readfile(root .. '/doc/deepwhite.txt')
    assert(#lines > 0, 'Missing editor help')
    local tags, links = {}, {}
    for _, line in ipairs(lines) do
        for tag in line:gmatch '%*([^%s*]+)%*' do
            assert(not tags[tag], 'Duplicate help tag: ' .. tag)
            tags[tag] = true
        end
        for link in line:gmatch '|(deepwhite[^|%s]*)|' do
            links[link] = true
        end
    end
    for _, tag in ipairs {
        'deepwhite',
        'deepwhite.nvim',
        'deepwhite-quickstart',
        'deepwhite-setup',
        'deepwhite-options',
        'deepwhite-overrides',
        'deepwhite-terminal-colors',
        'deepwhite-integrations',
        'deepwhite-troubleshooting',
        'deepwhite-development',
    } do
        assert(tags[tag], 'Missing public help topic: ' .. tag)
    end
    for link in pairs(links) do
        assert(tags[link], 'Broken internal help link: ' .. link)
    end
    passed = passed + 1
    print 'PASS help tags and internal links'

    local doc = temp .. '/doc'
    vim.fn.mkdir(doc, 'p')
    assert(vim.fn.writefile(lines, doc .. '/deepwhite.txt') == 0, 'Could not copy help fixture')
    vim.opt.runtimepath:prepend(temp)
    vim.cmd('helptags ' .. vim.fn.fnameescape(doc))
    local generated = {}
    for _, line in ipairs(vim.fn.readfile(doc .. '/tags')) do
        local tag, file = line:match '^(%S+)\t([^\t]+)\t'
        if file == 'deepwhite.txt' then generated[tag] = true end
    end
    for tag in pairs(tags) do
        assert(generated[tag], 'helptags omitted ' .. tag)
        vim.cmd('help ' .. tag)
        assert(vim.fn.expand '%:p' == doc .. '/deepwhite.txt', 'Help resolved outside the fixture: ' .. tag)
        local line = vim.api.nvim_get_current_line()
        assert(line:find('*' .. tag .. '*', 1, true), 'Help did not jump to the tag: ' .. tag)
        passed = passed + 1
        print('PASS :help ' .. tag)
    end
end, debug.traceback)
vim.fn.delete(temp, 'rf')
if not ok then
    print('FAIL editor help\n' .. err)
    vim.cmd 'cquit 1'
end
print(string.format('RESULT: %d editor help checks passed', passed))
vim.cmd 'qa!'
