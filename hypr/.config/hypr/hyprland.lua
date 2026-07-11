-- This is an example Hyprland Lua config file.
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/

-- Please note not all available settings / options are set here.
-- For a full list, see the wiki

-- You can (and should!!) split this configuration into multiple files
-- Create your files separately and then require them like this:
-- require("myColors")


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})


---------------------------------
---- DEVICE SPECIFIC CONFIGS ----
---------------------------------

require("device")


---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local ipc         = "qs -c noctalia-shell ipc call"

local terminal    = "ghostty"
local fileManager = "dolphin"
local browser     = "firefox"
-- local menu        = ipc .. " launcher toggle"
local menu        = "fuzzel"
local runner      = "fuzzel --dmenu --lines 0"


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
-- hl.on("hyprland.start", function ()
--   hl.exec_cmd(terminal)
--   hl.exec_cmd("nm-applet")
--   hl.exec_cmd("waybar & hyprpaper & firefox")
-- end)


hl.on("hyprland.start", function()
    -- TEMP WORKAROUND: kwallet PAM unlocks via ksecretd, but kwalletd6 doesn't
    -- pick up the unlock state automatically. So after pam_kwallet_init, poke
    -- kwalletd6 to open the wallet (it grabs the key from ksecretd, no password
    -- needed). Remove this once kwallet-pam handles the ksecretd/kwalletd6 split
    -- properly upstream. See: https://bugs.kde.org/show_bug.cgi?id=516103
    hl.exec_cmd(
        "/usr/lib/pam_kwallet_init && sleep 2 && busctl --user call org.kde.kwalletd6 /modules/kwalletd6 org.kde.KWallet open sxs kdewallet 0 ''")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")

    -- hl.exec_cmd("qs -c noctalia-shell")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("curl -s http://ip-api.com/json | jq '.lat,.lon' | xargs bash -c 'wlsunset -t 3000 -l $0 -L $1'")

    hl.exec_cmd("sleep 2 && nm-applet")
    hl.exec_cmd("sleep 2 && blueman-applet")
    hl.exec_cmd("sleep 2 && steam -nochatui -nofriendsui -silent")
    hl.exec_cmd("sleep 2 && discord --start-minimized")
    hl.exec_cmd("sleep 2 && megasync")
    hl.exec_cmd("sleep 2 && bitwarden")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- QT
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")

hl.env("ELECTRON_OZONE_PLATFORM_HINT", "x11")

-- private env vars
require("private")


-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in          = 5,
        gaps_out         = 20,

        border_size      = 2,

        col              = {
            active_border   = { colors = { "rgba(8ec07cff)", "rgba(689d6aff)" }, angle = 45 },
            inactive_border = "rgba(928374ff)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing    = false,

        layout           = "scrolling",
    },

    decoration = {
        rounding         = 10,
        rounding_power   = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow           = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            -- color        = 0xee1a1a1a,
        },

        blur             = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
            special  = true
        },
    },

    animations = {
        enabled = true,
    },
})

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- Default springs
hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, spring = "easy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
-- hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.5, bezier = "almostLinear", style = "slidevert" })
-- hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
-- hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "easeOutQuint", style = "slidevert -50%" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "master",
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
        column_width = 0.5,
        explicit_column_widths = "0.5, 0.75, 1.0",
        direction = "right",
    },
})

----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = 1,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = true, -- If true disables the random hyprland logo / anime girl background. :(
    },
})


---------------
--- INPUT ----
---------------

