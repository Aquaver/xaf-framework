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
  
  private.removeWhitespaces = function(self, jsonString)                                 -- [!] Function: removeWhitespaces(jsonString) - Minifies the JSON string on input by removing all whitespaces (except in string literals).
    local currentCharacter = ''                                                          -- [!] Parameter: jsonString - Input JSON string to minify.
    local previousCharacter = ''                                                         -- [!] Return: transformedString - Minified JSON string, ready to output.
    local stringLiteral = false
    local totalLength = unicode.wlen(jsonString)
    local transformedString = ''

    for i = 1, totalLength do
      currentCharacter = string.sub(jsonString, i, i)

      if (currentCharacter == '\"') then
        if (previousCharacter == "\\") then
          transformedString = transformedString .. previousCharacter .. currentCharacter
        else
          stringLiteral = (not stringLiteral)
          transformedString = transformedString .. currentCharacter
        end
      elseif (string.find(currentCharacter, "%s")) then
        if (stringLiteral == true) then
          transformedString = transformedString .. currentCharacter
        end
      else
        transformedString = transformedString .. currentCharacter
      end

      previousCharacter = currentCharacter
    end

    return transformedString
  end
  
  private.writeArray = function(self, inputArray)                                         -- [!] Function: writeArray(inputArray) - Converts array raw data to proper JSON string.
    assert(type(inputArray) == "table", "[XAF Core] Expected TABLE as argument #1")       -- [!] Parameter: inputArray - Input data to convert.
                                                                                          -- [!] Return: stringArray - Converted string from input array data.
    local stringArray = ''
    stringArray = stringArray .. '[' .. '\n'
    private.currentIndent = private.currentIndent + private.indentSize -- Shift one level more (up) nested indentation.

    for i = 1, #inputArray do
      stringArray = stringArray .. string.rep(' ', private.currentIndent)
      stringArray = private:getValue(stringArray, inputArray[i], "array", true)
      stringArray = stringArray .. ',' .. '\n'
    end

    if (#inputArray > 0) then
      stringArray = string.sub(stringArray, 1, -3)
    end

    private.currentIndent = private.currentIndent - private.indentSize -- Shift one level less (down) nested indentation.
    stringArray = stringArray .. '\n' .. string.rep(' ', private.currentIndent) .. ']'

    return stringArray
  end
  
  private.writeBoolean = function(self, inputBoolean)                                     -- [!] Function: writeBoolean(inputBoolean) - Converts boolean raw data to proper JSON string.
    assert(type(inputBoolean) == "boolean", "[XAF Core] Expected BOOLEAN as argument #1") -- [!] Parameter: inputBoolean - Input data to convert.
                                                                                          -- [!] Return: stringBoolean - Converted string from input boolean data.
    return tostring(inputBoolean)
  end
  
  private.writeNull = function(self, inputNull)                                -- [!] Function: writeNull(inputNull) - Converts null raw data to proper JSON string.
    assert(type(inputNull) == "nil", "[XAF Core] Expected NIL as argument #1") -- [!] Parameter: inputNull - Input data to convert.
                                                                               -- [!] Return: stringNull - Converted string from input nil (null) data.
    return "null"
  end
  
  private.writeNumber = function(self, inputNumber)                                    -- [!] Function: writeNumber(inputNumber) - Converts number raw data to proper JSON string.
    assert(type(inputNumber) == "number", "[XAF Core] Expected NUMBER as argument #1") -- [!] Parameter: inputNumber - Input data to convert.
                                                                                       -- [!] Return: stringNumber - Converted string from input number data (or null on infinite or NaN).
    if (inputNumber == math.huge or
        inputNumber == -math.huge or
        inputNumber ~= inputNumber) then -- NaN (not a number) detected.
          return "null" -- JSON treats infinites and NaNs as null.
    end

    return tostring(inputNumber)
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
