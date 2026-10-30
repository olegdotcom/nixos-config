-- Native Hyprland config (0.55+). Home Manager deploys this directory as-is.
-- https://wiki.hypr.land/configuring/
local main_mod = "ALT"

-- Let Hyprland arrange connected displays; retain the existing 2x scaling.
hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = 2,
})

-- TODO: Remove this after upgrading to Hyprland 0.57.
-- Keep the laptop's position stable across docking. Hyprland 0.56.2 can leave
-- bars at stale coordinates when outputs move (upstream fix: Hyprland #15842).
hl.monitor({
  output = "eDP-1",
  mode = "preferred",
  position = "0x0",
  scale = 2,
})

hl.config({
  input = {
    kb_layout = "us",
    repeat_delay = 300, -- Milliseconds before repeating (default: 600).
    repeat_rate = 50,   -- Repeats per second (default: 25).
    follow_mouse = 1,
    touchpad = {
      natural_scroll = false,
      scroll_factor = 0.2,
      clickfinger_behavior = true,
      tap_to_click = false,
    },
  },
  general = {
    gaps_in = 5,
    gaps_out = 10,
    border_size = 2,
    col = {
      active_border = {
        colors = { "rgba(33ccffee)", "rgba(00ff99ee)" },
        angle = 45,
      },
      inactive_border = "rgba(595959aa)",
    },
    layout = "dwindle",
  },
  decoration = { rounding = 5 },
  animations = { enabled = true },
  misc = {
    -- The old wallpaper.png was an exact copy of Hyprland's wall2.png.
    force_default_wallpaper = 2,
    disable_splash_rendering = true,
    -- Adaptive sync for fullscreen windows (1 would enable it always).
    vrr = 2,
  },
})

-- Start once per session; reloading the config does not duplicate daemons.
hl.on("hyprland.start", function()
  for _, command in ipairs({ "waybar", "hypridle", "nm-applet" }) do
    hl.exec_cmd(command)
  end
end)

hl.curve("window_ease", {
  type = "bezier",
  points = { { 0.05, 0.9 }, { 0.1, 1.05 } },
})
hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "window_ease" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

-- Three-finger Back/Forward navigation on both trackpads.
for _, direction in ipairs({ "left", "right" }) do
  hl.gesture({
    fingers = 3,
    direction = direction,
    action = function()
      hl.dispatch(hl.dsp.send_shortcut({
        mods = "ALT",
        key = direction == "left" and "Left" or "Right",
      }))
    end,
  })
end

-- Launchers and session controls.
hl.bind(main_mod .. " + T", hl.dsp.exec_cmd("foot"))
hl.bind(main_mod .. " + B", hl.dsp.exec_cmd("chromium"))
hl.bind(main_mod .. " + O", hl.dsp.exec_cmd("anyrun"))
hl.bind(main_mod .. " + Q", hl.dsp.window.close())
hl.bind(main_mod .. " + SHIFT + Q", hl.dsp.exit())
-- Use hypridle's guarded lock command, just like idle and suspend locking.
hl.bind(main_mod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(main_mod .. " + SHIFT + L", hl.dsp.exec_cmd("systemctl suspend"))
hl.bind(main_mod .. " + P", hl.dsp.exec_cmd("hyprshot -m region -o ~/screenshots"))

-- Holding volume/brightness keys repeats; these also work while locked.
for _, binding in ipairs({
  { "XF86AudioRaiseVolume",  "pamixer -i 5" },
  { "XF86AudioLowerVolume",  "pamixer -d 5" },
  { "XF86MonBrightnessUp",   "brightnessctl set 5%+" },
  { "XF86MonBrightnessDown", "brightnessctl set 5%-" },
}) do
  hl.bind(binding[1], hl.dsp.exec_cmd(binding[2]), { locked = true, repeating = true })
end
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"), { locked = true })

for _, direction in ipairs({ "left", "right", "up", "down" }) do
  hl.bind(main_mod .. " + " .. direction, hl.dsp.focus({ direction = direction }))
end

-- 0 selects workspace 10. Moving a window follows it to its new workspace.
for workspace = 1, 10 do
  local key = workspace % 10
  -- Keep all ten buttons available through Waybar's native workspace protocol.
  hl.workspace_rule({ workspace = tostring(workspace), persistent = true })
  hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
  hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
