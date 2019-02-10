-- Extensible Application Framework Package Manager add-on package updating script.
-- That program makes package updating more automated and downloads newer version of it automatically from its source repository.
-- Every subcommand options is standalone and needs to use flags to run itself.

local arguments, options = ...
local component = require("component")
local event = require("event")
local filesystem = require("filesystem")
local httpstream = require("xaf/utility/httpstream")
local jsonparser = require("xaf/utility/jsonparser")
local unicode = require("unicode")
local xafcore = require("xaf/core/xafcore")
local xafcoreTable = xafcore:getTableInstance()

local configTable = _G._XAF
local configVersion = (configTable) and configTable._VERSION or ''

if (options.h == true or options.help == true) then
end

if (options.p == true or options.package == true) then
  os.exit()
end

print("--------------------------------------")
print("-- XAF Package Manager - Controller --")
print("--------------------------------------")
print("  >> Package updating program")
print("  >> Use 'xaf-pm update [-h | --help]' for command manual")
