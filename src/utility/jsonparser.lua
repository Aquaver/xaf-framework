-------------------------------------
-- XAF Module - Utility:JSONParser --
-------------------------------------
-- [>] This class provides mechanism for reading data stored in JSON (JavaScript Object Notation) format.
-- [>] It comes with simple parser, which returns processed data to JSON object as Lua table.
-- [>] Currently, it has only one function to parse input string.

local unicode = require("unicode")

local JsonParser = {
  C_NAME = "Generic JSON Parser",
  C_INSTANCE = true,
  C_INHERIT = true,

  static = {}
}

function JsonParser:initialize()
  local parent = nil
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}

  private.currentCharacter = ''
  private.currentIndex = 0
  private.inputData = ''
  private.stringEscapes = {['b'] = "\b", ['n'] = "\n", ['t'] = "\t", ['r'] = "\r", ['f'] = "\f", ['\"'] = '\"', ["\\"] = "\\"}

  private.getNextCharacter = function(self)                                                                      -- [!] Function: getNextCharacter() - Returns next character from entire input string.
    private.currentIndex = private.currentIndex + 1                                                              -- [!] Return: currentCharacter - Next character from input JSON string.
    private.currentCharacter = string.sub(private.inputData, private.currentIndex + 1, private.currentIndex + 1)

    return private.currentCharacter
  end

  private.getValue = function(self)                                                                                                                     -- [!] Function: getValue() - Detects following value type in input string and parses it.
    if (private.currentCharacter == '[') then
      return private:parseArray()
    elseif (private.currentCharacter == 't' or private.currentCharacter == 'f') then
      return private:parseBoolean()
    elseif (private.currentCharacter == 'n') then
      return private:parseNull()
    elseif (private.currentCharacter == '-' or (private.currentCharacter and private.currentCharacter >= '0' and private.currentCharacter <= '9')) then
      return private:parseNumber()
    elseif (private.currentCharacter == '{') then
      return private:parseObject()
    elseif (private.currentCharacter == '\"') then
      return private:parseString()
    else
      error("[XAF Error] Syntax error encountered while parsing JSON data")
    end
  end

  private.parseArray = function(self)                                                                         -- [!] Function: parseArray() - Parses string token into JSON array type value.
    local valueArray = {}                                                                                     -- [!] Return: valueArray - Parsed JSON array as Lua table.

    if (private.currentCharacter == '[') then
      if (private:getNextCharacter() == ']') then
        return valueArray
      end

      repeat
        table.insert(valueArray, private:getValue())

        if (private.currentCharacter == ']') then
          private:getNextCharacter()
          return valueArray
        end
      until not (private.currentCharacter and private.currentCharacter == ',' and private:getNextCharacter())
    else
      error("[XAF Error] Syntax error encountered while parsing JSON data - parsing array")
    end
  end

  private.parseBoolean = function(self)                                                                 -- [!] Function: parseBoolean() - Parses string token into JSON boolean type value.
    local valueBoolean = ''                                                                             -- [!] Return: valueBoolean - Parsed JSON boolean value ('true' or 'false').

    if (private.currentCharacter == 't') then
      for i = 1, 4 do
        valueBoolean = valueBoolean .. private.currentCharacter
        private:getNextCharacter()
      end

      if (valueBoolean == "true") then
        return true
      else
        error("[XAF Error] Syntax error encountered while parsing JSON data - parsing boolean (true)")
      end
    elseif (private.currentCharacter == 'f') then
      for i = 1, 5 do
        valueBoolean = valueBoolean .. private.currentCharacter
        private:getNextCharacter()
      end

      if (valueBoolean == "false") then
        return false
      else
        error("[XAF Error] Syntax error encountered while parsing JSON data - parsing boolean (false)")
      end
    else
      error("[XAF Error] Syntax error encountered while parsing JSON data - parsing boolean")
    end
  end

  private.parseNull = function(self)                                                         -- [!] Function: parseNull() - Parses string token into JSON null type value.
    local valueNull = ''                                                                     -- [!] Return: valueNull - Parsed JSON null value (as Lua 'nil').

    if (private.currentCharacter == 'n') then
      for i = 1, 4 do
        valueNull = valueNull .. private.currentCharacter
        private:getNextCharacter()
      end

      if (valueNull == "null") then
        return nil
      else
        error("[XAF Error] Syntax error encountered while parsing JSON data - parsing null")
      end
    else
      error("[XAF Error] Syntax error encountered while parsing JSON data - parsing null")
    end
  end

  private.parseNumber = function(self)                                                                            -- [!] Function: parseNumber() - Parses string token into JSON number type value.
    local valueNumber = ''                                                                                        -- [!] Return: valueNumber - Parsed JSON number value.

    if (private.currentCharacter == '-') then
      valueNumber = valueNumber .. private.currentCharacter
      private:getNextCharacter()
    end

    while (private.currentCharacter and private.currentCharacter >= '0' and private.currentCharacter <= '9') do
      valueNumber = valueNumber .. private.currentCharacter
      private:getNextCharacter()
    end

    if (private.currentCharacter == '.') then
      valueNumber = valueNumber .. private.currentCharacter
      private:getNextCharacter()

      while (private.currentCharacter and private.currentCharacter >= '0' and private.currentCharacter <= '9') do
        valueNumber = valueNumber .. private.currentCharacter
        private:getNextCharacter()
      end
    end

    if (private.currentCharacter == 'e' or private.currentCharacter == 'E') then
      valueNumber = valueNumber .. private.currentCharacter
      private:getNextCharacter()

      if (private.currentCharacter == '-' or private.currentCharacter == '+') then
        valueNumber = valueNumber .. private.currentCharacter
        private:getNextCharacter()
      end

      while (private.currentCharacter and private.currentCharacter >= '0' and private.currentCharacter <= '9') do
        valueNumber = valueNumber .. private.currentCharacter
        private:getNextCharacter()
      end
    end

    if (tonumber(valueNumber)) then
      return tonumber(valueNumber)
    else
      error("[XAF Error] Syntax error encountered while parsing JSON data - parsing number")
    end
  end

  private.parseObject = function(self)                                                                            -- [!] Function: parseObject() - Parses string token into JSON object type value.
    local valueObject = {}                                                                                        -- [!] Return: valueObject - Parsed JSON object value as Lua table (with non-index keys).

    if (private.currentCharacter == '{') then
      if (private:getNextCharacter() == '}') then
        return valueObject
      end

      repeat
        local objectKey = private:parseString()

        if (private.currentCharacter == ':') then
          private:getNextCharacter()
          valueObject[objectKey] = private:getValue()

          if (private.currentCharacter == '}') then
            private:getNextCharacter()
            return valueObject
          end
        else
          error("[XAF Error] Syntax error encountered while parsing JSON data - parsing object (colon expected)")
        end
      until not (private.currentCharacter and private.currentCharacter == ',' and private:getNextCharacter())
    else
      error("[XAF Error] Syntax error encountered while parsing JSON data - parsing object")
    end
  end

  private.parseString = function(self)                                                       -- [!] Function: parseString - Parses string token into JSON string type value.
    local valueString = ''                                                                   -- [!] Return: valueString - Parsed JSON string value.

    if (private.currentCharacter == '\"') then
      private:getNextCharacter()

      while (private.currentCharacter) do
        if (private.currentCharacter == '\"') then
          private:getNextCharacter()
          return valueString
        end

        if (private.currentCharacter == "\\") then
          private:getNextCharacter()

          if (private.stringEscapes[private.currentCharacter]) then
            valueString = valueString .. private.stringEscapes[private.currentCharacter]
          else
            valueString = valueString .. private.currentCharacter
          end
        else
          valueString = valueString .. private.currentCharacter
        end

        private:getNextCharacter()
      end
    else
      error("[XAF Error] Syntax error encountered while parsing JSON data - parsing string")
    end
  end

  private.removeWhitespaces = function(self, jsonString)                                 -- [!] Function: removeWhitespaces(jsonString) - Minifies the JSON string on input by removing all whitespaces (except in string literals).
    local currentCharacter = ''                                                          -- [!] Parameter: jsonString - Input JSON string to minify.
    local previousCharacter = ''                                                         -- [!] Return: transformedString - Minified JSON string, ready to parse.
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

  public.parse = function(self, inputJson)                                           -- [!] Function: parse(inputJson) - Starts JSON text processing procedure into Lua object.
    assert(type(inputJson) == "string", "[XAF Core] Expected STRING as argument #1") -- [!] Parameter: inputJson - JSON data as plain text string.
                                                                                     -- [!] Return: ... - Processed JSON object table or value (number, boolean, string, nil).
    private.inputData = private:removeWhitespaces(inputJson)
    private.currentCharacter = string.sub(private.inputData, 1, 1)
    private.currentIndex = 0

    return private:getValue(private.inputData)
  end

  return {
    private = private,
    public = public
  }
end

function JsonParser:extend()
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

function JsonParser:new()
  local class = self:initialize()
  local private = class.private
  local public = class.public

  if (self.C_INSTANCE == true) then
    return public
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be instanced")
  end
end

return JsonParser
