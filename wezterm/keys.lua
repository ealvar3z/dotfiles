local wezterm = require("wezterm")
local a = wezterm.action

local function map(mods, key, actio)
    return { mods = mods, key = key, action = action }
end

return {
    setup = function(config)
	config.leader = { mods = "CTRL", key = "b" } -- too used to tmux
	config.keys = {
	    -- just in case we have tmux running
	    map("LEADER|CTRL", "b", a.SendKey({ mods = "CTRL", key = "b" })),
	    map("CTRL|SHIFT", "5", a.SplitHorizontal({ domain = "CurrentPaneDomain" })),
	    map("CTRL|SHIFT", "'", a.SplitVertical({ domain = "CurrentPaneDomain" })),
	}
    end,
}
