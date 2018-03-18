-- Extensible Application Framework main controller script.
-- After installation it will be created in 'bin' directory to be used as a command.
-- This program allows the user initializing API and general package managing.

local filesystem = require("filesystem")
local shell = require("shell")

local arguments, options = shell.parse(...)
local command = table.remove(arguments, 1)
local configTable = _G._XAF
local configVersion = (configTable) and configTable._VERSION or ''

if (command) then
  local pathRoot = "aquaver.github.io"
  local pathProject = "xaf-framework"
  local pathScripts = "scripts"
  
  if (command == "init") then
    if (filesystem.exists(filesystem.concat(pathRoot, pathProject, pathScripts, command .. ".lua"))) then
      local initFile = filesystem.open(filesystem.concat(pathRoot, pathProject, pathScripts, command .. ".lua"), 'r')
      local initFunction = nil
      local initCode = ''
      local initData = initFile:read(math.huge)
      
      while (initData) do
        initCode = initCode .. initData
        initData = initFile:read(math.huge)
      end
      
      initFunction = load(initCode)
      initFunction(arguments, options)
    else
      print("---------------------------------------------------")
      print("-- Extensible Application Framework - Controller --")
      print("---------------------------------------------------")
      print("  >> Cannot find XAF initialization script")
      print("  >> Try installing entire package again or download the script manually")
    end
  else
    if (configTable) then
      if (filesystem.exists(filesystem.concat(pathRoot, pathProject, pathScripts, command .. ".lua")) == true) then
        local commandFile = filesystem.open(filesystem.concat(pathRoot, pathProject, pathScripts, command .. ".lua"), 'r')
        local commandFunction = nil
        local commandCode = ''
        local commandData = commandFile:read(math.huge)
        local commandResults = {}
        
        while (commandData) do
          commandCode = commandCode .. commandData
          commandData = commandFile:read(math.huge)
        end
        
        commandFile:close()
        commandFunction = load(commandCode)
        commandResults = {commandFunction(arguments, options)}
        
        return table.unpack(commandResults)
      else
        print("---------------------------------------------------")
        print("-- Extensible Application Framework - Controller --")
        print("---------------------------------------------------")
        print("  >> Cannot find following command 'xaf " .. command .. "'")
        print("  >> Use 'xaf list' - for available command list")
      end
    else
      print("---------------------------------------------------")
      print("-- Extensible Application Framework - Controller --")
      print("---------------------------------------------------")
      print("  >> Cannot execute following command 'xaf " .. command .. "'")
      print("  >> Please initialize the API first using 'xaf init'")
    end
  end
else
  if (configTable) then
    print("---------------------------------------------------")
    print("-- Extensible Application Framework - Controller --")
    print("---------------------------------------------------")
    print("  >> XAF has been initialized successfully and it is ready to use...")
    print("  >> Package global API version: " .. configVersion)
    print("  >> Use 'xaf list' - for available command list")
  else
    print("---------------------------------------------------")
    print("-- Extensible Application Framework - Controller --")
    print("---------------------------------------------------")
    print("  >> XAF has not been initialized yet...")
    print("  >> Use 'xaf init' - to initialize the API")
  end
end
