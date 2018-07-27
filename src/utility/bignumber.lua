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

  private.buildFromTable = function(self, buildDecimalDigits, buildIntegerDigits, buildNumberSign) -- [!] Function: buildFromTable(buildDecimalDigits, buildIntegerDigits, buildNumberSign) - Creates new BigNumber object based on digit tables and number sign.
    assert(type(buildDecimalDigits) == "table", "[XAF Utility] Expected TABLE as argument #1")     -- [!] Parameter: buildDecimalDigits - Table with decimal component digits for new BigNumber object.
    assert(type(buildIntegerDigits) == "table", "[XAF Utility] Expected TABLE as argument #2")     -- [!] Parameter: buildIntegerDigits - Table with integer digits for new BigNumber object.
    assert(type(buildNumberSign) == "number", "[XAF Utility] Expected NUMBER as argument #3")      -- [!] Parameter: buildNumberSign - New sign value for created BigNumber object.
                                                                                                   -- [!] Return: BigNumber - Newly created BigNumber number object.
    local newObject = BigNumber:extend()
    newObject.private.decimalDigits = buildDecimalDigits
    newObject.private.decimalLength = #buildDecimalDigits
    newObject.private.integerDigits = buildIntegerDigits
    newObject.private.integerLength = #buildIntegerDigits

    if (buildNumberSign == 0 or buildNumberSign == 1) then
      newObject.private.numberSign = buildNumberSign
      newObject.private:normalizeNumber()
    else
      error("[XAF Error] Invalid BigNumber sign value - must be equal to zero '0' or one '1'")
    end

    return newObject.public
  end

  private.checkPrecision = function(self, firstObject, secondObject, digitCount)                    -- [!] Function: checkPrecision(firstObject, secondObject, digitCount) - Checks whether computed number has reached specified precision (used in functions).
    assert(type(firstObject) == "table", "[XAF Utility] Expected TABLE as argument #1")             -- [!] Parameter: firstObject - Previous result of calculated number value.
    assert(type(secondObject) == "table", "[XAF Utility] Expected TABLE as argument #2")            -- [!] Parameter: secondObject - Next result (more precise) of calculated number value.
    assert(type(digitCount) == "number", "[XAF Utility] Expected NUMBER as argument #3")            -- [!] Parameter: digitCount - Number of decimal digits of precision limit (for example '3' means precision equal to 0.001).
                                                                                                    -- [!] Return: precisionResult - Boolean flag of reaching specified precision.
    if (firstObject.returnValue == nil) then
      error("[XAF Error] Required valid BigNumber object to check precision (first)")
    elseif (secondObject.returnValue == nil) then
      error("[XAF Error] Required valid BigNumber object to check precision (second)")
    elseif (xafcoreMath:checkNatural(digitCount, false) == false) then
      error("[XAF Error] Digit count value must be natural number (including zero)")
    else
      local limitString = '0' .. private.separatorDecimal .. string.rep('0', digitCount - 1) .. '1'
      local limitObject = BigNumber:new(limitString)
      local objectDifference = firstObject:subtract(secondObject)
      local objectAbsolute = objectDifference:absoluteValue()
      local precisionResult = objectAbsolute:isLower(limitObject)

      return precisionResult
    end
  end

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
