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
  print("----------------------------------")
  print("-- XAF Package Manager - Manual --")
  print("----------------------------------")
  print("  >> NAME")
  print("    >> xaf-pm category - Repository category viewer")
  print()
  print("  >> SYNOPSIS")
  print("    >> xaf-pm category")
  print("    >> xaf-pm category [-c | --content] <index> <name>")
  print("    >> xaf-pm category [-h | --help]")
  print("    >> xaf-pm category [-l | --list] <index>")
  print()
  print("  >> DESCRIPTION")
  print("    >> This command is mainly used to retrieve the XAF PM source repository category list, or get add-on list in specified category.")

  os.exit()
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
    local repositoryIndexRaw = arguments[1]
    local repositoryIndex = 0
    local categoryName = arguments[2]

    if (tonumber(repositoryIndexRaw) == nil and repositoryIndexRaw ~= "default") then
      print("    >> Invalid repository index value")
      print("    >> This value must be natural number (of 'default')")
      print("    >> Use 'xaf-pm category [-c | --content]' again with proper index")

      os.exit()
    else
      repositoryIndex = (tonumber(repositoryIndexRaw) == nil) and "default" or tonumber(repositoryIndexRaw)
    end

    if (type(categoryName) == "string") then
      if (string.find(categoryName, '/')) then
        print("    >> Invalid repository category name")
        print("    >> Enter valid category name without '/' characters")

        os.exit()
      end
    else
      print("    >> Invalid repository category name - must not be empty")
      print("    >> Enter valid category name without '/' characters")

      os.exit()
    end

    if (sourceData[repositoryIndex] == nil) then
      print("    >> Repository with index '" .. repositoryIndex .. "' is not registered")
      print("    >> Register mote repositories using 'xaf-pm repository [-a | --add]'")
    else
      print("    >> Found repository with index: " .. repositoryIndex)
      print("    >> Repository registered with this index: " .. sourceData[repositoryIndex])
      print("    >> Trying to retrieve category content list...")

      local targetAddress = "https://api.github.com/repos/"
      local targetSuffix = "/git/trees/master"
      local inetAddress = targetAddress .. sourceData[repositoryIndex] .. targetSuffix
      local inetComponent = component.getPrimary("internet")
      local inetConnection = httpstream:new(inetComponent, inetAddress)

      if (inetConnection:connect() == true) then
        local packageCount = 0
        local totalCount = 0
        local jsonData = ''
        local jsonObject = nil
        local jsonTable = {}

        for dataChunk in inetConnection:getData() do
          jsonData = jsonData .. dataChunk
        end

        inetConnection:disconnect()
        jsonObject = jsonparser:new()
        jsonTable = jsonObject:parse(jsonData)

        for i = 1, #jsonTable["tree"] do
          if (jsonTable["tree"][i]["path"] == categoryName) then
            inetAddress = jsonTable["tree"][i]["url"]
            inetConnection = httpstream:new(inetComponent, inetAddress)

            if (inetConnection:connect() == true) then
              jsonData = ''
              jsonTable = {}

              for dataChunk in inetConnection:getData() do
                jsonData = jsonData .. dataChunk
              end

              inetConnection:disconnect()
              jsonTable = jsonObject:parse(jsonData)

              for i = 1, #jsonTable["tree"] do
                local objectPath = jsonTable["tree"][i]["path"]
                local objectType = jsonTable["tree"][i]["type"]

                if (objectType == "tree") then
                  local configAddress = "https://raw.githubusercontent.com/"
                  local configBranch = "/master/"
                  local configPath = "/_config/package.info"

                  inetAddress = configAddress .. sourceData[repositoryIndex] .. configBranch .. categoryName .. '/' .. objectPath .. configPath
                  inetConnection = httpstream:new(inetComponent, inetAddress)

                  if (inetConnection:connect() == true) then
                    print("      >> Object found: " .. objectPath .. " (valid PM package)")
                    packageCount = packageCount + 1
                    totalCount = totalCount + 1
                    inetConnection:disconnect()
                  else
                    print("      >> Object found: " .. objectPath .. " (unknown item - missing configuration file)")
                    totalCount = totalCount + 1
                  end
                else
                  print("      >> Object found: " .. objectPath .. " (unknown object)")
                  totalCount = totalCount + 1
                end
              end

              print("    >> Valid XAF PM packages found: " .. packageCount)
              print("    >> Total (also unknown) objects found: " .. totalCount)
              os.exit()
            else
              print("      >> Cannot connect to category content package tree")
              print("      >> Ensure you have not lost internet access")
            end
          end
        end

        print("      >> Cannot find the following category: " .. categoryName)
        print("      >> Ensure you have choosen right repository")
        print("      >> Try running 'xaf-pm category [-c | --content]' again with another parameters")
      else
        print("      >> Cannot connect to target repository")
        print("      >> Ensure you have not lost internet access")
      end
    end
  elseif (options.l == true or options.list == true) then
    local repositoryIndexRaw = arguments[1]
    local repositoryIndex = 0

    if (tonumber(repositoryIndexRaw) == nil and repositoryIndexRaw ~= "default") then
      print("    >> Invalid repository index value")
      print("    >> This value must be natural number (or 'default')")
      print("    >> Use 'xaf-pm category [-l | --list]' again with proper index")

      os.exit()
    else
      repositoryIndex = (tonumber(repositoryIndexRaw) == nil) and "default" or tonumber(repositoryIndexRaw)
    end

    if (sourceData[repositoryIndex] == nil) then
      print("    >> Repository with index '" .. repositoryIndex .. "' is not registered")
      print("    >> Register more repositories using 'xaf-pm repository [-a | -add]'")
    else
      print("    >> Found repository with index: " .. repositoryIndex)
      print("    >> Repository registered with this index: " .. sourceData[repositoryIndex])
      print("    >> Trying to retrieve the category list...")

      local targetAddress = "https://api.github.com/repos/"
      local targetSuffix = "/git/trees/master"
      local inetAddress = targetAddress .. sourceData[repositoryIndex] .. targetSuffix
      local inetComponent = component.getPrimary("internet")
      local inetConnection = httpstream:new(inetComponent, inetAddress)

      if (inetConnection:connect() == true) then
        local categoryCount = 0
        local jsonData = ''
        local jsonObject = nil
        local jsonTable = {}

        for dataChunk in inetConnection:getData() do
          jsonData = jsonData .. dataChunk
        end

        inetConnection:disconnect()
        jsonObject = jsonparser:new()
        jsonTable = jsonObject:parse(jsonData)

        for i = 1, #jsonTable["tree"] do
          local objectPath = jsonTable["tree"][i]["path"]
          local objectType = jsonTable["tree"][i]["type"]

          if (objectPath ~= "_config" and objectType == "tree") then
            categoryCount = categoryCount + 1
            print("      >> Category found: " .. objectPath)
          end
        end

        print("    >> Total categories found: " .. categoryCount)
      else
        print("      >> Cannot connect to '" .. sourceData[repositoryIndex] .. "' repository")
        print("      >> Ensure you have not lost internet access")
      end
    end
  end

  os.exit()
end

print("--------------------------------------")
print("-- XAF Package Manager - Controller --")
print("--------------------------------------")
print("  >> Package source repository category viewer")
print("  >> Use 'xaf-pm category [-h | --help]' for command manual")
