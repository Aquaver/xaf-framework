# XAF Module - Network:DNSServer

DNS Server is as its name says module which allows creating and running simple but so powerful Domain Name System networks. However, this class is top-level network specific implementation and it provides only the most core domain management functionalities like registering, unregistering and two-way translation (forward and reverse). Due to that, this module was designed to store only unique addresses and domain names, which prevents registering two equal addresses or two the same domain names.

## Class documentation

* **Class name -** `Generic DNSP Server`, **instantiable -** `true`, **inheritable -** `true`
* **Static fields**

  * *no static fields*

* **Constructor -** `DnsServer:new(modem, rootPath)`
* **Dependencies -** `Network:Server`

## Network documentation

* **Accepted requests**

  * **Request name -** `DNS_REGISTER`, **parameters -** `string: registerAddress`, `string: registerDomainName`
  * **Request name -** `DNS_TRANSLATE_FORWARD`, **parameters -** `string: translateDomainName`
  * **Request name -** `DNS_TRANSLATE_REVERSE`, **parameters -** `string: translateAddress`
  * **Request name -** `DNS_UNREGISTER`, **parameters -** `string: unregisterObject`

* **Response messages**

  * `Address Already Exists` - received on trying to register domain with address, which already exists in DNS database.
  * `Address Not Exists` - sent on attempt to reverse translate address which has not been registered.
  * `Domain Ambiguity` - message received in response on trying to unregister address, which has equal value, but as domain name. Therefore, it is strongly recommended using domain names out of UUID (address) regular expression.
  * `Domain Name Already Exists` - received on trying to register domain with name, which already exists in database.
  * `Domain Not Exists` - message sent in response on attempt to translate domain name, which has not been registered in DNS registry.
  * `Invalid Address` - received on sending address with invalid UUID syntax.
  * `Invalid Domain Name` - mostly sent in response on sending `nil` domain name.
  * `Invalid Domain Object` - as same as the upper one, sent when trying to unregister `nil` domain object.
  * `OK` - Message sent as response on proper request.

## Method documentation

* *All methods from* `Network:Server`

### Private in-class method documentation

* **Function:** `doRegister(event)` - Registers the address and domain name in DNS server.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `doTranslateForward(event)` - Translates received domain name and responds with its corresponding address.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `doTranslateReverse(event)` - Translates requested address to corresponding domain name and returns it as response.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `doUnregister(event)` - Unregisters the address and domain name from DNS server.

  * **Parameter:** `event` - Event table with received request object.

* **Function:** `prepareWorkspace(rootPath)` - Initializes the workspace for DNS server.

  * **Parameter:** `rootPath` - DNS server workspace tree root path string.
  * **Return:** `'true'` - If server workspace has been initialized successfully.

* **Function:** `process(event)` - Passes the whole event table object and processes the DNS request.

  * **Parameter:** `event` - Event table object from function `event.pull()` in OC Event API.
  * **Return:** `status, ...` - Request status (false, when server has received unknown request, otherwise - true) and potential request returned values.
