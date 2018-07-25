------------------------------------
-- XAF Module - Utility:BigNumber --
------------------------------------
-- [>] This class represents an arbitrary precision number object, which is stored as a table.
-- [>] It has many functions that work as operators for these numbers.
-- [>] BigNumber objects are immutable, it means that 'operator' functions return new BigNumber instead of editing existing ones.
-- [>] Object of this class could be created using standard Lua number notation - it supports even exponential notation (e, E signs).

local xafcore = require("xaf/core/xafcore")
local xafcoreMath = xafcore:getMathInstance()
local xafcoreTable = xafcore:getTableInstance()

local BigNumber = {
  C_NAME = "Arbitrary Precision Number",
  C_INSTANCE = true,
  C_INHERIT = true,

  static = {}
}

function BigNumber:initialize()
  local parent = nil
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}

  private.decimalDigits = {}
  private.decimalLength = 0
  private.decimalPrecision = -1    -- Precision value, how many decimal digits are shown in returned string value (minimum 0, -1 means no fixed limit).
  private.decimalPrecisionMax = 10 -- Max precision value for computing (for example in division) in decimal digits (minimum 1).
  private.integerDigits = {}
  private.integerLength = 0
  private.initialExponent = 0
  private.numberSign = 0
  private.separatorDecimal = '.'
  private.separatorThousandsDecimal = ''
  private.separatorThousandsInteger = ''
  private.radixMaximumValue = 16
  private.radixMinimumValue = 2
  private.radixCharacterTable = {
    '0', '1', '2', '3', '4', '5', '6', '7',
    '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'
  }

  return {
    private = private,
    public = public
  }
end

function BigNumber:extend()
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

function BigNumber:new(numberString, numberRadix)
  local class = self:initialize()
  local private = class.private
  local public = class.public

  if (numberRadix == nil) then
    private:convertString(numberString)
    private:normalizeNumber()
  else
    private:convertStringRadix(numberString, numberRadix) -- Additionally converts number from given base to internal (decimal).
    private:normalizeNumber()
  end

  if (private.initialExponent ~= 0) then
    local numberExponent = private.initialExponent
    local numberObject = nil

    if (private.initialExponent > 0) then
      numberObject = public:shiftCommaRightwise(numberExponent)
    else
      numberObject = public:shiftCommaLeftwise(-1 * numberExponent)
    end

    local newObject = BigNumber:new(numberObject:getValue())
    local newTable = newObject:returnValue()
    private.decimalDigits = newTable.decimalDigits
    private.decimalLength = newTable.decimalLength
    private.integerDigits = newTable.integerDigits
    private.integerLength = newTable.integerLength
    private.numberSign = newTable.numberSign
    private:normalizeNumber()
  end

  if (self.C_INSTANCE == true) then
    return public
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be instanced")
  end
end

return BigNumber
