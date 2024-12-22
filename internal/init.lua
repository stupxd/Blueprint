Blueprint = {}
Blueprint.INTERNAL_debugging = true

Blueprint.SETTINGS = {}

Blueprint.nfs = require "blueprint.nfs"
local lovely = require "lovely"

Blueprint.use_smods = function ()
    return SMODS and not (MODDED_VERSION == "0.9.8-STEAMODDED")
end


Blueprint.find_self = function (target_filename)
    local mods_path = lovely.mod_dir

	local mod_folders = Blueprint.nfs.getDirectoryItems(mods_path)
    for _, folder in pairs(mod_folders) do
        local path = string.format('%s/%s', mods_path, folder)
        local files = Blueprint.nfs.getDirectoryItems(path)

        for _, filename in pairs(files) do
            if filename == target_filename then
                return path
            end
        end
    end
end

Blueprint.path = Blueprint.find_self('blueprint.lua')
assert(Blueprint.path, "Failed to find mod folder. Make sure that `Blueprint` folder has `blueprint.lua` file!")

Blueprint.load_mod_file = function (path, name, as_txt)
    name = name or path

    local file, err = Blueprint.nfs.read(Blueprint.path..'/'..path)

    assert(file, string.format([=[[Blueprint] Failed to load mod file %s (%s).:
%s]=], path, name, tostring(err)))

    return as_txt and file
                   or load(file, string.format(" Blueprint - %s ", name))()
end

Blueprint.log = function (msg)
    if Blueprint.INTERNAL_debugging then
        local msg = type(msg) == "string" and msg or Blueprint.dump(msg)
        
        print("[Blueprint] "..msg)
    end
end


return Blueprint