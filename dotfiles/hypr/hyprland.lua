-- Native Hyprland config (0.57+). Home Manager deploys this directory as-is.
-- https://wiki.hypr.land/configuring/
local main_mod = "ALT"

-- Use 2x scaling for every display. The lid bindings need an explicit panel
-- rule because partial updates do not inherit the fallback rule's scale.
for _, output in ipairs({ "", "eDP-1" }) do
  hl.monitor({ output = output, scale = 2 })
end

-- Match the ASUS OSD's Display P3 preset, regardless of the dock's port name.
hl.monitor({
  output = "desc:ASUSTek COMPUTER INC PA32QCV",
  scale = 2,
  cm = "dp3",
})

-- Disable the panel on lid close and enable it on lid open.
-- https://wiki.hypr.land/configuring/core/binds/switches/
hl.bind("switch:on:Lid Switch", function()
  hl.monitor({ output = "eDP-1", disabled = true })
end, { locked = true })
hl.bind("switch:off:Lid Switch", function()
  hl.monitor({ output = "eDP-1", disabled = false })
end, { locked = true })

hl.config({
  input = {
    repeat_delay = 300, -- Milliseconds before repeating (default: 600).
    repeat_rate = 50,   -- Repeats per second (default: 25).
    touchpad = {
      scroll_factor = 0.2,
      clickfinger_behavior = true,
      tap_to_click = false,
    },
  },
  general = {
    gaps_out = 5,
    border_size = 2,
    col = {
      active_border = {
        colors = { "rgba(33ccffee)", "rgba(00ff99ee)" },
        angle = 45,
      },
      inactive_border = "rgba(595959aa)",
    },
  },
  decoration = { rounding = 5 },
  animations = { enabled = false },
  render = {
    -- Keep hyprsunset active for fullscreen photos, videos, and games too.
    non_shader_cm_interop = 1,
  },
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
  for _, command in ipairs({ "waybar", "hypridle", "hyprsunset", "nm-applet" }) do
    hl.exec_cmd(command)
  end
end)

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
