------------------------------------
-- XAF Module - Network:REPClient --
------------------------------------
-- [>] This is the client side module of Remote Executor Protocol.
-- [>] It allows requesting for executing remote located scripts.
-- [>] That class implements mechanisms for returning received parameters for performed program.

local client = require("xaf/network/client")
local xafcore = require("xaf/core/xafcore")
local xafcoreText = xafcore:getTextInstance()

local RepClient = {
  C_NAME = "Generic REP Client",
  C_INSTANCE = true,
  C_INHERIT = true,

  static = {}
}

function RepClient:initialize()
  local parent = client:extend()
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}
  
  public.execute = function(self, scriptPath, ...)                                                   -- [!] Function: execute(scriptPath, ...) - Sends 'REP_EXECUTE' request type to the REP server.
    assert(type(scriptPath) == "string", "[XAF Network] Expected STRING as argument #1")             -- [!] Parameter: scriptPath - Relative path of script to be parformed.
                                                                                                     -- [!] Parameter: ... - Optional arguments passed to the target program.
    local scriptRelativePath = scriptPath                                                            -- [!] Return: ... - Boolean flag of request status and optional returned arguments from executed script.
    local scriptParameters = {...}

    return private:sendRawRequest("REP_EXECUTE", scriptRelativePath, table.unpack(scriptParameters))
  end
  
  public.executeAbsolute = function(self, scriptPath, ...)                                                    -- [!] Function: executeAbsolute(scriptPath, ...) - Sends 'REP_EXECUTE_ABSOLUTE' request type to the REP server.
    assert(type(scriptPath) == "string", "[XAF Network] Expected STRING as argument #1")                      -- [!] Parameter: scriptPath - Absolute path of the script to be execute, in entire server file tree.
                                                                                                              -- [!] Parameter: ... - Optional arguments passed to the targed script.
    local scriptAbsolutePath = scriptPath                                                                     -- [!] Return: ... - Boolean flag of request procession and optional returned values from performed program.
    local scriptParameters = {...}

    return private:sendRawRequest("REP_EXECUTE_ABSOLUTE", scriptAbsolutePath, table.unpack(scriptParameters))
  end
  
  public.executeCommand = function(self, scriptCommand, ...)                                                -- [!] Function: executeCommand(scriptCommand, ...) - Sends 'REP_EXECUTE_COMMAND' request type to REP server.
    assert(type(scriptCommand) == "string", "[XAF Network] Expected STRING as argument #1")                 -- [!] Parameter: scriptCommand - Name of given command to execute on the server.
                                                                                                            -- [!] Parameter: ... - Optional arguments passed to the command.
    local scriptCommandName = scriptCommand                                                                 -- [!] Return: ... - Response status and its message - this function does not return any values from execution.
    local scriptParameters = {...}

    return private:sendRawRequest("REP_EXECUTE_COMMAND", scriptCommandName, table.unpack(scriptParameters))
  end
  
  public.executeNoProtect = function(self, scriptPath, ...)                                                     -- [!] Function: executeNoProtect(scriptPath, ...) - Sends 'REP_EXECUTE_NO_PROTECT' request to the target REP server.
    assert(type(scriptPath) == "string", "[XAF Network] Expected STRING as argument #1")                        -- [!] Parameter: scriptPath - Relative path of target script to be executed.
                                                                                                                -- [!] Parameter: ... - Optional argument list passed to the script.
    local scriptRelativePath = scriptPath                                                                       -- [!] Return: ... - Boolean flag of exeution status and optional returned argument list.
    local scriptParameters = {...}

    return private:sendRawRequest("REP_EXECUTE_NO_PROTECT", scriptRelativePath, table.unpack(scriptParameters))
  end
  
  public.executeNoReturn = function(self, scriptPath, ...)                                                     -- [!] Function: executeNoReturn(scriptPath, ...) - Sends 'REP_EXECUTE_NO_RETURN' request to target REP server.
    assert(type(scriptPath) == "string", "[XAF Network] Expected STRING as argument #1")                       -- [!] Parameter: scriptPath - Relative path of script to execute.
                                                                                                               -- [!] Parameter: ... - Argument list passed to the target script.
    local scriptRelativePath = scriptPath                                                                      -- [!] Return: ... - Response status and its message - no execution results returned from the response.
    local scriptParameters = {...}

    return private:sendRawRequest("REP_EXECUTE_NO_RETURN", scriptRelativePath, table.unpack(scriptParameters))
  end

  return {
    private = private,
    public = public
  }
end

function RepClient:extend()
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

function RepClient:new(modem)
  local class = self:initialize()
  local private = class.private
  local public = class.public

  public:setModem(modem)

  if (self.C_INSTANCE == true) then
    return public
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be instanced")
  end
end

return RepClient
