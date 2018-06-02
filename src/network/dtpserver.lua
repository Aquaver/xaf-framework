------------------------------------
-- XAF Module - Network:DTPServer --
------------------------------------
-- [>] This class describes the most primary behavior of Data Transfer Protocol server.
-- [>] In simple words that protocol works as remote database, which stores 'table' files with key-value entries.
-- [>] These database files may be hierarchized and ordered in directories, which builds the tree data layout.
-- [>] Built-in request types have been designed for creating tables (or directories), renaming, removing and key-value pairs managing.

local filesystem = require("filesystem")
local server = require("xaf/network/server")
local xafcore = require("xaf/core/xafcore")
local xafcoreString = xafcore:getStringInstance()
local xafcoreTable = xafcore:getTableInstance()
local xafcoreText = xafcore:getTextInstance()

local DtpServer = {
  C_NAME = "Generic DTP Server",
  C_INSTANCE = true,
  C_INHERIT = true,
  
  static = {}
}

function DtpServer:initialize()
  local parent = server:extend()
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}
  
  private.serverPaths = {}
  private.serverPaths["dtp_root"] = '/'
  private.serverPaths["dtp_database"] = "DTP_DATABASE"
  
  private.doDataGet = function(self, event)                                       -- [!] Function: doDataGet(event) - Returns the data value from specified table by its key.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1") -- [!] Parameter: event - Event table with received request object.
    
    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local tablePath = filesystem.canonical(event[7])
    local dataKey = event[8]
    local fullTablePath = filesystem.concat(private.serverPaths["dtp_database"], tablePath)
    
    if (filesystem.exists(fullTablePath) == false) then
      modem.send(responseAddress, port, false, "Table Not Exists")
    elseif (filesystem.isDirectory(fullTablePath) == true) then
      modem.send(responseAddress, port, false, "Invalid Table File")
    elseif (dataKey == nil) then
      modem.send(responseAddress, port, false, "Nil Data Key")
    else
      local tableObject = xafcoreTable:loadFromFile(fullTablePath)
      local tableValue = tableObject[dataKey]
      
      modem.send(responseAddress, port, true, "OK", tableValue)
    end
  end
  
  private.doDataSet = function(self, event)                                       -- [!] Function: doDataSet(event) - Changes or sets new data value in specified table by its key.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1") -- [!] Parameter: event - Event table with received request object.
    
    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local tablePath = filesystem.canonical(event[7])
    local dataKey = event[8]
    local dataValue = event[9]
    local fullTablePath = filesystem.concat(private.serverPaths["dtp_database"], tablePath)
    
    if (filesystem.exists(fullTablePath) == false) then
      modem.send(responseAddress, port, false, "Table Not Exists")
    elseif (filesystem.isDirectory(fullTablePath) == true) then
      modem.send(responseAddress, port, false, "Invalid Table File")
    elseif (dataKey == nil) then
      modem.send(responseAddress, port, false, "Nil Data Key")
    else
      local tableObject = xafcoreTable:loadFromFile(fullTablePath)
      tableObject[dataKey] = dataValue
      
      xafcoreTable:saveToFile(tableObject, fullTablePath, false)
      
      modem.send(responseAddress, port, true, "OK")
    end
  end
  
  private.doDirectoryCreate = function(self, event)                                                                             -- [!] Function: doDirectoryCreate(event) - Creates new directory in DTP server tree.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")                                               -- [!] Parameter: event - Event table with received request object.
    
    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local directoryPath = filesystem.canonical(event[7])
    local directoryName = event[8]
    local fullDirectoryPath = filesystem.concat(private.serverPaths["dtp_database"], directoryPath)
    local fullNewDirectoryPath = filesystem.concat(fullDirectoryPath, directoryName)
    
    if (filesystem.exists(fullDirectoryPath) == false) then
      modem.send(responseAddress, port, false, "Path Not Exists")
    elseif (filesystem.exists(fullNewDirectoryPath) == true) then
      modem.send(responseAddress, port, false, "Directory Already Exists")
    elseif (filesystem.isDirectory(fullDirectoryPath) == false) then
      modem.send(responseAddress, port, false, "Path Is Not A Directory")
    elseif (directoryName == nil or xafcoreString:checkControlCharacter(directoryName) == true
    or xafcoreString:checkSpecialCharacter(directoryName) == true or xafcoreString:checkWhitespace(directoryName) == true) then
      modem.send(responseAddress, port, false, "Invalid Directory Name")
    else
      filesystem.makeDirectory(fullNewDirectoryPath)
      
      modem.send(responseAddress, port, true, "OK")
    end
  end
  
  private.doObjectMove = function(self, event)                                                -- [!] Function: doObjectMove(event) - Moves specified object (table or entire directory) to new directory.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")             -- [!] Parameter: event - Event table with received request object.
    
    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local moveObject = filesystem.canonical(event[7])
    local movePath = filesystem.canonical(event[8])
    local fullMoveObject = filesystem.concat(private.serverPaths["dtp_database"], moveObject)
    local fullMovePath = filesystem.concat(private.serverPaths["dtp_database"], movePath)
    
    if (filesystem.exists(fullMoveObject) == false) then
      modem.send(responseAddress, port, false, "Object Not Exists")
    elseif (filesystem.exists(fullMovePath) == false) then
      modem.send(responseAddress, port, false, "Path Not Exists")
    elseif (filesystem.isDirectory(fullMovePath) == false) then
      modem.send(responseAddress, port, false, "Path Is Not A Directory")
    elseif (moveObject == '' or moveObject == '/') then
      modem.send(responseAddress, port, false, "Access Denied")
    else
      local pathSegments = xafcoreText:split(fullMoveObject, '/')
      local segmentsCount = #pathSegments
      local objectName = pathSegments[segmentsCount]
      local newObjectPath = filesystem.concat(fullMovePath, objectName)
      
      filesystem.rename(fullMoveObject, newObjectPath)
      
      modem.send(responseAddress, port, true, "OK")
    end
  end
  
  private.doObjectRemove = function(self, event)                                              -- [!] Function: doObjectRemove(event) - Removes selected object (table or entire directory) from DTP server tree.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")             -- [!] Parameter: event - Event table with received request object.
    
    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local objectPath = filesystem.canonical(event[7])
    local fullObjectPath = filesystem.concat(private.serverPaths["dtp_database"], objectPath)
    
    if (filesystem.exists(fullObjectPath) == false) then
      modem.send(responseAddress, port, false, "Object Not Exists")
    elseif (objectPath == '' or objectPath == '/') then
      modem.send(responseAddress, port, false, "Access Denied")
    else
      filesystem.remove(fullObjectPath)
      
      modem.send(responseAddress, port, true, "OK")
    end
  end
  
  private.doObjectRename = function(self, event)                                                                    -- [!] Function: doObjectRename(event) - Changes name of the specified object (table or entire directory) in server file tree.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")                                   -- [!] Parameter: event - Event table with received request object.
    
    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local objectPath = filesystem.canonical(event[7])
    local newName = event[8]
    local fullObjectPath = filesystem.concat(private.serverPaths["dtp_database"], objectPath)
    
    if (filesystem.exists(fullObjectPath) == false) then
      modem.send(responseAddress, port, false, "Object Not Exists")
    elseif (objectPath == '' or objectPath == '/') then
      modem.send(responseAddress, port, false, "Access Denied")
    elseif (newName == nil or xafcoreString:checkControlCharacter(newName) == true
    or xafcoreString:checkSpecialCharacter(newName) == true or xafcoreString:checkWhitespace(newName) == true) then
      modem.send(responseAddress, port, false, "Invalid Object New Name")
    else
      local pathSegments = xafcoreText:split(fullObjectPath, '/')
      local segmentsCount = #pathSegments
      local newObjectPath = ''
      
      for i = 1, segmentsCount - 1 do
        newObjectPath = newObjectPath .. pathSegments[i]
        newObjectPath = newObjectPath .. '/'
      end
      
      newObjectPath = newObjectPath .. newName
      
      if (filesystem.exists(newObjectPath) == true) then
        modem.send(responseAddress, port, false, "New Name Already Occupied")
      else
        filesystem.rename(fullObjectPath, newObjectPath)
        
        modem.send(responseAddress, port, true, "OK")
      end
    end
  end
  
  private.doTableCreate = function(self, event)                                                                         -- [!] Function: doTableCreate(event) - Creates new database node - a single table file which stores key-value pairs.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")                                       -- [!] Parameter: event - Event table with received request object.
    
    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local directoryPath = filesystem.canonical(event[7])
    local tableName = event[8]
    local fullDirectoryPath = filesystem.concat(private.serverPaths["dtp_database"], directoryPath)
    local fullTablePath = filesystem.concat(fullDirectoryPath, tableName)
    
    if (filesystem.exists(fullDirectoryPath) == false) then
      modem.send(responseAddress, port, false, "Directory Not Exists")
    elseif (filesystem.exists(fullTablePath) == true) then
      modem.send(responseAddress, port, false, "Table Already Exists")
    elseif (tableName == nil or xafcoreString:checkControlCharacter(tableName) == true
    or xafcoreString:checkSpecialCharacter(tableName) == true or xafcoreString:checkWhitespace(tableName) == true) then
      modem.send(responseAddress, port, false, "Invalid Table Name")
    else
      filesystem.open(fullTablePath, 'w'):close()
      
      modem.send(responseAddress, port, true, "OK")
    end
  end
  
  private.prepareWorkspace = function(self, rootPath)                                                                             -- [!] Function: prepareWorkspace(rootPath) - Prepares and initializes the workspace for DTP server.
    assert(type(rootPath) == "string", "[XAF Network] Expected STRING as argument #1")                                            -- [!] Parameter: rootPath - Workspace root path string.
                                                                                                                                  -- [!] Return: 'true' - If the workspace has been prepared and initialized successfully.
    private.serverPaths["dtp_root"] = rootPath
    private.serverPaths["dtp_database"] = filesystem.concat(private.serverPaths["dtp_root"], private.serverPaths["dtp_database"])
    
    if (filesystem.exists(private.serverPaths["dtp_root"]) == false) then
      filesystem.makeDirectory(private.serverPaths["dtp_root"])
    end
    
    if (filesystem.exists(private.serverPaths["dtp_database"]) == false) then
      filesystem.makeDirectory(private.serverPaths["dtp_database"])
    end
    
    return true
  end
  
  public.process = function(self, event)                                             -- [!] Function: process(event) - Processes received request object.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")    -- [!] Parameter: event - Event table with request object from 'event.pull()' function in OC Event API.
                                                                                     -- [!] Return: status, ... - Request procession status ('false' in case of receiving unknown request type, in otherwise 'true') and potential return values.
    local modem = private.componentModem
    local port = private.port
    local address = modem.address
    
    if (private.active == true) then
      if (modem) then
        if (event[1] == "modem_message") then
          if (event[2] == address and event[4] == port) then
            local requestName = event[6]
            
            if (requestName == "DTP_DATA_GET") then
              return true, private:doDataGet(event)
            elseif (requestName == "DTP_DATA_SET") then
              return true, private:doDataSet(event)
            elseif (requestName == "DTP_DIRECTORY_CREATE") then
              return true, private:doDirectoryCreate(event)
            elseif (requestName == "DTP_OBJECT_MOVE") then
              return true, private:doObjectMove(event)
            elseif (requestName == "DTP_OBJECT_REMOVE") then
              return true, private:doObjectRemove(event)
            elseif (requestName == "DTP_OBJECT_RENAME") then
              return true, private:doObjectRename(event)
            elseif (requestName == "DTP_TABLE_CREATE") then
              return true, private:doTableCreate(event)
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

function DtpServer:extend()
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

function DtpServer:new(modem, rootPath)
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

return DtpServer
