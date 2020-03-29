------------------------------------
-- XAF Module - Network:REPServer --
------------------------------------
-- [>] This class represents the mechanism of server side of Remote Executor Protocol.
-- [>] It allows the user executing scripts on a remote machine through client's computer.
-- [>] That implementation possesses some options of executing like performing as command or no value returning.

local filesystem = require("filesystem")
local server = require("xaf/network/server")
local shell = require("shell")
local unicode = require("unicode")
local xafcore = require("xaf/core/xafcore")
local xafcoreExecutor = xafcore:getExecutorInstance()

local RepServer = {
  C_NAME = "Generic REP Server",
  C_INSTANCE = true,
  C_INHERIT = true,

  static = {}
}

function RepServer:initialize()
  local parent = server:extend()
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}

  private.serverPaths = {}
  private.serverPaths["rep_root"] = '/'
  private.serverPaths["rep_scripts"] = "REP_SCRIPTS"

  private.doExecute = function(self, event)                                                    -- [!] Function: doExecute(event) - Tries to execute script with given parameter as path.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")              -- [!] Parameter: event - Event table with received request object.

    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local scriptPath = filesystem.canonical(event[8])
    local scriptFullPath = filesystem.concat(private.serverPaths["rep_scripts"], scriptPath)
    local scriptParameters = nil
    local returnParameters = nil
    local executionFlag = nil

    if (filesystem.exists(scriptFullPath) == false) then
      modem.send(responseAddress, port, false, "Script Not Exists")
    elseif (filesystem.isDirectory(scriptFullPath) == true) then
      modem.send(responseAddress, port, false, "Invalid File")
    else
      scriptParameters = {}
      returnParameters = {}

      for i = 9, #event do
        table.insert(scriptParameters, event[i])
      end

      returnParameters = {xafcoreExecutor:runExternal(scriptFullPath, table.unpack(scriptParameters))}
      executionFlag = table.remove(returnParameters, 1)

      if (executionFlag == true) then
        modem.send(responseAddress, port, true, "OK", table.unpack(returnParameters))
      else
        modem.send(responseAddress, port, false, "Script Execution Error")
      end
    end
  end

  private.doExecuteAbsolute = function(self, event)                                                -- [!] Function: doExecuteAbsolute(event) - Tries to execute program with given parameter as absolute path in server file tree.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")                  -- [!] Parameter: event - Event table with received request object.

    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local scriptPath = filesystem.canonical(event[8])
    local scriptParameters = nil
    local returnParameters = nil
    local executionFlag = nil

    if (filesystem.exists(scriptPath) == false) then
      modem.send(responseAddress, port, false, "Script Not Exists")
    elseif (filesystem.isDirectory(scriptPath) == true) then
      modem.send(responseAddress, port, false, "Invalid File")
    else
      scriptParameters = {}
      returnParameters = {}

      for i = 9, #event do
        table.insert(scriptParameters, event[i])
      end

      returnParameters = {xafcoreExecutor:runExternal(scriptPath, table.unpack(scriptParameters))}
      executionFlag = table.remove(returnParameters, 1)

      if (executionFlag == true) then
        modem.send(responseAddress, port, true, "OK", table.unpack(returnParameters))
      else
        modem.send(responseAddress, port, false, "Script Execution Error")
      end
    end
  end

  private.doExecuteCommand = function(self, event)                                -- [!] Function: doExecuteCommand(event) - Tries to execute given program as shell command from root binaries directory.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1") -- [!] Parameter: event - Event table with received request object.

    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local scriptCommand = event[8]
    local scriptParameters = nil
    local scriptLine = scriptCommand
    local scriptFullPath = filesystem.concat("bin", scriptCommand .. ".lua")

    if (filesystem.exists(scriptFullPath) == false) then
      modem.send(responseAddress, port, false, "Script Not Exists")
    elseif (filesystem.isDirectory(scriptFullPath) == true) then
      modem.send(responseAddress, port, false, "Invalid File")
    else
      for i = 9, #event do
        scriptLine = scriptLine .. ' ' .. tostring(event[i])
      end

      shell.execute(scriptLine)
      modem.send(responseAddress, port, true, "OK")
    end
  end

  private.doExecuteNoProtect = function(self, event)                                         -- [!] Function: doExecuteNoProtect(event) - Tries to run program (without default protection) with given parameter as its path - to use with custom execution error handler.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")            -- [!] Parameter: event - Event table with received request object.

    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local scriptPath = filesystem.canonical(event[8])
    local scriptFullPath = filesystem.concat(private.serverPaths["rep_scripts"], scriptPath)
    local scriptParameters = nil
    local returnParameters = nil

    if (filesystem.exists(scriptFullPath) == false) then
      modem.send(responseAddress, port, false, "Script Not Exists")
    elseif (filesystem.isDirectory(scriptFullPath) == true) then
      modem.send(responseAddress, port, false, "Invalid File")
    else
      local scriptFile = filesystem.open(scriptFullPath, 'r')
      local scriptCode = ''
      local scriptData = scriptFile:read(math.huge)
      local scriptFunction = nil

      scriptParameters = {}
      returnParameters = {}

      while (scriptData) do
        scriptCode = scriptCode .. scriptData
        scriptData = scriptFile:read(math.huge)
      end

      for i = 9, #event do
        table.insert(scriptParameters, event[i])
      end

      scriptFile:close()
      scriptFunction = load(scriptCode)

      returnParameters = {scriptFunction(table.unpack(scriptParameters))}
      modem.send(responseAddress, port, true, "OK", table.unpack(returnParameters))
    end
  end

  private.doExecuteNoReturn = function(self, event)                                                    -- [!] Function: doExecuteNoReturn(event) - Tries to execute script with passed path - it does not return result parameters.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")                      -- [!] Parameter: event - Event table with received request object.

    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local scriptPath = filesystem.canonical(event[8])
    local scriptFullPath = filesystem.concat(private.serverPaths["rep_scripts"], scriptPath)
    local scriptParameters = nil
    local returnParameters = nil
    local executionFlag = nil

    if (filesystem.exists(scriptFullPath) == false) then
      modem.send(responseAddress, port, false, "Script Not Exists")
    elseif (filesystem.isDirectory(scriptFullPath) == true) then
      modem.send(responseAddress, port, false, "Invalid File")
    else
      scriptParameters = {}
      returnParameters = {}

      for i = 9, #event do
        table.insert(scriptParameters, event[i])
      end

      returnParameters = {xafcoreExecutor:runExternal(scriptFullPath, table.unpack(scriptParameters))}
      executionFlag = table.remove(returnParameters, 1)

      if (executionFlag == true) then
        modem.send(responseAddress, port, true, "OK") -- This request does not return any result parameters.
      else
        modem.send(responseAddress, port, false, "Script Executor Error")
      end
    end
  end

  private.doScriptList = function(self, event)                                           -- [!] Function: doScriptList(event) - Retrieves full script list stored on REP server.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")        -- [!] Parameter: event - Event table with received request object.

    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local scriptPath = private.serverPaths["rep_scripts"]
    local scriptList = string.char(0) -- Next correct script paths are delimited by '//' characters.
    local scriptData = ''

    function getList(subPath, subLevel)
      for item in filesystem.list(subPath) do
        local pathString = filesystem.concat(subPath, item)
        local pathSegments = {}

        if (filesystem.isDirectory(pathString) == true) then
          getList(pathString, subLevel + 1)
        else
          pathSegments = filesystem.segments(pathString)
          scriptData = ''

          for i = 1, subLevel do
            scriptData = scriptData .. pathSegments[#pathSegments - subLevel + i] .. '/'
          end

          scriptData = string.sub(scriptData, 1, unicode.wlen(scriptData) - 1)
          scriptList = scriptList .. scriptData .. string.char(0)
        end
      end
    end

    getList(scriptPath, 1)
    modem.send(responseAddress, port, true, "OK", scriptList)
  end

  private.prepareWorkspace = function(self, rootPath)                                                                           -- [!] Function: prepareWorkspace(rootPath) - Initializes the workspace for REP server.
    assert(type(rootPath) == "string", "[XAF Network] Expected STRING as argument #1")                                          -- [!] Parameter: rootPath - REP server workspace tree root path string.
                                                                                                                                -- [!] Return: 'true' - If all required directories have been prepared correctly.
    private.serverPaths["rep_root"] = rootPath
    private.serverPaths["rep_scripts"] = filesystem.concat(private.serverPaths["rep_root"], private.serverPaths["rep_scripts"])

    if (filesystem.exists(private.serverPaths["rep_root"]) == false) then
      filesystem.makeDirectory(private.serverPaths["rep_root"])
    end

    if (filesystem.exists(private.serverPaths["rep_scripts"]) == false) then
      filesystem.makeDirectory(private.serverPaths["rep_scripts"])
    end

    return true
  end

  private.process = function(self, event)                                         -- [!] Function: process(event) - Captures request and passes its object to proper handling function.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1") -- [!] Parameter: event - Event table from OC Event API `event.pull()` function which holds request object.
                                                                                  -- [!] Return: status, ... - Processing status as boolean flag and additional request values (unless NO_RETURN choosen).
    local requestName = event[7]

    if (requestName == "REP_EXECUTE") then
      return true, private:doExecute(event)
    elseif (requestName == "REP_EXECUTE_ABSOLUTE") then
      return true, private:doExecuteAbsolute(event)
    elseif (requestName == "REP_EXECUTE_COMMAND") then
      return true, private:doExecuteCommand(event)
    elseif (requestName == "REP_EXECUTE_NO_PROTECT") then
      return true, private:doExecuteNoProtect(event)
    elseif (requestName == "REP_EXECUTE_NO_RETURN") then
      return true, private:doExecuteNoReturn(event)
    elseif (requestName == "REP_SCRIPT_LIST") then
      return true, private:doScriptList(event)
    else
      return false
    end
  end

  return {
    private = private,
    public = public
  }
end

function RepServer:extend()
  local class = self:initialize()
  local private = class.private
  local public = class.public

  if (self.C_INHERIT == true) then
    return {
      private = private,
      public = public
    }
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be inherited")
  end
end

function RepServer:new(modem, rootPath)
  local class = self:initialize()
  local private = class.private
  local public = class.public

  public:setModem(modem)
  assert(type(rootPath) == "string", "[XAF Network] Expected STRING as argument #2")
  private:prepareWorkspace(rootPath)

  if (self.C_INSTANCE == true) then
    return public
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be instanced")
  end
end

return RepServer
