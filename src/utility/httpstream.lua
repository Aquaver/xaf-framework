-------------------------------------
-- XAF Module - Utility:HTTPStream --
-------------------------------------
-- [>] This class represents the HTTP stream, which is used for connecting with HTTP servers and doing some actions with them.
-- [>] It was designed as each stream object may connect with only one server - its URL is set in constructor.
-- [>] The user is able to perform few types of actions on HTTP stream objects like body data retrieving, getting date and time or sending POST data.
-- [>] Currently that module supports only sending GET and POST requests.
-- [>] Connection with HTTP Secure targets (HTTPS) are also fully supported.

local unicode = require("unicode")
local xafcore = require("xaf/core/xafcore")
local xafcoreMath = xafcore:getMathInstance()
local xafcoreText = xafcore:getTextInstance()

local HttpStream = {
  C_NAME = "Generic HTTP Stream",
  C_INSTANCE = true,
  C_INHERIT = true,
  
  static = {}
}

function HttpStream:initialize()
  local parent = nil
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}
  
  private.componentInternet = nil
  private.connectionHandle = nil
  private.isConnected = false
  private.isSecure = false
  private.maxTimeout = 1
  private.maxTries = 3
  private.postData = nil
  private.requestHeaders = {}
  private.responseCode = 0
  private.responseHeaders = {}
  private.responseMessage = ''
  private.targetUrl = ''
  
  public.clearPostData = function(self) -- [!] Function: clearPostData() - Clears previously set HTTP POST data string and restores it to 'nil' value.
    private.postData = nil              -- [!] Return: 'true' - If the POST string has been cleared without errors.
    
    return true
  end
  
  public.connect = function(self)                                            -- [!] Function: connect() - Tries to connect with previously set HTTP server with its URL.
    local connectionHandle = nil                                             -- [!] Return: status - Connection status, if 'true' then the connection is established, 'false' otherwise.
    local internet = private.componentInternet
    local postData = private.postData
    local requestHeaders = private.requestHeaders
    local responseTable = {}
    local status = false
    local targetUrl = private.targetUrl
    local timeout = private.maxTimeout
    local tries = private.maxTries
    
    if (postData) then
      connectionHandle = internet.request(targetUrl, postData, requestHeaders)
    else
      connectionHandle = internet.request(targetUrl, requestHeaders)
    end
    
    if (private.isConnected == false) then
      for i = 1, tries do
        responseTable = {connectionHandle.response()}
        
        if (responseTable[1] and responseTable[2] and responseTable[3]) then
          private.connectionHandle = connectionHandle
          private.isConnected = true
          private.responseCode = responseTable[1]
          private.responseMessage = responseTable[2]
          private.responseHeaders = responseTable[3]
          
          status = true
          return status
        else
          os.sleep(timeout)
        end
      end
      
      return status
    else
      error("[XAF Error] Already connected")
    end
  end
  
  public.disconnect = function(self)      -- [!] Function: disconnect() - Disconnects from target server and closes its stream.
    if (private.isConnected == true) then -- [!] Return: 'true' - If the stream has been closed correctly.
      private.connectionHandle.close()
      private.connectionHandle = nil
      private.isConnected = false
      
      return true
    else
      error("[XAF Error] Already disconnected")
    end
  end
  
  public.isConnected = function(self) -- [!] Function: isConnected() - Returns boolean flag is the stream currently connected to its target.
    return private.isConnected        -- [!] Return: isConnected - Stream connection flag.
  end
  
  public.isSecure = function(self) -- [!] Function: isSecure() - Returns boolean flag is the stream secure (whether is HTTPS protocol used).
    return private.isSecure        -- [!] Return: isSecure - Secure stream boolean flag.
  end
  
  public.getCard = function(self)    -- [!] Function: getCard() - Returns internet card component attached to HTTP stream object.
    return private.componentInternet -- [!] Return: componentInternet - Stream object's internet card component.
  end
  
  public.getData = function(self)                       -- [!] Function: getData() - Returns an iterator for getting HTTP received body data.
    if (private.isConnected == true) then               -- [!] Return: dataChunk - Next data chunks from received body.
      local connectionHandle = private.connectionHandle
      local dataChunk = ''
      
      return function()
        while(dataChunk) do
          dataChunk = connectionHandle.read(math.huge)
          
          return dataChunk
        end
      end
    else
      error("[XAF Error] Not connected")
    end
  end
  
  public.getDateObject = function(self)                                                                                                                                                  -- [!] Function: getDateObject() - Returns a table with an actual date and time elements returned from HTTP server.
    if (private.isConnected == true) then                                                                                                                                                -- [!] Return: dateObject - Date and time elements table.
      local dateString = private.responseHeaders["Date"][1]
      local dateObject = {}
      local dateObjectRaw = xafcoreText:split(dateString, " ,:")
      local dayNames = {["Mon"] = 1, ["Tue"] = 2, ["Wed"] = 3, ["Thu"] = 4, ["Fri"] = 5, ["Sat"] = 6, ["Sun"] = 7}
      local monthNames = {["Jan"] = 1, ["Feb"] = 2, ["Mar"] = 3, ["Apr"] = 4, ["May"] = 5, ["Jun"] = 6, ["Jul"] = 7, ["Aug"] = 8, ["Sep"] = 9, ["Oct"] = 10, ["Nov"] = 11, ["Dec"] = 12}
      
      dateObject["WEEK_DAY"] = dayNames[dateObjectRaw[1]]
      dateObject["MONTH_DAY"] = tonumber(dateObjectRaw[2])
      dateObject["MONTH"] = monthNames[dateObjectRaw[3]]
      dateObject["YEAR"] = tonumber(dateObjectRaw[4])
      dateObject["TIME_HOUR"] = tonumber(dateObjectRaw[5])
      dateObject["TIME_MINUTE"] = tonumber(dateObjectRaw[6])
      dateObject["TIME_SECOND"] = tonumber(dateObjectRaw[7])
      dateObject["TIMEZONE"] = dateObjectRaw[8]
      
      return dateObject
    else
      error("[XAF Error] Not connected")
    end
  end
  
  public.getMaxTimeout = function(self) -- [!] Function: getMaxTimeout() - Returns current maximum waiting time for HTTP response.
    return private.maxTimeout           -- [!] Return: maxTimeout - Maximum timeout value in seconds.
  end
  
  public.getMaxTries = function(self) -- [!] Function: getMaxTries() - Returns current maximum attempts number for connecting.
    return private.maxTries           -- [!] Return: maxTries - Maximum attempts number.
  end
  
  public.getResponseCode = function(self) -- [!] Function: getResponseCode() - Returns code of the HTTP response.
    if (private.isConnected == true) then -- [!] Return: responseCode - HTTP response code.
      return private.responseCode
    else
      error("[XAF Error] Not connected")
    end
  end
  
  public.getResponseHeader = function(self, headerName)                                  -- [!] Function: getResponseHeader(headerName) - Returns specified header value from responded table.
    assert(type(headerName) == "string", "[XAF Utility] Expected STRING as argument #1") -- [!] Parameter: headerName - Specified name of choosen HTTP header from table.
                                                                                         -- [!] Return: headerValue - Value of specified responded HTTP header.
    if (private.isConnected == true) then
      if (private.responseHeaders[headerName]) then
        return private.responseHeaders[headerName][1]
      else
        return nil
      end
    else
      error("[XAF Error] Not connected")
    end
  end
  
  public.getResponseHeaders = function(self) -- [!] Function: getResponseHeaders() - Returns headers table of the HTTP response.
    if (private.isConnected == true) then    -- [!] Return: responseHeaders - HTTP response headers as table.
      return private.responseHeaders
    else
      error("[XAF Error] Not connected")
    end
  end
  
  public.getResponseMessage = function(self) -- [!] Function: getResponseMessage() - Returns message of the HTTP response.
    if (private.isConnected == true) then    -- [!] Return: responseMessage - HTTP response message.
      return private.responseMessage
    else
      error("[XAF Error] Not connected")
    end
  end
  
  public.setCard = function(self, internet)                                          -- [!] Function: setCard(internet) - Sets the internet card component and attaches it to stream.
    assert(type(internet) == "table", "[XAF Utility] Expected TABLE as argument #1") -- [!] Parameter: internet - New internet card component.
                                                                                     -- [!] Return: 'true' - If new internet component has been set correctly.
    if (internet.type == "internet") then
      private.componentInternet = internet
    else
      error("[XAF Error] Invalid internet card component")
    end
    
    return true
  end
  
  public.setMaxTimeout = function(self, newTimeout)                                      -- [!] Function: setMaxTimeout(newTimeout) - Changes maximum time for single connection attempt in seconds.
    assert(type(newTimeout) == "number", "[XAF Utility] Expected NUMBER as argument #1") -- [!] Parameter: newTimeout - New timeout value in seconds.
                                                                                         -- [!] Return: 'true' - If new timeout value has been set correctly.
    private.maxTimeout = newTimeout
    
    return true
  end
  
  public.setMaxTries = function(self, newTries)                                         -- [!] Function: setMaxTries(newTries) - Sets maximum connection tries number.
    assert(type(newTries) == "number", "[XAF Utility] Expected NUMBER as argument #1")  -- [!] Parameter: newTries - New attempts number value.
                                                                                        -- [!] Return: 'true' - If attempts number has been changed properly.
    if (xafcoreMath:checkNatural(newTries, true) == true) then
      private.maxTries = newTries
    else
      error("[XAF Error] Invalid connection tries number - must be a positive integer")
    end
    
    return true
  end
  
  public.setPostData = function(self, postData)                                      -- [!] Function: setPostData(postData) - Sets data string for HTTP POST method.
    assert(type(postData) == "table", "[XAF Utility] Expected TABLE as argument #1") -- [!] Parameter: postData - New POST data as key-value pairs.
                                                                                     -- [!] Return: 'true' - If new POST data has been changed properly.
    local postTable = postData
    local postString = ''
    
    for key, value in pairs(postTable) do
      postString = postString .. tostring(key) .. '='
      postString = postString .. tostring(value) .. '&'
    end
    
    postString = unicode.sub(postString, 1, unicode.wlen(postString) - 1)
    private.postData = postString
    
    return true
  end
  
  public.setRequestHeader = function(self, name, value)                            -- [!] Function: setRequestHeader(name, value) - Sets new header in request headers table. To use before 'connect()' function.
    assert(type(name) == "string", "[XAF Utility] Expected STRING as argument #1") -- [!] Parameter: name - Header name as string.
                                                                                   -- [!] Parameter: value - New header value - if 'nil' then the header will be removed from table.
    local headerName = name                                                        -- [!] Return: 'true' - If new header has been set properly.
    local headerValue = value
    
    private.requestHeaders[headerName] = headerValue
    return true
  end

  return {
    private = private,
    public = public
  }
end

function HttpStream:extend()
  local class = self:initialize()
  local private = class.private
  local public = class.public
  
  if (self.C_INHERIT == true) then
    return {
      private = private,
      public = public
    }
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be inherited")
  end
end

function HttpStream:new(card, url)
  local class = self:initialize()
  local private = class.private
  local public = class.public
  
  public:setCard(card)
  assert(type(url) == "string", "[XAF Utility] Expected STRING as argument #2")
  
  if (string.sub(string.lower(url), 1, 7) == "http://") then
    private.targetUrl = url
    private.isSecure = false
  elseif (string.sub(string.lower(url), 1, 8) == "https://") then
    private.targetUrl = url
    private.isSecure = true
  else
    error("[XAF Error] Invalid URL pattern - should start with 'http(s)://...'")
  end

  if (self.C_INSTANCE == true) then
    return public
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be instanced")
  end
end

return HttpStream
