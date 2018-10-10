-- Extensible Application Framework Package Manager add-on packages management program.
-- This script is used to install, uninstall, getting information and listing installed add-ons.
-- Every subcommand option is standalone and needs to use flag to run itself.

local arguments, options = ...
local component = require("component")
local event = require("event")
local filesystem = require("filesystem")
local httpstream = require("xaf/utility/httpstream")
local jsonparser = require("xaf/utility/jsonparser")
local unicode = require("unicode")
local xafcore = require("xaf/core/xafcore")
local xafcoreMath = xafcore:getMathInstance()
local xafcoreTable = xafcore:getTableInstance()

local configTable = _G._XAF
local configVersion = (configTable) and configTable._VERSION or ''
local gpu = component.getPrimary("gpu")
local gpuWidth, gpuHeight = gpu.getResolution()

if (options.h == true or options.help == true) then
end

if (options.l == true or options.list == true or options.r == true or options.remove == true) then
  local pathRoot = "aquaver.github.io"
  local pathPackages = "xaf-packages"

  if (options.l == true or options.list == true) then
  elseif (options.r == true or options.remove == true) then
  end

  os.exit()
end

if (options.a == true or options.add == true or options.i == true or options.info == true) then
      local pathRoot = "aquaver.github.io"
      local pathProject = "xaf-framework"
      local pathPackages = "xaf-packages"
      local pathData = "data"
      local pathName = "pm-source.info"

      local sourceAddress = ''
      local sourcePath = filesystem.concat(pathRoot, pathProject, pathData, pathName)
      local sourceData = {}
      local sourceTotalSize = 0

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
        print("  >> Trying to connect to target repository...")
      end

      if (options.a == true or options.add == true) then
      elseif (options.i == true or options.info == true) then
      end

  os.exit()
end

print("--------------------------------------")
print("-- XAF Package Manager - Controller --")
print("--------------------------------------")
print("  >> Add-on package management program")
print("  >> Use 'xaf-pm package [-h | --help]' for command manual")
