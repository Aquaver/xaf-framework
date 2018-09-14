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

  private.normalizeNumber = function(self)                -- [!] Function: normalizeNumber() - Normalizes the number by removing unnecessary leading and trailing zeros.
    local decimalLength = private.decimalLength           -- [!] Return: 'true' - If the number has been normalized properly.
    local integerLength = private.integerLength

    for i = integerLength, 2, -1 do
      if (private.integerDigits[i] == 0) then
        table.remove(private.integerDigits, i)
        private.integerLength = private.integerLength - 1
      else
        break
      end
    end

    for i = decimalLength, 1, -1 do
      if (private.decimalDigits[i] == 0) then
        table.remove(private.decimalDigits, i)
        private.decimalLength = private.decimalLength - 1
      else
        break
      end
    end

    if (private.integerLength < 1) then
      private.integerDigits = {0}
      private.integerLength = 1
    end

    if (private.integerLength == 1 and private.decimalLength == 0) then
      if (private.integerDigits[1] == 0) then
        private.numberSign = 0 -- Change number sign to 0 if integer component is equal to zero and it has no fraction (there are no 'negative zeros').
      end
    end

    return true
  end

  private.rawAdd = function(self, numberObject)                                                                 -- [!] Function: rawAdd(numberObject) - Calculates raw sum of two BigNumber values without considering the sign, used in normal operations.
    assert(type(numberObject) == "table", "[XAF Utility] Expected TABLE as argument #1")                        -- [!] Parameter: numberObject - Valid BigNumber object to compute the sum of them.
                                                                                                                -- [!] Return: BigNumber - Newly created BigNumber object which holds sum of these two objects.
    if (numberObject.returnValue == nil) then
      error("[XAF Error] Invalid BigNumber object - use instance(s) of this class only")
    else
      local numberTable = numberObject:returnValue()
      local decimalDigits = numberTable.decimalDigits
      local decimalLength = numberTable.decimalLength
      local integerDigits = numberTable.integerDigits
      local integerLength = numberTable.integerLength
      local numberSign = numberTable.numberSign

      if (decimalDigits and decimalLength and integerDigits and integerLength and numberSign) then
        local integerLimit = (private.integerLength > integerLength) and private.integerLength or integerLength
        local decimalLimit = (private.decimalLength > decimalLength) and private.decimalLength or decimalLength
        local newDecimalDigits = {}
        local newDecimalLength = 0
        local newIntegerDigits = {}
        local newIntegerLength = 0
        local newNumberSign = 0 -- This function will always return positive (neutral) number.
        local digitCarry = 0

        for i = decimalLimit, 1, -1 do
          local localDecimal = (private.decimalDigits[i] == nil) and 0 or private.decimalDigits[i]
          local otherDecimal = (decimalDigits[i] == nil) and 0 or decimalDigits[i]
          local sumNumber = digitCarry + localDecimal + otherDecimal
          local sumDigit = sumNumber % 10
          local sumCarry = sumNumber / 10

          if (newDecimalDigits[i] == nil) then
            newDecimalDigits[i] = sumDigit
            newDecimalLength = newDecimalLength + 1
          end

          digitCarry = math.floor(sumCarry)
        end

        for i = 1, integerLimit do
          local localInteger = (private.integerDigits[i] == nil) and 0 or private.integerDigits[i]
          local otherInteger = (integerDigits[i] == nil) and 0 or integerDigits[i]
          local sumNumber = digitCarry + localInteger + otherInteger
          local sumDigit = sumNumber % 10
          local sumCarry = sumNumber / 10

          if (newIntegerDigits[i] == nil) then
            newIntegerDigits[i] = sumDigit
            newIntegerLength = newIntegerLength + 1
          end

          digitCarry = math.floor(sumCarry)
        end

        if (digitCarry > 0) then
          table.insert(newIntegerDigits, digitCarry)
          newIntegerLength = newIntegerLength + 1
        end

        return private:buildFromTable(newDecimalDigits, newIntegerDigits, newNumberSign)
      else
        error("[XAF Error] Invalid BigNumber object - use instance(s) of this class only")
      end
    end
  end

  private.rawSubtract = function(self, numberObject)                                                            -- [!] Function: rawSubtract(numberObject) - Calculates raw difference of two BigNumber values without considering the sign, used in normal operations.
    assert(type(numberObject) == "table", "[XAF Utility] Expected TABLE as argument #1")                        -- [!] Parameter: numberObject - Valid BigNumber object to calculate the difference of them.
                                                                                                                -- [!] Return: BigNumber - Created BigNumber object which stores difference between this object and 'numberObject'.
    if (numberObject.returnValue == nil) then
      error("[XAF Error] Invalid BigNumber object - use instance(s) of this class only")
    else
      local absoluteThis = public:absoluteValue()
      local absoluteOther = numberObject:absoluteValue()
      local numberTable = absoluteOther:returnValue()
      local decimalDigits = numberTable.decimalDigits
      local decimalLength = numberTable.decimalLength
      local integerDigits = numberTable.integerDigits
      local integerLength = numberTable.integerLength
      local numberSign = numberTable.numberSign

      if (decimalDigits and decimalLength and integerDigits and integerLength and numberSign) then
        local integerLimit = (private.integerLength > integerLength) and private.integerLength or integerLength
        local decimalLimit = (private.decimalLength > decimalLength) and private.decimalLength or decimalLength
        local newDecimalDigits = {}
        local newDecimalLength = 0
        local newIntegerDigits = {}
        local newIntegerLength = 0
        local newNumberSign = 0 -- This function will always return positive (neutral) number.
        local digitCarry = 0

        if (absoluteThis:isEqual(absoluteOther) == true) then
          return private:buildFromTable({}, {0}, 0) -- If two numbers for subtract are equal then return BigNumber with value zero.
        elseif (absoluteThis:isGreater(absoluteOther) == true) then
          for i = decimalLimit, 1, -1 do
            local localDecimal = (private.decimalDigits[i] == nil) and 0 or private.decimalDigits[i]
            local otherDecimal = (decimalDigits[i] == nil) and 0 or decimalDigits[i]
            local subNumber = ((digitCarry + localDecimal) - otherDecimal)
            local subDigit = nil

            if (subNumber < 0) then
              digitCarry = -1
              subNumber = subNumber + 10
              subDigit = subNumber % 10
            else
              digitCarry = 0
              subDigit = subNumber % 10
            end

            if (newDecimalDigits[i] == nil) then
              newDecimalDigits[i] = subDigit
              newDecimalLength = newDecimalLength + 1
            end
          end

          for i = 1, integerLimit do
            local localInteger = (private.integerDigits[i] == nil) and 0 or private.integerDigits[i]
            local otherInteger = (integerDigits[i] == nil) and 0 or integerDigits[i]
            local subNumber = ((digitCarry + localInteger) - otherInteger)
            local subDigit = nil

            if (subNumber < 0) then
              digitCarry = -1
              subNumber = subNumber + 10
              subDigit = subNumber % 10
            else
              digitCarry = 0
              subDigit = subNumber % 10
            end

            if (newIntegerDigits[i] == nil) then
              newIntegerDigits[i] = subDigit
              newIntegerLength = newIntegerLength + 1
            end
          end

          return private:buildFromTable(newDecimalDigits, newIntegerDigits, newNumberSign)
        elseif (absoluteThis:isLower(absoluteOther) == true) then
          for i = decimalLimit, 1, -1 do
            local localDecimal = (decimalDigits[i] == nil) and 0 or decimalDigits[i]
            local otherDecimal = (private.decimalDigits[i] == nil) and 0 or private.decimalDigits[i]
            local subNumber = ((digitCarry + localDecimal) - otherDecimal)
            local subDigit = nil

            if (subNumber < 0) then
              digitCarry = -1
              subNumber = subNumber + 10
              subDigit = subNumber % 10
            else
              digitCarry = 0
              subDigit = subNumber % 10
            end

            if (newDecimalDigits[i] == nil) then
              newDecimalDigits[i] = subDigit
              newDecimalLength = newDecimalLength + 1
            end
          end

          for i = 1, integerLimit do
            local localInteger = (integerDigits[i] == nil) and 0 or integerDigits[i]
            local otherInteger = (private.integerDigits[i] == nil) and 0 or private.integerDigits[i]
            local subNumber = ((digitCarry + localInteger) - otherInteger)
            local subDigit = nil

            if (subNumber < 0) then
              digitCarry = -1
              subNumber = subNumber + 10
              subDigit = subNumber % 10
            else
              digitCarry = 0
              subDigit = subNumber % 10
            end

            if (newIntegerDigits[i] == nil) then
              newIntegerDigits[i] = subDigit
              newIntegerLength = newIntegerLength + 1
            end
          end

          return private:buildFromTable(newDecimalDigits, newIntegerDigits, newNumberSign)
        end
      else
        error("[XAF Error] Invalid BigNumber object - use instance(s) of this class only")
      end
    end
  end
  
  public.absoluteValue = function(self)         -- [!] Function: absoluteValue() - Returns absolute value of present BigNumber object.
    local decimalDigits = private.decimalDigits -- [!] Return: BigNumber - New object which holds the absolute value of this object.
    local integerDigits = private.integerDigits
    local newNumberSign = 0 -- Absolute value of any number is always positive (neutral).

    return private:buildFromTable(decimalDigits, integerDigits, newNumberSign)
  end
  
  public.add = function(self, numberObject)                                                -- [!] Function: add(numberObject) - Computes sum on two BigNumber object, it considers their signs.
    assert(type(numberObject) == "table", "[XAF Utility] Expected TABLE as argument #1")   -- [!] Parameter: numberObject - Valid BigNumber object to calculate the sum with present object.
                                                                                           -- [!] Return: resultObject - BigNumber object which stores the sum of it and given number object.
    if (numberObject.returnValue == nil) then
      error("[XAF Error] Invalid BigNumber object - use instance(s) of this class only")
    else
      local absoluteThis = public:absoluteValue()
      local absoluteOther = numberObject:absoluteValue()
      local localSign = public:getNumberSign()
      local otherSign = numberObject:getNumberSign()

      if (absoluteOther and otherSign) then
        if (localSign == 0 and otherSign == 0) then
          local resultObject = private:rawAdd(numberObject)
          local resultSign = 0

          resultObject:setNumberSign(resultSign)
          return resultObject
        elseif (localSign == 1 and otherSign == 1) then
          local resultObject = private:rawAdd(numberObject)
          local resultSign = 1

          resultObject:setNumberSign(resultSign)
          return resultObject
        else
          local resultObject = private:rawSubtract(numberObject)
          local resultSign = nil

          if (absoluteThis:isEqual(absoluteOther) == true) then
            resultSign = 0 -- Equal numbers with opposite signs always sum to zero.
          elseif (absoluteThis:isGreater(absoluteOther) == true) then
            resultSign = localSign
          elseif (absoluteThis:isLower(absoluteOther) == true) then
            resultSign = otherSign
          end

          resultObject:setNumberSign(resultSign)
          return resultObject
        end
      else
        error("[XAF Error] Invalid BigNumber object - use instance(s) of this class only")
      end
    end
  end
  
  public.ceiling = function(self)                                              -- [!] Function: ceiling() - Returns lowest integer greater than or equal to this BigNumber.
    local constantOne = BigNumber:new('1')                                     -- [!] Return: resultObject - Newly created BigNumber object that holds result of ceiling function.
    local decimalLength = private.decimalLength
    local integerDigits = private.integerDigits
    local numberSign = public:getNumberSign()
    local resultObject = private:buildFromTable({}, integerDigits, numberSign)

    if (decimalLength > 0) then
      if (numberSign == 0) then
        resultObject = resultObject:add(constantOne)
      end
    end

    return resultObject
  end
  
  public.divide = function(self, numberObject)                                                -- [!] Function: divide(numberObject) - Calculates quotient of two BigNumber numbers, where the present one is dividend.
    assert(type(numberObject) == "table", "[XAF Utility] Expected TABLE as argument #1")      -- [!] Parameter: numberObject - Valid BigNumber object which is a divisor.
                                                                                              -- [!] Return: quotientObject - Calculated quotient with maximum decimal digit precision equal to dividend's maximum precision property.
    if (numberObject.returnValue == nil) then
      error("[XAF Error] Invalid BigNumber object - use instance(s) of this class only")
    else
      local absoluteThis = public:absoluteValue()
      local absoluteOther = numberObject:absoluteValue()
      local constantOne = BigNumber:new('1')
      local constantTen = BigNumber:new("10")
      local localSign = public:getNumberSign()
      local otherSign = numberObject:getNumberSign()
      local quotientObject = nil
      local quotientSign = 0
      local quotientString = '0'

      if (absoluteOther and otherSign) then
        if (absoluteOther:getValue() == '0') then
          error("[XAF Error] BigNumber divisor must not be equal to zero (division by zero)")
        else
          local divisorTable = absoluteOther:returnValue()
          local divisorDecimalLength = divisorTable.decimalLength
          local numberIndex = 1
          local numberTable = {}

          for i = 1, divisorDecimalLength do
            absoluteThis = absoluteThis:multiply(constantTen) -- Shifts 'comma' to remove decimal component in divisor, it makes calculating easier.
            absoluteOther = absoluteOther:multiply(constantTen)
          end

          local dividendTable = absoluteThis:returnValue()
          local dividendDecimalDigits = dividendTable.decimalDigits
          local dividendDecimalLength = dividendTable.decimalLength
          local dividendIntegerDigits = dividendTable.integerDigits
          local dividendIntegerLength = dividendTable.integerLength

          for i = dividendIntegerLength, 1, -1 do
            table.insert(numberTable, dividendIntegerDigits[i])
          end

          for i = 1, dividendDecimalLength do
            table.insert(numberTable, dividendDecimalDigits[i])
          end

          local isDecimal = false
          local interObject = BigNumber:new('0')
          local partialResultDigit = nil
          local partialResult = nil
          local precision = 0
          local precisionMax = public:getMaxPrecision()
          local resultString = tostring(numberTable[1]) -- First leftmost digit of dividend.
          local resultObject = BigNumber:new(resultString)

          while (precision < precisionMax) do -- Repeat calculating until maximum decimal precision reached.
            if (resultObject:isEqual(absoluteOther) == true) then
              partialResultDigit = BigNumber:new('1')
              quotientString = quotientString .. '1'
            elseif (resultObject:isGreater(absoluteOther) == true) then
              partialResultDigit = BigNumber:new('0')
              partialResult = resultObject:absoluteValue()

              while (not partialResult:isLower(absoluteOther) == true) do
                partialResultDigit = partialResultDigit:add(constantOne)
                partialResult = partialResult:subtract(absoluteOther)
              end

              quotientString = quotientString .. partialResultDigit:getValue()
            elseif (resultObject:isLower(absoluteOther) == true) then
              partialResultDigit = BigNumber:new('0')
              quotientString = quotientString .. '0'
            end

            numberIndex = numberIndex + 1
            numberDigit = (numberTable[numberIndex] == nil) and 0 or numberTable[numberIndex]
            interObject = partialResultDigit:multiply(absoluteOther)
            precision = (isDecimal == true) and precision + 1 or precision

            if ((numberIndex - 1) == dividendIntegerLength) then
              isDecimal = true
              quotientString = quotientString .. private.separatorDecimal
            end

            resultObject = resultObject:subtract(interObject)
            resultString = resultObject:getValue() .. numberDigit
            resultObject = BigNumber:new(resultString)
          end
        end

        quotientSign = (localSign == otherSign) and 0 or 1
        quotientObject = BigNumber:new(quotientString)
        quotientObject:setNumberSign(quotientSign)

        return quotientObject
      else
        error("[XAF Error] Invalid BigNumber object - use instance(s) of this class only")
      end
    end
  end
  
  public.floor = function(self)                                                -- [!] Function: floor() - Returns greatest integer less than or equal to this BigNumber object.
    local constantOne = BigNumber:new('1')                                     -- [!] Return: resultObject - BigNumber object which stores value of floor function computed on this object.
    local decimalLength = private.decimalLength
    local integerDigits = private.integerDigits
    local numberSign = public:getNumberSign()
    local resultObject = private:buildFromTable({}, integerDigits, numberSign)

    if (decimalLength > 0) then
      if (numberSign == 1) then
        resultObject = resultObject:subtract(constantOne)
      end
    end

    return resultObject
  end
  
  public.getMaxPrecision = function(self) -- [!] Function: getMaxPrecision() - Returns maximum computable precision value, the number of decimal digits in operations.
    return private.decimalPrecisionMax    -- [!] Return: decimalPrecisionMax - Maximum decimal precision property value.
  end
  
  public.getNumberSign = function(self) -- [!] Function: getNumberSign() - Returns BigNumber object's current sign value (0 means neutral or positive, 1 means negative).
    return private.numberSign           -- [!] Return: numberSign - Number sign value of this object as Lua number.
  end
  
  public.getObjectValue = function(self)                                                 -- [!] Function: getObjectValue() - Returns full copy of this BigNumber object (mostly used in functions).
    local decimalDigits = private.decimalDigits                                          -- [!] Return: objectValue - Newly created BigNumber based on this object.
    local integerDigits = private.integerDigits
    local numberSign = private.numberSign
    local objectValue = private:buildFromTable(decimalDigits, integerDigits, numberSign)

    return objectValue
  end
  
  public.getPrecision = function(self) -- [!] Function: getPrecision() - Returns BigNumber current precision value (number of decimal digits returned in 'getValue()' function).
    return private.decimalPrecision    -- [!] Return: decimalPrecision - Value of current precision property.
  end
  
  public.getThousandsSeparators = function(self)               -- [!] Function: getThousandsSeparators() - Returns BigNumber thousands group separators (after each three digits), both decimal and integer.
    local separatorInteger = private.separatorThousandsInteger -- [!] Return: separatorInteger, separatorDecimal - Separator characters for both thousands integer and fraction component.
    local separatorDecimal = private.separatorThousandsDecimal

    return separatorInteger, separatorDecimal
  end
  
  public.getValue = function(self)                                                                          -- [!] Function: getValue() - Returns BigNumber object's current number value as string.
    local decimalDigits = private.decimalDigits                                                             -- [!] Return: stringValue - String representation of BigNumber value.
    local decimalLength = private.decimalLength
    local decimalPrecision = (private.decimalPrecision == -1) and decimalLength or private.decimalPrecision
    local integerDigits = private.integerDigits
    local integerLength = private.integerLength
    local numberSign = private.numberSign
    local stringValue = ''

    if (numberSign == 1) then
      stringValue = stringValue .. '-'
    end

    for i = integerLength, 1, -1 do
      if (i % 3 == 0) then
        stringValue = stringValue .. private.separatorThousandsInteger
      end

      stringValue = stringValue .. integerDigits[i]
    end

    if (decimalLength > 0 and decimalPrecision > 0) then
      stringValue = stringValue .. private.separatorDecimal

      for i = 1, decimalLength do
        decimalPrecision = decimalPrecision - 1
        stringValue = stringValue .. decimalDigits[i]

        if (i % 3 == 0) then
          stringValue = stringValue .. private.separatorThousandsDecimal
        end

        if (decimalPrecision == 0) then
          break
        end
      end
    end

    if (numberSign == 0 and string.sub(stringValue, 1, 1) == ' ') then
      stringValue = string.sub(stringValue, 2)
    elseif (numberSign == 1 and string.sub(stringValue, 2, 2) == ' ') then -- Consider negative numbers with leading minus character.
      stringValue = '-' .. string.sub(stringValue, 3)
    end

    if (string.sub(stringValue, -1) == ' ') then
      stringValue = string.sub(stringValue, 1, -2)
    end

    if (decimalPrecision > 0) then
      stringValue = (decimalLength == 0) and stringValue .. private.separatorDecimal or stringValue
      stringValue = stringValue .. string.rep('0', decimalPrecision)
    end

    return stringValue
  end
  
  public.getValueRadix = function(self, radixValue)                                                                        -- [!] Function: getValueRadix(radixValue) - Returns current BigNumber object's number value in specified radix (base).
    assert(type(radixValue) == "number", "[XAF Utility] Expected NUMBER as argument #1")                                   -- [!] Parameter: radixValue - Number base value, must be integer from 2 (binary) to 16 (hexadecimal).
                                                                                                                           -- [!] Return: numberString - String representation of this number object in given radix.
    local constantZero = BigNumber:new('0')
    local fractionPrecision = 0
    local radixMax = private.radixMaximumValue
    local radixMin = private.radixMinimumValue
    local radixTable = private.radixCharacterTable
    local radixNumber = BigNumber:new(tostring(radixValue))

    if (xafcoreMath:checkInteger(radixValue) == true and radixValue >= radixMin and radixValue <= radixMax) then
      local numberValue = public:absoluteValue()
      local numberInteger = numberValue:floor()
      local numberFraction = numberValue:subtract(numberInteger)
      local numberRemainder = BigNumber:new('1')
      local numberIndex = 0
      local numberCharacter = ''
      local numberString = ''
      local numberSign = public:getNumberSign()

      if (numberInteger:isEqual(constantZero) == 0) then
        numberString = numberString .. '0'
      else
        while (numberInteger:isEqual(constantZero) == false) do
          numberRemainder = numberInteger:modulo(radixNumber)
          numberInteger = numberInteger:divide(radixNumber)
          numberInteger = numberInteger:floor()

          numberCharacter = radixTable[tonumber(numberRemainder:getValue()) + 1]
          numberString = numberCharacter .. numberString
          numberIndex = numberIndex + 1

          if (numberIndex % 3 == 0) then
            numberString = private.separatorThousandsInteger .. numberString
          end
        end
      end

      if (numberFraction:isEqual(constantZero) == false) then
        numberString = numberString .. private.separatorDecimal
        numberIndex = 0

        while (fractionPrecision < private.decimalPrecisionMax and numberFraction:isEqual(constantZero) == false) do
          numberFraction = numberFraction:multiply(radixNumber)
          numberRemainder = numberFraction:floor()
          numberFraction = numberFraction:subtract(numberRemainder)

          numberCharacter = radixTable[tonumber(numberRemainder:getValue()) + 1]
          numberString = numberString .. numberCharacter
          numberIndex = numberIndex + 1
          fractionPrecision = fractionPrecision + 1

          if (numberIndex % 3 == 0) then
            numberString = numberString .. private.separatorThousandsDecimal
          end
        end
      end

      if (numberSign == 0 and string.sub(numberString, 1, 1) == ' ') then
        numberString = string.sub(numberString, 2)
      elseif (numberSign == 1 and string.sub(numberString, 2, 2) == ' ') then -- Consider negative numbers with leading minus character.
        numberString = '-' .. string.sub(numberString, 3)
      end

      if (string.sub(numberString, -1) == ' ') then
        numberString = string.sub(numberString, 1, -2)
      end

      if (numberSign == 1) then
        numberString = '-' .. numberString
      end

      return numberString
    else
      error("[XAF Error] Invalid BigNumber radix value, must be integer in range from " .. radixMin .. " to " .. radixMax)
    end
  end
  
  public.greatestCommonDivisor = function(self, numberObject)                                   -- [!] Function: greatestCommonDivisor(numberObject) - Calculates GCD (greatest common divisor) of present BigNumber and parameter.
    assert(type(numberObject) == "table", "[XAF Utility] Expected TABLE as argument #1")        -- [!] Parameter: numberObject - Valid BigNumber object as second pair number for GCD function.
                                                                                                -- [!] Return: resultObject - Computed greatest common divisor of this object and parameter's one.
    if (numberObject.returnValue == nil) then
      error("[XAF Error] Invalid BigNumber object - use instance(s) of this class only")
    else
      local absoluteThis = public:absoluteValue()
      local absoluteOther = numberObject:absoluteValue()
      local constantZero = BigNumber:new('0')
      local resultObject = absoluteThis:getObjectValue()
      local helperObject = nil

      if (absoluteOther) then
        if (absoluteThis:isInteger() == false or absoluteOther:isInteger() == false) then
          error("[XAF Error] Greatest common divisor must be calculated on integer BigNumbers")
        else
          while (absoluteOther:isEqual(constantZero) == false) do
            helperObject = resultObject:modulo(absoluteOther)
            resultObject = absoluteOther:getObjectValue()
            absoluteOther = helperObject:getObjectValue()
          end

          return resultObject
        end
      else
        error("[XAF Error] Invalid BigNumber object - use instance(s) of this class only")
      end
    end
  end
  
  public.isEqual = function(self, numberObject)                                                    -- [!] Function: isEqual(numberObject) - Checks is this BigNumber equal to given as parameter one.
    assert(type(numberObject) == "table", "[XAF Utility] Expected TABLE as argument #1")           -- [!] Parameter: numberObject - Valid BigNumber object to check it is equal to this one.
                                                                                                   -- [!] Return: 'true' or 'false' - Boolean flag is this BigNumber equal to 'numberObject'.
    if (numberObject.returnValue == nil) then
      error("[XAF Error] Invalid BigNumber object - use instance(s) of this class only")
    else
      local numberTable = numberObject:returnValue()
      local decimalDigits = numberTable.decimalDigits
      local decimalLength = numberTable.decimalLength
      local integerDigits = numberTable.integerDigits
      local integerLength = numberTable.integerLength
      local numberSign = numberTable.numberSign

      if (decimalDigits and decimalLength and integerDigits and integerLength and numberSign) then
        if (private.numberSign ~= numberSign) then
          return false
        elseif (private.integerLength ~= integerLength) then
          return false
        elseif (private.decimalLength ~= decimalLength) then
          return false
        else
          for i = integerLength, 1, -1 do
            local localInteger = private.integerDigits[i]
            local otherInteger = integerDigits[i]

            if (localInteger ~= otherInteger) then
              return false
            end
          end

          for i = 1, decimalLength do
            local localDecimal = private.decimalDigits[i]
            local otherDecimal = decimalDigits[i]

            if (localDecimal ~= otherDecimal) then
              return false
            end
          end
        end

        return true
      else
        error("[XAF Error] Invalid BigNumber object - use instance(s) of this class only")
      end
    end
  end
  
  public.isGreater = function(self, numberObject)                                                                 -- [!] Function: isGreater(numberObject) - Checks is this BigNumber greater than given one.
    assert(type(numberObject) == "table", "[XAF Utility] Expected TABLE as argument #1")                          -- [!] Parameter: numberObject - Valid BigNumber object to check it is lower than this one.
                                                                                                                  -- [!] Return: 'true' or 'false' - Boolean flag is this BigNumber greater than 'numberObject'.
    if (numberObject.returnValue == nil) then
      error("[XAF Error] Invalid BigNumber object - use instance(s) of this class only")
    else
      local numberTable = numberObject:returnValue()
      local decimalDigits = numberTable.decimalDigits
      local decimalLength = numberTable.decimalLength
      local integerDigits = numberTable.integerDigits
      local integerLength = numberTable.integerLength
      local numberSign = numberTable.numberSign

      if (decimalDigits and decimalLength and integerDigits and integerLength and numberSign) then
        if (public:isEqual(numberObject) == true) then
          return false
        elseif (private.numberSign ~= numberSign) then
          return (private.numberSign < numberSign)
        elseif (private.integerLength ~= integerLength) then
          if (private.numberSign == 0) then
            return (private.integerLength > integerLength)
          else
            return (private.integerLength < integerLength)
          end
        else
          local integerLimit = (private.integerLength > integerLength) and private.integerLength or integerLength
          local decimalLimit = (private.decimalLength > decimalLength) and private.decimalLength or decimalLength

          for i = integerLimit, 1, -1 do
            local localInteger = (private.integerDigits[i] == nil) and 0 or private.integerDigits[i]
            local otherInteger = (integerDigits[i] == nil) and 0 or integerDigits[i]

            if (localInteger ~= otherInteger) then
              if (private.numberSign == 0) then
                return (localInteger > otherInteger)
              else
                return (localInteger < otherInteger)
              end
            end
          end

          for i = 1, decimalLimit do
            local localDecimal = (private.decimalDigits[i] == nil) and 0 or private.decimalDigits[i]
            local otherDecimal = (decimalDigits[i] == nil) and 0 or decimalDigits[i]

            if (localDecimal ~= otherDecimal) then
              if (private.numberSign == 0) then
                return (localDecimal > otherDecimal)
              else
                return (localDecimal < otherDecimal)
              end
            end
          end
        end

        return true
      else
        error("[XAF Error] Invalid BigNumber object - use instance(s) of this class only")
      end
    end
  end
  
  public.isInteger = function(self)                                  -- [!] Function: isInteger() - Checks whether this BigNumber object is an integer (has not fraction component).
    local approximationLower = public:floor()                        -- [!] Return: isInteger - Boolean flag, is the present object an integer value.
    local approximationUpper = public:ceiling()
    local isInteger = approximationLower:isEqual(approximationUpper)

    return isInteger
  end
  
  public.isLower = function(self, numberObject)                                                                   -- [!] Function: isLower(numberObject) - Checks is this BigNumber lower than given one.
    assert(type(numberObject) == "table", "[XAF Utility] Expected TABLE as argument #1")                          -- [!] Parameter: numberObject - Valid BigNumber object to check it is greater than this one.
                                                                                                                  -- [!] Return: 'true' or 'false' - Boolean flag is this BigNumber lower than 'numberObject'.
    if (numberObject.returnValue == nil) then
      error("[XAF Error] Invalid BigNumber object - use instance(s) of this class only")
    else
      local numberTable = numberObject:returnValue()
      local decimalDigits = numberTable.decimalDigits
      local decimalLength = numberTable.decimalLength
      local integerDigits = numberTable.integerDigits
      local integerLength = numberTable.integerLength
      local numberSign = numberTable.numberSign

      if (decimalDigits and decimalLength and integerDigits and integerLength and numberSign) then
        if (public:isEqual(numberObject) == true) then
          return false
        elseif (private.numberSign ~= numberSign) then
          return (private.numberSign > numberSign)
        elseif (private.integerLength ~= integerLength) then
          if (private.numberSign == 0) then
            return (private.integerLength < integerLength)
          else
            return (private.integerLength > integerLength)
          end
        else
          local integerLimit = (private.integerLength > integerLength) and private.integerLength or integerLength
          local decimalLimit = (private.decimalLength > decimalLength) and private.decimalLength or decimalLength

          for i = integerLimit, 1, -1 do
            local localInteger = (private.integerDigits[i] == nil) and 0 or private.integerDigits[i]
            local otherInteger = (integerDigits[i] == nil) and 0 or integerDigits[i]

            if (localInteger ~= otherInteger) then
              if (private.numberSign == 0) then
                return (localInteger < otherInteger)
              else
                return (localInteger > otherInteger)
              end
            end
          end

          for i = 1, decimalLimit do
            local localDecimal = (private.decimalDigits[i] == nil) and 0 or private.decimalDigits[i]
            local otherDecimal = (decimalDigits[i] == nil) and 0 or decimalDigits[i]

            if (localDecimal ~= otherDecimal) then
              if (private.numberSign == 0) then
                return (localDecimal < otherDecimal)
              else
                return (localDecimal > otherDecimal)
              end
            end
          end
        end

        return true
      else
        error("[XAF Error] Invalid BigNumber object - use instance(s) of this class only")
      end
    end
  end
  
  public.isNatural = function(self, positive)                            -- [!] Function: isNatural(positive) - Checks whether the present BigNumber object belongs to set of natural numbers.
    local approximationLower = public:floor()                            -- [!] Parameter: positive - If 'true' then zero will not be treated as natural number.
    local approximationUpper = public:ceiling()                          -- [!] Return: isNatural - Boolean flag is this BigNumber value natural.
    local constantNegative = BigNumber:new('-1')
    local constantZero = BigNumber:new('0')
    local isInteger = approximationLower:isEqual(approximationUpper)
    local isNatural = (isInteger and public:isGreater(constantNegative))

    if (positive == true) then
      isNatural = (isNatural and public:isGreater(constantZero))
    end

    return isNatural
  end
  
  public.lowestCommonMultiple = function(self, numberObject)                                   -- [!] Function: lowestCommonMultiple(numberObject) - Computes LCM (lowest common multiple) of two BigNumber objects.
    assert(type(numberObject) == "table", "[XAF Utility] Expected TABLE as argument #1")       -- [!] Parameter: numberObject - Valid BigNumber object as second pair number for LCM function.
                                                                                               -- [!] Return: resultObject - Newly created BigNumber which holds value of calculated lowest common multiple.
    if (numberObject.returnValue == nil) then
      error("[XAF Error] Invalid BigNumber object - use instance(s) of this class only")
    else
      local absoluteThis = public:absoluteValue()
      local absoluteOther = numberObject:absoluteValue()

      if (absoluteOther) then
        if (absoluteThis:isInteger() == false or absoluteOther:isInteger() == false) then
          error("[XAF Error] Lowest common multiple must be calculates on integer BigNumbers")
        else
          local divisorObject = absoluteThis:greatestCommonDivisor(absoluteOther)
          local helperObject = absoluteThis:multiply(absoluteOther)
          local resultObject = helperObject:divide(divisorObject)

          return resultObject
        end
      else
        error("[XAF Error] Invalid BigNumber object - use instance(s) of this class only")
      end
    end
  end
  
  public.modularAdd = function(self, numberObject, modulusObject)                                  -- [!] Function: modularAdd(numberObject, modulusObject) - Performs modular arithmetic addition on parameter BigNumber object.
    assert(type(numberObject) == "table", "[XAF Utility] Expected TABLE as argument #1")           -- [!] Parameter: numberObject - Second pair number which is an addend in this operation.
    assert(type(modulusObject) == "table", "[XAF Utility] Expected TABLE as argument #2")          -- [!] Parameter: modulusObject - Modulo value for this addition, also upper bound for the result.
                                                                                                   -- [!] Return: modulusResult - Calculated value of '(thisObject + numberObject) mod modulusObject' result.
    if (numberObject.returnValue == nil) then
      error("[XAF Error] Invalid BigNumber object - use instance(s) of this class only")
    elseif (modulusObject.returnValue == nil) then
      error("[XAF Error] Invalid BigNumber (modulus) object - use instance(s) of this class only")
    else
      if (public:isInteger() == false or numberObject:isInteger() == false) then
        error("[XAF Error] BigNumber modular operations require both numbers to be integer")
      elseif (modulusObject:isNatural(false) == false) then
        error("[XAF Error] BigNumber modulus must be natural number (including zero)")
      else
        local modulusFirst = public:modulo(modulusObject)
        local modulusSecond = numberObject:modulo(modulusObject)
        local modulusSum = modulusFirst:add(modulusSecond)
        local modulusResult = modulusSum:modulo(modulusObject)

        return modulusResult
      end
    end
  end
  
  public.modularInverse = function(self, modulusObject)                                            -- [!] Function: modularInverse(modulusObject) - Finds modular arithmetic multiplicative inverse of this BigNumber.
    assert(type(modulusObject) == "table", "[XAF Utility] Expected TABLE as argument #1")          -- [!] Parameter: modulusObject - Modulo value of the inversion, upper bound for the result.
                                                                                                   -- [!] Return: modulusResult - Value of '(thisObject ^ -1) mod modulusObject' result (returns -1 if there is no inverse).
    if (modulusObject.returnValue == nil) then
      error("[XAF Error] Invalid BigNumber (modulus) object - use instance(s) of this class only")
    else
      if (public:isInteger() == false) then
        error("[XAF Error] BigNumber modular inversion requires this number to be integer")
      elseif (modulusObject:isNatural(false) == false) then
        error("[XAF Error] BigNumber modulus must be natural number (including zero)")
      else
        local constantNegative = BigNumber:new('-1')
        local constantOne = BigNumber:new('1')
        local modulusIndex = constantOne:getObjectValue()

        if (public:greatestCommonDivisor(modulusObject):isEqual(constantOne) == true) then
          while (modulusIndex:isEqual(modulusObject) == false) do
            local modulusResult = modulusIndex:subtract(constantOne)
            local modulusProduct = public:multiply(modulusResult)
            local modulusValue = modulusProduct:modulo(modulusObject)

            if (modulusValue:isEqual(constantOne) == true) then
              return modulusResult
            else
              modulusIndex = modulusIndex:add(constantOne)
            end
          end
        else
          return constantNegative -- This BigNumber has not modular multiplicative inverse, returning BigNumber equal to -1.
        end
      end
    end
  end
  
  public.modularMultiply = function(self, numberObject, modulusObject)                             -- [!] Function: modularMultiply(numberObject, modulusObject) - Calculates modular arithmetic multiplication on parameter number object.
    assert(type(numberObject) == "table", "[XAF Utility] Expected TABLE as argument #1")           -- [!] Parameter: numberObject - BigNumber object, acts as multiplicand in this operation.
    assert(type(modulusObject) == "table", "[XAF Utility] Expected TABLE as argument #2")          -- [!] Parameter: modulusObject - Modulo value for this multiplication, also upper bound for the result.
                                                                                                   -- [!] Return: modulusResult - Calculated value of '(thisObject * numberObject) mod modulusObject' result.
    if (numberObject.returnValue == nil) then
      error("[XAF Error] Invalid BigNumber object - use instance(s) of this class only")
    elseif (modulusObject.returnValue == nil) then
      error("[XAF Error] Invalid BigNumber (modulus) object - use instance(s) of this class only")
    else
      if (public:isInteger() == false or numberObject:isInteger() == false) then
        error("[XAF Error] BigNumber modular operations require both numbers to be integer")
      elseif (modulusObject:isNatural(false) == false) then
        error("[XAF Error] BigNumber modulus must be natural number (including zero)")
      else
        local modulusFirst = public:modulo(modulusObject)
        local modulusSecond = numberObject:modulo(modulusObject)
        local modulusProduct = modulusFirst:multiply(modulusSecond)
        local modulusResult = modulusProduct:modulo(modulusObject)

        return modulusResult
      end
    end
  end
  
  public.modularPower = function(self, exponent, modulusObject)                                          -- [!] Function: modularPower(exponent, modulusObject) - Performs modular arithmetic exponentiation on parameter exponent.
    assert(type(exponent) == "number", "[XAF Utility] Expected NUMBER as argument #1")                   -- [!] Parameter: exponent - Power exponent, as primitive Lua number, which must be natural (including zero).
    assert(type(modulusObject) == "table", "[XAF Utility] Expected TABLE as argument #2")                -- [!] Parameter: modulusObject - Modulo value for this exponentiation, also upper bound for the result.
                                                                                                         -- [!] Return: modulusResult - Computed value of '(thisObject ^ exponent) mod modulusObject' result.
    if (modulusObject.returnValue == nil) then
      error("[XAF Error] Invalid BigNumber (modulus) object - use instance(s) of this class only")
    else
      if (public:isInteger() == false) then
        error("[XAF Error] BigNumber modular exponentiation requires this number to be integer")
      elseif (xafcoreMath:checkNatural(exponent, false) == false) then
        error("[XAF Error] BigNumber modular exponentiation requires natural exponent (including zero)")
      elseif (modulusObject:isNatural(false) == false) then
        error("[XAF Error] BigNumber modulus must be natural number (including zero)")
      else
        local constantOne = BigNumber:new('1')
        local constantZero = BigNumber:new('0')
        local modulusResult = constantOne:getObjectValue()
        local modulusValue = nil

        if (modulusObject:isEqual(constantOne) == true) then
          return constantZero
        else
          for i = 1, exponent do
            modulusValue = public:multiply(modulusResult)
            modulusResult = modulusValue:modulo(modulusObject)
          end

          return modulusResult
        end
      end
    end
  end
  
  public.modularSubtract = function(self, numberObject, modulusObject)                             -- [!] Function: modularSubtract(numberObject, modulusObject) - Computes modular arithmetic subtraction on parameter BigNumber.
    assert(type(numberObject) == "table", "[XAF Utility] Expected TABLE as argument #1")           -- [!] Parameter: numberObject - Valid BigNumber which acts as subtrahend in this operation.
    assert(type(modulusObject) == "table", "[XAF Utility] Expected TABLE as argument #2")          -- [!] Parameter: modulusObject - Modulo value for this subtraction, also upper bound for the result.
                                                                                                   -- [!] Return: modulusResult - Computed value of '(thisObject - numberObject) mod modulusObject' result.
    if (numberObject.returnValue == nil) then
      error("[XAF Error] Invalid BigNumber object - use instance(s) of this class only")
    elseif (modulusObject.returnValue == nil) then
      error("[XAF Error] Invalid BigNumber (modulus) object - use instance(s) of this class only")
    else
      if (public:isInteger() == false or numberObject:isInteger() == false) then
        error("[XAF Error] BigNumber modular operations require both numbers to be integer")
      elseif (modulusObject:isNatural(false) == false) then
        error("[XAF Error] BigNumber modulus must be natural number (including zero)")
      else
        local modulusFirst = public:modulo(modulusObject)
        local modulusSecond = numberObject:modulo(modulusObject)
        local modulusDifference = modulusFirst:subtract(modulusSecond)
        local modulusResult = modulusDifference:modulo(modulusObject)

        return modulusResult
      end
    end
  end
  
  public.modulo = function(self, numberObject)                                           -- [!] Function: modulo(numberObject) - Calculates remainder after division of this BigNumber by divisor.
    assert(type(numberObject) == "table", "[XAF Utility] Expected TABLE as argument #1") -- [!] Parameter: numberObject - Valid BigNumber object as divisor for the modulo (modulus).
                                                                                         -- [!] Return: moduloResult - BigNumber object which stores computed modulo.
    if (numberObject.returnValue == nil) then
      error("[XAF Error] Invalid BigNumber object - use instance(s) of this class only")
    else
      if (public:isInteger() == true and numberObject:isInteger() == true) then
        local quotientRaw = public:divide(numberObject)
        local quotientFloor = quotientRaw:floor()
        local moduloMultiply = numberObject:multiply(quotientFloor)
        local moduloResult = public:subtract(moduloMultiply)

        return moduloResult
      else
        error("[XAF Error] BigNumber modulo requires both values to be integer")
      end
    end
  end
  
  public.multiply = function(self, numberObject)                                                          -- [!] Function: multiply(numberObject) - Performs a multiplication with present object as multiplier and given one as multiplicand.
    assert(type(numberObject) == "table", "[XAF Utility] Expected TABLE as argument #1")                  -- [!] Parameter: numberObject - Valid BigNumber object which will be multiplied with this object.
                                                                                                          -- [!] Return: resultObject - Result of the multiplication as newly created BigNumber.
    if (numberObject.returnValue == nil) then
      error("[XAF Error] Invalid BigNumber object - use instance(s) of this class only")
    else
      local absoluteThis = public:absoluteValue()
      local absoluteOther = numberObject:absoluteValue()
      local localSign = public:getNumberSign()
      local otherSign = numberObject:getNumberSign()
      local numberFirst = nil
      local numberSecond = nil

      if (absoluteOther and otherSign) then
        local digitsFirst = {}
        local digitsSecond = {}
        local shiftNumbers = {}
        local totalResult = private:buildFromTable({}, {0}, 0) -- Sum of all shift numbers gives the result of multiplication.
        numberFirst = (absoluteThis:isGreater(absoluteOther) == true) and absoluteThis or absoluteOther
        numberSecond = (absoluteThis:isGreater(absoluteOther) == true) and absoluteOther or absoluteThis

        local firstNumberTable = numberFirst:returnValue()
        local firstDecimalDigits = firstNumberTable.decimalDigits
        local firstDecimalLength = firstNumberTable.decimalLength
        local firstIntegerDigits = firstNumberTable.integerDigits
        local firstIntegerLength = firstNumberTable.integerLength

        local secondNumberTable = numberSecond:returnValue()
        local secondDecimalDigits = secondNumberTable.decimalDigits
        local secondDecimalLength = secondNumberTable.decimalLength
        local secondIntegerDigits = secondNumberTable.integerDigits
        local secondIntegerLength = secondNumberTable.integerLength

        for i = firstDecimalLength, 1, -1 do
          table.insert(digitsFirst, firstDecimalDigits[i])
        end

        for i = 1, firstIntegerLength do
          table.insert(digitsFirst, firstIntegerDigits[i])
        end

        for i = secondDecimalLength, 1, -1 do
          table.insert(digitsSecond, secondDecimalDigits[i])
        end

        for i = 1, secondIntegerLength do
          table.insert(digitsSecond, secondIntegerDigits[i])
        end

        for i = 1, #digitsSecond do
          local digitCarry = 0
          local digitMultiply = 0
          local result = 0
          local resultCarry = 0
          shiftNumbers[i] = {}

          for j = 1, #digitsFirst do
            result = (digitsSecond[i] * digitsFirst[j]) + digitCarry
            resultCarry = result / 10
            digitMultiply = result % 10

            digitCarry = math.floor(resultCarry)
            table.insert(shiftNumbers[i], digitMultiply)
          end

          if (digitCarry > 0) then
            table.insert(shiftNumbers[i], digitCarry)
          end

          for j = 1, i - 1 do
            table.insert(shiftNumbers[i], 1, 0) -- Filling shifted numbers with trailing zeros to sum them later.
          end

          shiftNumbers[i] = private:buildFromTable({}, shiftNumbers[i], 0)
        end

        for i = 1, #shiftNumbers do
          totalResult = totalResult:add(shiftNumbers[i])
        end

        local resultObject = nil
        local resultTable = totalResult:returnValue()
        local resultDecimalDigits = {}
        local resultDecimalLength = firstDecimalLength + secondDecimalLength
        local resultIntegerDigits = resultTable.integerDigits
        local resultNumberSign = (localSign == otherSign) and 0 or 1

        for i = 1, resultDecimalLength do
          local resultDigitRaw = table.remove(resultIntegerDigits, 1)
          local resultDigit = (resultDigitRaw == nil) and 0 or resultDigitRaw

          table.insert(resultDecimalDigits, 1, resultDigit)
        end

        resultObject = private:buildFromTable(resultDecimalDigits, resultIntegerDigits, resultNumberSign)
        return resultObject
      else
        error("[XAF Error] Invalid BigNumber object - use instance(s) of this class only")
      end
    end
  end
  
  public.power = function(self, exponent)                                              -- [!] Function: power(exponent) - Calculates result of exponentiation of this BigNumber to parameter.
    assert(type(exponent) == "number", "[XAF Utility] Expected NUMBER as argument #1") -- [!] Parameter: exponent - Power exponent, as primitive Lua number (must be integer, may be negative to inverse).
                                                                                       -- [!] Return: resultValue - New BigNumber which stores computed exponentiation result.
    if (xafcoreMath:checkInteger(exponent) == true) then
      local constantOne = BigNumber:new('1')
      local exponentAbs = math.abs(exponent)
      local powerResult = public:getObjectValue()
      local powerValue = constantOne:getObjectValue()
      local resultValue = nil

      if (exponent == 0) then
        return constantOne
      else
        while (exponentAbs > 1) do
          if (exponentAbs % 2 == 0) then
            powerResult = powerResult:multiply(powerResult)
            exponentAbs = exponentAbs / 2
          else
            powerValue = powerResult:multiply(powerValue)
            powerResult = powerResult:multiply(powerResult)
            exponentAbs = (exponentAbs - 1) / 2
          end
        end

        if (exponent < 0) then
          constantOne:setMaxPrecision(public:getMaxPrecision())
          resultValue = powerResult:multiply(powerValue)
          resultValue = constantOne:divide(resultValue)
        else
          resultValue = powerResult:multiply(powerValue)
        end

        return resultValue
      end
    else
      error("[XAF Error] Invalid BigNumber power exponent - required integer value")
    end
  end
  
  public.returnValue = function(self)            -- [!] Function: returnValue() - Returns BigNumber object's private values, used in operations (not intended to normal use).
    return {                                     -- [!] Return: ... - Table with object's private values.
      ["decimalDigits"] = private.decimalDigits,
      ["decimalLength"] = private.decimalLength,
      ["integerDigits"] = private.integerDigits,
      ["integerLength"] = private.integerLength,
      ["numberSign"] = private.numberSign
    }
  end
  
  public.rootCube = function(self)                                                        -- [!] Function: rootCube() - Computes approximation of cube (third degree) root of this BigNumber.
    local absoluteThis = public:absoluteValue()                                           -- [!] Return: rootResult - BigNumber result of calculated cube root of this object.
    local constantDegree = BigNumber:new('3')
    local constantMultiplier = BigNumber:new('2')
    local rootInitial = math.pow(absoluteThis:getValue(), 1 / 3)
    local rootApproximation = (math.ceil(rootInitial) + math.floor(rootInitial)) / 2
    local rootResult = BigNumber:new(tostring(rootApproximation))
    local rootPrecision = public:getMaxPrecision()
    local rootPrevious = rootResult:getObjectValue()
    local rootQuotient = public:getObjectValue()
    local rootProduct = nil
    local rootSum = nil

    rootQuotient:setMaxPrecision(rootPrecision)

    repeat
      rootPrevious = rootResult:getObjectValue()
      rootProduct = rootPrevious:multiply(constantMultiplier)
      rootSum = rootProduct:add(rootQuotient:divide(rootPrevious:power(2)))
      rootResult = rootSum:divide(constantDegree)
    until (private:checkPrecision(rootPrevious, rootResult, rootPrecision) == true)

    local decimalLength = private.decimalLength
    local integerLength = private.integerLength
    local digitLimit = (decimalLength > integerLength) and decimalLength or integerLength

    for i = 1, digitLimit do
      rootPrevious = rootResult:getObjectValue()
      rootProduct = rootPrevious:multiply(constantMultiplier)
      rootSum = rootProduct:add(rootQuotient:divide(rootPrevious:power(2)))
      rootResult = rootSum:divide(constantDegree)
    end

    rootResult:setNumberSign(public:getNumberSign())
    rootResult:trimDecimal(rootPrecision)
    return rootResult
  end
  
  public.rootFourth = function(self)                                                        -- [!] Function: rootFourth() - Calculates approximated value of fourth degree root of present BigNumber number object.
    if (public:getNumberSign() == 1) then                                                   -- [!] Return: rootResult - Computed result value of fourth degree root of this BigNumber.
      error("[XAF Error] Attempt to calculate fourth degree root of negative number")
    else
      local constantDegree = BigNumber:new('4')
      local constantMultiplier = BigNumber:new('3')
      local rootInitial = math.pow(public:getValue(), 1 / 4)
      local rootApproximation = (math.ceil(rootInitial) + math.floor(rootInitial)) / 2
      local rootResult = BigNumber:new(tostring(rootApproximation))
      local rootPrecision = public:getMaxPrecision()
      local rootPrevious = rootResult:getObjectValue()
      local rootQuotient = public:getObjectValue()
      local rootProduct = nil
      local rootSum = nil

      rootQuotient:setMaxPrecision(rootPrecision)

      repeat
        rootPrevious = rootResult:getObjectValue()
        rootProduct = rootPrevious:multiply(constantMultiplier)
        rootSum = rootProduct:add(rootQuotient:divide(rootPrevious:power(3)))
        rootResult = rootSum:divide(constantDegree)
      until (private:checkPrecision(rootPrevious, rootResult, rootPrecision) == true)

      local decimalLength = private.decimalLength
      local integerLength = private.integerLength
      local digitLimit = (decimalLength > integerLength) and decimalLength or integerLength

      for i = 1, digitLimit do
        rootPrevious = rootResult:getObjectValue()
        rootProduct = rootPrevious:multiply(constantMultiplier)
        rootSum = rootProduct:add(rootQuotient:divide(rootPrevious:power(3)))
        rootResult = rootSum:divide(constantDegree)
      end

      rootResult:trimDecimal(rootPrecision)
      return rootResult
    end
  end
  
  public.rootSquare = function(self)                                                        -- [!] Function: rootSquare() - Calculates approximation of square (second degree) root of this BigNumber.
    if (public:getNumberSign() == 1) then                                                   -- [!] Return: rootResult - Result of computed square root of present number object.
      error("[XAF Error] Attempt to calculate square root of negative number")
    else
      local constantDegree = BigNumber:new('2')
      local rootInitial = math.pow(public:getValue(), 1 / 2)
      local rootApproximation = (math.ceil(rootInitial) + math.floor(rootInitial)) / 2
      local rootResult = BigNumber:new(tostring(rootApproximation))
      local rootPrecision = public:getMaxPrecision()
      local rootPrevious = rootResult:getObjectValue()
      local rootQuotient = public:getObjectValue()
      local rootSum = nil

      rootQuotient:setMaxPrecision(rootPrecision)

      repeat
        rootPrevious = rootResult:getObjectValue()
        rootSum = rootPrevious:add(rootQuotient:divide(rootPrevious))
        rootResult = rootSum:divide(constantDegree)
      until (private:checkPrecision(rootPrevious, rootResult, rootPrecision) == true)

      local decimalLength = private.decimalLength
      local integerLength = private.integerLength
      local digitLimit = (decimalLength > integerLength) and decimalLength or integerLength

      for i = 1, digitLimit do
        rootPrevious = rootResult:getObjectValue()
        rootSum = rootPrevious:add(rootQuotient:divide(rootPrevious))
        rootResult = rootSum:divide(constantDegree)
      end

      rootResult:trimDecimal(rootPrecision)
      return rootResult
    end
  end
  
  public.setMaxPrecision = function(self, newPrecision)                                      -- [!] Function: setMaxPrecision(newPrecision) - Changes maximum decimal precision property value.
    assert(type(newPrecision) == "number", "[XAF Utility] Expected NUMBER as argument #1")   -- [!] Parameter: newPrecision - New maximum precision value, must be positive natural number.
                                                                                             -- [!] Return: 'true' - Returned if this property has been changed correctly.
    if (xafcoreMath:checkNatural(newPrecision, true) == true) then
      private.decimalPrecisionMax = newPrecision
    else
      error("[XAF Error] Invalid maximum precision value - must be positive natural number")
    end

    return true
  end
  
  public.setNumberSign = function(self, newSign)                                               -- [!] Function: setNumberSign(newSign) - Changes sign value of current BigNumber object.
    assert(type(newSign) == "number", "[XAF Utility] Expected NUMBER as argument #1")          -- [!] Parameter: newSign - New sign value (0 as neutral/positive, 1 as negative number).
                                                                                               -- [!] Return: 'true' - If the new BigNumber sign value has been set without errors.
    if (newSign == 0 or newSign == 1) then
      private.numberSign = newSign
    else
      error("[XAF Error] Invalid BigNumber sign value - must be equal to zero '0' or one '1'")
    end

    return true
  end
  
  public.setPrecision = function(self, newPrecision)                                       -- [!] Function: setPrecision(newPrecision) - Changes the number of decimal digits returned in 'getValue()' function.
    assert(type(newPrecision) == "number", "[XAF Utility] Expected NUMBER as argument #1") -- [!] Parameter: newPrecision - New precision property value.
                                                                                           -- [!] Return: 'true' - If new precision value has been set correctly.
    if (xafcoreMath:checkNatural(newPrecision, false) == true or newPrecision == -1) then
      private.decimalPrecision = newPrecision
    else
      error("[XAF Error] Invalid precision value - must be natural number or equal to -1")
    end

    return true
  end
  
  public.setThousandsSeparators = function(self, integer, decimal)                    -- [!] Function: setThousandsSeparators(integer, decimal) - Changes BigNumber thousands separators characters.
    assert(type(integer) == "string", "[XAF Utility] Expected STRING as argument #1") -- [!] Parameter: integer - New separator character for integer component.
    assert(type(decimal) == "string", "[XAF Utility] Expected STRING as argument #2") -- [!] Parameter: decimal - New separator character for fraction part of the number.
                                                                                      -- [!] Return: 'true' - If the characters have been set without errors.
    private.separatorThousandsInteger = integer
    private.separatorThousandsDecimal = decimal

    return true
  end
  
  public.shiftCommaLeftwise = function(self, digitCount)                                          -- [!] Function: shiftCommaLeftwise(digitCount) - Creates new BigNumber with shifted decimal point leftwise, very useful when dealing with exponential notation.
    assert(type(digitCount) == "number", "[XAF Utility] Expected NUMBER as argument #1")          -- [!] Parameter: digitCount - Number of digits to shift decimal point by them.
                                                                                                  -- [!] Return: newNumberObject - New BigNumber object which stores the value of result of 'thisObject * 10 ^ (-1 * digitCount)' operation.
    if (xafcoreMath:checkNatural(digitCount, true) == true) then
      local numberObject = BigNumber:new(public:getValue())
      local numberTable = numberObject:returnValue()
      local newDecimalDigits = numberTable.decimalDigits
      local newDecimalLength = numberTable.decimalLength
      local newIntegerDigits = numberTable.integerDigits
      local newIntegerLength = numberTable.integerLength
      local newNumberSign = numberTable.numberSign
      local newNumberObject = nil

      for i = 1, digitCount do
        if (newIntegerLength > 1) then
          local digitValue = table.remove(newIntegerDigits, 1)

          table.insert(newDecimalDigits, 1, digitValue)
          newDecimalLength = newDecimalLength + 1
          newIntegerLength = newIntegerLength - 1
        else
          local digitValue = table.remove(newIntegerDigits, 1)

          table.insert(newDecimalDigits, 1, digitValue)
          newDecimalLength = newDecimalLength + 1
          newIntegerDigits = {0}
          newIntegerLength = 1
        end
      end

      newNumberObject = private:buildFromTable(newDecimalDigits, newIntegerDigits, newNumberSign)
      return newNumberObject
    else
      error("[XAF Error] Invalid shift digit count, must be natural number (except zero)")
    end
  end
  
  public.shiftCommaRightwise = function(self, digitCount)                                         -- [!] Function: shiftCommaRightwise(digitCount) - Makes new BigNumbers instance with shifted decimal point rightwise, useful in exponential notation.
    assert(type(digitCount) == "number", "[XAF Utility] Expected NUMBER as argument #1")          -- [!] Parameter: digitCount - Number of digits to shift decimal point by them.
                                                                                                  -- [!] Return: newNumberObject - New BigNumber instance that holds the value of result of 'thisObject * 10 ^ digitCount' operation.
    if (xafcoreMath:checkNatural(digitCount, true) == true) then
      local numberObject = BigNumber:new(public:getValue())
      local numberTable = numberObject:returnValue()
      local newDecimalDigits = numberTable.decimalDigits
      local newDecimalLength = numberTable.decimalLength
      local newIntegerDigits = numberTable.integerDigits
      local newIntegerLength = numberTable.integerLength
      local newNumberSign = numberTable.numberSign
      local newNumberObject = nil

      for i = 1, digitCount do
        if (newDecimalLength > 0) then
          local digitValue = table.remove(newDecimalDigits, 1)

          table.insert(newIntegerDigits, 1, digitValue)
          newDecimalLength = newDecimalLength - 1
          newIntegerLength = newIntegerLength + 1
        else
          table.insert(newIntegerDigits, 1, 0)
          newIntegerLength = newIntegerLength + 1
        end
      end

      newNumberObject = private:buildFromTable(newDecimalDigits, newIntegerDigits, newNumberSign)
      return newNumberObject
    else
      error("[XAF Error] Invalid shift digit count, must be natural number (except zero)")
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
