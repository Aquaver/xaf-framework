# XAF Module - Utility:HTTPStream

First module of new type - utility. This class is used for creating streams that connect to HTTP server by means of OC Internet Card. That stream comes with some methods for doing primary actions. The object is able to getting connection informations like response code, message or headers. It also might retrieve full body data from the stream to process it. Currently only GET and POST methods are supported, but it is enough for two-way communication, both sending and receiving data are easy with this module. **Important!** Retrieving full body data with `getData()` method is possible only one time per connection. Therefore, if you need to get the same body second time, you should disconnect and connect again to reset the stream buffer.

## Class documentation

* **Class name -** `Generic HTTP Stream`, **instantiable -** `true`, **inheritable -** `true`
* **Static fields**

  * `TIMEOUT_DEFAULT` - Initial value of timeout (in seconds) between connection tries, used in `setMaxTimeout()` method. Currently, its value is 1.
  * `TRIES_DEFAULT` - Default value of max connection tries (repetitions) before breaking further connection, may be used in `setMaxTries()` function. Currently, its value is 3.

* **Constructor -** `HTTPStream:new(card, url)`
* **Dependencies -** *no dependencies*

## Method documentation

* **Function:** `clearPostData()` - Clears previously set HTTP POST data string and restores it to 'nil' value.

  * **Return:** `'true'` - If the POST string has been cleared without errors.

* **Function:** `connect()` - Tries to connect with previously set HTTP server with its URL.

  * **Return:** `status` - Connection status, if 'true' then the connection is established, 'false' otherwise.

* **Function:** `disconnect()` - Disconnects from target server and closes its stream.

  * **Return:** `'true'` - If the stream has been closed correctly.

* **Function:** `isConnected()` - Returns boolean flag is the stream currently connected to its target.

  * **Return:** `isConnected` - Stream connection flag.

* **Function:** `isSecure()` - Returns boolean flag is the stream secure (whether is HTTPS protocol used).

  * **Return:** `isSecure` - Secure stream boolean flag.

* **Function:** `getCard()` - Returns internet card component attached to HTTP stream object.

  * **Return:** `componentInternet` - Stream object's internet card component.

* **Function:** `getData()` - Returns an iterator for getting HTTP received body data.

  * **Return:** `dataChunk` - Next data chunks from received body.

* **Function:** `getDateObject()` - Returns a table with an actual date and time elements returned from HTTP server.

  * **Return:** `dateObject` - Date and time elements table. List of table members and their meaning are shown below.

    * `WEEK_DAY` - Number of day of week (1 - Monday, 7 - Sunday).
    * `MONTH_DAY` - Number of day of month from 1 to 30 (or 28, 29, 31).
    * `MONTH` - Number of month (1 - January, 12 - December).
    * `YEAR` - Current year number.
    * `TIME_HOUR` - Number of hour in which the response happens from 0 to 23.
    * `TIME_MINUTE` - Number of minute, as in above from 0 to 59.
    * `TIME_SECOND` - Number of second from 0 to 59.
    * `TIMEZONE` - Absolute timezone string, which always is `GMT`.

* **Function:** `getMaxTimeout()` - Returns current maximum waiting time for HTTP response.

  * **Return:** `maxTimeout` - Maximum timeout value in seconds.

* **Function:** `getMaxTries()` - Returns current maximum attempts number for connecting.

  * **Return:** `maxTries` - Maximum attempts number.

* **Function:** `getResponseCode()` - Returns code of the HTTP response.

  * **Return:** `responseCode` - HTTP response code.

* **Function:** `getResponseHeader(headerName)` - Returns specified header value from responded table.

  * **Parameter:** `headerName` - Specified name of choosen HTTP header from table.
  * **Return:** `headerValue` - Value of specified responded HTTP header.

* **Function:** `getResponseHeaders()` - Returns headers table of the HTTP response.

  * **Return:** `responseHeaders` - HTTP response headers as table.

* **Function:** `getResponseMessage()` - Returns message of the HTTP response.

  * **Return:** `responseMessage` - HTTP response message.

* **Function:** `setCard(internet)` - Sets the internet card component and attaches it to stream.

  * **Parameter:** `internet` - New internet card component.
  * **Return:** `'true'` - If new internet component has been set correctly.

* **Function:** `setMaxTimeout(newTimeout)` - Changes maximum time for single connection attempt in seconds.

  * **Parameter:** `newTimeout` - New timeout value in seconds.
  * **Return:** `'true'` - If new timeout value has been set correctly.

* **Function:** `setMaxTries(newTries)` - Sets maximum connection tries number.

  * **Parameter:** `newTries` - New attempts number value.
  * **Return:** `'true'` - If attempts number has been changed properly.

* **Function:** `setPostData(postData)` - Sets data string for HTTP POST method.

  * **Parameter:** `postData` - New POST data as key-value pairs.
  * **Return:** `'true'` - If new POST data has been changed properly.

* **Function:** `setRequestHeader(name, value)` - Sets new header in request headers table. To use before 'connect()' function.

  * **Parameter:** `name` - Header name as string.
  * **Parameter:** `value` - New header value - if 'nil' then the header will be removed from table.
  * **Return:** `'true'` - If new header has been set properly.
