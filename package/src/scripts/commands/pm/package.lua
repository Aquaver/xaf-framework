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
  print("    >> xaf-pm package [-a | --add] <identifier> [-r | --readme]")
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
  local pathRoot = "io.github.aquaver"
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
    local packageName = arguments[1]
    local packagePath = ''

    if (packageName == nil) then
      print("--------------------------------------")
      print("-- XAF Package Manager - Controller --")
      print("--------------------------------------")
      print("  >> Invalid package name for removal")
      print("  >> Use 'xaf-pm package [-r | --remove]' again with proper package name")

      os.exit()
    else
      packagePath = filesystem.concat(pathRoot, pathPackages, tostring(packageName))
    end

    if (filesystem.exists(packagePath) == false) then
      print("--------------------------------------")
      print("-- XAF Package Manager - Controller --")
      print("--------------------------------------")
      print("  >> Package with entered name does not exist")
      print("  >> Use 'xaf-pm package [-r | --remove]' again with proper package name")

      os.exit()
    end

    filesystem.remove(packagePath)

    print("--------------------------------------")
    print("-- XAF Package Manager - Controller --")
    print("--------------------------------------")
    print("  >> Successfully removed following XAF PM package: " .. packageName)
    print("  >> This program could no longer be started via PM controller")
    print("  >> Another package with that name can be installed now")
  end

  os.exit()
end

