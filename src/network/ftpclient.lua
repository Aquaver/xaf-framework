------------------------------------
-- XAF Module - Network:FTPClient --
------------------------------------
-- [>] That class responses for client side communication of File Transfer Protocol.
-- [>] It implements all functions that are able to perform needed request types.
-- [>] As the FTP server, this module also supports transferring files with any length (concerning transferring time).

local client = require("xaf/network/client")
local filesystem = require("filesystem")
local unicode = require("unicode")
local xafcore = require("xaf/core/xafcore")
local xafcoreText = xafcore:getTextInstance()

local FtpClient = {
  C_NAME = "Generic FTP Client",
  C_INSTANCE = true,
  C_INHERIT = true,

  static = {}
}

function FtpClient:initialize()
  local parent = client:extend()
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}

  public.directoryCreate = function(self, path, name)                                   -- [!] Function: directoryCreate(path, name) - Sends 'FTP_DIRECTORY_CREATE' to the FTP server.
    assert(type(path) == "string", "[XAF Network] Expected STRING as argument #1")      -- [!] Parameter: path - Path to parent directory, in which the new directory will be created.
    assert(type(name) == "string", "[XAF Network] Expected STRING as argument #2")      -- [!] Parameter: name - Name of new directory.
                                                                                        -- [!] Return: ... - Status and message of performed request.
    local directoryPath = path
    local directoryName = name

    return private:sendRawRequest("FTP_DIRECTORY_CREATE", directoryPath, directoryName)
  end

  public.directoryList = function(self, path)                                                                                       -- [!] Function: directoryList(path) - Sends 'FTP_DIRECTORY_LIST' request to the FTP server.
    assert(type(path) == "string", "[XAF Network] Expected STRING as argument #1")                                                  -- [!] Parameter: path - Path of parent target directory, of whose file list will be retrieved.
                                                                                                                                    -- [!] Return: ... - Status of request, its message and returned list data (on proper request).
    local directoryPath = path
    local tableDirectories = {}
    local tableFiles = {}
    local responseStatus, responseMessage, dataDirectories, dataFiles = private:sendRawRequest("FTP_DIRECTORY_LIST", directoryPath)

    if (responseStatus == false) then
      return responseStatus, responseMessage
    else
      tableDirectories = xafcoreText:split(dataDirectories, '/')
      tableFiles = xafcoreText:split(dataFiles, '/')

      return responseStatus, responseMessage, tableDirectories, tableFiles
    end
  end

  public.fileDownload = function(self, remotePath, localDirectory, localName)                                                  -- [!] Function: fileDownload(remotePath, localDirectory, localName) - Tries to download file from remote FTP server using two types of 'FTP_FILE_DOWNLOAD' request.
    assert(type(remotePath) == "string", "[XAF Network] Expected STRING as argument #1")                                       -- [!] Parameter: remotePath - Full path to file on remote FTP server.
    assert(type(localDirectory) == "string", "[XAF Network] Expected STRING as argument #2")                                   -- [!] Parameter: localDirectory - Absolute path of local directory, to which the file will be downloaded.
    assert(type(localName) == "string", "[XAF Network] Expected STRING as argument #3")                                        -- [!] Parameter: localName - Name of downloaded (created) file with extension.
                                                                                                                               -- [!] Return: ... - Status and returned message of the request.
    local remoteFilePath = remotePath
    local localDirectoryPath = localDirectory
    local localFileName = localName
    local fullFilePath = filesystem.concat(localDirectoryPath, localFileName)

    if (filesystem.exists(localDirectory) == false) then
      error("[XAF Error] Directory '" .. localDirectory .. "' does not exist")
    elseif (filesystem.isDirectory(localDirectory) == false) then
      error("[XAF Error] Path '" .. localDirectory .. "' is not a directory")
    elseif (filesystem.exists(fullFilePath) == true) then
      error("[XAF Error] File '" .. fullFilePath .. "' already exists")
    else
      local fileObject = filesystem.open(fullFilePath, 'w')
      local responseStatus, responseMessage = private:sendRawRequest("FTP_FILE_DOWNLOAD_START", remoteFilePath)

      if (responseStatus == true) then
        local continueStatus = nil
        local continueMessage = ''
        local continueData = ''

        repeat
          continueStatus, continueMessage, continueData = private:sendRawRequest("FTP_FILE_DOWNLOAD_CONTINUE", remoteFilePath)
          fileObject:write(continueData)
        until (continueMessage == "OK (Stop)")

        fileObject:close()
        return continueStatus, continueMessage
      else
        fileObject:close()
        filesystem.remove(fullFilePath)

        return responseStatus, responseMessage
      end
    end
  end

  public.fileMove = function(self, file, path)                                     -- [!] Function: fileMove(file, path) - Sends 'FTP_FILE_MOVE' to the FTP server.
    assert(type(file) == "string", "[XAF Network] Expected STRING as argument #1") -- [!] Parameter: file - Full path to target file, which will be moved.
    assert(type(path) == "string", "[XAF Network] Expected STRING as argument #2") -- [!] Parameter: path - Full path of parent directory, where the file will be moved to.
                                                                                   -- [!] Return: ... - Status flag of request and its message.
    local moveFile = file
    local movePath = path

    return private:sendRawRequest("FTP_FILE_MOVE", moveFile, movePath)
  end

  public.fileRemove = function(self, path)                                         -- [!] Function: fileRemove(path) - Sends 'FTP_FILE_REMOVE' request to the FTP server.
    assert(type(path) == "string", "[XAF Network] Expected STRING as argument #1") -- [!] Parameter: path - Full path to file that will be removed.
                                                                                   -- [!] Return: ... - Boolean status and response message from the server.
    local filePath = path

    return private:sendRawRequest("FTP_FILE_REMOVE", filePath)
  end

  public.fileRename = function(self, path, name)                                   -- [!] Function: fileRename(path, name) - Sends 'FTP_FILE_RENAME' to the FTP server.
    assert(type(path) == "string", "[XAF Network] Expected STRING as argument #1") -- [!] Parameter: path - Path to the file which will be renamed.
    assert(type(name) == "string", "[XAF Network] Expected STRING as argument #2") -- [!] Parameter: name - New name of the file.
                                                                                   -- [!] Return: ... - Request status and feedback message.
    local filePath = path
    local newFileName = name

    return private:sendRawRequest("FTP_FILE_RENAME", filePath, newFileName)
  end

  public.fileUpload = function(self, localPath, remoteDirectory, remoteName)                                                                         -- [!] Function: fileUpload(localPath, remoteDirectory, remoteName) - Tries to upload the file onto FTP server using three types of 'FTP_FILE_UPLOAD' request.
    assert(type(localPath) == "string", "[XAF Network] Expected STRING as argument #1")                                                              -- [!] Parameter: localPath - Absolute path to local file.
    assert(type(remoteDirectory) == "string", "[XAF Network] Expected STRING as argument #2")                                                        -- [!] Parameter: remoteDirectory - Full path to directory on server to which the file will be uploaded.
    assert(type(remoteName) == "string", "[XAF Network] Expected STRING as argument #3")                                                             -- [!] Parameter: remoteName - Full name (with extension) of the file uploaded on the server.
                                                                                                                                                     -- [!] Return: ... - Status of the request (or uploading process) and potential message.
    local localFilePath = localPath
    local remoteDirectoryPath = remoteDirectory
    local remoteFileName = remoteName

    if (filesystem.exists(localFilePath) == false) then
      error("[XAF Error] File '" .. localFilePath .. "' does not exist")
    else
      local fileBuffer = {}
      local fileObject = filesystem.open(localFilePath, 'r')
      local fileData = ''
      local entireFileData = ''
      local headerBytes = 33 + unicode.wlen(remoteDirectoryPath) + unicode.wlen(remoteFileName)
      local maxChunkSize = private.componentModem.maxPacketSize() - headerBytes
      local responseStatus, responseMessage = private:sendRawRequest("FTP_FILE_UPLOAD_START", remoteDirectoryPath, remoteFileName)

      if (responseStatus == true) then
        while (fileData) do
          entireFileData = entireFileData .. fileData
          fileData = fileObject:read(math.huge)
        end

        for i = 1, unicode.wlen(entireFileData), maxChunkSize do
          local startIndex = i
          local endIndex = i + maxChunkSize - 1
          local fileChunk = string.sub(entireFileData, startIndex, endIndex)

          table.insert(fileBuffer, fileChunk)
        end

        while (responseStatus == true and fileBuffer[1]) do
          local chunkData = fileBuffer[1]
          local continueStatus, continueMessage = private:sendRawRequest("FTP_FILE_UPLOAD_CONTINUE", remoteDirectoryPath, remoteFileName, chunkData)

          if (continueStatus == true) then
            table.remove(fileBuffer, 1)
          else
            return continueStatus, continueMessage
          end
        end

        fileObject:close()
        return private:sendRawRequest("FTP_FILE_UPLOAD_STOP", remoteDirectoryPath, remoteFileName)
      else
        fileObject:close()
        return responseStatus, responseMessage
      end
    end
  end

  return {
    private = private,
    public = public
  }
end

function FtpClient:extend()
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

function FtpClient:new(modem)
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

return FtpClient
