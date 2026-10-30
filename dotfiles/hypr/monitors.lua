-- Use the ASUS alone while docked; restore the laptop panel on removal.
-- Match its description so changing the cable's port does not change policy.
local internal_output = "eDP-1"
local dock_description = "ASUSTek COMPUTER INC PA32QCV TALMSV000428"

local function dock_is_active()
    for _, monitor in ipairs(hl.get_monitors()) do
        if monitor.description == dock_description then
            return true
        end
    end
    return false
end

-- A single fallback gives both known displays and new outputs the same scale.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 2 })

-- This also runs on reload, before monitor rules are applied, so a docked
-- reload does not briefly enable the internal display.
local panel_disabled = dock_is_active()
local function configure_panel(disabled)
    hl.monitor({
        output = internal_output,
        mode = "preferred",
        position = "auto",
        scale = 2,
        disabled = disabled,
    })
end
configure_panel(panel_disabled)

local pending = false
local function schedule_layout()
    if pending then
        return
    end
    pending = true
    -- Let Hyprland finish adding/removing outputs before reading the list.
    -- Hyprland owns the one-shot timer and clears it on config reload.
    hl.timer(function()
        pending = false
        local disabled = dock_is_active()
        if disabled ~= panel_disabled then
            -- Set this first: changing the panel also emits monitor events.
            panel_disabled = disabled
            configure_panel(disabled)
        end
    end, { timeout = 100, type = "oneshot" })
end

for _, event in ipairs({ "hyprland.start", "monitor.added", "monitor.removed" }) do
    hl.on(event, schedule_layout)
end

-- Also used by the lid-open and manual recovery bindings.
return {
    relayout = function()
        panel_disabled = nil
        schedule_layout()
    end,
}
