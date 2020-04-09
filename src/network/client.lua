---------------------------------
-- XAF Module - Network:Client --
---------------------------------
-- [>] This class represents an abstract network client.
-- [>] It is used for creating standalone user-defined network protocols in XAF standard.
-- [>] All built-in protocols are designed using default OC configuration.
-- [>] Warning! Note that these protocols may not work properly in non-default conditions.

local event = require("event")
local xafcore = require("xaf/core/xafcore")
local xafcoreSecurity = xafcore:getSecurityInstance()

local Client = {
  C_NAME = "Abstract Network Client",
  C_INSTANCE = false, -- This class cannot be instanced, it is only used for extending in user-defined classes.
  C_INHERIT = true,

  static = {
    TIMEOUT_DEFAULT = 10 -- Default timeout value used in changing client timeout (in seconds).
  }
}

function Client:initialize()
  local parent = nil -- That module is the top-level parent for all network (protocol) related modules.
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}

  private.componentModem = nil                    -- By default, any client has not modem component assigned.
  private.targetAddress = ''                      -- Each client must have target address set before connection attempt.
  private.targetPort = 1                          -- Clients must also have target port set before connection.
  private.timeout = Client.static.TIMEOUT_DEFAULT -- Timeout is a time after which client will interrupt connection in seconds [-1 = infinity, default = 10].

  private.sendRawRequest = function(self, name, ...)                                     -- [!] Function: sendRawRequest(name, ...) - Sends raw request to the target server to previously set target port. To use in custom requesting functions as core connecting.
    assert(type(name) == "string", "[XAF Network] Expected STRING as argument #1")       -- [!] Parameter: name - Raw request name as string.
                                                                                         -- [!] Return: status, result - Status of the connection response, may be 'true' or 'false'. Second parameter is a response result(s) - it may be an error message on 'false' status.
    local clientVersion = _G._XAF._VERSION
    local modem = private.componentModem
    local requestName = name
    local requestArguments = {...}
    local targetAddress = private.targetAddress
    local targetPort = private.targetPort
    local timeout = private.timeout

    if (modem) then
      modem.open(targetPort)
      modem.send(targetAddress, targetPort, clientVersion, requestName, table.unpack(requestArguments))

      local response = {event.pull(timeout, "modem_message")}
      modem.close(targetPort)

      local responseLength = #response
      local responseName = response[1]
      local responseClientAddress = response[2]
      local responseServerAddress = response[3]
      local responsePort = response[4]
      local responseDistance = response[5] -- Currently unused but may be useful in the future.
      local responseParameters = {}

      for i = 7, responseLength do
        table.insert(responseParameters, response[i])
      end

      if (responseName) then
        if (targetAddress == responseServerAddress and targetPort == responsePort) then
          if (responseClientAddress == modem.address) then
            local status = response[6]
            local result = responseParameters

            return status, table.unpack(result)
          end
        end
      else
        return false, "Response Timeout"
      end
    else
      error("[XAF Error] Client network modem component has not been initialized")
    end
  end

  public.getModem = function(self) -- [!] Function: getModem() - Returns the modem component assigned to client.
    return private.componentModem  -- [!] Return: componentModem - Current client assigned network modem component.
  end

  public.getTargetAddress = function(self) -- [!] Function: getTargetAddress() - Returns client set target server's address.
    return private.targetAddress           -- [!] Return: targetAddress - Current target server address.
  end

  public.getTargetPort = function(self) -- [!] Function: getTargetPort() - Returns current client assigned target server's port.
    return private.targetPort           -- [!] Return: targetPort - Client target server's communication port number.
  end

  public.getTimeout = function(self) -- [!] Function: getTimeout() - Returns current client's set timeout in seconds.
    return private.timeout           -- [!] Return: timeout - Client timeout value in seconds [-1 = infinity].
  end

  public.setModem = function(self, modem)                                         -- [!] Function: setModem(modem) - Sets client network modem component.
    assert(type(modem) == "table", "[XAF Network] Expected TABLE as argument #1") -- [!] Parameter: modem - New modem component as its proxy.
                                                                                  -- [!] Return: 'true' - If new network component has been set properly.
    if (modem.type == "modem") then
      private.componentModem = modem
    else
      error("[XAF Error] Invalid network modem component")
    end

    return true
  end

  public.setTargetAddress = function(self, address)                                   -- [!] Function: setTargetAddress(address) - Changes client target server address.
    assert(type(address) == "string", "[XAF Network] Expected STRING as argument #1") -- [!] Parameter: address - New target server address.
                                                                                      -- [!] Return: 'true' - If new address value has been changed correctly.
    if (xafcoreSecurity:isUuid(address) == true) then
      private.targetAddress = address
    else
      error("[XAF Error] Invalid target address")
    end

    return true
  end

  public.setTargetPort = function(self, port)                                      -- [!] Function: setTargetPort(port) - Sets client target server communication port.
    assert(type(port) == "number", "[XAF Network] Expected NUMBER as argument #1") -- [!] Parameter: port - New target server port number.
                                                                                   -- [!] Return: 'true' - If new port has been changed successfully.
    if (port >= 1 and port <= 65535) then
      private.targetPort = port
    else
      error("[XAF Error] Invalid port number - must be a positive integer up to 65535")
    end

    return true
  end

  public.setTimeout = function(self, timeout)                                         -- [!] Function: setTimeout(timeout) - Sets new client's timeout time in seconds.
    assert(type(timeout) == "number", "[XAF Network] Expected NUMBER as argument #1") -- [!] Parameter: timeout - New timeout value in seconds [-1 = infinity].
                                                                                      -- [!] Return: 'true' - If new timeout value has been set without errors.
    if (timeout == -1) then
      private.timeout = math.huge
    else
      private.timeout = timeout
    end

    return true
  end

  return {
    private = private,
    public = public
  }
end

function Client:extend()
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

function Client:new()
  local class = self:initialize()
  local private = class.private
  local public = class.public

  if (self.C_INSTANCE == true) then
    return public
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be instanced")
  end
end

return Client
