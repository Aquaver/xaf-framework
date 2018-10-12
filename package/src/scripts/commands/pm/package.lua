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
  print("----------------------------------")
  print("-- XAF Package Manager - Manual --")
  print("----------------------------------")
  print("  >> NAME")
  print("    >> xaf-pm package - Add-on packages management program")
  print()
  print("  >> SYNOPSIS")
  print("    >> xaf-pm package")
  print("    >> xaf-pm package [-a | --add] <identifier>")
  print("    >> xaf-pm package [-h | --help]")
  print("    >> xaf-pm package [-i | --info] <identifier>")
  print("    >> xaf-pm package [-l | --list] [page]")
  print("    >> xaf-pm package [-r | --remove] <identifier>")
  print()
  print("  >> DESCRIPTION")
  print("    >> This script allows the user XAF PM add-on packages management, like installation, uninstallation and retrieving information about specific package.")

  os.exit()
end

if (options.l == true or options.list == true or options.r == true or options.remove == true) then
  local pathRoot = "aquaver.github.io"
  local pathPackages = "xaf-packages"

  if (options.l == true or options.list == true) then
    local listIndexRaw = arguments[1]
    local listIndex = 0
    local listIteration = 0 -- Default iteration indices, on 'nil' entered list page index.
    local listIterationMin = 1
    local listIterationMax = 10
    local listPath = filesystem.concat(pathRoot, pathPackages)
    local packageCount = 0
    local totalCount = 0

    if (listIndexRaw == nil) then
      listIndex = 1
    elseif (tonumber(listIndexRaw) == nil) then
      print("--------------------------------------")
      print("-- XAF Package Manager - Controller --")
      print("--------------------------------------")
      print("  >> Invalid package list index value")
      print("  >> This value must be natural number (or empty as 1)")
      print("  >> Use 'xaf-pm package [-l | --list]' again with proper index")

      os.exit()
    else
      if (xafcoreMath:checkNatural(tonumber(listIndexRaw), true) == false) then
        print("--------------------------------------")
        print("-- XAF Package Manager - Controller --")
        print("--------------------------------------")
        print("  >> Invalid package list index value")
        print("  >> This value must be natural number (or empty as 1)")
        print("  >> Use 'xaf-pm package [-l | --list]' again with proper index")

        os.exit()
      else
        listIndex = tonumber(listIndexRaw)
        listIterationMin = (listIndex - 1) * 10 + 1
        listIterationMax = (listIndex - 1) * 10 + 10
      end
    end

    if (filesystem.exists(listPath) == false) then
      print("--------------------------------------")
      print("-- XAF Package Manager - Controller --")
      print("--------------------------------------")
      print("  >> Cannot list XAF PM packages")
      print("  >> Unable to find master PM directory")
      print("  >> Missing directory name: " .. pathPackages)
    else
      print("--------------------------------------")
      print("-- XAF Package Manager - Controller --")
      print("--------------------------------------")
      print("  >> Master PM directory found")
      print("  >> Listing installed PM add-on packages...")

      for item in filesystem.list(listPath) do
        listIteration = listIteration + 1

        if (string.sub(item, -1, -1) == '/') then
          item = string.sub(item, 1, -2)
        end

        if (listIteration >= listIterationMin and listIteration <= listIterationMax) then
          if (filesystem.exists(filesystem.concat(listPath, item, "_config", "package.info")) == true) then
            print("    >> [" .. listIteration .. "] " .. item .. " (valid PM package)")
            packageCount = packageCount + 1
            totalCount = totalCount + 1
          else
            print("    >> [" .. listIteration .. "] " .. item .. " (unknown item - missing configuration file)")
            totalCount = totalCount + 1
          end
        end

        if (listIteration == listIterationMax + 1) then
          print("  >> More packages on 'xaf-pm package [-l | --list] " .. listIndex + 1 .. "'")
          break
        end
      end

      print("  >> Valid XAF PM packages found: " .. packageCount)
      print("  >> Total (also unknown) objects found: " .. totalCount)
    end
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
