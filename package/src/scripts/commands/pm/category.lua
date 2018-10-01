-- Extensible Application Framework Package Manager repository category viewer.
-- This script could be used to list the repository's categories or retrieve specific category's content (package list).
-- Every subcommand option is standalone and needs to use flag to run itself.

local arguments, options = ...
local component = require("component")
local filesystem = require("filesystem")
local httpstream = require("xaf/utility/httpstream")
local jsonparser = require("xaf/utility/jsonparser")
local xafcore = require("xaf/core/xafcore")
local xafcoreTable = xafcore:getTableInstance()

if (options.h == true or options.help == true) then
end

if (options.c == true or options.content == true or options.l == true or options.list == true) then
  local pathRoot = "aquaver.github.io"
  local pathProject = "xaf-framework"
  local pathData = "data"
  local pathName = "pm-source.info"

  local sourcePath = filesystem.concat(pathRoot, pathProject, pathData, pathName)
  local sourceData = {}

  if (filesystem.exists(sourcePath) == true) then
    sourceData = xafcoreTable:loadFromFile(sourcePath)
  else
    print("--------------------------------------")
    print("-- XAF Package Manager - Controller --")
    print("--------------------------------------")
    print("  >> Cannot find the source repositories list file")
    print("  >> Reinstall XAF package or download this file manually")
    print("  >> Missing file name: " .. pathName)

    os.exit()
  end

  if (component.isAvailable("internet") == false) then
    print("--------------------------------------")
    print("-- XAF Package Manager - Controller --")
    print("--------------------------------------")
    print("  >> Internet card component is not available")
    print("  >> Package Manager cannot connect to target repository")

    os.exit()
  else
    print("--------------------------------------")
    print("-- XAF Package Manager - Controller --")
    print("--------------------------------------")
    print("  >> Internet card component found")
    print("  >> Trying to connect to target repository")
  end

  if (options.c == true or options.content == true) then
  elseif (options.l == true or options.list == true) then
  end

  os.exit()
end

print("--------------------------------------")
print("-- XAF Package Manager - Controller --")
print("--------------------------------------")
print("  >> Package source repository category viewer")
print("  >> Use 'xaf-pm category [-h | --help]' for command manual")
