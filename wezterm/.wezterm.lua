local config = require("wezterm")

config.term = "xterm-256color"
config.audible_bell = "Disabled"

require("ui").setup(config)
require("keys").setup(config)
require("mouse").setup(config)

return config



