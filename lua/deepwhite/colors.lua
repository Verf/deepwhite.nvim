local M = {}

-- Independent terminal foregrounds on warm paper, not editor accent copies.
-- Colored text >= 4.5:1, body/neutral text >= 7:1; grays stay untinted.
-- Balance hue and saturation as well as lightness; chromatic tiers differ by >= 6 L*.
-- Editor/pastel colors and existing on_colors source mappings stay unchanged.
-- Each entry is { terminal role, existing on_colors source, default color }.
local terminal_roles = {
    { 'terminal_red', 'red', '#AD3535' },
    { 'terminal_green', 'success', '#31692D' },
    { 'terminal_yellow', 'yellow_fg', '#7C5917' },
    { 'terminal_blue', 'blue', '#36549E' },
    { 'terminal_magenta', 'purple', '#8E3078' },
    { 'terminal_cyan', 'hint', '#1A656D' },
    { 'terminal_white', 'base1', '#454545' },
    { 'terminal_bright_black', 'comment', '#4C4C4C' },
    { 'terminal_bright_red', 'red', '#C1453D' },
    { 'terminal_bright_green', 'success', '#427930' },
    { 'terminal_bright_yellow', 'yellow_fg', '#916717' },
    { 'terminal_bright_blue', 'blue', '#4368B4' },
    { 'terminal_bright_magenta', 'purple', '#A4478E' },
    { 'terminal_bright_cyan', 'hint', '#227980' },
    { 'terminal_bright_white', 'base0', '#505050' },
    -- Vivid keeps pink socket/door and orange device/FIFO categories, adapted for text.
    { 'terminal_pink', 'pink', '#9D4479' },
    { 'terminal_warning', 'warning', '#98521B' },
}

function M.get_colors(options)
    local colors = {
        base0 = '#1A1918', -- hsv(30, 8%, 10%)
        base1 = '#595855', -- hsv(45, 4%, 35%)
        base2 = '#807E79', -- hsv(43, 5%, 50%)
        base3 = '#999791', -- hsv(45, 5%, 60%)
        base4 = '#B3B1AD', -- hsv(40, 3%, 70%)
        base5 = '#CCCBC6', -- hsv(50, 3%, 80%)
        base6 = '#E6E4DF', -- hsv(43, 3%, 90%)
        base7 = '#FAF2EB', -- hsv(28, 6%, 98%)
        base8 = '#FAF6EB', -- hsv(45, 6%, 98%)

        light_orange = '#FAE1C8', -- hsv(30, 20%, 98%)
        light_yellow = '#FAFABB', -- hsv(60, 25%, 98%)
        light_cyan = '#BBFAFA', -- hsv(180, 25%, 98%)
        light_green = '#D4FAD4', -- hsv(120, 15%, 98%)
        light_blue = '#D4D4FA', -- hsv(240, 15%, 98%)
        light_purple = '#EDD4FA', -- hsv(280, 15%, 98%)
        light_pink = '#FAD4ED', -- hsv(320, 15%, 98%)
        light_red = '#FAD4D4', -- hsv(360, 15%, 98%)

        bright_orange = '#FAAF64', -- hsv(30, 60%, 98%)
        bright_yellow = '#FAFA64', -- hsv(60, 60%, 95%)
        bright_cyan = '#64FAFA', -- hsv(180, 60%, 98%)
        bright_green = '#64FA64', -- hsv(120, 60%, 98%)
        bright_blue = '#6464FA', -- hsv(240, 60%, 98%)
        bright_purple = '#C864FA', -- hsv(280, 60%, 98%)
        bright_pink = '#FA64C8', -- hsv(320, 60%, 98%)
        bright_red = '#FA6464', -- hsv(360, 60%, 98%)

        orange = '#F27900', -- hsv(30, 100%, 95%)
        yellow = '#F2F200', -- hsv(60, 100%, 95%)
        cyan = '#00A6A6', -- hsv(180, 100%, 65%)
        green = '#00A600', -- hsv(120, 100%, 65%)
        blue = '#0000A6', -- hsv(240, 100%, 65%)
        purple = '#6F00A6', -- hsv(280, 100%, 65%)
        pink = '#A6006F', -- hsv(320, 100%, 65%)
        red = '#A60000', -- hsv(360, 100%, 65%)

        diff_add = '#64FA64', -- hsv(120, 60%, 98%)
        diff_change = '#FAAF64', -- hsv(30, 60%, 98%)
        diff_delete = '#FA6464', -- hsv(360, 60%, 98%)

        diff_add_bg = '#AFFAAF', -- hsv(120, 30%, 98%)
        diff_change_bg = '#FAD4AF', -- hsv(30, 30%, 98%)
        diff_delete_bg = '#FAAFAF', -- hsv(360, 30%, 98%)

        diff_text = '#FA8919', -- hsv(60, 90%, 98%)

        iris = '#907aa9',
        muted = '#9893a5',

        -- Information foregrounds: keep the light/bright palette for background accents.
        comment = '#66635D',
        warning = '#A64B00',
        hint = '#006E73',
        success = '#216F21',
        yellow_fg = '#806000',
    }
    if options.low_blue_light then
        colors.base7 = '#FAFAFA' -- hsv(60, 0%, 98%)
    end
    colors.git_add = colors.success
    colors.git_change = colors.warning
    colors.git_delete = colors.red

    local original = {}
    for _, role in ipairs(terminal_roles) do
        original[role[2]] = colors[role[2]]
    end
    if options.on_colors then
        local ok, err = xpcall(function() options.on_colors(colors) end, debug.traceback)
        if not ok then error('deepwhite.nvim: on_colors failed: ' .. tostring(err), 0) end
    end
    -- Resolve terminal defaults after the hook: explicit terminal values win,
    -- including values equal to the defaults. Otherwise keep source overrides.
    for _, role in ipairs(terminal_roles) do
        if colors[role[1]] == nil then
            colors[role[1]] = colors[role[2]] == original[role[2]] and role[3] or colors[role[2]]
        end
    end
    return colors
end

-- ANSI slots 0-15, stored at Lua indices 1-16. Even white must be readable on a light background.
function M.get_terminal_colors(c)
    return {
        c.base0,
        c.terminal_red,
        c.terminal_green,
        c.terminal_yellow,
        c.terminal_blue,
        c.terminal_magenta,
        c.terminal_cyan,
        c.terminal_white,
        c.terminal_bright_black,
        c.terminal_bright_red,
        c.terminal_bright_green,
        c.terminal_bright_yellow,
        c.terminal_bright_blue,
        c.terminal_bright_magenta,
        c.terminal_bright_cyan,
        c.terminal_bright_white,
    }
end

return M
