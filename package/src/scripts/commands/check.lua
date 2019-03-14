-- Extensible Application Framework checking for update script.
-- It connects to main project repository and downloads latest package data.
-- This program will notify the user if the new update is available.

local arguments, options = ...
local component = require("component")
local httpstream = require("xaf/utility/httpstream")
local xafcore = require("xaf/core/xafcore")
local xafcoreTable = xafcore:getTableInstance()

if (options.h == true or options.help == true) then
  print("-----------------------------------------------")
  print("-- Extensible Application Framework - Manual --")
  print("-----------------------------------------------")
  print("  >> NAME")
  print("    >> xaf check - Automated checking for update script")
  print()
  print("  >> SYNOPSIS")
  print("    >> xaf check")
  print("    >> xaf check [-h | --help]")
  print()
  print("  >> DESCRIPTION")
  print("    >> This program let the user check for package updates and notifies if it is available.")

  os.exit()
end

if (component.isAvailable("internet") == false) then
  print("---------------------------------------------------")
  print("-- Extensible Application Framework - Controller --")
  print("---------------------------------------------------")
  print("  >> Internet card component is not available")
  print("  >> Checking for update procedure cannot be continued")

  os.exit()
else
  print("---------------------------------------------------")
  print("-- Extensible Application Framework - Controller --")
  print("---------------------------------------------------")
  print("  >> Internet card component found")
  print("  >> Trying to connect to project repository...")
end

local sourceAddress = "https://raw.githubusercontent.com/Aquaver/xaf-framework/"
local sourceReleaseBranch = "master"
local sourcePackageInfo = "/package/package.info"
local sourceData = ''

local inetAddress = sourceAddress .. sourceReleaseBranch .. sourcePackageInfo
local inetComponent = component.getPrimary("internet")
local inetConnection = httpstream:new(inetComponent, inetAddress)

if (inetConnection.connect() == true) then
  for dataChunk in inetConnection:getData() do
    sourceData = sourceData .. dataChunk
  end

  inetConnection.disconnect()
else
  print("    >> Cannot connect to project repository")
  print("    >> Try running 'xaf check' again")
  os.exit()
end

local infoTable = xafcoreTable:loadFromString(sourceData)
local infoName = infoTable.package_name
local infoStable = infoTable.package_stable
local infoVersion = infoTable.package_version
local localVersion = _G._XAF._VERSION

if (infoVersion == localVersion) then
  print("    >> Installed package version is equal to latest version (" .. localVersion .. ')')
  print("    >> Thank you for keeping XAF up to date")
  print("    >> Update checking procedure has been finished")
else
  print("    >> New version detected (local: " .. localVersion .. ", remote: " .. infoVersion .. ')')
  print("    >> Use 'xaf update " .. infoVersion .. "' to download and install this version")

  if (infoStable == "true") then
    print("      >> This version is marked as 'stable'")
    print("      >> All changes are fully backward compatible")
  elseif (infoStable == "false") then
    print("      >> Warning! This version is not marked as 'stable'")
    print("      >> You may experience some bugs in this software")
  else
    print("      >> Unknown release stage: '" .. infoStable .. "'")
    print("      >> Please notify the author about that")
    print("      >> Thank you for your feedback")
  end

  print("    >> Update checking procedure has been finished")
end