hl.config({
    input = {
        kb_layout    = "us",
        kb_variant   = "",
        kb_model     = "",
        kb_options   = "fkeys:basic_13-24",
        kb_rules     = "",

        follow_mouse = 1,

        sensitivity  = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad     = {
            natural_scroll = true,
            tap_to_click = false,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
-- hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
-- local closeWindowBind = hl.bind(mainMod .. " + C", hl.dsp.window.close())
-- -- closeWindowBind:set_enabled(false)
-- hl.bind(mainMod .. " + M",
--     hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
-- hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
-- hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
-- hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
-- hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
-- hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd(ipc .. " sessionMenu toggle"))
-- hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(browser .. " --private-window"))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
-- hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(ipc .. " lockScreen lock"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
-- hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(ipc .. " notifications toggleHistory"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("wayfreeze --after-freeze-cmd 'fish -c grimslurp; killall wayfreeze'"))
-- hl.bind(mainMod .. " + period", hl.dsp.exec_cmd(ipc .. " launcher emoji"))
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd("fish -c \"fishmoji --menu fuzzel -c -t\""))
-- hl.bind(mainMod .. " + G", hl.dsp.exec_cmd(ipc .. " plugin:steam-overlay toggle"))
-- hl.bind(mainMod .. " + Tab", hl.dsp.exec_cmd(ipc .. " plugin:workspace-overview toggle"))
-- hl.bind(mainMod .. " + Slash", hl.dsp.exec_cmd(ipc .. " launcher command"))
hl.bind(mainMod .. " + Slash", hl.dsp.exec_cmd(runner .. " | xargs -r " .. terminal .. " -e"))


hl.bind(mainMod .. " + SHIFT + Space", hl.dsp.window.float())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + C", hl.dsp.window.center())


-- My drop down terminal experience
-- (there is a companion window rule to float, center, and size far below)
hl.bind(mainMod .. " + Return", function()
    hl.dispatch(hl.dsp.workspace.toggle_special("terminal"))

    if #hl.get_windows({ tag = "dropdown_terminal*" }) == 0 then
        hl.exec_cmd(terminal, { tag = "+dropdown_terminal", workspace = "special:terminal" })
    end
end)


-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Focus left and right in scrolling layout
hl.bind(mainMod .. " + SHIFT + mouse_down", hl.dsp.layout("move -col"))
hl.bind(mainMod .. " + SHIFT + mouse_up", hl.dsp.layout("move +col"))

-- Move column left/right in scrolling layout
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.layout("swapcol r"))
hl.bind(mainMod .. " + SHIFT + comma", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.layout("swapcol r"))


hl.bind(mainMod .. " + F", hl.dsp.layout("colresize +conf"))


-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
-- hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
-- hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e+1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2.5%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2.5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, repeating = true })
hl.bind("F20", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("SHIFT + ALT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("playerctl volume 0.02+"),
    { locked = true, repeating = true })
hl.bind("SHIFT + ALT + XF86AudioLowerVolume", hl.dsp.exec_cmd("playerctl volume 0.02-"),
    { locked = true, repeating = true })


-----------------
-- Global binds -
-----------------

-- OBS pass-through binds
local obs_class = "class:^(com\\.obsproject\\.Studio)$"
hl.bind("SHIFT + F13", hl.dsp.pass({ window = obs_class }))
hl.bind("SHIFT + F14", hl.dsp.pass({ window = obs_class }))
hl.bind("SHIFT + F15", hl.dsp.pass({ window = obs_class }))
hl.bind("SHIFT + F16", hl.dsp.pass({ window = obs_class }))
hl.bind("SHIFT + F17", hl.dsp.pass({ window = obs_class }))
hl.bind("SHIFT + F18", hl.dsp.exec_cmd('obs-cmd scene-item toggle "Things to Show" "Game Capture"'))
hl.bind("SHIFT + F19", hl.dsp.exec_cmd('obs-cmd scene-item toggle "Things to Show" "Entire Screen"'))
hl.bind("SHIFT + F20", hl.dsp.exec_cmd('obs-cmd scene-item toggle "Things to Show" "Specific Window"'))

-- Discord shortcut pass-through
local discord_class = "class:^discord$"
hl.bind("CTRL + ALT + M", hl.dsp.send_shortcut({ mods = "CTRL + SHIFT", key = "M", window = discord_class }))
hl.bind("CTRL + ALT + D", hl.dsp.send_shortcut({ mods = "CTRL + SHIFT", key = "D", window = discord_class }))

-- "Soundboard" like keybinds
local sounds = os.getenv("HOME") .. "/MEGA/Streaming Assets/sounds/soundboard"
hl.bind("CTRL + SHIFT + ALT + 1",
    hl.dsp.exec_cmd('mpv --no-video --volume=75 "' .. sounds .. '/minecraft-drinking-sound-effect.mp3"'))


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name           = "suppress-maximize-events",
    match          = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name     = "fix-xwayland-drags",
    match    = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

hl.window_rule({
    name   = "dropdown-terminal-rules",
    match  = { class = "com.mitchellh.ghostty", workspace = "special:terminal" },
    float  = true,
    center = true,
    size   = { 1200, 800 }
})

hl.window_rule({
    name       = "steam-games",
    match      = { initial_class = "^steam_app_.*$" },
    fullscreen = true,
})

-- -- Float all steam windows by default
-- hl.window_rule({
--     name  = "steam-float",
--     match = { class = "^(steam)$" },
--     float = true,
-- })

-- -- Force main steam window back to tiled
-- hl.window_rule({
--     name  = "steam-main-tile",
--     match = { class = "^(steam)$", title = "^(Steam)$" },
--     tile  = true,
-- })

-- -- Pin friends list
-- hl.window_rule({
--     name  = "steam-friends-pin",
--     match = { class = "^(steam)$", title = "^(Friends List)$" },
--     pin   = true,
-- })

-- Always send Discord to workspace 5
hl.window_rule({
    name      = "discord-workspace",
    match     = { class = "^(discord)$" },
    workspace = 5,
})

hl.window_rule({
    name  = "float-modals",
    match = { modal = true },
    float = true,
})

local floatClasses = {
    "imv",
    "org\\.kde\\.kcalc",
}

hl.window_rule({
    name  = "float-misc-apps",
    match = { class = "^(" .. table.concat(floatClasses, "|") .. ")$" },
    float = true,
})

hl.window_rule({
    name         = "idle-inhibit-fullscreen",
    match        = { class = ".*" },
    idle_inhibit = "fullscreen",
})

hl.layer_rule({
    name         = "noctalia",
    match        = { namespace = "noctalia-background-.*$" },
    ignore_alpha = 0.5,
    blur         = true,
    blur_popups  = true,
})
