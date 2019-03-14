# XAF Module - Network:FTPServer

This class implements very important type of protocol - File Transfer Protocol, which is used for moving files from one computer to another in client-server architecture. However, among others implementations in OpenComputers, this one is different because of small, but powerful aspect. This server supports multiple filesystem components (like hard disks or even RAIDs) and logically 'combine' them into a one bigger filesystem filling them evenly. Therefore, it is strongly recommended using filesystem components with the same capacity. Furthermore, that module also supports transferring files that exceed the maximum network modem packet size by sending them in split form automatically. Even if you change the size (which is 8192 bytes by default), the server will adapt to this change. **Important!** The XAF implementation of FTP server is able to transfer files at any length with any maximum packet size but it may result in longer (or shorter) transferring time.

## Class documentation

* **Class name -** `Generic FTP Server`, **instantiable -** `true`, **inheritable -** `true`
* **Static fields**

  * *no static fields*

* **Constructor -** `FTPServer:new(modem, rootPath, addresses)`
* **Dependencies -** `Core:XAFCore`, `Network:Server`

## Network documentation

* **Accepted requests**

  * **Request name -** `FTP_DIRECTORY_CREATE`, **parameters -** `string: directoryPath`, `string: directoryName`
  * **Request name -** `FTP_DIRECTORY_LIST`, **parameters -** `string: directoryPath`
  * **Request name -** `FTP_FILE_DOWNLOAD_CONTINUE`, **parameters -** `string: targetPath`
  * **Request name -** `FTP_FILE_DOWNLOAD_START`, **parameters -** `string: targetPath`
  * **Request name -** `FTP_FILE_MOVE`, **parameters -** `string: moveFile`, `string: movePath`
  * **Request name -** `FTP_FILE_REMOVE`, **parameters -** `string: filePath`
  * **Request name -** `FTP_FILE_RENAME`, **parameters -** `string: filePath`, `string: newName`
  * **Request name -** `FTP_FILE_UPLOAD_CONTINUE`, **parameters -** `string: fileName`, `string: fileDataChunk`
  * **Request name -** `FTP_FILE_UPLOAD_START`, **parameters -** `string: directoryPath`, `string: fileName`
  * **Request name -** `FTP_FILE_UPLOAD_STOP`, **parameters -** `string: directoryPath`, `string: fileName`

* **Response messages**

  * `Access Denied` - message received when trying to breach (remove or rename) server root directory.
  * `Directory Already Exists` - got on attempt to creating new directory which already exists.
  * `Directory Not Exists` - received on trying to upload a file to target directory which does not exist.
  * `File Already Exists` - message received in attempt to upload a file to directory, in which there is another file with the same name.
  * `File Buffer Already Exists` - sent by server when try to send a file when the buffer is currently open for another one (sending more than one file simultaneously).
  * `File Buffer Not Exists` - received as response when client tries to 'continue sending' file, which has not been 'started' - its buffer is closed.
  * `File Not Exists` - generic message got on attempt to do something (move, remove, rename) with file, which does not exist.
  * `Invalid Directory Name` - sent by server as response on trying to create directory with invalid name (containing special or control characters) or just `nil` name.
  * `Invalid File` - message received when trying to download a entire directory (not a plain file).
  * `Invalid File Name` - message got on attempt to upload a file with invalid name given (the same as in case of directories).
  * `Invalid File New Name` - message sent as response on try to rename a file to new name which contains invalid characters.
  * `New Name Already Occupied` - received when trying to rename a file with name, that was being used by another file (or directory).
  * `Path Is Not A Directory` - sent by server on attempt to move, view list (or upload) a file to target path, that is not a directory - sending file 'to file'.
  * `Path Not Exists` - another generic message received when trying to create directory into on path, which does not exist.
  * `XAF Version Mismatch` - sent on XAF versions incompatibility on server and client machines.
  * `OK` - message received on proper request.
  * `OK (Next)` - special case message received when 'continue downloading' but there is more data assigned to this file in server's buffer. That means you should do downloading request again to get entire file.
  * `OK (Stop)` - special case message received on 'continue downloading' while there is **no** more data in its buffer - file has been completely transferred.

## Method documentation

* *All methods from* `Network:Server`
* **Function:** `process(event)` - Receives the request and processes it.

  * **Parameter:** `event` - Event table from 'event.pull()' function in OC Event API, with request object.
  * Return: status, ... - Request procession status ('true' if it has been processed properly or 'false' when server has received unknown request type) and potential return values.

### Private in-class method documentation

* **Function:** `doDirectoryCreate(event)` - Creates new directory in FTP workspace tree.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `doDirectoryList(event)` - Retrieves list of files and directories in given path.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `doFileDownloadContinue(event)` - Sends file chunk to receiver and closes the buffer if file end has been reached.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `doFileDownloadStart(event)` - Prepares the target file for downloading by creating its buffer (concerning maximum network packet size).

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `doFileMove(event)` - Moves specified file to new target directory.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `doFileRemove(event)` - Removes the specified file from FTP server workspace.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `doFileRename(event)` - Renames an existing file on FTP server to its new name.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `doFileUploadContinue(event)` - Continues uploading a file by sending its single chunk. This operation should be repeated until entire file has been transferred.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `doFileUploadStart(event)` - Prepares new file stream by checking conditions and creating it.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `doFileUploadStop(event)` - Concatenates file data from buffer and creates the files evenly on all server filesystem components.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `prepareWorkspace(rootPath)` - Sets the server root workspace path and creates all missing directories.

  * **Parameter:** `rootPath` - Root path of the server's workspace.
  * **Return:** `'true'` - If the workspace has been set properly.

* **Function:** `setWorkspace(addresses)` - Sets the FTP server workspace filesystem components addresses map.

  * **Parameter:** `addresses` - Table with filesystem components addresses.
  * **Return:** `'true'` - If the workspace map has been set without errors.