if (options.a == true or options.add == true or options.i == true or options.info == true) then
  local pathRoot = "io.github.aquaver"
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
    local infoName = "pm-update.info"
    local infoPath = filesystem.concat(pathRoot, pathProject, pathData, infoName)
    local infoDataTable = nil
    local packageIdentifier = arguments[1]
    local packageNameIndex = string.find(tostring(packageIdentifier), '/')
    local packageCategory = (packageNameIndex) and string.sub(tostring(packageIdentifier), 1, packageNameIndex - 1)
    local packageName = (packageNameIndex) and string.sub(tostring(packageIdentifier), packageNameIndex + 1, -1) or ''
    local selectedRepository = nil

    if (packageIdentifier == nil or packageNameIndex == nil) then
      print("    >> Invalid package identifier, must not be empty")
      print("    >> Required format: categoryName/packageName")

      os.exit()
    else
      print("    >> Searching for following package: " .. packageIdentifier)
    end

    if (filesystem.exists(filesystem.concat(pathRoot, pathPackages, packageName)) == true) then
      print("    >> Package with name '" .. packageName .. "' is already installed")
      print("    >> Remove it first with 'xaf-pm remove' before installing this one")
      print("    >> Installation procedure has been interrupted")

      os.exit()
    end

    if (filesystem.exists(infoPath) == true) then
      infoDataTable = xafcoreTable:loadFromFile(infoPath)
    else
      print("--------------------------------------")
      print("-- XAF Package Manager - Controller --")
      print("--------------------------------------")
      print("  >> Cannot find the package source list file")
      print("  >> Reinstall XAF package or download this file manually")
      print("  >> Missing file name: " .. infoName)

      os.exit()
    end

    for repositoryIndex, repositoryIdentifier in xafcoreTable:sortByKey(sourceData, false) do
      local targetAddress = "https://api.github.com/repos/"
      local targetSuffix = "/git/trees/master"
      local targetFlag = "?recursive=1"
      local targetFound = false

      print("    >> Checking repository: " .. repositoryIdentifier)

      local inetAddress = targetAddress .. repositoryIdentifier .. targetSuffix .. targetFlag
      local inetComponent = component.getPrimary("internet")

      local inetConnection = httpstream:new(inetComponent, inetAddress)
      inetConnection:setMaxTimeout(0.5)

      if (inetConnection:connect() == true) then
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
          if (jsonTable["tree"][i]["path"] == packageIdentifier) then
            targetFound = true

            print("      >> Package '" .. packageIdentifier .. "' found on repository: " .. repositoryIdentifier)
            print("      >> Would you like to install it from this source?")
            print("      >> Hit 'Y' to confirm, or 'N' to skip this repository")

            while (true) do
              local option = {event.pull("key_down")}

              if (option[3] == 89) then
                print("        >> Installation confirmed, continuing...")

                selectedRepository = repositoryIdentifier
                sourceAddress = jsonTable["tree"][i]["url"]
                inetAddress = jsonTable["tree"][i]["url"]

                inetConnection = httpstream:new(inetComponent, inetAddress)
                inetConnection:setMaxTimeout(0.5)

                if (inetConnection:connect() == true) then
                  jsonData = ''
                  jsonTable = {}

                  for dataChunk in inetConnection:getData() do
                    jsonData = jsonData .. dataChunk
                  end

                  inetConnection:disconnect()
                  jsonTable = jsonObject:parse(jsonData)

                  if (#jsonTable["tree"] == 2 and jsonTable["tree"][1]["path"] == "_bin" and jsonTable["tree"][2]["path"] == "_config") or
                     (#jsonTable["tree"] == 3 and jsonTable["tree"][1]["path"] == "README.md" and jsonTable["tree"][2]["path"] == "_bin" and jsonTable["tree"][3]["path"] == "_config") then
                        local repositoryAddress = "https://raw.githubusercontent.com/"
                        local repositoryPath = "_config/repository.info"
                        local repositoryBranch = "/master/"

                        inetAddress = repositoryAddress .. repositoryIdentifier .. repositoryBranch .. repositoryPath
                        inetConnection = httpstream:new(inetComponent, inetAddress)
                        inetConnection:setMaxTimeout(0.5)

                        if (inetConnection:connect() == true) then
                          local repositoryInfoData = ''
                          local repositoryInfoTable = {}

                          for dataChunk in inetConnection:getData() do
                            repositoryInfoData = repositoryInfoData .. dataChunk
                          end

                          repositoryInfoTable = xafcoreTable:loadFromString(repositoryInfoData)
                          repositoryInfoData = ''

                          if (configVersion > repositoryInfoTable["repository-xaf"]) then
                            local dataAddress = "https://raw.githubusercontent.com/"
                            local dataPath = "/_config/package.info"
                            local dataBranch = "/master/"

                            inetAddress = dataAddress .. repositoryIdentifier .. dataBranch .. packageIdentifier .. dataPath
                            inetConnection = httpstream:new(inetComponent, inetAddress)
                            inetConnection:setMaxTimeout(0.5)

                            if (inetConnection:connect() == true) then
                              local infoData = ''
                              local infoTable = {}

                              for dataChunk in inetConnection:getData() do
                                infoData = infoData .. dataChunk
                              end

                              infoTable = xafcoreTable:loadFromString(infoData)
                              infoData = ''

                              if (infoTable["package-description"] and infoTable["package-identifier"] and infoTable["package-index"] and
                                  infoTable["package-owner"] and infoTable["package-title"] and infoTable["package-version"] and infoTable["package-xaf"]) then
                                    if (packageName == infoTable["package-identifier"]) then
                                      if (configVersion > infoTable["package-xaf"]) then
                                        print("        >> Installing package '" .. packageIdentifier .. "' from repository: " .. repositoryIdentifier)
                                        print("        >> All prerequisites have been checked")
                                        print("        >> Starting installation procedure...")

                                        inetAddress = sourceAddress .. targetFlag
                                        inetConnection = httpstream:new(inetComponent, inetAddress)
                                        inetConnection:setMaxTimeout(0.5)

                                        if (inetConnection:connect() == true) then
                                          jsonData = ''
                                          jsonTable = {}

                                          for dataChunk in inetConnection:getData() do
                                            jsonData = jsonData .. dataChunk
                                          end

                                          inetConnection:disconnect()
                                          jsonTable = jsonObject:parse(jsonData)
                                          filesystem.makeDirectory(filesystem.concat(pathRoot, pathPackages, packageName)) -- Create package master directory before downloading binaries

                                          for j = 1, #jsonTable["tree"] do
                                            local objectPath = jsonTable["tree"][j]["path"]
                                            local objectType = jsonTable["tree"][j]["type"]
                                            local pathRoot = "io.github.aquaver"
                                            local pathProject = "xaf-packages"

                                            if (objectPath ~= "README.md" or (objectPath == "README.md" and (options.r == true or options.readme == true))) then -- The user is able to include 'README.md' in downloaded package.
                                              if (objectType == "tree") then
                                                filesystem.makeDirectory(filesystem.concat(pathRoot, pathProject, packageName, objectPath))
                                              elseif (objectType == "blob") then
                                                local filePath = filesystem.concat(pathRoot, pathProject, packageName, objectPath)
                                                local fileObject = nil
                                                local fileSize = -1

                                                inetAddress = dataAddress .. repositoryIdentifier .. dataBranch .. packageIdentifier .. '/' .. objectPath
                                                inetConnection = httpstream:new(inetComponent, inetAddress)

                                                inetConnection:setMaxTimeout(0.5)
                                                print("          >> Trying to download: " .. packageName .. '/' .. objectPath)

                                                if (inetConnection:connect() == true) then
                                                  fileObject = filesystem.open(filePath, 'w')
                                                  fileSize = 0

                                                  for dataChunk in inetConnection:getData() do
                                                    fileObject:write(dataChunk)
                                                    fileSize = fileSize + unicode.wlen(dataChunk)
                                                  end

                                                  sourceTotalSize = sourceTotalSize + fileSize
                                                  fileObject:close()
                                                  print("            >> Downloaded file: " .. packageName .. '/' .. objectPath .. " (" .. string.format("%.2f", fileSize / 1024) .. " kB)")
                                                else
                                                  print("            >> Cannot download '" .. packageName .. '/' .. objectPath .. "' file")
                                                end
                                              end
                                            end
                                          end

                                          local infoFile = filesystem.open(infoPath, 'w')
                                          local infoKey = packageName
                                          local infoValue = selectedRepository .. ':' .. packageCategory

                                          infoFile:write("[#] Extensible Application Framework Package Manager application source." .. '\n')
                                          infoFile:write("[#] This file stores specific packages source identifiers which are used in updating." .. '\n')
                                          infoFile:write("[#] Data represented in XAF Table Format." .. '\n' .. '\n')
                                          infoFile:close()

                                          infoDataTable[infoKey] = infoValue
                                          xafcoreTable:saveToFile(infoDataTable, infoPath, true)

                                          print("              >> Successfully downloaded package '" .. packageIdentifier .. "' from repository: " .. repositoryIdentifier)
                                          print("              >> Downloaded package total size: " .. string.format("%.2f", sourceTotalSize / 1024) .. " kB")
                                          print("              >> Installation procedure has been finished")
                                          print("              >> You can now use 'xaf-pm run " .. packageName .. "' to start the program")

                                          os.exit()
                                        else
                                          print("          >> Cannot connect to package installation content tree")
                                          print("          >> Ensure you have not lost internet access")
                                          print("          >> Installation procedure has been interrupted")

                                          os.exit()
                                        end
                                      else
                                        print("        >> This package requires newer XAF version (" .. infoTable["package-xaf"] .. ')')
                                        print("        >> Detected local API version: " .. configVersion)
                                        print("        >> Please update XAF via 'xaf update' before package installation")
                                        print("        >> Installation procedure has been interrupted")

                                        os.exit()
                                      end
                                    else
                                      print("        >> Package identifier mismatch detected")
                                      print("        >> Identifier from configuration file and package directory name must be equal")
                                      print("        >> This package cannot be installed")

                                      os.exit()
                                    end
                              else
                                print("        >> Invalid package description file detected")
                                print("        >> If this message appears again, contact the package owner")
                                print("        >> Installation procedure has been interrupted")

                                os.exit()
                              end
                            else
                              print("        >> Cannot retrieve package description file")
                              print("        >> Ensure you have not lost internet access")
                              print("        >> Installation procedure has been interrupted")

                              os.exit()
                            end
                          else
                            print("        >> Repository '" .. repositoryIdentifier .. "' forces requirement to have newer XAF version")
                            print("        >> Detected local API version: " .. configVersion .. " (required by repository is: " .. repositoryInfoTable["repository-xaf"] .. ')')
                            print("        >> Please update XAF via 'xaf update' before installing from this repository")
                            print("        >> Installation procedure has been interrupted")

                            os.exit()
                          end
                        else
                          print("        >> Cannot retrieve repository description file")
                          print("        >> Ensure you have not lost internet access")
                          print("        >> Installation procedure has been interrupted")

                          os.exit()
                        end
                  else
                    print("        >> Invalid XAF PM package structure")
                    print("        >> Encountered unexpected files in package master directory")
                    print("        >> This package cannot be installed")

                    os.exit()
                  end
                else
                  print("        >> Cannot connect to package content tree...")
                  print("        >> Ensure you have not lost internet access")
                  print("        >> Installation procedure has been interrupted")

                  os.exit()
                end
              elseif (option[3] == 78) then
                print("        >> Skipped the following repository: " .. repositoryIdentifier)
                break
              end
            end
          end
        end
      else
        print("      >> Cannot connect to '" .. repositoryIdentifier .. "' repository")
        print("      >> Ensure you have not lost internet access")

        os.exit()
      end

      if (targetFound == false) then
        print("      >> Cannot find package '" .. packageIdentifier .. "' on repository: " .. repositoryIdentifier)
      end
    end
  elseif (options.i == true or options.info == true) then
    local packageIdentifier = arguments[1]
    local packageNameIndex = string.find(tostring(packageIdentifier), '/')
    local packageName = (packageNameIndex) and string.sub(tostring(packageIdentifier), packageNameIndex + 1, -1) or ''

    if (packageIdentifier == nil or packageNameIndex == nil) then
      print("    >> Invalid package identifier, must not be empty")
      print("    >> Required format: categoryName/packageName")

      os.exit()
    else
      print("    >> Searching for following package: " .. packageIdentifier)
    end

    for repositoryIndex, repositoryIdentifier in xafcoreTable:sortByKey(sourceData, false) do
      local targetAddress = "https://api.github.com/repos/"
      local targetSuffix = "/git/trees/master"
      local targetFlag = "?recursive=1"

      print("    >> Checking repository: " .. repositoryIdentifier)

      local inetAddress = targetAddress .. repositoryIdentifier .. targetSuffix .. targetFlag
      local inetComponent = component.getPrimary("internet")

      local inetConnection = httpstream:new(inetComponent, inetAddress)
      inetConnection:setMaxTimeout(0.5)

      if (inetConnection:connect() == true) then
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
          if (jsonTable["tree"][i]["path"] == packageIdentifier) then
            inetAddress = jsonTable["tree"][i]["url"]
            inetConnection = httpstream:new(inetComponent, inetAddress)
            inetConnection:setMaxTimeout(0.5)

            if (inetConnection:connect() == true) then
              jsonData = ''
              jsonTable = {}

              for dataChunk in inetConnection:getData() do
                jsonData = jsonData .. dataChunk
              end

              inetConnection:disconnect()
              jsonTable = jsonObject:parse(jsonData)

              if (#jsonTable["tree"] == 2 and jsonTable["tree"][1]["path"] == "_bin" and jsonTable["tree"][2]["path"] == "_config") or
                 (#jsonTable["tree"] == 3 and jsonTable["tree"][1]["path"] == "README.md" and jsonTable["tree"][2]["path"] == "_bin" and jsonTable["tree"][3]["path"] == "_config") then
                    local dataAddress = "https://raw.githubusercontent.com/"
                    local dataPath = "/_config/package.info"
                    local dataBranch = "/master/"

                    inetAddress = dataAddress .. repositoryIdentifier .. dataBranch .. packageIdentifier .. dataPath
                    inetConnection = httpstream:new(inetComponent, inetAddress)
                    inetConnection:setMaxTimeout(0.5)

                    if (inetConnection:connect() == true) then
                      local infoData = ''
                      local infoTable = {}

                      for dataChunk in inetConnection:getData() do
                        infoData = infoData .. dataChunk
                      end

                      infoTable = xafcoreTable:loadFromString(infoData)
                      infoData = ''

                      if (infoTable["package-description"] and infoTable["package-identifier"] and infoTable["package-index"] and
                          infoTable["package-owner"] and infoTable["package-title"] and infoTable["package-version"] and infoTable["package-xaf"]) then
                            if (packageName == infoTable["package-identifier"]) then
                              print("      >> Successfully found information data of package: " .. packageIdentifier)
                              print("      >> This package exists on repository: " .. repositoryIdentifier)
                              print("        >> Package title: " .. infoTable["package-title"])
                              print("        >> Package owner: " .. infoTable["package-owner"])
                              print("        >> Package version: " .. infoTable["package-version"])
                              print("        >> Package required XAF version: " .. infoTable["package-xaf"])

                              print(string.rep('-', gpuWidth))
                              print(infoTable["package-description"])

                              os.exit()
                            else
                              print("      >> Package identifier mismatch detected")
                              print("      >> Identifier from configuration file and package directory name must be equal")
                              print("      >> This package cannot be installed")

                              os.exit()
                            end
                      else
                        print("      >> Invalid package description file detected")
                        print("      >> If this message appears again, contact the package owner")

                        os.exit()
                      end
                    else
                      print("      >> Cannot retrieve package description file")
                      print("      >> Ensure you have not lost internet access")

                      os.exit()
                    end
              else
                print("      >> Invalid XAF PM package structure")
                print("      >> Encountered unexpected files in package master directory")
                print("      >> This package cannot be installed")

                os.exit()
              end
            else
              print("      >> Cannot connect to package content tree...")
              print("      >> Ensure you have not lost internet access")

              os.exit()
            end
          end
        end
      else
        print("      >> Cannot connect to '" .. repositoryIdentifier .. "' repository")
        print("      >> Ensure you have not lost internet access")

        os.exit()
      end

      print("      >> Cannot find package '" .. packageIdentifier .. "' on repository: " .. repositoryIdentifier)
    end
  end

  os.exit()
end

print("--------------------------------------")
print("-- XAF Package Manager - Controller --")
print("--------------------------------------")
print("  >> Add-on package management program")
print("  >> Use 'xaf-pm package [-h | --help]' for command manual")
