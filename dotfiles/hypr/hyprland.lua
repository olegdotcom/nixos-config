-- Native Hyprland config (0.57+). Home Manager deploys this directory as-is.
-- https://wiki.hypr.land/configuring/
local main_mod = "ALT"

-- Use the same defaults for every display. The lid handler needs an explicit
-- panel rule so its partial updates retain the preferred mode and 2x scaling.
for _, output in ipairs({ "", "eDP-1" }) do
  hl.monitor({ output = output, mode = "preferred", position = "auto", scale = 2, disabled = false })
end

-- Match the ASUS OSD's Display P3 preset, regardless of the dock's port name.
hl.monitor({
  output = "desc:ASUSTek COMPUTER INC PA32QCV",
  mode = "preferred",
  position = "auto",
  scale = 2,
  cm = "dp3",
  sdr_eotf = "srgb",
})

-- Clamshell mode for any external display. Hyprland moves the workspaces;
-- keep the current one selected and the pointer on it after disabling the panel.
local panel_disabled, pending_workspace
local function sync_clamshell()
  local lid <close> = io.open("/proc/acpi/button/lid/LID0/state", "r")
  local closed = lid ~= nil and (lid:read(64) or ""):find("closed", 1, true) ~= nil

  local external = false
  for _, monitor in ipairs(hl.get_monitors()) do
    if monitor.name ~= "eDP-1" and monitor.name ~= "FALLBACK" then
      external = true
      break
    end
  end
  local disabled = closed and external
  if disabled ~= panel_disabled then
    panel_disabled = disabled
    local workspace = hl.get_active_workspace()
    pending_workspace = disabled and workspace and workspace.id or nil
    hl.monitor({ output = "eDP-1", disabled = disabled })
  end

  -- Monitor changes are asynchronous; finish once the panel has been removed.
  if pending_workspace and not hl.get_monitor("eDP-1") then
    local workspace = hl.get_workspace(pending_workspace)
    local monitor = workspace and workspace.monitor
    if monitor and monitor.name ~= "FALLBACK" then
      pending_workspace = nil
      hl.dispatch(hl.dsp.focus({ workspace = workspace.id }))
      -- 0.57 exposes logical dimensions, including scaling and rotation.
      local mode = monitor.mode
      hl.dispatch(hl.dsp.cursor.move({ x = monitor.x + mode.width / 2, y = monitor.y + mode.height / 2 }))
    end
  end
end

hl.bind("switch:on:Lid Switch", sync_clamshell, { locked = true })
hl.bind("switch:off:Lid Switch", sync_clamshell, { locked = true })
for _, event in ipairs({ "hyprland.start", "config.reloaded", "monitor.layout_changed" }) do
  hl.on(event, sync_clamshell)
end

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
