# XAF Module - Network:DTPClient

This class is a client for XAF one of built-in network protocols - the DTP object. It provides all required functions for making queries to the server like directory creating, object management (removing, renaming), table creating and data receiving and setting. That module may be directly used in very simple network architectures in order to remote database management. **Important!** This is the client documentation only. If you would like to know more informations about the entire protocol, request types or response messages, you should read documentation about DTP server class.

## Class documentation

* **Class name -** `Generic DTP Client`
* **Static fields**

  * *no static fields*

* **Constructor -** `DTPClient:new(modem)`
* **Dependencies -** `Core:XAFCore`, `Network:Client`

## Method documentation

* *All methods from* `Network:Client`

* **Function:** `dataGet(path, key)` - Sends the 'DTP_DATA_GET' request to DTP server.

  * **Parameter:** `path` - Path of the table file you want to get data from.
  * **Parameter:** `key` - Key (index) of specified data value.
  * **Return:** `...` - Status of the request and message or requested data value from the table.

* **Function:** `dataSet(path, key, value)` - Sends the 'DTP_DATA_SET' request to DTP server.

  * **Parameter:** `path` - Path of table file you want to save data to.
  * **Parameter:** `key` - Data key to save the value.
  * **Parameter:** `value` - Data value to be saved.
  * **Return:** `...` - Status of request and responded message.

* **Function:** `directoryCreate(path, name)` - Sends the 'DTP_DIRECTORY_CREATE' request to DTP server.

  * **Parameter:** `path` - Parent directory path to create new directory into.
  * **Parameter:** `name` - Name of the new directory.
  * **Return:** `...` - Status of request and feedback message.

* **Function:** `objectMove(object, directory)` - Sends the 'DTP_OBJECT_MOVE' request to DTP server.

  * **Parameter:** `object` - Path of the object to move.
  * **Parameter:** `directory` - Path of target directory to which the object will be moved.
  * **Return:** `...` - Status and message of the request.

* **Function:** `objectRemove(object)` - Sends the 'DTP_OBJECT_REMOVE' request to DTP server.

  * **Parameter:** `object` - Path of the object to remove.
  * **Return:** `...` - Status of the request and its feedback message.

* **Function:** `objectRename(object, name)` - Sends the 'DTP_OBJECT_RENAME' request to DTP server.

  * **Parameter:** `object` - Path to object to rename.
  * **Parameter:** `name` - New valid name of the object.
  * **Return:** `...` - Status of request and responded message.

* **Function:** `tableCreate(directory, name)` - Sends the 'DTP_TABLE_CREATE' request to DTP server.

  * **Parameter:** `directory` - Target directory in which new table will be created.
  * **Parameter:** `name` - New table file name.
  * **Return:** `...` - Status of the request and its message.
