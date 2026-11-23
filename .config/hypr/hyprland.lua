require("lua.animations")
require("lua.autostart")
require("lua.decoration")
require("lua.environments")
require("lua.general")
require("lua.input")
require("lua.keybinds")
require("lua.misc")
-- require("lua.nvidia") -- Uncomment this line if you have an Nvidia GPU
require("lua.rules")
require("lua.utils.customConfigs")

local customDir = os.getenv("HOME") .. "/.mio-os/.config/hypr/lua/custom/"

if is_file_exists(customDir .. "autostart.lua") then
    require("lua.custom.autostart")
end

if is_file_exists(customDir .. "environments.lua") then
    require("lua.custom.environments")
end

if is_file_exists(customDir .. "input.lua") then
    require("lua.custom.input")
end

if is_file_exists(customDir .. "keybinds.lua") then
    require("lua.custom.keybinds")
end

if is_file_exists(customDir .. "rules.lua") then
    require("lua.custom.rules")
end

if is_file_exists(customDir .. "monitors.lua") then
    require("lua.custom.monitors")
else
    require("lua.monitors")
end
