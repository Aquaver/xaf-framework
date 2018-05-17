-- Extensible Application Framework automated updating program.
-- After performing 'xaf check' command and retrieving new version, the user might use this command to download and install the update automatically.
-- Successfully finished version installation cannot be reversed. Therefore if you want to return to older version, just use 'xaf update <older version>'.

local arguments, options = ...
local version = table.remove(arguments, 1)
local component = require("component")
local httpstream = require("xaf/utility/httpstream")
local xafcore = require("xaf/core/xafcore")
local xafcoreExecutor = xafcore:getExecutorInstance()

if (options.h == true or options.help == true) then
  print("-----------------------------------------------")
  print("-- Extensible Application Framework - Manual --")
  print("-----------------------------------------------")
  print("  >> NAME")
  print("    >> xaf update - Automated XAF update downloader and installer")
  print()
  print("  >> SYNOPSIS")
  print("    >> xaf update")
  print("    >> xaf update [-h | --help]")
  print("    >> xaf update <version>")
  print()
  print("  >> DESCRIPTION")
  print("    >> This script is used in downloading and installing available package updates. It downloads installer program from specified version release and automatically executes it. The user is able to abort the process during installation.")
  
  os.exit()
end

if (version == nil) then
  print("---------------------------------------------------")
  print("-- Extensible Application Framework - Controller --")
  print("---------------------------------------------------")
  print("  >> Invalid version identifier")
  print("  >> Use correct 'xaf update <version>' command syntax")
  print("  >> Use '-h' or '--help' option for command help")
  
  os.exit()
end

if (component.isAvailable("internet") == false) then
  print("---------------------------------------------------")
  print("-- Extensible Application Framework - Controller --")
  print("---------------------------------------------------")
  print("  >> Internet card component not found")
  print("  >> Update process has been interrupted")
  
  os.exit()
else
  print("---------------------------------------------------")
  print("-- Extensible Application Framework - Controller --")
  print("---------------------------------------------------")
  print("  >> Internet card component is available, continuing...")
  print("  >> Selected release version: " .. version)
  print("  >> Trying to connect to project repository...")
end

local releaseAddress = "https://raw.githubusercontent.com/Aquaver/xaf-framework/"
local releaseInstaller = "/installer.lua"
local internetAddress = releaseAddress .. version .. releaseInstaller
local internetComponent = component.getPrimary("internet")
local internetConnection = httpstream:new(internetComponent, internetAddress)

if (internetConnection:connect() == true) then
  local installerCode = ''
  local installerFunction = nil
  
  for dataChunk in internetConnection:getData() do
    installerCode = installerCode .. dataChunk
  end
  
  internetConnection:disconnect()
  installerFunction = load(installerCode)
  
  print("    >> Loading installer...")
  xafcoreExecutor:run(installerFunction)
else
  print("    >> Cannot connect to project repository")
  print("    >> Ensure the version identifier (" .. version .. ") is correct")
  print("    >> Try running 'xaf update' again")
end
