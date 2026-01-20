local wezterm = require("wezterm")

wezterm.on("gui-startup", function(_)
  local _, _, window = wezterm.mux.spawn_window({})
  window:gui_window():maximize()
end)

local config = {}

config.color_scheme = "Navy and Ivory (terminal.sexy)"

if wezterm.target_triple == "x86_64-apple-darwin" then
  config.font_size = 16
else
  config.font_size = 10
end

config.window_close_confirmation = "NeverPrompt"

config.set_environment_variables = {
  XDG_CONFIG_HOME = os.getenv("HOME") .. "/.config",
}

config.leader = { key = "Space", mods = "SHIFT", timeout_milliseconds = 1000 }

config.keys = {
  -- Pane management
  {
    key = "h",
    mods = "LEADER",
    action = wezterm.action.ActivatePaneDirection("Left"),
  },
  {
    key = "j",
    mods = "LEADER",
    action = wezterm.action.ActivatePaneDirection("Down"),
  },
  {
    key = "k",
    mods = "LEADER",
    action = wezterm.action.ActivatePaneDirection("Up"),
  },
  {
    key = "l",
    mods = "LEADER",
    action = wezterm.action.ActivatePaneDirection("Right"),
  },
  {
    key = "n",
    mods = "LEADER",
    action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "d",
    mods = "LEADER",
    action = wezterm.action.CloseCurrentPane({ confirm = false }),
  },

  -- Tab management
  {
    key = "h",
    mods = "LEADER|SHIFT",
    action = wezterm.action.ActivateTabRelative(-1),
  },
  {
    key = "l",
    mods = "LEADER|SHIFT",
    action = wezterm.action.ActivateTabRelative(1),
  },
  {
    key = "n",
    mods = "LEADER|SHIFT",
    action = wezterm.action.SpawnTab("CurrentPaneDomain"),
  },
  {
    key = "d",
    mods = "LEADER|SHIFT",
    action = wezterm.action.CloseCurrentTab({ confirm = false }),
  },
}

return config

-- Resources
-- https://github.com/wez/wezterm/issues/3299
