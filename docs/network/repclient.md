# XAF Module - Network:REPClient

This class is a simple client side representation of Remote Executor Protocol mechanisms that let the user performing scripts and programs on distant computer and receiving arguments through the network. It contains all functions that provide primary methods of communication and execution on target REP server computer. That module generally allows executing programs, passing arguments and script listing.

## Class documentation

* **Class name -** `Generic REP Client`, **instantiable -** `true`, **inheritable -** `true`
* **Static fields**

  * *no static fields*

* **Constructor -** `REPClient:new(modem)`
* **Dependencies -** `Core:XAFCore`, `Network:Client`

## Method documentation

* *All methods from* `Network:Client`
* **Function:** `execute(scriptPath, ...)` - Sends 'REP_EXECUTE' request type to the REP server.

  * **Parameter:** `scriptPath` - Relative path of script to be parformed.
  * **Parameter:** `...` - Optional arguments passed to the target program.
  * **Return:** `...` - Boolean flag of request status and optional returned arguments from executed script.

* **Function:** `executeAbsolute(scriptPath, ...)` - Sends 'REP_EXECUTE_ABSOLUTE' request type to the REP server.

  * **Parameter:** `scriptPath` - Absolute path of the script to be execute, in entire server file tree.
  * **Parameter:** `...` - Optional arguments passed to the targed script.
  * **Return:** `...` - Boolean flag of request procession and optional returned values from performed program.

* **Function:** `executeCommand(scriptCommand, ...)` - Sends 'REP_EXECUTE_COMMAND' request type to REP server.

  * **Parameter:** `scriptCommand` - Name of given command to execute on the server.
  * **Parameter:** `...` - Optional arguments passed to the command.
  * **Return:** `...` - Response status and its message - this function does not return any values from execution.

* **Function:** `executeNoProtect(scriptPath, ...)` - Sends 'REP_EXECUTE_NO_PROTECT' request to the target REP server.

  * **Parameter:** `scriptPath` - Relative path of target script to be executed.
  * **Parameter:** `...` - Optional argument list passed to the script.
  * **Return:** `...` - Boolean flag of exeution status and optional returned argument list.

* **Function:** `executeNoReturn(scriptPath, ...)` - Sends 'REP_EXECUTE_NO_RETURN' request to target REP server.

  * **Parameter:** `scriptPath` - Relative path of script to execute.
  * **Parameter:** `...` - Argument list passed to the target script.
  * **Return:** `...` - Response status and its message - no execution results returned from the response.

* **Function:** `scriptList()` - Sends 'REP_SCRIPT_LIST' request type to the target REP server.

  * **Return:** `responseStatus, responseMessage, scriptTable` - Response status, message and retrieved full script list as Lua table.
