# XAF Module - Network:Client

Client is the first class in network module, which may be used for creating new user-defined network protocols in XAF standard. It cannot be instanced - it an abstract top-level parent for all network clients. That class describes behavior implemented in all XAF client-server communication protocols. It is strongly recommended using it in your classes while creating your own network systems and communication rules.

## Class documentation

* **Class name -** `Abstract Network Client`, **instantiable -** `false`, **inheritable -** `true`
* **Static fields**

  * `TIMEOUT_DEFAULT` - Constant used in `setTimeout(timeout)` function as `timeout` parameter. It changes the client timeout value to its default which equals 10 seconds.

* **Constructor -** *class is not instantiable - no constructor*
* **Dependencies -** `Core:XAFCore`

## Method documentation

* **Function:** `getModem()` - Returns the modem component assigned to client.

  * **Return:** `componentModem` - Current client assigned network modem component.

* **Function:** `getTargetAddress()` - Returns client set target server's address.

  * **Return:** `targetAddress` - Current target server address.

* **Function:** `getTargetPort()` - Returns current client assigned target server's port.

  * **Return:** `targetPort` - Client target server's communication port number.

* **Function:** `getTimeout()` - Returns current client's set timeout in seconds.

  * **Return:** `timeout` - Client timeout value in seconds [-1 = infinity].

* **Function:** `setModem(modem)` - Sets client network modem component.

  * **Parameter:** `modem` - New modem component as its proxy.
  * **Return:** `'true'` - If new network component has been set properly.

* **Function:** `setTargetAddress(address)` - Changes client target server address.

  * **Parameter:** `address` - New target server address.
  * **Return:** `'true'` - If new address value has been changed correctly.

* **Function:** `setTargetPort(port)` - Sets client target server communication port.

  * **Parameter:** `port` - New target server port number.
  * **Return:** `'true'` - If new port has been changed successfully.

* **Function:** `setTimeout(timeout)` - Sets new client's timeout time in seconds.

  * **Parameter:** `timeout` - New timeout value in seconds [-1 = infinity].
  * **Return:** `'true'` - If new timeout value has been set without errors.

### Private in-class method documentation

* **Function:** `sendRawRequest(name, ...)` - Sends raw request to the target server to previously set target port. To use in custom requesting functions as core connecting.

  * **Parameter:** `name` - Raw request name as string.
  * **Return:** `status, result` - Status of the connection response, may be 'true' or 'false'. Second parameter is a response result(s) - it may be an error message on 'false' status. **Important!** Note that it has built-in timeout notifying functionality, you do not have to implement it in your classes. Therefore, if timeout was exceeded then this function will automatically return `Response Timeout` message. You only have to return it in your requesting function.
