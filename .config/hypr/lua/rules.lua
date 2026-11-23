require("lua.utils.customConfigs")

local customDir = os.getenv("HOME") .. "/.mio-os/.config/hypr/lua/custom/"

local settings
if is_file_exists(customDir .. "settings.lua") then
    settings = require("lua.custom.settings")
else
    settings = require("lua.settings")
end

hl.window_rule({
    name = "utils",
    match = {
        class = "^(blueman-manager|org\\.pulseaudio\\.pavucontrol|network|systemUpdate|btop)$"
    },
    float = true,
    size = {1280, 720},
    center = true
})

hl.window_rule({
    name = "pictureInPictrue",
    match = {
        title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"
    },
    float = true,
    size = {"(monitor_w*0.25)", "(monitor_h*0.25)"},
    move = {"(monitor_w*0.74)", "(monitor_h*0.04)"},
    pin = true,
    keep_aspect_ratio = true
})

hl.window_rule({
    name = "portalDialogs",
    match = {
        class = "^(org\\.freedesktop\\.impl\\.portal\\.desktop\\.(hyprland|gtk)|[Xx]dg-desktop-portal-gtk|hyprland-share-picker)$"
    },
    float = true,
    center = true
})

hl.window_rule({
    name = "portalDialogs",
    match = {
        class = "^(org.freedesktop.impl.portal.desktop.(hyprland|gtk)|[Xx]dg-desktop-portal-gtk|hyprland-share-picker)$"
    },
    float = true,
    center = true,
})

hl.window_rule({
    name = "dialogs",
    match = {
        title = "^(Choose Files|Save As|Confirm to replace files|File Operation Progress|Open|Authentication Required|Add Folder to Workspace|File Upload.*|.*dialog.*|Empty Trash|Rename.*|Save.*|Extract)$"
    },

    float = true,
    center = true
})

hl.window_rule({
    name = "gamesByClass",
    match = {
        class = "^(.*osu.*|steam_app_.*|steam)$"
    },
    monitor = settings.mainMonitor,
    immediate = true,
})

hl.window_rule({
    name = "gamesByTitle",
    match = {
        title = "^(Euro Truck Simulator 2)$"
    },
    monitor = settings.mainMonitor,
    immediate = true,
})

hl.layer_rule({
    name = "blurLayers",
    match = {
        namespace = "^(waybar|rofi|notifications)$"
    },

    blur = true,
    blur_popups = true,
    ignore_alpha = 0.5
})

hl.layer_rule({
    name = "hiddenLayers",
    match = {
        namespace = "^(notifications)$"
    },

    no_screen_share = true
})

hl.layer_rule({
    name = "noAnimationForSelection",
    match = {
        namespace = "^(selection|hyprpicker|org.satty.satty)$"
    },

    no_anim = true
})
