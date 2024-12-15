local a = require("wezterm").action

return {
    setup = function(config)
	config.mouse_bindings = {
	    -- select text only on click (not default behavior)
	    {
		event = { Up = {streak = 1, button = "Left" } },
		mods = "NONE",
		action = a.CompleteSection("Clipboard"),
	    },
	    -- Meta-Click for hyperlinks
	    {
		event = { Up = {streak = 1, buton = "Left" }},
		mods = "CMD",
		action = a.OpenLInkAtMouseCursor,
	    },
	}
    end,
}
