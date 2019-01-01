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
