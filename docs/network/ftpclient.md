# XAF Module - Network:FTPClient

Client side version of XAF implemented File Transfer Protocol service. This class comes with all needed functions that are able to perform primary request types for remote file management like moving, removing, renaming, two-way file transferring (uploading and downloading) and obviously directory creating. Setting up and configuring the FTP client is much more simply than it could be imagined. You only need to get your computer's modem component and set the target server address and the client will do the rest. With implemented functions working with remote files is very easy. Moreover, the FTP server is fantastic solution to extend your computer's capacity and keep the files safe in the 'cloud'.

## Class documentation

* **Class name -** `Generic FTP Client`, **instantiable -** `true`, **inheritable -** `true`
* **Static fields**

  * *no static fields*

* **Constructor -** `FTPClient:new(modem)`
* **Dependencies -** `Network:Client`

## Method documentation

* *All methods from* `Network:Client`
* **Function:** `directoryCreate(path, name)` - Sends 'FTP_DIRECTORY_CREATE' to the FTP server.

  * **Parameter:** `path` - Path to parent directory, in which the new directory will be created.
  * **Parameter:** `name` - Name of new directory.
  * **Return:** `...` - Status and message of performed request.

* **Function:** `fileDownload(remotePath, localDirectory, localName)` - Tries to download file from remote FTP server using two types of 'FTP_FILE_DOWNLOAD' request.

  * **Parameter:** `remotePath` - Full path to file on remote FTP server.
  * **Parameter:** `localDirectory` - Absolute path of local directory, to which the file will be downloaded.
  * **Parameter:** `localName` - Name of downloaded (created) file with extension.
  * **Return:** `...` - Status and returned message of the request.

* **Function:** `fileMove(file, path)` - Sends 'FTP_FILE_MOVE' to the FTP server.

  * **Parameter:** `file` - Full path to target file, which will be moved.
  * **Parameter:** `path` - Full path of parent directory, where the file will be moved to.
  * **Return:** `...` - Status flag of request and its message.

* **Function:** `fileRemove(path)` - Sends 'FTP_FILE_REMOVE' request to the FTP server.

  * **Parameter:** `path` - Full path to file that will be removed.
  * **Return:** `...` - Boolean status and response message from the server.

* **Function:** `fileRename(path, name)` - Sends 'FTP_FILE_RENAME' to the FTP server.

  * **Parameter:** `path` - Path to the file which will be renamed.
  * **Parameter:** `name` - New name of the file.
  * **Return:** `...` - Request status and feedback message.

* **Function:** `fileUpload(localPath, remoteDirectory, remoteName)` - Tries to upload the file onto FTP server using three types of 'FTP_FILE_UPLOAD' request.

  * **Parameter:** `localPath` - Absolute path to local file.
  * **Parameter:** `remoteDirectory` - Full path to directory on server to which the file will be uploaded.
  * **Parameter:** `remoteName` - Full name (with extension) of the file uploaded on the server.
  * **Return:** `...` - Status of the request (or uploading process) and potential message.
