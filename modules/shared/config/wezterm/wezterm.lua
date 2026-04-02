local wezterm = require("wezterm")
local config = wezterm.config_builder()

require("startup-monitor")

local function get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end

  return "Dark"
end

local function scheme_for_appearance(appearance)
  if appearance:find("Dark") then
    return "Ashes (dark) (terminal.sexy)"
    -- return "Ayu Dark (Gogh)"
  end

  return "Ashes (light) (terminal.sexy)"
  -- return "Ayu Light (Gogh)"
end

local function tab_bar_colors_for_scheme(scheme_name)
  local scheme = wezterm.get_builtin_color_schemes()[scheme_name]
  if not scheme then
    return nil, nil
  end

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

local appearance = get_appearance()
local scheme_name = scheme_for_appearance(appearance)

config.color_scheme = scheme_name

local colors, window_frame = tab_bar_colors_for_scheme(scheme_name)
if colors then
  config.colors = colors
end

if window_frame then
  config.window_frame = window_frame
end

return config
