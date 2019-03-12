------------------------------------
-- XAF Module - Network:DNSServer --
------------------------------------
-- [>] This class represents the most simple implementation of Domain Name System Protocol (server-sided).
-- [>] It provides core DNS functionality - domain registering, unregistering and two-way translation.
-- [>] Due to that module implements only plain DNS related processes, it is strongly recommended extending and reimplementing it.

local filesystem = require("filesystem")
local server = require("xaf/network/server")
local xafcore = require("xaf/core/xafcore")
local xafcoreSecurity = xafcore:getSecurityInstance()
local xafcoreTable = xafcore:getTableInstance()

local DnsServer = {
  C_NAME = "Generic DNSP Server",
  C_INSTANCE = true,
  C_INHERIT = true,

  static = {}
}

function DnsServer:initialize()
  local parent = server:extend() -- This class is server-sided module. Therefore, it extends from server (not client) class.
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}

  private.serverPaths = {}
  private.serverPaths["dns_root"] = '/'
  private.serverPaths["dns_registry"] = "DNS_REGISTRY"
  private.serverPaths["dns_registry_forward"] = "REGISTRY_FORWARD"
  private.serverPaths["dns_registry_reverse"] = "REGISTRY_REVERSE"

  private.doRegister = function(self, event)                                                               -- [!] Function: doRegister(event) - Registers the address and domain name in DNS server.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")                          -- [!] Parameter: event - Event table with received request object.

    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local registerAddress = event[8]
    local registerDomainName = event[9]
    local pathForward = filesystem.concat(private.serverPaths["dns_registry_forward"], registerDomainName)
    local pathReverse = filesystem.concat(private.serverPaths["dns_registry_reverse"], registerAddress)

    if (registerAddress == nil or xafcoreSecurity:isUuid(tostring(registerAddress)) == false) then
      modem.send(responseAddress, port, false, "Invalid Address")
    elseif (registerDomainName == nil) then
      modem.send(responseAddress, port, false, "Invalid Domain Name")
    elseif (filesystem.exists(pathReverse) == true) then
      modem.send(responseAddress, port, false, "Address Already Exists")
    elseif (filesystem.exists(pathForward) == true) then
      modem.send(responseAddress, port, false, "Domain Name Already Exists")
    else
      local tableForward = {}
      local tableReverse = {}
      local fileForward = filesystem.open(pathForward, 'w')
      local fileReverse = filesystem.open(pathReverse, 'w')

      fileForward:write("[#] DNS Entry - Forward" .. '\n' .. '\n')
      fileReverse:write("[#] DNS Entry - Reverse" .. '\n' .. '\n')
      fileForward:close()
      fileReverse:close()

      tableForward["domain_target_address"] = registerAddress
      tableForward["domain_registrar_address"] = modem.address
      tableReverse["domain_target_name"] = registerDomainName
      tableReverse["domain_registrar_address"] = modem.address
      xafcoreTable:saveToFile(tableForward, pathForward, true)
      xafcoreTable:saveToFile(tableReverse, pathReverse, true)

      modem.send(responseAddress, port, true, "OK")
    end
  end

  private.doTranslateForward = function(self, event)                                                        -- [!] Function: doTranslateForward(event) - Translates received domain name and responds with its corresponding address.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")                           -- [!] Parameter: event - Event table with received request object.

    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local translateDomainName = event[8]
    local pathForward = filesystem.concat(private.serverPaths["dns_registry_forward"], translateDomainName)

    if (translateDomainName == nil) then
      modem.send(responseAddress, port, false, "Invalid Domain Name")
    elseif (filesystem.exists(pathForward) == false) then
      modem.send(responseAddress, port, false, "Domain Not Exists")
    else
      local tableForward = xafcoreTable:loadFromFile(pathForward)
      local targetAddress = tableForward["domain_target_address"]

      modem.send(responseAddress, port, true, "OK", targetAddress)
    end
  end

  private.doTranslateReverse = function(self, event)                                                     -- [!] Function: doTranslateReverse(event) - Translates requested address to corresponding domain name and returns it as response.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")                        -- [!] Parameter: event - Event table with received request object.

    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local translateAddress = event[8]
    local pathReverse = filesystem.concat(private.serverPaths["dns_registry_reverse"], translateAddress)

    if (translateAddress == nil or xafcoreSecurity:isUuid(translateAddress) == false) then
      modem.send(responseAddress, port, false, "Invalid Address")
    elseif (filesystem.exists(pathReverse) == false) then
      modem.send(responseAddress, port, false, "Address Not Exists")
    else
      local tableReverse = xafcoreTable:loadFromFile(pathReverse)
      local targetDomainName = tableReverse["domain_target_name"]

      modem.send(responseAddress, port, true, "OK", targetDomainName)
    end
  end

  private.doUnregister = function(self, event)                                                                                          -- [!] Function: doUnregister(event) - Unregisters the address and domain name from DNS server.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")                                                       -- [!] Parameter: event - Event table with received request object.

    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local unregisterObject = event[8]
    local pathForward = filesystem.concat(private.serverPaths["dns_registry_forward"], unregisterObject)
    local pathReverse = filesystem.concat(private.serverPaths["dns_registry_reverse"], unregisterObject)

    if (unregisterObject == nil) then
      modem.send(responseAddress, port, false, "Invalid Domain Object")
    elseif (filesystem.exists(pathForward) == false and filesystem.exists(pathReverse) == false) then
      modem.send(responseAddress, port, false, "Domain Not Exists")
    elseif (filesystem.exists(pathForward) == true and filesystem.exists(pathReverse) == true) then
      modem.send(responseAddress, port, false, "Domain Ambiguity")
    else
      if (filesystem.exists(pathForward) == true) then
        local tableForward = xafcoreTable:loadFromFile(pathForward)
        local removePathReverse = filesystem.concat(private.serverPaths["dns_registry_reverse"], tableForward["domain_target_address"])

        if (filesystem.exists(removePathReverse) == true) then
          filesystem.remove(removePathReverse)
        end

        filesystem.remove(pathForward)
      elseif (filesystem.exists(pathReverse) == true) then
        local tableReverse = xafcoreTable:loadFromFile(pathReverse)
        local removePathForward = filesystem.concat(private.serverPaths["dns_registry_forward"], tableReverse["domain_target_name"])

        if (filesystem.exists(removePathForward) == true) then
          filesystem.remove(removePathForward)
        end

        filesystem.remove(pathReverse)
      end

      modem.send(responseAddress, port, true, "OK")
    end
  end

  private.prepareWorkspace = function(self, rootPath)                                                                                                 -- [!] Function: prepareWorkspace(rootPath) - Initializes the workspace for DNS server.
    assert(type(rootPath) == "string", "[XAF Network] Expected STRING as argument #1")                                                                -- [!] Parameter: rootPath - DNS server workspace tree root path string.
                                                                                                                                                      -- [!] Return: 'true' - If server workspace has been initialized successfully.
    private.serverPaths["dns_root"] = rootPath
    private.serverPaths["dns_registry"] = filesystem.concat(private.serverPaths["dns_root"], private.serverPaths["dns_registry"])
    private.serverPaths["dns_registry_forward"] = filesystem.concat(private.serverPaths["dns_registry"], private.serverPaths["dns_registry_forward"])
    private.serverPaths["dns_registry_reverse"] = filesystem.concat(private.serverPaths["dns_registry"], private.serverPaths["dns_registry_reverse"])

    if (filesystem.exists(private.serverPaths["dns_root"]) == false) then
      filesystem.makeDirectory(private.serverPaths["dns_root"])
    end

    if (filesystem.exists(private.serverPaths["dns_registry"]) == false) then
      filesystem.makeDirectory(private.serverPaths["dns_registry"])
    end

    if (filesystem.exists(private.serverPaths["dns_registry_forward"]) == false) then
      filesystem.makeDirectory(private.serverPaths["dns_registry_forward"])
    end

    if (filesystem.exists(private.serverPaths["dns_registry_reverse"]) == false) then
      filesystem.makeDirectory(private.serverPaths["dns_registry_reverse"])
    end

    return true
  end

  public.process = function(self, event)                                           -- [!] Function: process(event) - Passes the whole event table object and processes the DNS request.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")  -- [!] Parameter: event - Event table object from function 'event.pull()' in OC Event API.
                                                                                   -- [!] Return: status, ... - Request status ('false' when server has received unknown request, otherwise 'true') and potential request returned values.
    local modem = private.componentModem
    local port = private.port
    local address = modem.address

    if (private.active == true) then
      if (modem) then
        if (event[1] == "modem_message") then
          if (event[2] == address and event[4] == port) then
            local clientVersion = event[6]
            local serverVersion = _G._XAF._VERSION
            local responseAddress = event[3]
            local responsePort = event[4]
            local requestName = event[7]

            if (clientVersion == serverVersion) then
              if (requestName == "DNS_REGISTER") then
                return true, private:doRegister(event)
              elseif (requestName == "DNS_TRANSLATE_FORWARD") then
                return true, private:doTranslateForward(event)
              elseif (requestName == "DNS_TRANSLATE_REVERSE") then
                return true, private:doTranslateReverse(event)
              elseif (requestName == "DNS_UNREGISTER") then
                return true, private:doUnregister(event)
              end
            else
              modem.send(responseAddress, responsePort, false, "XAF Version Mismatch")
            end

            return false
          end
        end
      else
        error("[XAF Error] Server network modem component has not been initialized")
      end
    else
      error("[XAF Error] Server is already stopped")
    end
  end

  return {
    private = private,
    public = public
  }
end

function DnsServer:extend()
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

function DnsServer:new(modem, rootPath)
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

return DnsServer
