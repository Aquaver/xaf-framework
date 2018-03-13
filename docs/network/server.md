# XAF Module - Network:Server

Server module is the top-level class for all servers - passive network components (computers) which response on clients requests. It describes the default behavior for all servers - setting working network modem, port number and starting or stopping. Furthermore, on these two least actions, the server may perform task function (its called initialization or finalization respectively) that allow preparing server to work or for example closes all file handles before stopping and shutting the machine down.

## Class documentation

* **Class name -** `Abstract Network Server`, **instantiable -** `false`, **inheritable -** `true`
* **Static fields**

  * *no static fields*

* **Constructor -** *class is not instantiable - no constructor*
* **Dependencies -** *no dependencies*

## Method documentation

* **Function:** `getModem()` - Returns current server's modem component as its proxy.

  * **Return:** `componentModem` - Proxy of server's modem component.

* **Function:** `getPort()` - Returns server working port as its number value.

  * **Return:** `port` - Server working port value.

* **Function:** `isRunning()` - Returns current server activity state as boolean.

  * **Return:** `active` - Server's activity flag.

* **Function:** `process()` - Default server processing function, which always throw an error. It was created to remind that every custom server class must override this method.

* **Function:** `setModem(modem)` - Sets new server network modem component.

  * **Parameter:** `modem` - Server's working modem component as proxy.
  * **Return:** `'true'` - If new modem component has been changed successfully.

* **Function:** `setOnStart(task, ...)` - Changes function task performed on server starting.

  * **Parameter:** `task` - New task function.
  * **Parameter:** `...` - New event task function parameter list.
  * **Return:** `'true'` - If new function has been set correctly.

* **Function:** `setOnStop(task, ...)` - Changes callback function executed on server stopping.

  * **Parameter:** `task` - New callback function.
  * **Parameter:** `...` - New callback function arguments.
  * **Return:** `'true'` - If new event callback function has been set properly.

* **Function:** `setPort(port)` - Sets new server working port number.

  * **Parameter:** `port` - New server's working port value.
  * **Return:** `'true'` - If new port number has been set without errors.

* **Function:** `start()` - Starts the server by opening its port and executing initialization function (if present).

  * **Return:** `...` - Results from server's initialization function (if present).

* **Function:** `stop()` - Stops the server by closing its port and executing finalization function (if present).

  * **Return:** `...` - Results from server's finalization function (if present).
