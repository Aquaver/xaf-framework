-- Extensible Application Framework Package Manager main controller script.
-- After XAF package installation, this program will be created in 'bin' directory to be used as a command.
-- This program allows custom XAF based add-ons installation and general source management.

local filesystem = require("filesystem")
local shell = require("shell")

local arguments, options = shell.parse(...)
local command = table.remove(arguments, 1)
local configTable = _G._XAF
local configVersion = (configTable) and configTable._VERSION or ''

if (command) then
  local pathRoot = "aquaver.github.io"
  local pathProject = "xaf-framework"
  local pathScript = "scripts"
  local pathSub = "pm"

  if (configTable) then
    if (filesystem.exists(filesystem.concat(pathRoot, pathProject, pathScript, pathSub, command .. ".lua")) == true) then
      local commandFile = filesystem.open(filesystem.concat(pathRoot, pathProject, pathScript, pathSub, command .. ".lua"), 'r')
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
      print("--------------------------------------")
      print("-- XAF Package Manager - Controller --")
      print("--------------------------------------")
      print("  >> Cannot find following command 'xaf-pm " .. command .. "'")
      print("  >> Use 'xaf-pm list' - for available command list")
    end
  else
    print("--------------------------------------")
    print("-- XAF Package Manager - Controller --")
    print("--------------------------------------")
    print("  >> Cannot execute following command 'xaf-pm " .. command .. "'")
    print("  >> Please initialize the API first using 'xaf init'")
  end
else
  if (configTable) then
    print("--------------------------------------")
    print("-- XAF Package Manager - Controller --")
    print("--------------------------------------")
    print("  >> Successfully detected XAF installed on this computer")
    print("  >> Package global API version: " .. configVersion)
    print("  >> Use 'xaf-pm list' - for available command list")
  else
    print("--------------------------------------")
    print("-- XAF Package Manager - Controller --")
    print("--------------------------------------")
    print("  >> XAF has not been initialized yet...")
    print("  >> Use 'xaf init' - to initialize the API")
  end
end
