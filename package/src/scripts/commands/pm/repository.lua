-- Extensible Application Framework Package Manager source repository manager.
-- This program is used to add, remove listed add-on repositories, and retrieving their description.
-- Every subcommand option is standalone and needs to use flag to run itself.

local arguments, options = ...
local component = require("component")
local filesystem = require("filesystem")
local httpstream = require("xaf/utility/httpstream")
local xafcore = require("xaf/core/xafcore")
local xafcoreMath = xafcore:getMathInstance()
local xafcoreTable = xafcore:getTableInstance()

local gpu = component.getPrimary("gpu")
local gpuWidth, gpuHeight = gpu.getResolution()

if (options.h == true or options.help == true) then
end

if (options.l == true or options.list == true or options.p == true or options.priority == true or -- First group, offline (local only) commands - do not need internet component.
    options.r == true or options.remove == true) then
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

      if (options.l == true or options.list == true) then
      elseif (options.p == true or options.priority == true) then
      elseif (options.r == true or options.remove == true) then
      end

      os.exit()
end

if (options.a == true or options.add == true or options.i == true or options.info == true) then -- Second group, online commands - required internet card component to work.
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
    print("  >> Trying to connect to target repository...")
  end

  local targetAddress = "https://raw.githubusercontent.com/"
  local targetRepository = arguments[1]
  local targetPriority = arguments[2]
  local targetPath = "/master/_config/repository.info"

  if (options.a == true or options.add == true) then
  elseif (options.i == true or options.info == true) then
  end

  os.exit()
end

print("--------------------------------------")
print("-- XAF Package Manager - Controller --")
print("--------------------------------------")
print("  >> Source repository management program")
print("  >> Use 'xaf-pm repository [-h | --help]' for command manual")
