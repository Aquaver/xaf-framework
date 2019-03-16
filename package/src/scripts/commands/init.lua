-- Extensible Application Framework initialization script.
-- This program must be executed on every computer start before using XAF-based programs.
-- You could run it by using XAF controller script with 'xaf init' command.

local arguments, options = ...
local filesystem = require("filesystem")

local configTable = _G._XAF
local pathRoot = "aquaver.github.io"
local pathProject = "xaf-framework"

if (options.h == true or options.help == true) then
  print("-----------------------------------------------")
  print("-- Extensible Application Framework - Manual --")
  print("-----------------------------------------------")
  print("  >> NAME")
  print("    >> xaf init - Command used for package API initialization")
  print()
  print("  >> SYNOPSIS")
  print("    >> xaf init")
  print("    >> xaf init [-h | --help]")
  print()
  print("  >> DESCRIPTION")
  print("    >> Activates initialization procedure which allows using entire XAF interface and loads all required elements to _XAF global table.")
  
  os.exit()
end

if (configTable) then
  print("---------------------------------------------------")
  print("-- Extensible Application Framework - Controller --")
  print("---------------------------------------------------")
  print("  >> XAF interface is already initialized")
  print("  >> You could use 'xaf list' - for available command list")
else
  local packagePath = filesystem.concat(pathRoot, pathProject)
  local fullPath = packagePath .. "/?.lua"
  local pathSegment = ';/' .. fullPath
  
  package.path = package.path .. pathSegment
  _G._XAF = {}
  _G._XAF._APPDATA = {}
  _G._XAF._VERSION = "1.1.0"
  
  print("---------------------------------------------------")
  print("-- Extensible Application Framework - Controller --")
  print("---------------------------------------------------")
  print("  >> XAF has been initialized successfully and it is ready to use...")
  print("  >> You can now use 'xaf list' - for available command list")
end
