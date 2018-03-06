# XAF Module - DNSClient

This class is a client to XAF built-in DNS server module, which provides straight and simple communication in this protocol. It has implemented four functions where each of them makes corresponding request to the server and returns response from it. That class should be used in order to create custom and reimplemented DNS protocol or just making client software with graphical user interface. **Important!** This is the client documentation only. If you would like to know more informations about the entire protocol, request types or response messages, you should read documentation about DNS server class.

## Class documentation

* **Class name -** `Generic DNSP Client`, **instantiable -** `true`, **inheritable -** `true`
* **Static fields**

  * *no static fields*

* **Constructor -** `DnsClient:new(modem)`
* **Dependencies -** `Network:Client`

## Method documentation

* *All methods from* `Network:Client`
* **Function:** `register(address, name)` - Sends the 'DNS_REGISTER' request to DNS server.

  * **Parameter:** `address` - Address of component (usually computer) to register.
  * **Parameter:** `name` - Domain name of component to register.
  * **Return:** `...` - Status and message received from the server.

* **Function:** `translateForward(name)` - Sends the 'DNS_TRANSLATE_FORWARD' request to DNS server.

  * **Parameter:** `name` - Domain name to translate to its address, registered in DNS server.
  * **Return:** `...` - Status and message or received address from the server.

* **Function:** `translateReverse(address)` - Sends the 'DNS_TRANSLATE_REVERSE' request to DNS server.

  * **Parameter:** `address` - Address to translate to its corresponding domain name, registered in DNS server.
  * **Return:** `...` - Status and message or received domain name assigned to requested address.

* **Function:** `unregister(object)` - Sends the 'DNS_UNREGISTER' request to DNS server.

  * **Parameter:** `object` - Object (domain name or address) you wish to unregister.
  * **Return:** `...` - Status and message received from the server.
