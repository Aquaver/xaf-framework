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
        local indexLength = #sourceData
        local indexRaw = arguments[1]
        local index = 0
        local priorityRaw = arguments[2]
        local priority = 0

        if (tonumber(indexRaw) == nil) then
          print("--------------------------------------")
          print("-- XAF Package Manager - Controller --")
          print("--------------------------------------")
          print("  >> Invalid repository index value")
          print("  >> This value must be natural number (up to: " .. indexLength .. ')')
          print("  >> Use 'xaf-pm repository [-p | --priority]' again with proper index")

          os.exit()
        else
          if (xafcoreMath:checkNatural(tonumber(indexRaw), true) == false or tonumber(indexRaw) > indexLength) then
            print("--------------------------------------")
            print("-- XAF Package Manager - Controller --")
            print("--------------------------------------")
            print("  >> Invalid repository index value")
            print("  >> This value must be natural number (up to: " .. indexLength .. ')')
            print("  >> Use 'xaf-pm repository [-p | --priority]' again with proper index")

            os.exit()
          else
            index = tonumber(indexRaw)
          end
        end

        if (tonumber(priorityRaw) == nil) then
          print("--------------------------------------")
          print("-- XAF Package Manager - Controller --")
          print("--------------------------------------")
          print("  >> Invalid repository new priority value")
          print("  >> This value must be natural number (up to: " .. indexLength .. ')')
          print("  >> Use 'xaf-pm repository [-p | --priority]' again with proper priority value")

          os.exit()
        else
          if (xafcoreMath:checkNatural(tonumber(priorityRaw), true) == false or tonumber(indexRaw) > indexLength) then
            print("--------------------------------------")
            print("-- XAF Package Manager - Controller --")
            print("--------------------------------------")
            print("  >> Invalid repository new priority value")
            print("  >> This value must be natural number (up to: " .. indexLength .. ')')
            print("  >> Use 'xaf-pm repository [-p | --priority]' again with proper priority value")

            os.exit()
          else
            priority = tonumber(priorityRaw)
          end
        end

        local listFile = filesystem.open(sourcePath, 'w')
        local removedEntry = table.remove(sourceData, index)

        listFile:write("[#] Extensible Application Framework Package Manager source repository list." .. '\n')
        listFile:write("[#] This file is used to store user added custom XAF add-on package repositories." .. '\n')
        listFile:write("[#] Data represented in XAF Table Format." .. '\n' .. '\n')
        listFile:close()

        table.insert(sourceData, priority, removedEntry)
        xafcoreTable:saveToFile(sourceData, sourcePath, true)

        print("--------------------------------------")
        print("-- XAF Package Manager - Controller --")
        print("--------------------------------------")
        print("  >> Successfully changed priority of repository: " .. removedEntry)
        print("  >> It is available now under index '" .. priority .. "' instead of '" .. index .. "'")
      elseif (options.r == true or options.remove == true) then
        local indexLength = #sourceData
        local indexRaw = arguments[1]
        local index = 0

        if (tonumber(indexRaw) == nil) then
          print("--------------------------------------")
          print("-- XAF Package Manager - Controller --")
          print("--------------------------------------")
          print("  >> Invalid repository removal index value")
          print("  >> This value must be natural number (up to: " .. indexLength .. ')')
          print("  >> Use 'xaf-pm repository [-r | --remove]' again with proper index")

          os.exit()
        else
          if (xafcoreMath:checkNatural(tonumber(indexRaw), true) == false or tonumber(indexRaw) > indexLength) then
            print("--------------------------------------")
            print("-- XAF Package Manager - Controller --")
            print("--------------------------------------")
            print("  >> Invalid repository removal index value")
            print("  >> This value must be natural number (up to: " .. indexLength .. ')')
            print("  >> Use 'xaf-pm repository [-r | --remove]' again with proper index")

            os.exit()
          else
            index = tonumber(indexRaw)
          end

          local listFile = filesystem.open(sourcePath, 'w')
          local removedEntry = table.remove(sourceData, index)

          listFile:write("[#] Extensible Application Framework Package Manager source repository list." .. '\n')
          listFile:write("[#] This file is used to store user added custom XAF add-on package repositories." .. '\n')
          listFile:write("[#] Data represented in XAF Table Format." .. '\n' .. '\n')
          listFile:close()

          xafcoreTable:saveToFile(sourceData, sourcePath, true)

          print("--------------------------------------")
          print("-- XAF Package Manager - Controller --")
          print("--------------------------------------")
          print("  >> Successfully removed following repository: " .. removedEntry)
          print("  >> Package Manager will no longer install add-ons from it")
        end
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
    if (targetRepository == nil) then
      print("    >> Invalid target repository identifier, must not be empty")
      print("    >> Required format: userName/repositoryName")

      os.exit()
    end

    local inetAddress = targetAddress .. targetRepository .. targetPath
    local inetComponent = component.getPrimary("internet")
    local inetConnection = httpstream:new(inetComponent, inetAddress)
    local inetResponse = 0

    if (inetConnection:connect() == true) then
      local infoData = ''

      for dataChunk in inetConnection:getData() do
        infoData = infoData .. dataChunk
      end

      inetResponse = inetConnection:getResponseCode()
      inetConnection:disconnect()
      inetComponent = nil

      if (inetResponse == 404) then
        print("    >> Target repository does not exist on GitHub service")
        print("    >> Ensure you entered valid repository identifier")
        print("    >> Required format: userName/repositoryName")

        os.exit()
      else
        local infoPath = "/aquaver.github.io/xaf-framework/repository.info"
        local infoFile = filesystem.open(infoPath, 'w')
        local infoTable = nil

        infoFile:write(infoData)
        infoFile:close()
        infoTable = xafcoreTable:loadFromFile(infoPath)
        filesystem.remove(infoPath)

        if (infoTable["repository-description"] and infoTable["repository-owner"] and infoTable["repository-title"] and infoTable["repository-xaf"]) then
          local pathRoot = "aquaver.github.io"
          local pathProject = "xaf-framework"
          local pathData = "data"
          local pathName = "pm-source.info"

          local sourcePath = filesystem.concat(pathRoot, pathProject, pathData, pathName)
          local sourceData = {}
          local sourceLength = 0

          if (filesystem.exists(sourcePath) == true) then
            sourceData = xafcoreTable:loadFromFile(sourcePath)
            sourceLength = #sourceData
          else
            print("    >> Cannot find the source repositories list file")
            print("    >> Reinstall XAF package or download this file manually")
            print("    >> Missing file name: " .. pathName)

            os.exit()
          end

          if (targetPriority == nil) then
            targetPriority = 1
            table.insert(sourceData, 1, targetRepository)
          elseif (tonumber(targetPriority) == nil) then
            print("    >> Invalid new repository priority value")
            print("    >> This value must be natural number (up to: " .. sourceLength + 1 .. ')')
            print("    >> Use 'xaf-pm repository [-a | --add]' again with proper priority value")

            os.exit()
          else
            if (xafcoreMath:checkNatural(tonumber(targetPriority), true) == false or tonumber(targetPriority) > sourceLength + 1) then
              print("    >> Invalid new repository priority value")
              print("    >> This value must be natural number (up to: " .. sourceLength + 1 .. ')')
              print("    >> Use 'xaf-pm repository [-a | --add]' again with proper priority value")

              os.exit()
            else
              table.insert(sourceData, tonumber(targetPriority), targetRepository)
            end
          end

          local listFile = filesystem.open(sourcePath, 'w')
          local addedRepository = targetRepository

          listFile:write("[#] Extensible Application Framework Package Manager source repository list." .. '\n')
          listFile:write("[#] This file is used to store user added custom XAF add-on package repositories." .. '\n')
          listFile:write("[#] Data represented in XAF Table Format." .. '\n' .. '\n')
          listFile:close()

          xafcoreTable:saveToFile(sourceData, sourcePath, true)

          print("    >> Successfully added following repository: " .. addedRepository)
          print("    >> Package Manager will install programs from it with '" .. targetPriority .. "' priority")
        else
          print("    >> Invalid repository description file detected")
          print("    >> Try running 'xaf-pm repository [-a | --add]' again")
          print("    >> If this message appears again, contact the repository owner")

          os.exit()
        end
      end
    else
      print("    >> Cannot connect to target repository")
      print("    >> Try running 'xaf-pm repository [-a | --add]' again")

      os.exit()
    end
  elseif (options.i == true or options.info == true) then
    if (targetRepository == nil) then
      print("    >> Invalid target repository identifier, must not be empty")
      print("    >> Required format: userName/repositoryName")

      os.exit()
    end

    local inetAddress = targetAddress .. targetRepository .. targetPath
    local inetComponent = component.getPrimary("internet")
    local inetConnection = httpstream:new(inetComponent, inetAddress)
    local inetResponse = 0

    if (inetConnection:connect() == true) then
      local infoData = ''

      for dataChunk in inetConnection:getData() do
        infoData = infoData .. dataChunk
      end

      inetResponse = inetConnection:getResponseCode()
      inetConnection:disconnect()
      inetComponent = nil

      if (inetResponse == 404) then
        print("    >> Target repository does not exist on GitHub service")
        print("    >> Ensure you entered valid repository identifier")
        print("    >> Required format: userName/repositoryName")

        os.exit()
      else
        local infoPath = "/aquaver.github.io/xaf-framework/repository.info"
        local infoFile = filesystem.open(infoPath, 'w')
        local infoTable = nil

        infoFile:write(infoData)
        infoFile:close()
        infoTable = xafcoreTable:loadFromFile(infoPath)
        filesystem.remove(infoPath)

        if (infoTable["repository-description"] and infoTable["repository-owner"] and infoTable["repository-title"] and infoTable["repository-xaf"]) then
          print("  >> Successfully connected to target repository:")
          print("    >> Repository title: " .. infoTable["repository-title"])
          print("    >> Repository owner: " .. infoTable["repository-owner"])
          print("    >> Repository required XAF version: " .. infoTable["repository-xaf"])

          print(string.rep('-', gpuWidth))
          print(infoTable["repository-description"])
        else
          print("    >> Invalid repository description file detected")
          print("    >> Try running 'xaf-pm repository [-i | --info]' again")
          print("    >> If this message appears again, contact the repository owner")
        end
      end
    else
      print("    >> Cannot connect to target repository")
      print("    >> Try running 'xaf-pm repository [-i | --info]' again")

      os.exit()
    end
  end

  os.exit()
end

print("--------------------------------------")
print("-- XAF Package Manager - Controller --")
print("--------------------------------------")
print("  >> Source repository management program")
print("  >> Use 'xaf-pm repository [-h | --help]' for command manual")
