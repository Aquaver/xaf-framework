-- Extensible Application Framework Package Manager add-on update checking program.
-- This script is used for checking remote version of installed package and comparing their versions.
-- Every subcommand options is standalone and needs to use flag to run itself.

local arguments, options = ...
local component = require("component")
local event = require("event")
local filesystem = require("filesystem")
local httpstream = require("xaf/utility/httpstream")
local jsonparser = require("xaf/utility/jsonparser")
local xafcore = require("xaf/core/xafcore")
local xafcoreTable = xafcore:getTableInstance()

local configTable = _G._XAF
local configVersion = (configTable) and configTable._VERSION or ''

if (options.h == true or options.help == true) then
  print("----------------------------------")
  print("-- XAF Package Manager - Manual --")
  print("----------------------------------")
  print("  >> NAME")
  print("    >> xaf-pm check - Package update checking program")
  print()
  print("  >> SYNOPSIS")
  print("    >> xaf-pm check")
  print("    >> xaf-pm check [-h | --help]")
  print("    >> xaf-pm check [-p | --package] <identifier>")
  print()
  print("  >> DESCRIPTION")
  print("    >> This programs is used for checking remote version of installed package and returning information about update possibility.")

  os.exit()
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

  local sourceIndex = 0
  local sourceCategory = ''
  local sourceRepository = ''
  local sourceString = ''

  if (packageName == nil or packageString == '') then
    print("--------------------------------------")
    print("-- XAF Package Manager - Controller --")
    print("--------------------------------------")
    print("  >> Invalid package name to update check")
    print("  >> Use 'xaf-pm check [-p | --package]' again with proper package name")

    os.exit()
  else
    packageData = filesystem.concat(pathRoot, pathProject, pathData, pathName)
    packagePath = filesystem.concat(pathRoot, pathPackages, packageString)
  end

  if (filesystem.exists(packageData) == false) then
    print("--------------------------------------")
    print("-- XAF Package Manager - Controller --")
    print("--------------------------------------")
    print("  >> Cannot continue update checking procedure")
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
    print("  >> Use 'xaf-pm check [-p | --package]' again with proper name")

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
      sourceIndex = string.find(sourceString, ':')
      sourceCategory = string.sub(sourceString, sourceIndex + 1, -1)
      sourceRepository = string.sub(sourceString, 1, sourceIndex - 1)
    end
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
        print("      >> Retrieving description data")

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

          if (#jsonTable["tree"] == 2 and jsonTable["tree"][1]["path"] == "_bin" and jsonTable["tree"][2]["path"] == "_config") then
            local repositoryAddress = "https://raw.githubusercontent.com/"
            local repositoryPath = "_config/repository.info"
            local repositoryBranch = "/master/"

            inetAddress = repositoryAddress .. sourceRepository .. repositoryBranch .. repositoryPath
            inetConnection = httpstream:new(inetComponent,inetAddress)
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
                          local localConfigPath = filesystem.concat(packagePath, "_config", "package.info")
                          local localConfigData = xafcoreTable:loadFromFile(localConfigPath)
                          local versionLocal = localConfigData["package-version"]
                          local versionRemote = infoTable["package-version"]

                          if (versionRemote > versionLocal) then
                            print("        >> Successfully retrieved information about '" .. packageString)
                            print("        >> An update is available for this package")
                            print("        >> Remote version: " .. versionRemote .. " (local version: " .. versionLocal .. ')')
                            print("        >> You can now use 'xaf-pm update " .. packageString .. "' to update this package")
                            print("        >> Update checking procedure has been finished")
                          else
                            print("        >> Successfully retrieved information about: " .. packageString)
                            print("        >> No update is available, you have the latest version of this package (" .. versionLocal .. ')')
                            print("        >> Updated checking procedure has been finished")
                          end

                          os.exit()
                        else
                          print("        >> Package identifier mismatch detected")
                          print("        >> Identifier from configuration file and package directory (entered name) must be equal")
                          print("        >> This package cannot be updated")

                          os.exit()
                        end
                  else
                    print("        >> Invalid package description file detected")
                    print("        >> If this message appears again, contact the package owner")
                    print("        >> Update checking procedure has been interrupted")

                    os.exit()
                  end
                else
                  print("        >> Cannot retrieve package description file")
                  print("        >> Ensure you have not lost internet access")
                  print("        >> Update checking procedure has been interrupted")

                  os.exit()
                end
              else
                print("        >> Repository '" .. sourceRepository .. "' forces requirement to have newer XAF version")
                print("        >> Detected local API version: " .. configVersion .. " (required by this repository is: " .. repositoryInfoTable["repository-xaf"] .. ')')
                print("        >> Please update XAF via 'xaf update' before updating this package")
                print("        >> Update checking procedure has been interrupted")

                os.exit()
              end
            else
              print("        >> Cannot retrieve repository description file")
              print("        >> Ensure you have not lost internet access")
              print("        >> Update checking procedure has been interrupted")

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
          print("        >> Update checking procedure has been interrupted")

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
    print("      >> Update checking procedure has been interrupted")
  end

  os.exit()
end

print("--------------------------------------")
print("-- XAF Package Manager - Controller --")
print("--------------------------------------")
print("  >> Package update checking program")
print("  >> Use 'xaf-pm check [-h | --help]' for command manual")
