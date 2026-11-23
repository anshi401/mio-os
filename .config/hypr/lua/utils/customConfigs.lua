require("lua.utils.files")

hl.on("hyprland.start", function()
    local homeDir = os.getenv("HOME")
    local hyprDir = homeDir .. "/.mio-os/.config/hypr/lua"
    local hyprCustomDir = hyprDir .. "/custom"
    local fishCustomDir = homeDir .. "/.mio-os/.config/fish"

    local files = {
        hyprCustomDir .. "/environments.lua",
        hyprCustomDir .. "/autostart.lua",
        hyprCustomDir .. "/keybinds.lua",
        hyprCustomDir .. "/rules.lua",
        hyprCustomDir .. "/input.lua",
        fishCustomDir .. "/custom.fish"
    }

    local copies = {
        { src = hyprDir .. "/settings.lua", dst = hyprCustomDir .. "/settings.lua" },
        { src = hyprDir .. "/monitors.lua", dst = hyprCustomDir .. "/monitors.lua" },
    }

    local createdFiles = 0

    for _, file in ipairs(files) do
        if create_if_not_exists(file) then
            createdFiles = createdFiles + 1
        end
    end

    for _, item in ipairs(copies) do
        if copy_if_not_exists(item.src, item.dst) then
            createdFiles = createdFiles + 1
        end
    end

    if createdFiles > 0 then
        local msg = "Created " .. createdFiles .. " custom config files."
        hl.exec_cmd("notify-send -i 'dialog-information-symbolic' 'Configs' '" .. msg .. "' -h string:x-canonical-private-synchronous:custom_configs -t 5000")
        hl.exec_cmd("hyprctl reload")
    end
end)
