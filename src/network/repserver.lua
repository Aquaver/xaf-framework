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
    local scriptPath = filesystem.canonical(event[7])
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

      for i = 8, #event do
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
    local scriptPath = filesystem.canonical(event[7])
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

      for i = 8, #event do
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
    local scriptCommand = event[7]
    local scriptParameters = nil
    local scriptLine = scriptCommand
    local scriptFullPath = filesystem.concat("bin", scriptCommand .. ".lua")

    if (filesystem.exists(scriptFullPath) == false) then
      modem.send(responseAddress, port, false, "Script Not Exists")
    elseif (filesystem.isDirectory(scriptFullPath) == true) then
      modem.send(responseAddress, port, false, "Invalid File")
    else
      for i = 8, #event do
        scriptLine = scriptLine .. ' ' .. tostring(event[i])
      end

      shell.execute(scriptLine)
      modem.send(responseAddress, port, true, "OK")
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
