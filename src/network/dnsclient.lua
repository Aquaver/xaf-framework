------------------------------------
-- XAF Module - Network:DNSClient --
------------------------------------
-- [>] This module is a client implementation for XAF built-in DNS Protocol.
-- [>] It may be used directly with top-level DNS server module, but you could obviously extend it.
-- [>] That class comes with four function which allow making requests corresponding to them.

local client = require("xaf/network/client")
local xafcore = require("xaf/core/xafcore")
local xafcoreSecurity = xafcore:getSecurityInstance()

local DnsClient = {
  C_NAME = "Generic DNSP Client",
  C_INSTANCE = true,
  C_INHERIT = true,
  
  static = {}
}

function DnsClient:initialize()
  local parent = client:extend() -- This class is client-sided module. Therefore, it inherits directly from client (not server) class.
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}
  
  public.register = function(self, address, name)                                        -- [!] Function: register(address, name) - Sends the 'DNS_REGISTER' request to DNS server.
    assert(type(address) == "string", "[XAF Network] Expected STRING as argument #1")    -- [!] Parameter: address - Address of component (usually computer) to register.
    assert(type(name) == "string", "[XAF Network] Expected STRING as argument #2")       -- [!] Parameter: name - Domain name of component to register.
                                                                                         -- [!] Return: ... - Status and message received from the server.
    local registerAddress = address
    local registerDomainName = name
    
    if (xafcoreSecurity:isUuid(registerAddress) == true) then
      return private:sendRawRequest("DNS_REGISTER", registerAddress, registerDomainName)
    else
      error("[XAF Error] Invalid address syntax")
    end
  end
  
  public.translateForward = function(self, name)                                   -- [!] Function: translateForward(name) - Sends the 'DNS_TRANSLATE_FORWARD' request to DNS server.
    assert(type(name) == "string", "[XAF Network] Expected STRING as argument #1") -- [!] Parameter: name - Domain name to translate to its address, registered in DNS server.
                                                                                   -- [!] Return: ... - Status and message or received address from the server.
    local translateDomainName = name
    
    return private:sendRawRequest("DNS_TRANSLATE_FORWARD", translateDomainName)
  end
  
  public.translateReverse = function(self, address)                                   -- [!] Function: translateReverse(address) - Sends the 'DNS_TRANSLATE_REVERSE' request to DNS server.
    assert(type(address) == "string", "[XAF Network] Expected STRING as argument #1") -- [!] Parameter: address - Address to translate to its corresponding domain name, registered in DNS server.
                                                                                      -- [!] Return: ... - Status and message or received domain name assigned to requested address.
    local translateAddress = address
    
    if (xafcoreSecurity:isUuid(translateAddress) == true) then
      return private:sendRawRequest("DNS_TRANSLATE_REVERSE", translateAddress)
    else
      error("[XAF Error] Invalid address syntax")
    end
  end
  
  public.unregister = function(self, object)                                         -- [!] Function: unregister(object) - Sends the 'DNS_UNREGISTER' request to DNS server.
    assert(type(object) == "string", "[XAF Network] Expected STRING as argument #1") -- [!] Parameter: object - Object (domain name or address) you wish to unregister.
                                                                                     -- [!] Return: ... - Status and message received from the server.
    local unregisterObject = object
    
    return private:sendRawRequest("DNS_UNREGISTER", unregisterObject)
  end
  
  return {
    private = private,
    public = public
  }
end

function DnsClient:extend()
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

function DnsClient:new(modem)
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

return DnsClient
