-------------------------------------
-- XAF Module - Utility:JSONWriter --
-------------------------------------
-- [>] This module is a pair with JSONParser class, which provides saving data in JSON format.
-- [>] It allows to write any data (tables, arrays, strings, numbers, booleans and nils) to JSON.
-- [>] Currently, is has only one function to write input data to JSON.

local unicode = require("unicode")
local xafcore = require("xaf/core/xafcore")
local xafcoreMath = xafcore:getMathInstance()
local xafcoreTable = xafcore:getTableInstance()

local JsonWriter = {
  C_NAME = "Generic JSON Writer",
  C_INSTANCE = true,
  C_INHERIT = true,

  static = {}
}

function JsonWriter:initialize()
  local parent = nil
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}

  private.currentIndent = 0
  private.indentSize = 0
  private.inputData = nil
  private.stringEscapes = {['\b'] = "\\b", ['\n'] = "\\n", ['\t'] = "\\t", ['\r'] = "\\r", ['\f'] = "\\f", ['\"'] = '\\"', ["\\"] = "\\\\"}

  private.checkDataType = function(self, data)                                                                   -- [!] Function: checkDataType(data) - Checks input data type according to JSON.
    if (type(data) == "boolean" or type(data) == "nil" or type(data) == "number" or type(data) == "string") then -- [!] Parameter: data - Input data with any type (may be nil).
      return type(data)                                                                                          -- [!] Return: dataType - String name of checked data type (or nil on invalid data, for instance: Lua functions).
    elseif (type(data) == "table") then
      if (#data >= xafcoreTable:getLength(data)) then
        return "array" -- Table has number indices only (JSON array).
      else
        return "object" -- Table has string type keys (JSON object).
      end
    else
      return nil
    end
  end

  private.getValue = function(self, dataString, dataValue, messageErrorType)                           -- [!] Function: getValue(dataString, dataValue, messageErrorType) - Determines passed data type and tries to convert it to JSON string.
    assert(type(dataString) == "string", "[XAF Core] Expected STRING as argument #1")                  -- [!] Parameter: dataString - Raw JSON string partially converted.
    assert(type(messageErrorType) == "string", "[XAF Core] Expected STRING as argument #3")            -- [!] Parameter: dataValue - Next data value to convert.
                                                                                                       -- [!] Parameter: messageErrorType - Internal value to determine where the error occured.
    local valueRaw = dataValue                                                                         -- [!] Return: dataString - Partially converted JSON data string.
    local valueType = private:checkDataType(valueRaw)

    if (valueType == "array") then
      dataString = dataString .. private:writeArray(valueRaw)
    elseif (valueType == "boolean") then
      dataString = dataString .. private:writeBoolean(valueRaw)
    elseif (valueType == "nil") then
      dataString = dataString .. private:writeNull(valueRaw)
    elseif (valueType == "number") then
      dataString = dataString .. private:writeNumber(valueRaw)
    elseif (valueType == "object") then
      dataString = dataString .. private:writeObject(valueRaw)
    elseif (valueType == "string") then
      dataString = dataString .. private:writeString(valueRaw)
    else
      error("[XAF Error] Invalid data type occured while writing JSON - parsing " .. messageErrorType)
    end

    return dataString
  end

  return {
    private = private,
    public = public
  }
end

function JsonWriter:extend()
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

function JsonWriter:new(defaultIndent)
  local class = self:initialize()
  local private = class.private
  local public = class.public

  if (xafcoreMath:checkNatural(defaultIndent, false) == true) then
    private.indentSize = defaultIndent
  else
    error("[XAF Error] Default string indentation size must be natural number (including zero)")
  end

  if (self.C_INSTANCE == true) then
    return public
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be instanced")
  end
end

return JsonWriter