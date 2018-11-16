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
elseif (options.l == true or options.list == true) then
end
