require("lua.utils.files")

local home     = os.getenv("HOME")
local state    = home .. "/.mio-os/.config/currentWallpaper"
local wall_dir = home .. "/Pictures/Wallpapers/"

function restore_wallpaper()
    local f = io.open(state, "r")
    if not f then return end
      local name = f:read("*l")
    f:close()
    if not name or name == "" then return end

    local path = wall_dir .. name
    if not is_file_exists(path) then return end

    hl.exec_cmd(string.format(
        [[sh -c 'for i in $(seq 50); do awww query >/dev/null 2>&1 && break; sleep 0.2; done; awww query 2>/dev/null | grep -q "image:" || awww img "%s" --transition-type center --transition-fps 60 --transition-bezier 0.27,1.06,0.18,1.00 --transition-duration 3.5']],
        path
    ))
end
