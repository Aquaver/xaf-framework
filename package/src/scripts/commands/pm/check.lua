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
  os.exit()
end

print("--------------------------------------")
print("-- XAF Package Manager - Controller --")
print("--------------------------------------")
print("  >> Package update checking program")
print("  >> Use 'xaf-pm check [-h | --help]' for command manual")
