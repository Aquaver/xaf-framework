# XAF Module - Network:REPServer

Another module that allows creating custom networks and managing them, but this class is a little different. It connects the logical side of the network and its control side - because it could be used as a terminal. Generally this protocol, called Remote Executor Protocol implements mechanisms for executing any scripts and programs stored on REP server disk and obviously sending or retrieving parameters to it and from it. This class possesses function only related with this protocol, so if you need to get functionalities for exchaning script sources between computers, you will need to use FTP protocol too, and connect it with this one to work properly.

## Class documentation

* **Class name -** `Generic REP Server`, **instantiable -** `true`, **inheritable -** `true`
* **Static fields**

  * *no static fields*

* **Constructor -** `REPServer:new(modem, rootPath)`
* **Dependencies -** `Core:XAFCore`, `Network:Server`

## Network documentation

* **Accepted requests**

  * **Request name -** `REP_EXECUTE`, **parameters -** `string: scriptPath, ...`
  * **Request name -** `REP_EXECUTE_ABSOLUTE`, **parameters -** `string: scriptPath, ...`
  * **Request name -** `REP_EXECUTE_COMMAND`, **parameters -** `string: commandName, ...`
  * **Request name -** `REP_EXECUTE_NO_PROTECT`, **parameters -** `string: scriptPath, ...`
  * **Request name -** `REP_EXECUTE_NO_RETURN`, **parameters -** `string: scriptPath, ...`
  * **Request name -** `REP_SCRIPT_LIST`, **parameters -** *no parameters*

* **Response messages**

  * `Invalid File` - received on attempt to executing path of directory, not a file.
  * `Script Execution Error` - information received when (protected) execution of given script has failed.
  * `Script Not Exists` - message sent on case when the target script does not exist on REP server disk.
  * `OK` - message recevied on proper request made, often with received execution results.

## Method documentation

* *All methods from* `Network:Server`

### Private in-class method documentation

* **Function:** `doExecute(event)` - Tries to execute script with given parameter as path.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `doExecuteAbsolute(event)` - Tries to execute program with given parameter as absolute path in server file tree.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `doExecuteCommand(event)` - Tries to execute given program as shell command from root binaries directory.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `doExecuteNoProtect(event)` - Tries to run program (without default protection) with given parameter as its path - to use with custom execution error handler.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `doExecuteNoReturn(event)` - Tries to execute script with passed path - it does not return result parameters.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `doScriptList(event)` - Retrieves full script list stored on REP server.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `prepareWorkspace(rootPath)` - Initializes the workspace for REP server.

  * **Parameter:** `rootPath` - REP server workspace tree root path string.
  * **Return:** `'true'` - If all required directories have been prepared correctly.

* **Function:** `process(event)` - Captures request and passes its object to proper handling function.

  * **Parameter:** `event` - Event table from OC Event API `event.pull()` function which holds request object.
  * **Return:** `status, ...` - Processing status as boolean flag and additional request values (unless NO_RETURN choosen).
