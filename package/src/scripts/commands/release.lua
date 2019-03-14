-- Extensible Application Framework release information program.
-- This program is able to get current XAF release list and information about specific release.
-- The user may check latest release before XAF updating.

local arguments, options = ...
local argument = table.remove(arguments, 1)
local component = require("component")
local httpstream = require("xaf/utility/httpstream")
local jsonparser = require("xaf/utility/jsonparser")
local xafcore = require("xaf/core/xafcore")
local xafcoreMath = xafcore:getMathInstance()

local gpu = component.getPrimary("gpu")
local gpuWidth, gpuHeight = gpu.getResolution()

if (options.h == true or options.help == true) then
  print("-----------------------------------------------")
  print("-- Extensible Application Framework - Manual --")
  print("-----------------------------------------------")
  print("  >> NAME")
  print("    >> xaf release - XAF release information program")
  print()
  print("  >> SYNOPSIS")
  print("    >> xaf release")
  print("    >> xaf release [-h | --help]")
  print("    >> xaf release [-i | --info] <version>")
  print("    >> xaf release [-l | --list] [page]")
  print()
  print("  >> DESCRIPTION")
  print("    >> This program lets the user listing all current XAF releases and retrieving information about specified release version.")

  os.exit()
end

if (options.i == nil and options.info == nil and options.l == nil and options.list == nil) then
  print("---------------------------------------------------")
  print("-- Extensible Application Framework - Controller --")
  print("---------------------------------------------------")
  print("  >> Release data retrieving program")
  print("  >> Use 'xaf release [-h | --help]' for command manual")

  os.exit()
end

if (component.isAvailable("internet") == false) then
  print("---------------------------------------------------")
  print("-- Extensible Application Framework - Controller --")
  print("---------------------------------------------------")
  print("  >> Internet card component is not available")
  print("  >> Release data retrieving procedure cannot be continued")

  os.exit()
else
  print("---------------------------------------------------")
  print("-- Extensible Application Framework - Controller --")
  print("---------------------------------------------------")
  print("  >> Internet card component found")
  print("  >> Trying to connect to project repository...")
end

local sourceAddress = "https://api.github.com/repos/Aquaver/xaf-framework/"
local sourceReleases = "releases"
local sourceTags = "tags"
local sourceFlags = "?per_page=10&page=" .. tostring(argument)

local inetAddress = nil
local inetComponent = component.getPrimary("internet")
local inetConnection = nil

if (options.i == true or options.info == true) then
  inetAddress = sourceAddress .. sourceReleases .. '/' .. sourceTags .. '/' .. tostring(argument)
  inetConnection = httpstream:new(inetComponent, inetAddress)

  if (argument == nil) then
    print("    >> Empty XAF version identifier")
    print("    >> Use correct 'xaf release [-i | --info]' with correct release tag")
    print("    >> Use 'xaf release [-h | --help] for command manual'")

    os.exit()
  end

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

    print("    >> Retrieved release data from version: " .. argument)
    print("      >> Release name: " .. jsonTable["name"])
    print("      >> Release tag: " .. jsonTable["tag_name"])
    print("      >> Release author: " .. jsonTable["author"]["login"])
    print("      >> Release downloads: " .. jsonTable["assets"][1]["download_count"])
    print("      >> Release installer size: " .. string.format("%.2f", tonumber(jsonTable["assets"][1]["size"]) / 1024) .. " kB")

    print(string.rep('-', gpuWidth))
    print(jsonTable["body"])
  else
    print("    >> Cannot connect to project repository")
    print("    >> Ensure the release identifier (" .. argument .. ") is correct")
    print("    >> Try running 'xaf release' again")
  end
elseif (options.l == true or options.list == true) then
  inetAddress = sourceAddress .. sourceReleases .. sourceFlags
  inetConnection = httpstream:new(inetComponent, inetAddress)

  if (argument == nil) then
    argument = 1
  elseif (tonumber(argument) == nil) then
    print("    >> Invalid release list index, must be natural number")
    print("    >> Try running 'xaf release' again with correct index")
    os.exit()
  elseif (xafcoreMath:checkNatural(tonumber(argument), true) == false) then
    print("    >> Invalid release list index, must be natural number")
    print("    >> Try running 'xaf release' again with correct index")
    os.exit()
  end

  if (inetConnection:connect() == true) then
    local jsonData = ''
    local jsonObject = nil
    local jsonTable = {}
    local jsonLength = 0

    for dataChunk in inetConnection:getData() do
      jsonData = jsonData .. dataChunk
    end

    inetConnection:disconnect()
    jsonObject = jsonparser:new()
    jsonTable = jsonObject:parse(jsonData)
    jsonLength = #jsonTable

    for i = 1, jsonLength do
      print("      >> Release: " .. jsonTable[i]["tag_name"] .. " - " .. jsonTable[i]["name"] .. " (" .. jsonTable[i]["assets"][1]["download_count"] .. ')')

      if (i == jsonLength and jsonTable[i]["tag_name"] ~= "1.0.0") then
        print()
        print("        >> Use 'xaf release [-l | --list] " .. tonumber(argument) + 1 .. "' for older releases")
      end
    end
  else
    print("    >> Cannot connect to project repository")
    print("    >> Try running 'xaf release' again")
  end
end
