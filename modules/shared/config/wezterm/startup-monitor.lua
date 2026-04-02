-- File: ~/.config/wezterm/startup-monitor.lua
-- pre-requisites:
---- alias cls='clear'
---- alias wd='while true; do tput cup 0 0; command duf; sleep 2; done'
---- alias dp='watch -n 1 "docker ps -a --format \"table {{.ID}}\t{{.Names}}\t{{.Status}}\" "'

local wezterm = require("wezterm")
local mux = wezterm.mux
local enable_startup_monitor = os.getenv("WEZTERM_STARTUP_MONITOR") == "1"

local function setup_startup_handler()
  wezterm.on("gui-startup", function(cmd)
    if cmd then
      mux.spawn_window(cmd)
      return
    end

    if not enable_startup_monitor then
      return
    end

    local tab, pane, _window = mux.spawn_window({
      workspace = "dev-monitor-session",
    })

    local bottom_pane = pane:split({ direction = "Bottom", size = 0.5 })
    local top_right_pane = pane:split({ direction = "Right", size = 0.5 })
    local bottom_right_pane = bottom_pane:split({ direction = "Right", size = 0.5 })

    pane:send_text("htop\n")
    top_right_pane:send_text("exit\n")
    bottom_pane:send_text("wd\n")
    bottom_right_pane:send_text("sudo /opt/homebrew/sbin/iftop -i en0\n")

    bottom_pane:activate()
  end)
end

setup_startup_handler()

return true
