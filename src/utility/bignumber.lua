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

  private.convertString = function(self, numberString)                                                     -- [!] Function: convertString(numberString) - Creates new BigNumber by converting string in number notation to BigNumber object.
    assert(type(numberString) == "string", "[XAF Utility] Expected STRING as argument #1")                 -- [!] Parameter: numberString - Valid string in Lua number notation (supports exponential notation).
                                                                                                           -- [!] Return: 'true' - If the string has been converted to BigNumber without errors.
    local newDecimalDigits = {}
    local newDecimalLength = 0
    local newIntegerDigits = {}
    local newIntegerLength = 0
    local newNumberSign = 0
    local isDecimal = false
    local stringLength = #numberString

    if (stringLength == 0) then
      error("[XAF Error] Number string for initializing BigNumber must not be empty")
    else
      local firstCharacter = string.sub(numberString, 1, 1)

      if (firstCharacter == '-') then
        if (stringLength == 1) then
          error("[XAF Error] Invalid string for BigNumber object - required digits after minus character")
        else
          newNumberSign = 1
          numberString = string.sub(numberString, 2)
          stringLength = stringLength - 1
        end
      end

      for i = 1, stringLength do
        local currentCharacter = string.sub(numberString, i, i)

        if (tonumber(currentCharacter)) then
          if (isDecimal == true) then
            table.insert(newDecimalDigits, tonumber(currentCharacter))
            newDecimalLength = newDecimalLength + 1
          else
            table.insert(newIntegerDigits, 1, tonumber(currentCharacter))
            newIntegerLength = newIntegerLength + 1
          end
        elseif (currentCharacter == private.separatorDecimal) then
          if (newIntegerLength == 0) then
            newIntegerDigits = {0}
            newIntegerLength = 1
          end

          if (isDecimal == false) then
            isDecimal = true
          else
            error("[XAF Error] Invalid string for BigNumber object - encountered two decimal separators")
          end
        elseif (currentCharacter == 'e' or currentCharacter == 'E') then
          local exponentString = ''
          local exponentValue = 0

          for j = (i + 1), stringLength do
            currentCharacter = string.sub(numberString, j, j)

            if (tonumber(currentCharacter) or currentCharacter == '+' or currentCharacter == '-') then
              exponentString = exponentString .. currentCharacter
            else
              error("[XAF Error] Invalid string for BigNumber object - encountered non-number exponent")
            end
          end

          if (tonumber(exponentString)) then
            exponentValue = tonumber(exponentString)
            private.initialExponent = exponentValue
          else
            error("[XAF Error] Invalid string for BigNumber object - encountered non-number exponent")
          end

          break
        else
          error("[XAF Error] Invalid string for BigNumber object - encountered non-digit character")
        end
      end

      private.decimalDigits = newDecimalDigits
      private.decimalLength = newDecimalLength
      private.integerDigits = newIntegerDigits
      private.integerLength = newIntegerLength
      private.numberSign = newNumberSign

      return true
    end
  end

  private.convertStringRadix = function(self, numberString, radixValue)                                                    -- [!] Function: convertStringRadix(numberString, radixValue) - Converts given string into new BigNumber object with given radix (base).
    assert(type(numberString) == "string", "[XAF Utility] Expected STRING as argument #1")                                 -- [!] Parameter: numberString - New object number value as string representation (this function does not support exponential notation).
    assert(type(radixValue) == "number", "[XAF Utility] Expected NUMBER as argument #2")                                   -- [!] Parameter: radixValue - Number value of entered string base (radix), must be integer from 2 (binary) to 16 (hexadecimal).
                                                                                                                           -- [!] Return: 'true' - If the entered string has been converted into new BigNumber without errors.
    local radixMax = private.radixMaximumValue
    local radixMin = private.radixMinimumValue
    local radixTable = private.radixCharacterTable
    local radixNumber = BigNumber:new(tostring(radixValue))

    if (xafcoreMath:checkInteger(radixValue) == true and radixValue >= radixMin and radixValue <= radixMax) then
      local newDecimalDigits = {}
      local newDecimalLength = 0
      local newIntegerDigits = {}
      local newIntegerLength = 0
      local newNumberSign = 0
      local isDecimal = false
      local stringLength = #numberString
      numberString = string.lower(numberString)

      if (stringLength == 0) then
        error("[XAF Error] Number string for initializing BigNumber must not be empty")
      else
        local firstCharacter = string.sub(numberString, 1, 1)

        if (firstCharacter == '-') then
          if (stringLength == 1) then
            error("[XAF Error] Invalid string for BigNumber object - required digits after minus character")
          else
            newNumberSign = 1
            numberString = string.sub(numberString, 2)
            stringLength = stringLength - 1
          end
        end

        for i = 1, stringLength do
          local currentCharacter = string.sub(numberString, i, i)
          local indexTable = xafcoreTable:searchByValue(radixTable, currentCharacter, 0)
          local indexLength = #indexTable

          if (indexLength == 1) then
            if (indexTable[1] > radixValue) then
              error("[XAF Error] Invalid string for BigNumber object - encountered non-digit character (for this radix)")
            else
              if (isDecimal == true) then
                table.insert(newDecimalDigits, 1, currentCharacter)
                newDecimalLength = newDecimalLength + 1
              else
                table.insert(newIntegerDigits, 1, currentCharacter)
                newIntegerLength = newIntegerLength + 1
              end
            end
          elseif (currentCharacter == private.separatorDecimal) then
            if (newIntegerLength == 0) then
              newIntegerDigits = {0}
              newIntegerLength = 1
            end

            if (isDecimal == false) then
              isDecimal = true
            else
              error("[XAF Error] Invalid string for BigNumber object - encountered two decimal separators")
            end
          elseif (indexLength == 0) then
            error("[XAF Error] Invalid string for BigNumber object - encountered non-digit character")
          else
            error("[XAF Error] Invalid string for BigNumber object - encountered non-digit character")
          end
        end

        local newNumberTable = nil
        local newNumberObject = BigNumber:new('0')
        local decimalDenominator = radixNumber:power(newDecimalLength)
        local decimalNumerator = BigNumber:new('0')

        for i = 1, newIntegerLength do
          local characterRaw = newIntegerDigits[i]
          local characterTable = xafcoreTable:searchByValue(radixTable, characterRaw, 0)
          local characterIndex = BigNumber:new(tostring(characterTable[1] - 1))
          local characterValue = characterIndex:multiply(radixNumber:power(i - 1))

          newNumberObject = newNumberObject:add(characterValue)
        end

        if (decimalDenominator:isEqual(decimalNumerator) == false) then
          for i = 1, newDecimalLength do
            local characterRaw = newDecimalDigits[i]
            local characterTable = xafcoreTable:searchByValue(radixTable, characterRaw, 0)
            local characterIndex = BigNumber:new(tostring(characterTable[1] - 1))
            local characterValue = characterIndex:multiply(radixNumber:power(i - 1))

            decimalNumerator = decimalNumerator:add(characterValue)
          end

          decimalNumerator:setMaxPrecision(public:getMaxPrecision())
          decimalDenominator:setMaxPrecision(public:getMaxPrecision())
          newNumberObject = newNumberObject:add(decimalNumerator:divide(decimalDenominator))
          newNumberObject:setNumberSign(newNumberSign)
          newNumberTable = newNumberObject:returnValue()

          private.decimalDigits = newNumberTable.decimalDigits
          private.decimalLength = newNumberTable.decimalLength
          private.integerDigits = newNumberTable.integerDigits
          private.integerLength = newNumberTable.integerLength
          private.numberSign = newNumberTable.numberSign

          return true
        end
      end
    else
      error("[XAF Error] Invalid BigNumber radix value, must be integer in range from " .. radixMin .. " to " .. radixMax)
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
