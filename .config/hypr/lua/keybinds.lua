require("lua.utils.customConfigs")

local customDir = os.getenv("HOME") .. "/.mio-os/.config/hypr/lua/custom/"

local settings
if is_file_exists(customDir .. "settings.lua") then
    settings = require("lua.custom.settings")
else
    settings = require("lua.settings")
end

hl.bind(settings.main .. " + Q", hl.dsp.window.close())
hl.bind(settings.main .. " + SHIFT + Q", hl.dsp.exit())

hl.bind(settings.main .. " + RETURN", hl.dsp.exec_cmd(settings.terminal))
hl.bind(settings.main .. " + E", hl.dsp.exec_cmd(settings.fileManager))
hl.bind(settings.main .. " + B", hl.dsp.exec_cmd(settings.browser))
hl.bind(settings.main .. " + T", hl.dsp.exec_cmd(settings.textEditor))
hl.bind("CONTROL + SHIFT + ESCAPE", hl.dsp.exec_cmd(settings.terminal .. " --class btop btop"))
hl.bind(settings.main .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind(settings.main .. " + SHIFT + B", hl.dsp.exec_cmd("~/.mio-os/.local/bin/batteryMenu.sh"))
hl.bind("CONTROL + ALT + DELETE", hl.dsp.exec_cmd("~/.mio-os/.local/bin/powerMenu.sh"))
hl.bind(settings.main .. " + W", hl.dsp.exec_cmd("~/.mio-os/.local/bin/wallpaperChanger.sh"))
hl.bind(settings.main .. " + SHIFT + W", hl.dsp.exec_cmd("~/.mio-os/.local/bin/waybarLayoutChanger.sh"))

hl.bind("ALT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.bring_to_top())
end)

-- hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot -z -m output --clipboard-only"))
-- hl.bind("CONTROL + PRINT", hl.dsp.exec_cmd("hyprshot -z -m region --clipboard-only"))

hl.bind(
    "PRINT",
    hl.dsp.exec_cmd(
        'sh -c "grim -g \\"$(slurp -o -r -c \'#ff0000ff\')\\" -t ppm - | tee >(wl-copy --type image/png) | satty -f - --output-filename ~/Pictures/screenshot-%Y-%m-%d_%H-%M-%S.png"'
    ),
    { description = "Satty Screenshot" }
)

hl.bind(settings.main .. "+ R", hl.dsp.exec_cmd("recorder.sh save"))
hl.bind(settings.main .. "+ SHIFT + R", hl.dsp.exec_cmd("recorder.sh record"))

hl.bind("ALT + SPACE", hl.dsp.exec_cmd("rofi -show drun -config ~/.mio-os/.config/rofi/styles/appLauncher.rasi"))
hl.bind(settings.main .. " + TAB", hl.dsp.exec_cmd("rofi -show window -config ~/.mio-os/.config/rofi/styles/appLauncher.rasi"))
hl.bind(settings.main .. " + C", hl.dsp.exec_cmd("rofi -show calc -no-show-match -no-sort -config ~/.mio-os/.config/rofi/styles/calculator.rasi"))
hl.bind(settings.main .. " + PERIOD", hl.dsp.exec_cmd("rofi -show emoji -config ~/.mio-os/.config/rofi/styles/emojiMenu.rasi"))
hl.bind(settings.main .. " + V", hl.dsp.exec_cmd("~/.mio-os/.local/bin/clipboardHistory.sh"))
hl.bind(settings.main .. " + N", hl.dsp.exec_cmd("~/.mio-os/.local/bin/notificationsHistory.sh"))

hl.bind(settings.main .. " + H", hl.dsp.layout("focus l"))
hl.bind(settings.main .. " + L", hl.dsp.layout("focus r"))
hl.bind(settings.main .. " + SHIFT + H", hl.dsp.layout("colresize -0.1"))
hl.bind(settings.main .. " + SHIFT + L", hl.dsp.layout("colresize +0.1"))
hl.bind(settings.main .. " + J", hl.dsp.layout("swapcol l"))
hl.bind(settings.main .. " + K", hl.dsp.layout("swapcol r"))

-- hl.bind(settings.main .. " + J", hl.dsp.layout("move -col"))
-- hl.bind(settings.main .. " + K", hl.dsp.layout("move +col"))

-- hl.bind(settings.main .. " + Y", hl.dsp.layout("swapcol l"))
-- hl.bind(settings.main .. " + O", hl.dsp.layout("swapcol r"))

-- hl.bind(settings.main .. " + H", hl.dsp.focus({ direction = "left" }))
-- hl.bind(settings.main .. " + L", hl.dsp.focus({ direction = "right" }))
-- hl.bind(settings.main .. " + K", hl.dsp.focus({ direction = "up" }))
-- hl.bind(settings.main .. " + J", hl.dsp.focus({ direction = "down" }))

-- hl.bind(settings.main .. " + Y", hl.dsp.window.move({ direction = "left" }))
-- hl.bind(settings.main .. " + O", hl.dsp.window.move({ direction = "right" }))
-- hl.bind(settings.main .. " + I", hl.dsp.window.move({ direction = "up" }))
-- hl.bind(settings.main .. " + U", hl.dsp.window.move({ direction = "down" }))

-- hl.bind(settings.main .. " + SHIFT + H", hl.dsp.window.resize({ x = -30, y = 0, relative = true }), { repeating = true })
-- hl.bind(settings.main .. " + SHIFT + L", hl.dsp.window.resize({ x = 30, y = 0, relative = true }), { repeating = true })
-- hl.bind(settings.main .. " + SHIFT + K", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), { repeating = true })
-- hl.bind(settings.main .. " + SHIFT + J", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), { repeating = true })

hl.bind(settings.main .. " + F", hl.dsp.window.float())

for i = 1, 10 do
    local key = i % 10
    hl.bind(settings.main .. " + " .. key, hl.dsp.focus({ workspace = i}))
    hl.bind(settings.main .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(settings.main .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(settings.main .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(settings.main .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(settings.main .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("~/.mio-os/.local/bin/volumeControl.sh --sound --inc"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("~/.mio-os/.local/bin/volumeControl.sh --sound --dec"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("~/.mio-os/.local/bin/volumeControl.sh --sound --mute"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("~/.mio-os/.local/bin/volumeControl.sh --mic --mute"), { locked = true, repeating = true })

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("~/.mio-os/.local/bin/brightnessControl.sh --inc"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("~/.mio-os/.local/bin/brightnessControl.sh --dec"), { locked = true, repeating = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
