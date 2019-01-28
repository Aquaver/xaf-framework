------------------------------------
-- XAF Module - Network:FTPServer --
------------------------------------
-- [>] This class represents the most simple implementation of server-sided File Transfer Protocol service.
-- [>] That module possesses built-in functions that realize all core request types for FTP server.
-- [>] It allows among others file management like moving, removing, renaming, files tree listing, directory creating and obviously two-way file transferring.

local component = require("component")
local filesystem = require("filesystem")
local server = require("xaf/network/server")
local unicode = require("unicode")
local xafcore = require("xaf/core/xafcore")
local xafcoreString = xafcore:getStringInstance()
local xafcoreTable = xafcore:getTableInstance()
local xafcoreText = xafcore:getTextInstance()

local FtpServer = {
  C_NAME = "Generic FTP Server",
  C_INSTANCE = true,
  C_INHERIT = true,

  static = {}
}

function FtpServer:initialize()
  local parent = server:extend()
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}

  private.fileBuffer = {} -- Buffer table which stores file data before uploading on the server.
  private.mountCounter = 0
  private.mountPrefix = "FS:%s"
  private.serverPaths = {}
  private.serverPaths["ftp_root"] = '/'
  private.serverPaths["ftp_storage"] = "FTP_STORAGE"
  private.workspaceMap = {}

  private.doDirectoryCreate = function(self, event)                                                                             -- [!] Function: doDirectoryCreate(event) - Creates new directory in FTP workspace tree.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")                                               -- [!] Parameter: event - Event table with received request object.

    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local directoryPath = filesystem.canonical(event[8])
    local directoryName = event[9]
    local fullDirectoryPath = filesystem.concat(private.serverPaths["ftp_storage"], private.mountPrefix, directoryPath)
    local fullNewDirectoryPath = filesystem.concat(fullDirectoryPath, directoryName)
    local controlMount_fullDirectoryPath = string.format(fullDirectoryPath, 1)
    local controlMount_fullNewDirectoryPath = string.format(fullNewDirectoryPath, 1)

    if (filesystem.exists(controlMount_fullDirectoryPath) == false) then
      modem.send(responseAddress, port, false, "Path Not Exists")
    elseif (filesystem.exists(controlMount_fullNewDirectoryPath) == true) then
      modem.send(responseAddress, port, false, "Directory Already Exists")
    elseif (filesystem.isDirectory(controlMount_fullDirectoryPath) == false) then
      modem.send(responseAddress, port, false, "Path Is Not A Directory")
    elseif (directoryName == nil or xafcoreString:checkControlCharacter(directoryName) == true
    or xafcoreString:checkSpecialCharacter(directoryName) == true or xafcoreString:checkWhitespace(directoryName) == true) then
      modem.send(responseAddress, port, false, "Invalid Directory Name")
    else
      for i = 1, private.mountCounter do
        filesystem.makeDirectory(string.format(fullNewDirectoryPath, i))
      end

      modem.send(responseAddress, port, true, "OK")
    end
  end

  private.doDirectoryList = function(self, event)                                                                       -- [!] Function: doDirectoryList(event) - Retrieves list of files and directories in given path.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")                                       -- [!] Parameter: event - Event table with received request object.

    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local directoryPath = filesystem.canonical(event[8])
    local fullDirectoryPath = filesystem.concat(private.serverPaths["ftp_storage"], private.mountPrefix, directoryPath)
    local controlMount_fullDirectoryPath = string.format(fullDirectoryPath, 1)

    if (filesystem.exists(controlMount_fullDirectoryPath) == false) then
      modem.send(responseAddress, port, false, "Path Not Exists")
    elseif (filesystem.isDirectory(controlMount_fullDirectoryPath) == false) then
      modem.send(responseAddress, port, false, "Path Is Not A Directory")
    else
      local tableDirectories = {}
      local tableFiles = {}
      local stringDirectories = '/'
      local stringFiles = '/'

      for itemPath in filesystem.list(controlMount_fullDirectoryPath) do
        if (string.sub(itemPath, -1, -1) == '/') then
          tableDirectories[itemPath] = 0
        else
          tableFiles[itemPath] = 0
        end
      end

      for key, value in xafcoreTable:sortByKey(tableDirectories, false) do
        stringDirectories = stringDirectories .. string.sub(key, 1, -2) .. '/'
      end

      for key, value in xafcoreTable:sortByKey(tableFiles, false) do
        stringFiles = stringFiles .. key .. '/'
      end

      modem.send(responseAddress, port, true, "OK", stringDirectories, stringFiles)
    end
  end

  private.doFileDownloadContinue = function(self, event)                                                          -- [!] Function: doFileDownloadContinue(event) - Sends file chunk to receiver and closes the buffer if file end has been reached.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")                                 -- [!] Parameter: event - Event table with received request object.

    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local targetPath = filesystem.canonical(event[8])
    local fullTargetPath = filesystem.concat(private.serverPaths["ftp_storage"], private.mountPrefix, targetPath)

    if (private.fileBuffer[responseAddress]) then
      if (private.fileBuffer[responseAddress]["file_path"] == fullTargetPath) then
        local data = private.fileBuffer[responseAddress]["file_data"][1]
        local dataNext = private.fileBuffer[responseAddress]["file_data"][2]

        if (dataNext) then
          table.remove(private.fileBuffer[responseAddress]["file_data"], 1)
          modem.send(responseAddress, port, true, "OK (Next)", data)
        else
          private.fileBuffer[responseAddress] = nil
          modem.send(responseAddress, port, true, "OK (Stop)", data)
        end
      else
        modem.send(responseAddress, port, false, "File Buffer Already Exists")
      end
    else
      modem.send(responseAddress, port, false, "File Buffer Not Exists")
    end
  end

  private.doFileDownloadStart = function(self, event)                                                             -- [!] Function: doFileDownloadStart(event) - Prepares the target file for downloading by creating its buffer (concerning maximum network packet size).
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")                                 -- [!] Parameter: event - Event table with received request object.

    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local targetPath = filesystem.canonical(event[8])
    local fullTargetPath = filesystem.concat(private.serverPaths["ftp_storage"], private.mountPrefix, targetPath)
    local controlMount_fullTargetPath = string.format(fullTargetPath, 1)

    if (filesystem.exists(controlMount_fullTargetPath) == false) then
      modem.send(responseAddress, port, false, "File Not Exists")
    elseif (filesystem.isDirectory(controlMount_fullTargetPath) == true) then
      modem.send(responseAddress, port, false, "Invalid File")
    elseif (targetPath == '' or targetPath == '/') then
      modem.send(responseAddress, port, false, "Access Denied")
    else
      local headerBytes = 19
      local maxChunkLength = modem.maxPacketSize() - headerBytes -- Max chunk length counts additional bytes required to send the packet.
      local entireFileData = ''

      private.fileBuffer[responseAddress] = {}
      private.fileBuffer[responseAddress]["file_path"] = fullTargetPath
      private.fileBuffer[responseAddress]["file_data"] = {}

      for i = 1, private.mountCounter do
        local filePath = string.format(fullTargetPath, i)
        local fileObject = filesystem.open(filePath, 'r')
        local singleFileData = ''

        while (singleFileData) do
          entireFileData = entireFileData .. singleFileData
          singleFileData = fileObject:read(math.huge)
        end

        fileObject:close()
      end

      for i = 1, unicode.wlen(entireFileData), maxChunkLength do
        local startIndex = i
        local endIndex = i + maxChunkLength - 1
        local fileChunk = string.sub(entireFileData, startIndex, endIndex)

        table.insert(private.fileBuffer[responseAddress]["file_data"], fileChunk)
      end

      modem.send(responseAddress, port, true, "OK")
    end
  end

  private.doFileMove = function(self, event)                                                                  -- [!] Function: doFileMove(event) - Moves specified file to new target directory.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")                             -- [!] Parameter: event - Event table with received request object.

    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local moveFile = filesystem.canonical(event[8])
    local movePath = filesystem.canonical(event[9])
    local fullMoveFile = filesystem.concat(private.serverPaths["ftp_storage"], private.mountPrefix, moveFile)
    local fullMovePath = filesystem.concat(private.serverPaths["ftp_storage"], private.mountPrefix, movePath)
    local controlMount_fullMoveFile = string.format(fullMoveFile, 1)
    local controlMount_fullMovePath = string.format(fullMovePath, 1)

    if (filesystem.exists(controlMount_fullMoveFile) == false) then
      modem.send(responseAddress, port, false, "File Not Exists")
    elseif (filesystem.exists(controlMount_fullMovePath) == false) then
      modem.send(responseAddress, port, false, "Path Not Exists")
    elseif (filesystem.isDirectory(controlMount_fullMovePath) == false) then
      modem.send(responseAddress, port, false, "Path Is Not A Directory")
    elseif (moveFile == '' or moveFile == '/') then
      modem.send(responseAddress, port, false, "Access Denied")
    else
      local pathSegments = xafcoreText:split(fullMoveFile, '/')
      local segmentsCount = #pathSegments
      local fileName = pathSegments[segmentsCount]
      local newFilePath = filesystem.concat(fullMovePath, fileName)

      for i = 1, private.mountCounter do
        filesystem.rename(string.format(fullMoveFile, i), string.format(newFilePath, i))
      end

      modem.send(responseAddress, port, true, "OK")
    end
  end

  private.doFileRemove = function(self, event)                                                                -- [!] Function: doFileRemove(event) - Removes the specified file from FTP server workspace.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")                             -- [!] Parameter: event - Event table with received request object.

    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local filePath = filesystem.canonical(event[8])
    local fullFilePath = filesystem.concat(private.serverPaths["ftp_storage"], private.mountPrefix, filePath)
    local controlMount_fullFilePath = string.format(fullFilePath, 1)

    if (filesystem.exists(controlMount_fullFilePath) == false) then
      modem.send(responseAddress, port, false, "File Not Exists")
    elseif (filePath == '' or filePath == '/') then
      modem.send(responseAddress, port, false, "Access Denied")
    else
      for i = 1, private.mountCounter do
        filesystem.remove(string.format(fullFilePath, i))
      end

      modem.send(responseAddress, port, true, "OK")
    end
  end

  private.doFileRename = function(self, event)                                                                      -- [!] Function: doFileRename(event) - Renames an existing file on FTP server to its new name.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")                                   -- [!] Parameter: event - Event table with received request object.

    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local filePath = filesystem.canonical(event[8])
    local newName = event[9]
    local fullFilePath = filesystem.concat(private.serverPaths["ftp_storage"], private.mountPrefix, filePath)
    local controlMount_fullFilePath = string.format(fullFilePath, 1)

    if (filesystem.exists(controlMount_fullFilePath) == false) then
      modem.send(responseAddress, port, false, "File Not Exists")
    elseif (filePath == '' or filePath == '/') then
      modem.send(responseAddress, port, false, "Access Denied")
    elseif (newName == nil or xafcoreString:checkControlCharacter(newName) == true
    or xafcoreString:checkSpecialCharacter(newName) == true or xafcoreString:checkWhitespace(newName) == true) then
      modem.send(responseAddress, port, false, "Invalid File New Name")
    else
      local pathSegments = xafcoreText:split(fullFilePath, '/')
      local segmentsCount = #pathSegments
      local newFilePath = ''
      local controlMount_newFilePath = ''

      for i = 1, segmentsCount - 1 do
        newFilePath = newFilePath .. pathSegments[i]
        newFilePath = newFilePath .. '/'
      end

      newFilePath = newFilePath .. newName
      controlMount_newFilePath = string.format(newFilePath, 1)

      if (filesystem.exists(controlMount_newFilePath) == true) then
        modem.send(responseAddress, port, false, "New Name Already Occupied")
      else
        for i = 1, private.mountCounter do
          filesystem.rename(string.format(fullFilePath, i), string.format(newFilePath, i))
        end

        modem.send(responseAddress, port, true, "OK")
      end
    end
  end

  private.doFileUploadContinue = function(self, event)                                             -- [!] Function: doFileUploadContinue(event) - Continues uploading a file by sending its single chunk. This operation should be repeated until entire file has been transferred.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")                  -- [!] Parameter: event - Event table with received request object.

    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local directoryPath = filesystem.canonical(event[8])
    local fileName = event[9]
    local fileDataChunk = event[10]
    local fullDirectoryPath = filesystem.concat(private.serverPaths["ftp_storage"], private.mountPrefix, directoryPath)
    local fullFilePath = filesystem.concat(fullDirectoryPath, fileName)

    if (private.fileBuffer[responseAddress]) then
      if (private.fileBuffer[responseAddress]["file_path"] == fullFilePath) then
        table.insert(private.fileBuffer[responseAddress]["file_data"], fileDataChunk)

        modem.send(responseAddress, port, true, "OK")
      else
        modem.send(responseAddress, port, false, "File Buffer Already Exists")
      end
    else
      modem.send(responseAddress, port, false, "File Buffer Not Exists")
    end
  end

  private.doFileUploadStart = function(self, event)                                                                     -- [!] Function: doFileUploadStart(event) - Prepares new file stream by checking conditions and creating it.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")                                       -- [!] Parameter: event - Event table with received request object.

    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local directoryPath = filesystem.canonical(event[8])
    local fileName = event[9]
    local fullDirectoryPath = filesystem.concat(private.serverPaths["ftp_storage"], private.mountPrefix, directoryPath)
    local fullFilePath = filesystem.concat(fullDirectoryPath, fileName)
    local controlMount_fullDirectoryPath = string.format(fullDirectoryPath, 1)
    local controlMount_fullFilePath = string.format(fullFilePath, 1)

    if (filesystem.exists(controlMount_fullDirectoryPath) == false) then
      modem.send(responseAddress, port, false, "Directory Not Exists")
    elseif (filesystem.exists(controlMount_fullFilePath) == true) then
      modem.send(responseAddress, port, false, "File Already Exists")
    elseif (fileName == nil or xafcoreString:checkControlCharacter(fileName) == true
    or xafcoreString:checkSpecialCharacter(fileName) == true or xafcoreString:checkWhitespace(fileName) == true) then
      modem.send(responseAddress, port, false, "Invalid File Name")
    else
      for i = 1, private.mountCounter do
        filesystem.open(string.format(fullFilePath, i), 'w'):close()
      end

      private.fileBuffer[responseAddress] = {}
      private.fileBuffer[responseAddress]["file_path"] = fullFilePath
      private.fileBuffer[responseAddress]["file_data"] = {}

      modem.send(responseAddress, port, true, "OK")
    end
  end

  private.doFileUploadStop = function(self, event)                                                                      -- [!] Function: doFileUploadStop(event) - Concatenates file data from buffer and creates the files evenly on all server filesystem components.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")                                       -- [!] Parameter: event - Event table with received request object.

    local modem = private.componentModem
    local port = private.port
    local responseAddress = event[3]
    local directoryPath = filesystem.canonical(event[8])
    local fileName = event[9]
    local fullDirectoryPath = filesystem.concat(private.serverPaths["ftp_storage"], private.mountPrefix, directoryPath)
    local fullFilePath = filesystem.concat(fullDirectoryPath, fileName)

    if (private.fileBuffer[responseAddress]) then
      if (private.fileBuffer[responseAddress]["file_path"] == fullFilePath) then
        local fileChunks = private.fileBuffer[responseAddress]["file_data"]
        local fileData = ''

        for i = 1, #fileChunks do
          fileData = fileData .. fileChunks[i]
        end

        if (unicode.wlen(fileData) >= private.mountCounter) then
          local chunkSize = math.ceil(unicode.wlen(fileData) / private.mountCounter)

          for i = 1, private.mountCounter do
            local fileChunkPath = string.format(fullFilePath, i)
            local fileChunkObject = filesystem.open(fileChunkPath, 'w')

            fileChunkObject:write(string.sub(fileData, 1 + (i - 1) * chunkSize, chunkSize + (i - 1) * chunkSize))
            fileChunkObject:close()
          end
        else
          for i = 1, unicode.wlen(fileData) do
            local fileChunkPath = string.format(fullFilePath, i)
            local fileChunkObject = filesystem.open(fileChunkPath, 'w')

            fileChunkObject:write(string.sub(fileData, i, i))
            fileChunkObject:close()
          end

          for i = unicode.wlen(fileData) + 1, private.mountCounter do
            local fileChunkPath = string.format(fullFilePath, i)
            local fileChunkObject = filesystem.open(fileChunkPath, 'w')

            fileChunkObject:close()
          end
        end

        private.fileBuffer[responseAddress] = nil
        modem.send(responseAddress, port, true, "OK")
      else
        modem.send(responseAddress, port, false, "File Buffer Already Exists")
      end
    else
      modem.send(responseAddress, port, false, "File Buffer Not Exists")
    end
  end

  private.prepareWorkspace = function(self, rootPath)                                                                           -- [!] Function: prepareWorkspace(rootPath) - Sets the server root workspace path and creates all missing directories.
    assert(type(rootPath) == "string", "[XAF Network] Expected STRING as argument #1")                                          -- [!] Parameter: rootPath - Root path of the server's workspace.
                                                                                                                                -- [!] Return: 'true' - If the workspace has been set properly.
    private.serverPaths["ftp_root"] = rootPath
    private.serverPaths["ftp_storage"] = filesystem.concat(private.serverPaths["ftp_root"], private.serverPaths["ftp_storage"])

    if (filesystem.exists(private.serverPaths["ftp_root"]) == false) then
      filesystem.makeDirectory(private.serverPaths["ftp_root"])
    end

    if (filesystem.exists(private.serverPaths["ftp_storage"]) == false) then
      filesystem.makeDirectory(private.serverPaths["ftp_storage"])
    end

    return true
  end

  private.setWorkspace = function(self, addresses)                                         -- [!] Function: setWorkspace(addresses) - Sets the FTP server workspace filesystem components addresses map.
    assert(type(addresses) == "table", "[XAF Network] Expected TABLE as argument #1")      -- [!] Parameter: addresses - Table with filesystem components addresses.
                                                                                           -- [!] Return: 'true' - If the workspace map has been set without errors.
    local rawAddresses = addresses
    local unsortedAddresses = {}
    local sortedAddresses = {}

    for key, value in pairs(rawAddresses) do
      unsortedAddresses[value] = 0
    end

    for key, value in xafcoreTable:sortByKey(unsortedAddresses, false) do
      local componentAddress = key
      local componentType = component.type(componentAddress)

      if (componentType == "filesystem") then
        table.insert(sortedAddresses, componentAddress)
      else
        error("[XAF Error] Invalid filesystem component")
      end
    end

    for i = 1, #sortedAddresses do
      local mountAddress = sortedAddresses[i]
      local mountPrefix = string.format(private.mountPrefix, i)
      local mountPath = filesystem.concat(private.serverPaths["ftp_storage"], mountPrefix)

      filesystem.mount(mountAddress, mountPath)
    end

    private.mountCounter = #sortedAddresses
    private.workspaceMap = sortedAddresses
    return true
  end

  public.process = function(self, event)                                             -- [!] Function: process(event) - Receives the request and processes it.
    assert(type(event) == "table", "[XAF Network] Expected TABLE as argument #1")    -- [!] Parameter: event - Event table from 'event.pull()' function in OC Event API, with request object.
                                                                                     -- [!] Return: status, ... - Request procession status ('true' if it has been processed properly or 'false' when server has received unknown request type) and potential return values.
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
              if (requestName == "FTP_DIRECTORY_CREATE") then
                return true, private:doDirectoryCreate(event)
              elseif (requestName == "FTP_DIRECTORY_LIST") then
                return true, private:doDirectoryList(event)
              elseif (requestName == "FTP_FILE_DOWNLOAD_CONTINUE") then
                return true, private:doFileDownloadContinue(event)
              elseif (requestName == "FTP_FILE_DOWNLOAD_START") then
                return true, private:doFileDownloadStart(event)
              elseif (requestName == "FTP_FILE_MOVE") then
                return true, private:doFileMove(event)
              elseif (requestName == "FTP_FILE_REMOVE") then
                return true, private:doFileRemove(event)
              elseif (requestName == "FTP_FILE_RENAME") then
                return true, private:doFileRename(event)
              elseif (requestName == "FTP_FILE_UPLOAD_CONTINUE") then
                return true, private:doFileUploadContinue(event)
              elseif (requestName == "FTP_FILE_UPLOAD_START") then
                return true, private:doFileUploadStart(event)
              elseif (requestName == "FTP_FILE_UPLOAD_STOP") then
                return true, private:doFileUploadStop(event)
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

function FtpServer:extend()
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

function FtpServer:new(modem, rootPath, addresses)
  local class = self:initialize()
  local private = class.private
  local public = class.public

  public:setModem(modem)
  assert(type(rootPath) == "string", "[XAF Network] Expected STRING as argument #2")
  private:prepareWorkspace(rootPath)
  assert(type(addresses) == "table", "[XAF Network] Expected TABLE as argument #3")
  private:setWorkspace(addresses)

  if (self.C_INSTANCE == true) then
    return public
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be instanced")
  end
end

return FtpServer
