-- Extensible Application Framework deinstallation program.
-- This script is used to completely uninstall XAF with its API and package configuration entities.
-- Manual uninstallation is not necessary when updating or changing the API version, XAF controller will do it automatically.

local arguments, options = ...
local computer = require("computer")
local event = require("event")
local filesystem = require("filesystem")

if (options.h == true or options.help == true) then
  print("-----------------------------------------------")
  print("-- Extensible Application Framework - Manual --")
  print("-----------------------------------------------")
  print("  >> NAME")
  print("    >> xaf remove - Program for XAF package removal and uninstallation")
  print()
  print("  >> SYNOPSIS")
  print("    >> xaf remove")
  print("    >> xaf remove [-h | --help]")
  print()
  print("  >> DESCRIPTION")
  print("    >> This script is used for complete uninstallation of XAF package and configuration removal. Automatically reboots the computer after successful uninstallation process. That program will not delete user's created applications based on XAF and its API.")

  os.exit()
end

print("---------------------------------------------------")
print("-- Extensible Application Framework - Controller --")
print("---------------------------------------------------")
print("  >> Starting XAF uninstallation procedure...")
print("  >> Hit 'Y' to confirm or 'N' to abort this process")
print("  >> Warning! This program will remove XAF completely!")

while (true) do
  local option = {event.pull("key_down")}

  if (option[3] == 89) then
    print("  >> Continuing deinstallation process...")
    break
  elseif (option[3] == 78) then
    print("  >> Deinstallation process has been interrupted")
    os.exit()
  end
end

local pathRoot = "io.github.aquaver"
local pathProject = "xaf-framework"
local pathPackages = "xaf-packages"
local pathBinaries = "bin"
local pathController = "xaf.lua"
local pathControllerManager = "xaf-pm.lua"

if (filesystem.remove(filesystem.concat(pathRoot, pathProject)) == true) then
  print("    >> XAF project directory has been removed")
end

if (filesystem.remove(filesystem.concat(pathBinaries, pathController)) == true) then
  print("    >> XAF controller script has been removed")
end

if (filesystem.remove(filesystem.concat(pathBinaries, pathControllerManager)) == true) then
  print("    >> XAF Package Manager controller script has been removed")
end

if (filesystem.exists(filesystem.concat(pathRoot, pathPackages)) == true) then
  print("    >> Detected XAF PM application packages - remove it?")
  print("      >> Hit 'Y' to accept or 'N' to leave it")
  print("      >> Warning! It will delete all installed PM application packages")

  while (true) do
    local option = {event.pull("key_down")}

    if (option[3] == 89) then
      if (filesystem.remove(filesystem.concat(pathRoot, pathPackages)) == true) then
        print("      >> XAF PM application package directory has been removed")
      end

      break
    elseif (option[3] == 78) then
      print("      >> XAF PM application package directory has not been removed, it still exists")
      break
    end
  end
end

if (_G._XAF) then
  _G._XAF = nil

  print("    >> XAF configuration table has been cleared")
end

print("      >> Deinstallation procedure has been finished")
print("      >> Rebooting computer in 5 seconds...")

os.sleep(5)
computer.shutdown(true)
