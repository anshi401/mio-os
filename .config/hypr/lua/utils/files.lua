function is_file_exists(name)
   local f = io.open(name, "r")
   if f ~= nil then
      io.close(f)
      return true
   else
      return false
   end
end

function create_if_not_exists(path)
    if not is_file_exists(path) then
        os.execute("mkdir -p \"$(dirname \"" .. path .. "\")\"")

        local comment = "--"
        if string.match(path, "fish") then
            comment = "#"
        end

        local content = comment .. " This file will not be overwritten across updates.\n" ..
            comment .. " See the corresponding files in ~/.mio-os/.config/hypr/lua for examples"

        os.execute("echo '" .. content .. "' > \"" .. path .. "\"")
        return true
    end
    return false
end

function copy_if_not_exists(src, dst)
    if is_file_exists(dst) then
        return false
    end

    if not is_file_exists(src) then
        return create_if_not_exists(dst)
    end

    os.execute("mkdir -p \"$(dirname \"" .. dst .. "\")\"")

    local fin = io.open(src, "r")
    local content = fin:read("*a")
    fin:close()

    local comment = "--"
    if string.match(dst, "fish") then
        comment = "#"
    end

    local header = comment .. " This file will not be overwritten across updates.\n" ..
                   comment .. " Copied from the default config, feel free to edit it.\n\n"

    local fout = io.open(dst, "w")
    if not fout then
        return false
    end
    fout:write(header, content)
    fout:close()

    return true
end
