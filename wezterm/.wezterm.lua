local wezterm = require("wezterm")

local config = wezterm.config_builder()
-- ui
--config.color_scheme = "Chalk"
config.color_scheme = "kanagawabones"

config.window_frame = {
    font = wezterm.font("Hack Nerd Font", {
        weight = "Bold"
    }),
}

config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = true

config.font = wezterm.font_with_fallback({
  "MesloLGS Nerd Font Mono",
  "Symbols Nerd Font Mono",
})
config.font_size = 16

-- tmux draws your tabs, so wezterm's tab bar is just noise
config.enable_tab_bar = false




-- keep adding config options here
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.7
config.macos_window_background_blur = 10


config.initial_cols = 120
config.initial_rows = 32


config.keys = {
  {
    key = ":", mods = "CTRL|SHIFT|ALT",
    action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" },
  },
  {
    key = "a", mods = "CMD",
    action = wezterm.action.Multiple {
      wezterm.action.ActivateCopyMode,
      wezterm.action.CopyMode("MoveToScrollbackTop"),
      wezterm.action.CopyMode("MoveToStartOfLine"),
      wezterm.action.CopyMode({ SetSelectionMode = "Line" }),
      wezterm.action.CopyMode("MoveToScrollbackBottom"),
      wezterm.action.CopyMode("MoveToEndOfLineContent"),
  },
},
}
---

return config

