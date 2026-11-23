local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

require("startup-monitor")

local function get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end

  return "Dark"
end

local function load_palette(appearance)
  local variant = appearance:find("Dark") and "dark" or "light"
  local path = wezterm.config_dir .. "/../ghostty/themes/kimbank-ashes-" .. variant
  wezterm.add_to_config_reload_watch_list(path)

  local scheme = { ansi = {}, brights = {} }
  local fields = {
    foreground = "foreground",
    background = "background",
    ["cursor-color"] = "cursor_bg",
    ["cursor-text"] = "cursor_fg",
    ["selection-background"] = "selection_bg",
    ["selection-foreground"] = "selection_fg",
    ["split-divider-color"] = "split",
  }
  for line in io.lines(path) do
    local key, value = line:match("^%s*([%w%-]+)%s*=%s*(%S+)")
    if fields[key] then
      scheme[fields[key]] = value
    elseif key == "palette" then
      local index, color = value:match("^(%d+)=(#%x+)$")
      index = tonumber(index)
      if index and index < 16 then
        local colors = index < 8 and scheme.ansi or scheme.brights
        colors[index % 8 + 1] = color
      end
    end
  end
  scheme.cursor_border = scheme.cursor_bg
  return scheme
end

local function tab_bar_colors_for_scheme(scheme)
  local bg = wezterm.color.parse(scheme.background)
  local fg = wezterm.color.parse(scheme.foreground)
  local _, _, lightness, _ = bg:hsla()
  local is_dark = lightness < 0.5

  local titlebar_bg = is_dark and bg:lighten_fixed(0.08) or bg:darken_fixed(0.06)
  local inactive_bg = is_dark and bg:lighten_fixed(0.14) or bg:darken_fixed(0.1)
  local active_tab_bg = is_dark and bg:lighten_fixed(0.2) or bg:darken_fixed(0.14)
  local hover_bg = is_dark and bg:lighten_fixed(0.24) or bg:darken_fixed(0.18)
  local edge = is_dark and bg:lighten_fixed(0.18) or bg:darken_fixed(0.14)
  local inactive_fg = is_dark and fg:darken_fixed(0.2) or fg:lighten_fixed(0.2)

  return {
    tab_bar = {
      background = titlebar_bg,
      inactive_tab_edge = edge,
      active_tab = {
        bg_color = active_tab_bg,
        fg_color = fg,
      },
      inactive_tab = {
        bg_color = inactive_bg,
        fg_color = inactive_fg,
      },
      inactive_tab_hover = {
        bg_color = hover_bg,
        fg_color = fg,
      },
      new_tab = {
        bg_color = inactive_bg,
        fg_color = inactive_fg,
      },
      new_tab_hover = {
        bg_color = hover_bg,
        fg_color = fg,
      },
    },
  }, {
    active_titlebar_bg = titlebar_bg,
    inactive_titlebar_bg = inactive_bg,
    active_titlebar_fg = fg,
    inactive_titlebar_fg = inactive_fg,
    active_titlebar_border_bottom = edge,
    inactive_titlebar_border_bottom = edge,
  }
end

local scheme = load_palette(get_appearance())
-- Match the terminal text settings in ../ghostty/config (also used by cmux).
config.font = wezterm.font("Sarasa Term J")
config.font_size = 14
config.enable_kitty_keyboard = true
-- Match key positions independently of the active input source.
config.leader = { key = "phys:A", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
  -- Send LF so terminal AI CLIs treat Shift+Enter as a multiline prompt break.
  { key = "Enter", mods = "SHIFT", action = act.SendString("\x0a") },
  { key = "phys:A", mods = "LEADER|CTRL", action = act.SendKey({ key = "a", mods = "CTRL" }) },
  { key = "phys:Backslash", mods = "LEADER", action = act.SplitPane({ direction = "Right" }) },
  { key = "phys:Backslash", mods = "LEADER|SHIFT", action = act.SplitPane({ direction = "Left" }) },
  { key = "phys:Minus", mods = "LEADER", action = act.SplitPane({ direction = "Down" }) },
  { key = "phys:Minus", mods = "LEADER|SHIFT", action = act.SplitPane({ direction = "Up" }) },
  { key = "phys:R", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
}
config.key_tables = {
  resize_pane = {
    { key = "Escape", action = act.PopKeyTable },
    { key = "Enter", action = act.PopKeyTable },
  },
}

local pane_directions = { ["phys:H"] = "Left", ["phys:J"] = "Down", ["phys:K"] = "Up", ["phys:L"] = "Right" }
for key, direction in pairs(pane_directions) do
  table.insert(config.keys, { key = key, mods = "LEADER", action = act.ActivatePaneDirection(direction) })
  table.insert(config.key_tables.resize_pane, { key = key, action = act.AdjustPaneSize({ direction, 1 }) })
end

local colors, window_frame = tab_bar_colors_for_scheme(scheme)
scheme.tab_bar = colors.tab_bar
config.colors = scheme
config.window_frame = window_frame

return config
