require("lua.utils.customConfigs")

local customDir = os.getenv("HOME") .. "/.mio-os/.config/hypr/lua/custom/"

local settings
if is_file_exists(customDir .. "settings.lua") then
    settings = require("lua.custom.settings")
else
    settings = require("lua.settings")
end

hl.env("settingsMainMonitor", settings.mainMonitor)
hl.env("settingsSecondMonitor", settings.secondMonitor)
hl.env("settingsKeyboardName", settings.keyboardName)
hl.env("settingsTheme", settings.gtkTheme)
hl.env("settingsMode", settings.mode)
hl.env("settingsIcons", settings.icons)
hl.env("settingsFont", settings.font .. " " .. settings.fontSize)
hl.env("settingsCursor", settings.cursor)
hl.env("settingsRecorderPath", settings.recorderPath)
hl.env("settingsRecorderFPS", settings.recorderFPS)
hl.env("settingsReplaySeconds", settings.replaySeconds)
hl.env("settingsRecorderCodec", settings.recorderCodec)
hl.env("settingsRecorderQuality", settings.recorderQuality)
hl.env("settingsRecorderBitrateMode", settings.recorderBitrateMode)
hl.env("settingsRecorderContainer", settings.recorderContainer)
hl.env("settingsRecorderCursor", settings.recorderCursor)
hl.env("settingsReplayStorage", settings.replayStorage)
hl.env("settingsReplayDateFolders", settings.replayDateFolders)

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")

hl.env("GTK_THEME", settings.gtkTheme)

hl.env("HYPRCURSOR_THEME", settings.cursor)
hl.env("HYPRCURSOR_SIZE", settings.cursorSize)
hl.env("XCURSOR_SIZE", settings.cursorSize)
hl.env("XCURSOR_THEME", settings.cursor)

hl.env("GDK_SCALE", "1")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("CLUTTER_BACKEND", "wayland")

hl.env("SDL_VIDEODRIVER", "wayland")

hl.env("MOZ_ENABLE_WAYLAND", "1")

hl.env("OZONE_PLATFORM", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")

-- Fix blur for some Gnome apps
hl.env("GDK_WAYLAND_DISABLE", "ext_background_effect_manager_v1")
