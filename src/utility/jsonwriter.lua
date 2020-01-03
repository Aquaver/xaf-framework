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
