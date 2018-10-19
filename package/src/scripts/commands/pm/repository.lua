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
  print("----------------------------------")
  print("-- XAF Package Manager - Manual --")
  print("----------------------------------")
  print("  >> NAME")
  print("    >> xaf-pm repository - Source repository management program")
  print()
  print("  >> SYNOPSIS")
  print("    >> xaf-pm repository")
  print("    >> xaf-pm repository [-a | --add] <identifier> [priority]")
  print("    >> xaf-pm repository [-h | --help]")
  print("    >> xaf-pm repository [-i | --info] <identifier>")
  print("    >> xaf-pm repository [-l | --list] [page]")
  print("    >> xaf-pm repository [-p | --priority] <index> <priority>")
  print("    >> xaf-pm repository [-r | --remove] <index>")
  print()
  print("  >> DESCRIPTION")
  print("    >> This script let the user manage XAF PM add-on package source repositories.")

  os.exit()
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
        local indexLength = #sourceData
        local indexRaw = arguments[1]
        local index = 0

        if (indexRaw == nil) then
          index = 1
        elseif (tonumber(indexRaw) == nil) then
          print("--------------------------------------")
          print("-- XAF Package Manager - Controller --")
          print("--------------------------------------")
          print("  >> Invalid repository list index value")
          print("  >> This value must be natural number (or empty as 1)")
          print("  >> Use 'xaf-pm repository [-l | --list]' again with proper index")

          os.exit()
        else
          if (xafcoreMath:checkNatural(tonumber(indexRaw), true) == false) then
            print("--------------------------------------")
            print("-- XAF Package Manager - Controller --")
            print("--------------------------------------")
            print("  >> Invalid repository list index value")
            print("  >> This value must be natural number (or empty as 1)")
            print("  >> Use 'xaf-pm repository [-l | --list]' again with proper index")

            os.exit()
          else
            index = tonumber(indexRaw)
          end
        end

        print("--------------------------------------")
        print("-- XAF Package Manager - Controller --")
        print("--------------------------------------")
        print("  >> Retrieving source repository list")

        if (sourceData["default"] == nil) then
          print("  >> Default repository not found")
        else
          print("  >> Default repository: " .. sourceData["default"])
        end

        for i = (index - 1) * 10 + 1, (index - 1) * 10 + 10 do
          if (sourceData[i]) then
            print("    >> [" .. i .. "] " .. sourceData[i])
          else
            break
          end
        end

        if (sourceData[(index - 1) * 10 + 11]) then
          print("  >> More repositories on 'xaf-pm repository [-l | --list] " .. index + 1 .. "'")
        end
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
