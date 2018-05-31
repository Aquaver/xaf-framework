------------------------------------
-- XAF Module - Network:DTPClient --
------------------------------------
-- [>] This class describes the XAF Data Transfer Protocol simple client implementation.
-- [>] It could be used directly but obviously you might reimplement it if needed.
-- [>] That module comes with API which provides sending all request types to the server.

local client = require("xaf/network/client")

local DtpClient = {
  C_NAME = "Generic DTP Client",
  C_INSTANCE = true,
  C_INHERIT = true,
  
  static = {}
}

function DtpClient:initialize()
  local parent = client:extend()
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}
  
  public.dataGet = function(self, path, key)                                       -- [!] Function: dataGet(path, key) - Sends the 'DTP_DATA_GET' request to DTP server.
    assert(type(path) == "string", "[XAF Network] Expected STRING as argument #1") -- [!] Parameter: path - Path of the table file you want to get data from.
    assert(type(key) ~= "nil", "[XAF Network] Expected ANYTHING as argument #2")   -- [!] Parameter: key - Key (index) of specified data value.
                                                                                   -- [!] Return: ... - Status of the request and message or requested data value from the table.
    local tablePath = path
    local dataKey = key
    
    return private:sendRawRequest("DTP_DATA_GET", tablePath, dataKey)
  end
  
  public.dataSet = function(self, path, key, value)                                -- [!] Function: dataSet(path, key, value) - Sends the 'DTP_DATA_SET' request to DTP server.
    assert(type(path) == "string", "[XAF Network] Expected STRING as argument #1") -- [!] Parameter: path - Path of table file you want to save data to.
    assert(type(key) ~= "nil", "[XAF Network] Expected ANYTHING as argument #2")   -- [!] Parameter: key - Data key to save the value.
                                                                                   -- [!] Parameter: value - Data value to be saved.
    local tablePath = path                                                         -- [!] Return: ... - Status of request and responded message.
    local dataKey = key
    local dataValue = value
    
    return private:sendRawRequest("DTP_DATA_SET", tablePath, dataKey, dataValue)
  end
  
  public.directoryCreate = function(self, path, name)                              -- [!] Function: directoryCreate(path, name) - Sends the 'DTP_DIRECTORY_CREATE' request to DTP server.
    assert(type(path) == "string", "[XAF Network] Expected STRING as argument #1") -- [!] Parameter: path - Parent directory path to create new directory into.
    assert(type(name) == "string", "[XAF Network] Expected STRING as argument #2") -- [!] Parameter: name - Name of the new directory.
                                                                                   -- [!] Return: ... - Status of request and feedback message.
    local directoryPath = path
    local directoryName = name
    
    return private:sendRawRequest("DTP_DIRECTORY_CREATE", directoryPath, directoryName)
  end
  
  public.objectMove = function(self, object, directory)                                 -- [!] Function: objectMove(object, directory) - Sends the 'DTP_OBJECT_MOVE' request to DTP server.
    assert(type(object) == "string", "[XAF Network] Expected STRING as argument #1")    -- [!] Parameter: object - Path of the object to move.
    assert(type(directory) == "string", "[XAF Network] Expected STRING as argument #2") -- [!] Parameter: directory - Path of target directory to which the object will be moved.
                                                                                        -- [!] Return: ... - Status and message of the request.
    local objectPath = object
    local directoryPath = directory
    
    return private:sendRawRequest("DTP_OBJECT_MOVE", objectPath, directoryPath)
  end
  
  public.objectRemove = function(self, object)                                       -- [!] Function: objectRemove(object) - Sends the 'DTP_OBJECT_REMOVE' request to DTP server.
    assert(type(object) == "string", "[XAF Network] Expected STRING as argument #1") -- [!] Parameter: object - Path of the object to remove.
                                                                                     -- [!] Return: ... - Status of the request and its feedback message.
    local objectPath = object
    
    return private:sendRawRequest("DTP_OBJECT_REMOVE", objectPath)
  end
  
  public.objectRename = function(self, object, name)                                 -- [!] Function: objectRename(object, name) - Sends the 'DTP_OBJECT_RENAME' request to DTP server.
    assert(type(object) == "string", "[XAF Network] Expected STRING as argument #1") -- [!] Parameter: object - Path to object to rename.
    assert(type(name) == "string", "[XAF Network] Expected STRING as argument #2")   -- [!] Parameter: name - New valid name of the object.
                                                                                     -- [!] Return: ... - Status of request and responded message.
    local objectPath = object
    local newName = name
    
    return private:sendRawRequest("DTP_OBJECT_RENAME", objectPath, newName)
  end
  
  public.tableCreate = function(self, directory, name)                                  -- [!] Function: tableCreate(directory, name) - Sends the 'DTP_TABLE_CREATE' request to DTP server.
    assert(type(directory) == "string", "[XAF Network] Expected STRING as argument #1") -- [!] Parameter: directory - Target directory in which new table will be created.
    assert(type(name) == "string", "[XAF Network] Expected STRING as argument #2")      -- [!] Parameter: name - New table file name.
                                                                                        -- [!] Return: ... - Status of the request and its message.
    local directoryPath = directory
    local tableName = name
    
    return private:sendRawRequest("DTP_TABLE_CREATE", directoryPath, tableName)
  end
  
  return {
    private = private,
    public = public
  }
end

function DtpClient:extend()
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

function DtpClient:new(modem)
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

return DtpClient
