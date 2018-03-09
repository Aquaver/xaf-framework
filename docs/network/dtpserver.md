# XAF Module - Network:DTPServer

Another XAF built-in useful network protocol called Data Transfer Protocol. In contrast to other implemented protocols like DNS or FTP, this is not present in real world. In few simple words, that module provides something like 'remote key-value database'. Its workspace may contain sub-directories (which could have more sub-directories itself) and data table files. Each file separates serialized table (by XAF's saving/reading mechanism - not OC's) which in turn contains its key-value pairs. Building network that uses DTP might be very useful, in particular for simple database which stores data that may be used by more computers. That module comes with few functions which are responsible for mechanisms related to this protocol.

## Class documentation

* **Class name -** `Generic DTP Server`, **instantiable -** `true`, **inheritable -** `true`
* **Static fields**

  * *no static fields*

* **Constructor -** `DtpServer:new(modem, rootPath)`
* **Dependencies -** `Core:XAFCore`, `Network:Server`

## Network documentation

* **Accepted requests**

  * **Request name -** `DTP_DATA_GET`, **parameters -** `string: tablePath`, `anything: dataKey`
  * **Request name -** `DTP_DATA_SET`, **parameters -** `string: tablePath`, `anything: dataKey`, `anything or nil: dataValue`
  * **Request name -** `DTP_DIRECTORY_CREATE`, **parameters -** `string: directoryPath`, `string: directoryName`
  * **Request name -** `DTP_OBJECT_MOVE`, **parameters -** `string: moveObject`, `string: movePath`
  * **Request name -** `DTP_OBJECT_REMOVE`, **parameters -** `string: objectPath`
  * **Request name -** `DTP_OBJECT_RENAME`, **parameters -** `string: objectPath`, `string: newName`
  * **Request name -** `DTP_TABLE_CREATE`, **parameters -** `string: directoryPath`, `string: tableName`

* **Response messages**

  * `Access Denied` - received on attempt to breach (remove or rename) server root directory.
  * `Directory Already Exists` - message got in response on trying to create directory in the same place as another with identical name.
  * `Directory Not Exists` - sent by server when client tries to create table or to move an object into directory which does not exist.
  * `Invalid Directory Name` - message received on creating directory contains prohibited character(s) like special characters, whitespace or control character (ASCII 0 - 31).
  * `Invalid Object New Name` - feedback sent by server on attempt to rename object to name, which contains prohibited characters.
  * `Invalid Table File` - message received on attempting to working with table related mechanisms (data get/set) on a directory.
  * `New Name Already Occupied` - received when renaming an object to name, which was currently used by another one in the same place.
  * `Nil Data Key` - sent by server in special case - when trying to get or set data to table while giving `nil` as data key.
  * `Object Not Exists` - message sent by server in response on attempt to removing or renaming object that does not exist.
  * `Path Is Not A Directory` - received on trying to move another object to file which is not a directory.
  * `Path Not Exists` - generic message received on trying to work with path does not exist.
  * `Table Already Exists` - feedback got when creating new table with name that was currently used by another table in directory.
  * `Table Not Exists` - message got on using table mechanisms (data get/set) on table that does not exist.
  * `OK` - received as response on proper request.

## Method documentation

* *All methods from* `Network:Server`

* **Function:** `process(event)` - Processes received request object.

  * **Parameter:** `event` - Event table with request object from 'event.pull()' function in OC Event API.
  * **Return:** `status`, `...` - Request procession status ('false' in case of receiving unknown request type, in otherwise 'true') and potential return values.

### Private in-class method documentation

* **Function:** `doDataGet(event)` - Returns the data value from specified table by its key.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `doDataSet(event)` - Changes or sets new data value in specified table by its key.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `doDirectoryCreate(event)` - Creates new directory in DTP server tree.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `doObjectMove(event)` - Moves specified object (table or entire directory) to new directory.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `doObjectRemove(event)` - Removes selected object (table or entire directory) from DTP server tree.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `doObjectRename(event)` - Changes name of the specified object (table or entire directory) in server file tree.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `doTableCreate(event)` - Creates new database node - a single table file which stores key-value pairs.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `prepareWorkspace(rootPath)` - Prepares and initializes the workspace for DTP server.

  * **Parameter:** `rootPath` - Workspace root path string.
  * **Return:** `'true'` - If the workspace has been prepared and initialized successfully.
