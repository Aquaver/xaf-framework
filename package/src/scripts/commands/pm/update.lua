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
  print("----------------------------------")
  print("-- XAF Package Manager - Manual --")
  print("----------------------------------")
  print("  >> NAME")
  print("    >> xaf-pm update - Package updating program")
  print()
  print("  >> SYNOPSIS")
  print("    >> xaf-pm update")
  print("    >> xaf-pm update [-h | --help]")
  print("    >> xaf-pm update [-p | --package] <identifier>")
  print()
  print("  >> DESCRIPTION")
  print("    >> This script is designed to perform automatic download an update from original package source repository and installing it.")
end

if (options.p == true or options.package == true) then
  local pathRoot = "io.github.aquaver"
  local pathProject = "xaf-framework"
  local pathPackages = "xaf-packages"
  local pathData = "data"
  local pathName = "pm-update.info"

  local packageName = arguments[1]
  local packageString = tostring(arguments[1])
  local packageDataTable = nil
  local packageData = ''
  local packagePath = ''

  local sourceTotalSize = 0
  local sourceIndex = 0
  local sourceCategory = ''
  local sourceRepository = ''
  local sourceString = ''

  if (packageName == nil or packageString == '') then
    print("--------------------------------------")
    print("-- XAF Package Manager - Controller --")
    print("--------------------------------------")
    print("  >> Invalid package name for updating")
    print("  >> Use 'xaf-pm update [-p | --package]' again with proper package name")

    os.exit()
  else
    packageData = filesystem.concat(pathRoot, pathProject, pathData, pathName)
    packagePath = filesystem.concat(pathRoot, pathPackages, packageString)
  end

  if (filesystem.exists(packageData) == false) then
    print("--------------------------------------")
    print("-- XAF Package Manager - Controller --")
    print("--------------------------------------")
    print("  >> Cannot continue updating procedure")
    print("  >> Unable to find package source list file")
    print("  >> Missing file name: " .. pathName)

    os.exit()
  else
    packageDataTable = xafcoreTable:loadFromFile(packageData)
  end

  if (filesystem.exists(packagePath) == false) then
    print("--------------------------------------")
    print("-- XAF Package Manager - Controller --")
    print("--------------------------------------")
    print("  >> Package with entered name does not exist")
    print("  >> Use 'xaf-pm update [-p | --package]' again with proper name")

    os.exit()
  else
    if (packageDataTable[packageString] == nil) then
      print("--------------------------------------")
      print("-- XAF Package Manager - Controller --")
      print("--------------------------------------")
      print("  >> Unable to find package identifier in update data file")
      print("  >> Despite this it exists in XAF PM packages directory")
      print("  >> Try removing this package and installing it again")

      os.exit()
    else
      sourceString = packageDataTable[packageString]
      sourceIndex = string.find(sourceString, ":")
      sourceCategory = string.sub(sourceString, sourceIndex + 1, -1)
      sourceRepository = string.sub(sourceString, 1, sourceIndex - 1)
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

    local targetAddress = "https://api.github.com/repos/"
    local targetSuffix = "/git/trees/master"
    local targetFlag = "?recursive=1"
    local targetFound = false

    print("    >> Searching for package '" .. packageString .. "' in category: " .. sourceCategory)
    print("    >> Package source repository: " .. sourceRepository)

    local inetAddress = targetAddress .. sourceRepository .. targetSuffix .. targetFlag
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
        if (jsonTable["tree"][i]["path"] == sourceCategory .. '/' .. packageString) then
          print("      >> Package found")
          print("      >> Retrieving package data")

          targetFound = true
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

                  inetAddress = repositoryAddress .. sourceRepository .. repositoryBranch .. repositoryPath
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

                      inetAddress = dataAddress .. sourceRepository .. dataBranch .. sourceCategory .. '/' .. packageString .. dataPath
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
                              if (packageString == infoTable["package-identifier"]) then
                                if (configVersion > infoTable["package-xaf"]) then
                                  print("        >> Updating package '" .. packageString .. "' from source repository: " .. sourceRepository)
                                  print("        >> All prerequisites have been checked")
                                  print("        >> Starting update downloading procedure...")

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

                                    for j = 1, #jsonTable["tree"] do
                                      local objectPath = jsonTable["tree"][j]["path"]
                                      local objectType = jsonTable["tree"][j]["type"]
                                      local pathRoot = "io.github.aquaver"
                                      local pathProject = "xaf-packages"

                                      if (objectType == "tree") then
                                        filesystem.makeDirectory(filesystem.concat(pathRoot, pathProject, packageName .. "_update", objectPath))
                                      elseif (objectType == "blob") then
                                        local filePath = filesystem.concat(pathRoot, pathProject, packageName .. "_update", objectPath)
                                        local fileObject = nil
                                        local fileSize = -1

                                        inetAddress = dataAddress .. sourceRepository .. dataBranch .. sourceCategory .. '/' .. packageString .. '/' .. objectPath
                                        inetConnection = httpstream:new(inetComponent, inetAddress)

                                        inetConnection:setMaxTimeout(0.5)
                                        print("          >> Trying to download: " .. packageString .. '/' .. objectPath)

                                        if (inetConnection:connect() == true) then
                                          fileObject = filesystem.open(filePath, 'w')
                                          fileSize = 0

                                          for dataChunk in inetConnection:getData() do
                                            fileObject:write(dataChunk)
                                            fileSize = fileSize + unicode.wlen(dataChunk)
                                          end

                                          sourceTotalSize = sourceTotalSize + fileSize
                                          fileObject:close()
                                          print("            >> Downloaded file: " .. packageString .. '/' .. objectPath .. " (" .. string.format("%.2f", fileSize / 1024) .. " kB)")
                                        else
                                          print("            >> Cannot download '" .. packageString .. '/' .. objectPath .. "' file")
                                        end
                                      end
                                    end

                                    print("              >> Successfully downloaded updated version of package '" .. packageString .. "' from repository: " .. sourceRepository)
                                    print("              >> Downloaded package total size: " .. string.format("%.2f", sourceTotalSize / 1024) .. " kB")
                                    print("              >> Are you sure to install this update?")
                                    print("              >> Hit 'Y' to confirm, or 'N' to abort and remove it")
                                    print("              >> Warning! It will delete entire current version of package with all its data")

                                    while (true) do
                                      local option = {event.pull("key_down")}

                                      if (option[3] == 89) then
                                        local oldPath = filesystem.concat(pathRoot, pathPackages, packageName)
                                        local newPath = filesystem.concat(pathRoot, pathPackages, packageName .. "_update")

                                        filesystem.remove(oldPath)
                                        filesystem.rename(newPath, oldPath)

                                        print("                >> Current version of package has been deleted")
                                        print("                >> Successfully installed package update")
                                        print("                >> Reboot this machine and initialize XAF to complete updating procedure")
                                        print("                >> Updating finished")
                                        break
                                      elseif (option[3] == 78) then
                                        local newPath = filesystem.concat(pathRoot, pathPackages, packageName .. "_update")
                                        filesystem.remove(newPath)

                                        print("                >> Updating procedure has been interrupted manually")
                                        print("                >> Downloaded updated version of package has been deleted")
                                        print("                >> Current package version remain unaffected")
                                        break
                                      end
                                    end

                                    os.exit()
                                  else
                                    print("          >> Cannot connect to package installation content tree")
                                    print("          >> Ensure you have not lost internet access")
                                    print("          >> Update downloading procedure has been interrupted")

                                    os.exit()
                                  end
                                else
                                  print("        >> This package update requires newer XAF version (" .. infoTable["package-xaf"] .. ')')
                                  print("        >> Detected local API version: " .. configVersion)
                                  print("        >> Please update XAF via 'xaf update' before package updating")
                                  print("        >> Updating procedure has been interrupted")

                                  os.exit()
                                end
                              else
                                print("        >> Package identifier mismatch detected")
                                print("        >> Identifier from configuration file and package directory (entered name) must be equal")
                                print("        >> This package cannot be updated")

                                os.exit()
                              end
                        else
                          print("        >> Invalid package description file detected")
                          print("        >> If this message appears again, contact the package owner")
                          print("        >> Updating procedure has been interrupted")

                          os.exit()
                        end
                      else
                        print("        >> Cannot retrieve package description file")
                        print("        >> Ensure you have not lost internet access")
                        print("        >> Updating procedure has been interrupted")

                        os.exit()
                      end
                    else
                      print("        >> Repository '" .. sourceRepository .. "' forces requirement to have newer XAF version")
                      print("        >> Detected local API version: " .. configVersion .. " (required by this repository is: " .. repositoryInfoTable["repository-xaf"] .. ')')
                      print("        >> Please update XAF via 'xaf update' before updating this package")
                      print("        >> Updating procedure has been interrupted")

                      os.exit()
                    end
                  else
                    print("        >> Cannot retrieve repository description file")
                    print("        >> Ensure you have not lost internet access")
                    print("        >> Updating procedure has been interrupted")

                    os.exit()
                  end
            else
              print("        >> Invalid XAF PM package structure")
              print("        >> Encountered unexpected files in package master directory")
              print("        >> This package cannot be updated")

              os.exit()
            end
          else
            print("        >> Cannot connect to package content tree")
            print("        >> Ensure you have not lost internet access")
            print("        >> Updating procedure has been interrupted")

            os.exit()
          end
        end
      end

      if (targetFound == false) then
        print("      >> Cannot find package '" .. packageString .. "' on repository: " .. sourceRepository)
        print("      >> This package might be removed")
        print("      >> If this package physically exists, try reinstalling it manually")
      end
    else
      print("      >> Cannot connect to '" .. sourceRepository .. "' repository")
      print("      >> Ensure you have not lost internet access")
      print("      >> Updating procedure has been interrupted")
    end
  end

  os.exit()
end

print("--------------------------------------")
print("-- XAF Package Manager - Controller --")
print("--------------------------------------")
print("  >> Package updating program")
print("  >> Use 'xaf-pm update [-h | --help]' for command manual")
