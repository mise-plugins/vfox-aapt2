local util = require("util")

--- Extension point, called after PreInstall, can perform additional operations,
--- such as file operations for the SDK installation directory
--- @param ctx table
--- @field ctx.rootPath string SDK installation directory
function PLUGIN:PostInstall(ctx)
    local rootPath = ctx.rootPath
    local os_name = util.getOsName()
    local version = ctx.version

    -- The downloaded file is a JAR (ZIP) containing the aapt2 binary
    -- vfox should have extracted it, but the JAR contains the binary directly
    -- We need to find and make it executable

    local jar_name = string.format("aapt2-%s-%s.jar", version, os_name)
    local jar_path = rootPath .. "/" .. jar_name

    -- Extract the JAR file (it's a ZIP)
    local extract_cmd
    if OS_TYPE == "windows" then
        -- On Windows, use PowerShell to extract
        extract_cmd = string.format('powershell -Command "Expand-Archive -Path \'%s\' -DestinationPath \'%s\' -Force"', jar_path, rootPath)
    else
        -- On Unix-like systems, use unzip
        extract_cmd = string.format('unzip -o "%s" -d "%s"', jar_path, rootPath)
    end

    local result = os.execute(extract_cmd)
    if not result then
        error("Failed to extract JAR file")
    end

    -- Remove the JAR file after extraction
    os.remove(jar_path)

    -- Make the binary executable on Unix systems
    if OS_TYPE ~= "windows" then
        local aapt2_path = rootPath .. "/aapt2"
        os.execute(string.format('chmod +x "%s"', aapt2_path))
    end
end
