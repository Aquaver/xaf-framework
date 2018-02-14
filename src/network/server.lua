---------------------------------
-- XAF Module - Network:Server --
---------------------------------
-- [>] That class represents an abstract server - passive network element which responses on clients' requests.
-- [>] It cannot be instanced directly, it must be firstly implemented in specific protocol class (on server side).
-- [>] This module is commonly used to create custom protocols and communication systems.

local Server = {
  C_NAME = "Abstract Network Server",
  C_INSTANCE = false,
  C_INHERIT = true,
  
  static = {}
}

function Server:initialize()
  local parent = nil
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}
  
  private.active = false
  private.eventStart = nil
  private.eventStartArguments = {}
  private.eventStop = nil
  private.eventStopArguments = {}
  private.componentModem = nil -- By default server has not modem component assigned.
  private.port = 1             -- Default server working port is equal to one.
  
  public.getModem = function(self) -- [!] Function: getModem() - Returns current server's modem component as its proxy.
    return private.componentModem  -- [!] Return: componentModem - Proxy of server's modem component.
  end
  
  public.getPort = function(self) -- [!] Function: getPort() - Returns server working port as its number value.
    return private.port           -- [!] Return: port - Server working port value.
  end
  
  public.isRunning = function(self) -- [!] Function: isRunning() - Returns current server activity state as boolean.
    return private.active           -- [!] Return: active - Server's activity flag.
  end
  
  public.process = function(self)                                                              -- [!] Function: process() - Default server processing function, which always throw an error.
    error("[XAF Error] Server processing function has not been initialized - running default")
  end
  
  public.setModem = function(self, modem)                                         -- [!] Function: setModem(modem) - Sets new server network modem component.
    assert(type(modem) == "table", "[XAF Network] Expected TABLE as argument #1") -- [!] Parameter: modem - Server's working modem component as proxy.
                                                                                  -- [!] Return: 'true' - If new modem component has been changed successfully.
    if (modem.type == "modem") then
      private.componentModem = modem
    else
      error("[XAF Error] Invalid network modem component")
    end
    
    return true
  end
  
  public.setOnStart = function(self, task, ...)                                        -- [!] Function: setOnStart(task, ...) - Changes function task performed on server starting.
    assert(type(task) == "function", "[XAF Network] Expected FUNCTION as argument #1") -- [!] Parameter: task - New task function.
                                                                                       -- [!] Parameter: ... - New event task function parameter list.
    local eventTask = task                                                             -- [!] Return: 'true' - If new function has been set correctly.
    local eventArguments = {...}
    
    private.eventStart = eventTask
    private.eventStartArguments = eventArguments
    
    return true
  end
  
  public.setOnStop = function(self, task, ...)                                         -- [!] Function: setOnStop(task, ...) - Changes callback function executed on server stopping.
    assert(type(task) == "function", "[XAF Network] Expected FUNCTION as argument #1") -- [!] Parameter: task - New callback function.
                                                                                       -- [!] Parameter: ... - New callback function arguments.
    local eventTask = task                                                             -- [!] Return: 'true' - If new event callback function has been set properly.
    local eventArguments = {...}
    
    private.eventStop = eventTask
    private.eventStopArguments = eventArguments
    
    return true
  end
  
  public.setPort = function(self, port)                                                     -- [!] Function: setPort(port) - Sets new server working port number.
    assert(type(port) == "number", "[XAF Network] Expected NUMBER as argument #1")          -- [!] Parameter: port - New server's working port value.
                                                                                            -- [!] Return: 'true' - If new port number has been set without errors.
    if (port >= 1 and port <= 65535) then
      private.port = port
    else
      error("[XAF Error] Invalid port number - must be a positive integer up to 65535")
    end
    
    return true
  end
  
  public.start = function(self)                   -- [!] Function: start() - Starts the server by opening its port and executing initialization function (if present).
    local event = private.eventStart              -- [!] Return: ... - Results from server's initialization function (if present).
    local arguments = private.eventStartArguments
    local modem = private.componentModem
    local port = private.port
    
    if (private.active == true) then
      error("[XAF Error] Server is already started")
    end
    
    if (modem) then
      if (modem.isOpen(port) == false) then
        private.active = true
        modem.open(port)
      end
    else
      error("[XAF Error] Server network modem component has not been initialized")
    end
    
    if (event) then
      return event(table.unpack(arguments))
    end
  end
  
  public.stop = function(self)                   -- [!] Function: stop() - Stops the server by closing its port and executing finalization function (if present).
    local event = private.eventStop              -- [!] Return: ... - Results from server's finalization function (if present).
    local arguments = private.eventStopArguments
    local modem = private.componentModem
    local port = private.port
    
    if (private.active == false) then
      error("[XAF Error] Server is already stopped")
    end
    
    if (modem) then
      if (modem.isOpen(port) == true) then
        private.active = false
        modem.close(port)
      end
    else
      error("[XAF Error] Server network modem component has not been initialized")
    end
    
    if (event) then
      return event(table.unpack(arguments))
    end
  end
  
  return {
    private = private,
    public = public
  }
end

function Server:extend()
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

function Server:new()
  local class = self:initialize()
  local private = class.private
  local public = class.public
  
  if (self.C_INSTANCE == true) then
    return public
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be instanced")
  end
end

return Server
