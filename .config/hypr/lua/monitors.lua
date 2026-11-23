require("lua.utils.customConfigs")

local customDir = os.getenv("HOME") .. "/.mio-os/.config/hypr/lua/custom/"

local settings
if is_file_exists(customDir .. "settings.lua") then
    settings = require("lua.custom.settings")
else
    settings = require("lua.settings")
end

hl.monitor({
    output = settings.mainMonitor,
    mode = "preferred",
    position = "auto",
    scale = 1,
})

hl.monitor({
    output = settings.secondMonitor,
    mode = "preferred",
    position = "auto",
    scale = 1,
})

hl.workspace_rule({workspace="1", monitor=settings.mainMonitor})
hl.workspace_rule({workspace="2", monitor=settings.mainMonitor})
hl.workspace_rule({workspace="3", monitor=settings.mainMonitor})
hl.workspace_rule({workspace="4", monitor=settings.mainMonitor})
hl.workspace_rule({workspace="5", monitor=settings.mainMonitor})

hl.workspace_rule({workspace="6", monitor=settings.secondMonitor})
hl.workspace_rule({workspace="7", monitor=settings.secondMonitor})
hl.workspace_rule({workspace="8", monitor=settings.secondMonitor})
hl.workspace_rule({workspace="9", monitor=settings.secondMonitor})
hl.workspace_rule({workspace="10", monitor=settings.secondMonitor})
