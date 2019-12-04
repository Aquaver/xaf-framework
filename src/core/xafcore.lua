-------------------------------
-- XAF Module - Core:XAFCore --
-------------------------------
-- [>] This module is a library, which consists of the few, but useful following parts:
-- [>] Executor: used to exit program safely or executing external scripts in protected mode.
-- [>] Security: provides data security functionality like UUID checking or random hex-string generating.
-- [>] String: used to searching strings for special or control characters.
-- [>] Table: tables manipulation, quick sorting, searching and saving/reading to/from external files and sources.
-- [>] Text: provides text manipulation functionality: padding to right/center/left, splitting or wrapping into table.

local computer = require("computer")
local filesystem = require("filesystem")
local term = require("term")
local textapi = require("text")
local unicode = require("unicode")

local XafCore = {
  C_NAME = "XAF Core",
  C_INSTANCE = false,
  C_INHERIT = false,

  static = {
    CONCAT_DEFAULT = 0, -- [>] Text instance related constants, used for string mode concatenation in function 'convertLinesToString()'
    CONCAT_SPACE = 1,   -- [>] Access to constants: local xafcore = require("xafcore") xafcore.static.NAME
    CONCAT_NOSPACE = 2, -- [?] Example: local myString = convertLinesToString(myTable, xafcore.static.CONCAT_DEFAULT)
    CONCAT_NEWLINE = 3
  }
}

function XafCore:getExecutorInstance()
  local public = {}

  public.run = function(self, task, ...)                                            -- [!] Function: run(task, ...) - Runs a protected task from given function and argument list.
    assert(type(task) == "function", "[XAF Core] Expected FUNCTION as argument #1") -- [!] Parameter: task - A function to run script from.
                                                                                    -- [!] Parameter: ... - Argument list that pass into function.
    local taskArguments = {...}                                                     -- [!] Return: ... - Result values - first value is always a status of execution, may be 'true' or 'false'.
    local taskFunction = task
    local taskResults = {}

    taskResults = {pcall(taskFunction, table.unpack(taskArguments))}

    return table.unpack(taskResults)
  end

  public.runExternal = function(self, filePath, ...)                                -- [!] Function: runExternal(path, ...) - Runs a protected task from external file and argument list.
    assert(type(filePath) == "string", "[XAF Core] Expected STRING as argument #1") -- [!] Parameter: filePath - Absolute path to Lua script file.
                                                                                    -- [!] Parameter: ... - Argument list (with extension) passed into script function.
    local taskPath = filePath                                                       -- [!] Return: ... - Result values - first value is always a status of execution, may be 'true' or 'false'.
    local taskFunction = nil
    local taskArguments = {...}
    local taskResults = {}

    if (filesystem.exists(taskPath) == true) then
      local taskFile = filesystem.open(taskPath, 'r')
      local taskCode = ""
      local taskData = taskFile:read(math.huge)

      while (taskData) do
        taskCode = taskCode .. tostring(taskData)
        taskData = taskFile:read(math.huge)
      end

      taskFile:close()
      taskFunction = load(taskCode)
      taskResults = {pcall(taskFunction, table.unpack(taskArguments))}

      return table.unpack(taskResults)
    else
      error("[XAF Error] File '" .. taskPath .. "' does not exist")
    end
  end

  public.stop = function(self, clear)                                              -- [!] Function: stop(clear) - Stops running program and safely exits it.
    assert(type(clear) == "boolean", "[XAF Core] Expected BOOLEAN as argument #1") -- [!] Parameter: clear - Terminal clearing flag: if 'true' then screen will clear itself.

    if (clear == true) then
      term.clear()
    end

    computer.pushSignal("")
    coroutine.yield() -- For older OC version with previous coroutine library.
    os.exit()         -- For newer (1.7 and later) OC version with modified coroutine library.
  end

  return public
end

function XafCore:getMathInstance()
  local public = {}

  public.checkInteger = function(self, number)                                    -- [!] Function: checkInteger(number) - Checks that is entered number integer (has not fractional component).
    assert(type(number) == "number", "[XAF Core] Expected NUMBER as argument #1") -- [!] Parameter: number - Number to check.
                                                                                  -- [!] Return: 'true' or 'false' - Flag, is the given number an integer.
    local approximationLower = math.floor(number)
    local approximationUpper = math.ceil(number)

    if (approximationLower == approximationUpper) then
      return true
    else
      return false
    end
  end

  public.checkNatural = function(self, number, positive)                              -- [!] Function: checkNatural(number, positive) - Checks that is entered number natural (non-negative integer).
    assert(type(number) == "number", "[XAF Core] Expected NUMBER as argument #1")     -- [!] Parameter: number - Number to check its naturality.
    assert(type(positive) == "boolean", "[XAF Core] Expected BOOLEAN as argument #2") -- [!] Parameter: positive - If 'true' then function will not consider zero as natural number.
                                                                                      -- [!] Return: 'true' or 'false' - Flag, is the entered number natural.
    local approximationLower = math.floor(number)
    local approximationUpper = math.ceil(number)

    if (approximationLower == approximationUpper) then
      if (positive == true) then
        return number > 0
      else
        return number >= 0
      end
    else
      return false
    end
  end

  public.getAdditiveInverse = function(self, number)                              -- [!] Function: getAdditiveInverse(number) - Trivial function, which returns the additive inverse of entered real number.
    assert(type(number) == "number", "[XAF Core] Expected NUMBER as argument #1") -- [!] Parameter: number - Number to get its additive inverse.
                                                                                  -- [!] Return: additiveInverse - Additive inverse of given number.
    local rawNumber = number
    local additiveInverse = rawNumber * (-1)

    return additiveInverse
  end

  public.getGreatestCommonDivisor = function(self, numberA, numberB)                         -- [!] Function: getGreatestCommonDivisor(numberA, numberB) - Calculates GCD (greatest common divisor) on two integer numbers.
    assert(type(numberA) == "number", "[XAF Core] Expected NUMBER as argument #1")           -- [!] Parameter: numberA - First pair number, must be an integer.
    assert(type(numberB) == "number", "[XAF Core] Expected NUMBER as argument #2")           -- [!] Parameter: numberB - Second pair number, also must be an integer.
                                                                                             -- [!] Return: resultGcd - Calculated GCD result number.
    if (public:checkInteger(numberA) == false or public:checkInteger(numberB) == false) then
      error("[XAF Error] Greatest common divisor must be calculated on integer numbers")
    else
      local helperVar = 0
      local resultGcd = numberA

      while (numberB ~= 0) do
        helperVar = resultGcd % numberB
        resultGcd = numberB
        numberB = helperVar
      end

      return math.abs(resultGcd)
    end
  end

  public.getLowestCommonMultiple = function(self, numberA, numberB)                          -- [!] Function: getLowestCommonMultiple(numberA, numberB) - Calculates LCM (lowest/least common multiple) on two integer numbers.
    assert(type(numberA) == "number", "[XAF Core] Expected NUMBER as argument #1")           -- [!] Parameter: numberA - First pair number, must be an integer.
    assert(type(numberB) == "number", "[XAF Core] Expected NUMBER as argument #2")           -- [!] Parameter: numberB - Second pair number, also must be an integer.
                                                                                             -- [!] Return: resultLcm - Calculated LCM result number.
    if (public:checkInteger(numberA) == false or public:checkInteger(numberB) == false) then
      error("[XAF Error] Lowest common multiple must be calculated on integer numbers")
    else
      local productAbs = math.abs(numberA * numberB)
      local resultLcm = productAbs / public:getGreatestCommonDivisor(numberA, numberB)

      return resultLcm
    end
  end

  public.getMultiplicativeInverse = function(self, number)                        -- [!] Function: getMultiplicativeInverse(number) - Trivial function, which returns the multiplicative inverse of entered real number.
    assert(type(number) == "number", "[XAF Core] Expected NUMBER as argument #1") -- [!] Parameter: number - Number to get its multiplicative inverse.
                                                                                  -- [!] Return: multiplicativeInverse - Multiplicative inverse of given number (number * multiplicativeInverse = 1 for any real number).
    local rawNumber = number
    local multiplicativeInverse = 1 / rawNumber

    return multiplicativeInverse
  end

  return public
end

function XafCore:getSecurityInstance()
  local public = {}

  public.convertBinaryToHex = function(self, binary, uppercase)                        -- [!] Function: convertBinaryToHex(binary, uppercase) - Converts binary string to its hexadecimal representation.
    assert(type(binary) == "string", "[XAF Core] Expected STRING as argument #1")      -- [!] Parameter: binary - Binary string to convert it.
    assert(type(uppercase) == "boolean", "[XAF Core] Expected BOOLEAN as argument #2") -- [!] Parameter: uppercase - Uppercase flag of output hexadecimal string.
                                                                                       -- [!] Return: hexString - Hexadecimal representation of binary string.
    local binaryString = binary
    local binaryLength = unicode.wlen(binaryString)
    local byteTable = {string.byte(binaryString, 1, binaryLength)}
    local hexString = ""
    local hexUppercase = uppercase

    for i = 1, binaryLength do
      hexString = hexString .. string.format("%02x", byteTable[i])
    end

    if (hexUppercase == true) then
      hexString = string.upper(hexString)
    end

    return hexString
  end

  public.getRandomHash = function(self, length, uppercase)                                             -- [!] Function: getRandomHash(length, uppercase) - Generates random hex-string at specified length.
    assert(type(length) == "number", "[XAF Core] Expected NUMBER as argument #1")                      -- [!] Parameter: length - Total length of the generated string in chars.
    assert(type(uppercase) == "boolean", "[XAF Core] Expected BOOLEAN as argument #2")                 -- [!] Parameter: uppercase - Uppercase flag, if 'true' then all letters will convert to its uppercase.
                                                                                                       -- [!] Return: hashString - Generated hexadecimal randomized string.
    local hashChars = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'}
    local hashLength = length
    local hashString = ""
    local isUppercase = uppercase

    for i = 1, hashLength do
      hashString = hashString .. hashChars[math.random(1, 16)]
    end

    if (isUppercase == true) then
      hashString = string.upper(hashString)
    end

    return hashString
  end

  public.getRandomUuid = function(self, uppercase)                                                     -- [!] Function: getRandomUuid(uppercase) - Generates random UUID version 4 string.
    assert(type(uppercase) == "boolean", "[XAF Core] Expected BOOLEAN as argument #1")                 -- [!] Parameter: uppercase - String uppercase flag, if 'true' then chars will be converted to uppercase.
                                                                                                       -- [!] Return: uuid - Generated UUID version 4 string.
    local uuidChars = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'}
    local uuid = ""
    local uuidRaw = ""
    local uuidUppercase = uppercase

    for i = 1, 30 do
      uuidRaw = uuidRaw .. uuidChars[math.random(1, 16)]
    end

    uuid = uuid .. string.sub(uuidRaw, 1, 8)
    uuid = uuid .. "-" .. string.sub(uuidRaw, 9, 12)
    uuid = uuid .. "-4" .. string.sub(uuidRaw, 13, 15)
    uuid = uuid .. "-" .. uuidChars[math.random(9, 12)] .. string.sub(uuidRaw, 16, 18)
    uuid = uuid .. "-" .. string.sub(uuidRaw, 19, 30)

    if (uuidUppercase == true) then
      uuid = string.upper(uuid)
    end

    return uuid
  end

  public.isUuid = function(self, uuid)                                                                 -- [!] Function: isUuid(uuid) - Checks if given string is an UUID.
    assert(type(uuid) == "string", "[XAF Core] Expected STRING as argument #1")                        -- [!] Parameter: uuid - UUID string to check it.
                                                                                                       -- [!] Return: isUuid - Boolean flag if passed string is an UUID.
    local uuidString = uuid
    local uuidLength = unicode.wlen(uuid)
    local uuidRegex = "(%x%x%x%x%x%x%x%x[-]%x%x%x%x[-]%x%x%x%x[-]%x%x%x%x[-]%x%x%x%x%x%x%x%x%x%x%x%x)"
    local isUuid = false

    if (uuidLength == 36 and string.match(uuidString, uuidRegex) == uuidString) then
      isUuid = true
    end

    return isUuid
  end

  return public
end

function XafCore:getStringInstance()
  local public = {}

  public.checkControlCharacter = function(self, data)                           -- [!] Function: checkControlCharacter(data) - Searches a string data to find control and unprintable characters (ASCII 0 - 31 and 127 code).
    assert(type(data) == "string", "[XAF Core] Expected STRING as argument #1") -- [!] Parameter: data - String to check by containing control characters.
                                                                                -- [!] Return: containCharacter - Boolean flag is string contains control characters.
    local checkedString = data
    local controlCharRegex = "[\0-\31\127]"
    local containCharacter = false

    if (string.find(checkedString, controlCharRegex)) then
      containCharacter = true
    end

    return containCharacter
  end

  public.checkSpecialCharacter = function(self, data)                           -- [!] Function: checkSpecialCharacter(data) - Checks whether argument string contains special character.
    assert(type(data) == "string", "[XAF Core] Expected STRING as argument #1") -- [!] Parameter: data - String to check by containing special characters.
                                                                                -- [!] Return: containCharacter - Boolean flag is string containing special characters.
    local checkedString = data
    local specialCharRegex = "[\a\b\f\n\r\t\v\\\"\'/]"
    local containCharacter = false

    if (string.find(checkedString, specialCharRegex)) then
      containCharacter = true
    end

    return containCharacter
  end

  public.checkWhitespace = function(self, data)                                 -- [!] Function: checkWhitespace(data) - Checks whether given string contains a white space.
    assert(type(data) == "string", "[XAF Core] Expected STRING as argument #1") -- [!] Parameter: data - String data to check it by white spaces.
                                                                                -- [!] Return: containCharacter - Boolean flag is string contain white spaces.
    local checkedString = data
    local whitespaceCharRegex = "[\n\r\t\v ]"
    local containCharacter = false

    if (string.find(checkedString, whitespaceCharRegex)) then
      containCharacter = true
    end

    return containCharacter
  end

  return public
end

function XafCore:getTableInstance()
  local public = {}

  public.getLength = function(self, array)                                     -- [!] Function: getLength(array) - Returns total length of given table (index and non-index keys).
    assert(type(array) == "table", "[XAF Core] Expected TABLE as argument #1") -- [!] Parameter: array - Table to get length from.
                                                                               -- [!] Return: arrayLength - Total length of given array.
    local checkedArray = array
    local arrayLength = 0

    for key, value in pairs(checkedArray) do
      arrayLength = arrayLength + 1
    end

    return arrayLength
  end

  public.loadFromFile = function(self, filePath)                                    -- [!] Function: loadFromFile(filePath) - Returns a table from file where it was previously saved.
    assert(type(filePath) == "string", "[XAF Core] Expected STRING as argument #1") -- [!] Parameter: filePath - Absolute path of file where table was saved.
                                                                                    -- [!] Return: loadTable - Successfully loaded table.
    local lineDelimiter = string.char(13, 10)
    local loadPath = filePath
    local loadTable = {}

    if (filesystem.exists(loadPath) == true) then
      local tableFile = filesystem.open(loadPath, 'r')
      local tableContent = ''
      local tableData = ''

      while (tableData) do
        tableContent = tableContent .. tableData
        tableData = tableFile:read(math.huge)
      end

      tableData = ''
      tableFile:close()
      loadTable = public:loadFromString(tableContent)
    else
      error("[XAF Error] File '" .. loadPath .. "' does not exist")
    end

    return loadTable
  end

  public.loadFromString = function(self, sourceString)                                  -- [!] Function: loadFromString(sourceString) - Returns a table from string in XAF Table Format (useful in reading data directly from remote source, for example from internet).
    assert(type(sourceString) == "string", "[XAF Core] Expected STRING as argument #1") -- [!] Parameter: sourceString - Source string in valid XAF Table Format.
                                                                                        -- [!] Return: loadTable - Successfully read and loaded table.
    local lineDelimiter = string.char(13, 10)
    local loadString = sourceString
    local loadTable = {}

    for line in string.gmatch(loadString, "[^" .. lineDelimiter .. "]+") do
      local delimiter = string.find(line, " = ")
      local key = nil
      local value = nil

      if (string.sub(line, 1, 3) ~= "[#]") then -- If line starts with [#] then it will be recognized as comment and ignored.
        if (delimiter) then
          local keyMarker = string.sub(line, 1, 3)
          local keyRaw = string.sub(line, 5, delimiter - 1)
          local valueMarker = string.sub(line, delimiter + 3, delimiter + 5)
          local valueRaw = string.sub(line, delimiter + 7)

          if (keyMarker == "[S]") then
            key = tostring(keyRaw)
          elseif (keyMarker == "[N]") then
            key = tonumber(keyRaw)
          elseif (keyMarker == "[B]") then
            if (keyRaw == "true") then
              key = true
            elseif (keyRaw == "false") then
              key = false
            end
          elseif (keyMarker == "[?]") then
            -- Key type is unknown - line is ignored.
          else
            error("[XAF Error] Invalid table line syntax - invalid key marker")
          end

          if (valueMarker == "[S]") then
            value = tostring(valueRaw)
          elseif (valueMarker == "[N]") then
            value = tonumber(valueRaw)
          elseif (valueMarker == "[B]") then
            if (valueRaw == "true") then
              value = true
            elseif (valueRaw == "false") then
              value = false
            end
          elseif (valueMarker == "[?]") then
            value = nil
          else
            error("[XAF Error] Invalid table line syntax - invalid value marker")
          end

          if (key) then
            loadTable[key] = value
          end
        else
          error("[XAF Error] Invalid table data syntax - delimiter not found")
        end
      end
    end

    return loadTable
  end

  public.saveToFile = function(self, array, filePath, append)                       -- [!] Function: saveToFile(array, filePath, append) - Saves table in a file with specified path.
    assert(type(array) == "table", "[XAF Core] Expected TABLE as argument #1")      -- [!] Parameter: array - Table which will be saved in file.
    assert(type(filePath) == "string", "[XAF Core] Expected STRING as argument #2") -- [!] Parameter: filePath - Absolute path of file in which table will be saved.
    assert(type(append) == "boolean", "[XAF Core] Expected BOOLEAN as argument #3") -- [!] Parameter: append - Boolean flag whether new table will override existing or will be appended to it.
                                                                                    -- [!] Return: 'true' - If table was saved successfully.
    local saveTable = array
    local savePath = filePath
    local saveMode = (append == true) and 'a' or 'w'
    local saveFile = filesystem.open(savePath, saveMode)

    for key, value in public:sortByKey(saveTable, false) do
      local keyType = type(key)
      local keyMarker = ''
      local valueType = type(value)
      local valueMarker = ''

      keyMarker = (keyType == "string") and "[S]" or (keyType == "number")
      and "[N]" or (keyType == "boolean") and "[B]" or "[?]"

      valueMarker = (valueType == "string") and "[S]" or (valueType == "number")
      and "[N]" or (valueType == "boolean") and "[B]" or "[?]"

      saveFile:write(keyMarker .. ' ' .. tostring(key) .. " = ")
      saveFile:write(valueMarker .. ' ' .. tostring(value) .. '\n')
    end

    saveFile:close()
    return true
  end

  public.searchByValue = function(self, array, value, option)                     -- [!] Function: searchByValue(array, value, option) - Returns table of keys of whose values meets search criteria.
    assert(type(array) == "table", "[XAF Core] Expected TABLE as argument #1")    -- [!] Parameter: array - Table to search for values.
    assert(type(value) ~= "nil", "[XAF Core] Expected ANYTHING as argument #2")   -- [!] Parameter: value - For this value function will search.
    assert(type(option) == "number", "[XAF Core] Expected NUMBER as argument #3") -- [!] Parameter: option - Searching option: 0 - equals values, positive (n > 0) - values more than given, negative (n < 0) - values less than given.
                                                                                  -- [!] Return: keyTable - Table with keys to which found values are assigned.
    local searchedTable = array
    local searchedValue = value
    local searchOption = option
    local keyTable = {}

    for key, value in pairs(searchedTable) do
      if (searchOption == 0) then
        if (value == searchedValue) then
          table.insert(keyTable, key)
        end
      elseif (searchOption > 0) then
        if (value > searchedValue) then
          table.insert(keyTable, key)
        end
      elseif (searchOption < 0) then
        if (value < searchedValue) then
          table.insert(keyTable, key)
        end
      end
    end

    return keyTable
  end

  public.sortByKey = function(self, unsorted, reversed)                               -- [!] Function: sortByKey(unsorted, reversed) - Returns an iterator which returns next key-value pairs from given table in sorted order.
    assert(type(unsorted) == "table", "[XAF Core] Expected TABLE as argument #1")     -- [!] Parameter: unsorted - Table to sort.
    assert(type(reversed) == "boolean", "[XAF Core] Expected BOOLEAN as argument #2") -- [!] Parameter: reversed - Reversion flag - if 'true' then iterator will return next pairs in reversed Z-A order, if 'false' then A-Z order.
                                                                                      -- [!] Return: key, value - Next key-value pairs in sorted order.
    local sortingTable = unsorted
    local reversionFlag = reversed
    local typeNumbers = {}
    local typeStrings = {}
    local typeBooleans = {}
    local typeUndefined = {} -- This table remain unsorted due to undefined type of keys.
    local sortingFunctionDefault = function(a, b) return a < b end
    local sortingFunctionReversed = function(a, b) return a > b end
    local iteratorTable = {}
    local iteratorLength = 1
    local iteratorIndex = 0

    for key, value in pairs(sortingTable) do
      local keyType = type(key)

      if (keyType == "number") then
        table.insert(typeNumbers, key)
      elseif (keyType == "string") then
        table.insert(typeStrings, key)
      elseif (keyType == "boolean") then
        table.insert(typeBooleans, tostring(key))
      else
        table.insert(typeUndefined, key)
      end

      iteratorLength = iteratorLength + 1
    end

    if (reversionFlag == true) then
      table.sort(typeNumbers, sortingFunctionReversed)
      table.sort(typeStrings, sortingFunctionReversed)
      table.sort(typeBooleans, sortingFunctionReversed)
    else
      table.sort(typeNumbers, sortingFunctionDefault)
      table.sort(typeStrings, sortingFunctionDefault)
      table.sort(typeBooleans, sortingFunctionDefault)
    end

    if (reversionFlag == true) then -- Inserting all sorted keys to one iterator table in reversed order.
      for key, value in ipairs(typeUndefined) do
        table.insert(iteratorTable, value)
      end

      for key, value in ipairs(typeBooleans) do
        if (value == "true") then
          table.insert(iteratorTable, true)
        elseif (value == "false") then
          table.insert(iteratorTable, false)
        end
      end

      for key, value in ipairs(typeStrings) do
        table.insert(iteratorTable, value)
      end

      for key, value in ipairs(typeNumbers) do
        table.insert(iteratorTable, value)
      end
    else
      for key, value in ipairs(typeNumbers) do
        table.insert(iteratorTable, value)
      end

      for key, value in ipairs(typeStrings) do
        table.insert(iteratorTable, value)
      end

      for key, value in ipairs(typeBooleans) do
        if (value == "true") then
          table.insert(iteratorTable, true)
        elseif (value == "false") then
          table.insert(iteratorTable, false)
        end
      end

      for key, value in ipairs(typeUndefined) do
        table.insert(iteratorTable, value)
      end
    end

    return function()
      iteratorIndex = iteratorIndex + 1

      if (iteratorIndex < iteratorLength) then
        local key = iteratorTable[iteratorIndex]
        local value = sortingTable[key]

        return key, value
      end
    end
  end

  return public
end

function XafCore:getTextInstance()
  local public = {}

  public.convertLinesToString = function(self, linesTable, mode)                                   -- [!] Function: convertLinesToString(linesTable, mode) - Converts table with string lines to one concatenated string.
    assert(type(linesTable) == "table", "[XAF Core] Expected TABLE as argument #1")                -- [!] Parameter: linesTable - Table with lines to concatenate.
    assert(type(mode) == "number", "[XAF Core] Expected NUMBER as argument #2")                    -- [!] Parameter: mode - Concatenation mode (0 - default, 1 - space, 2 - no space, 3 - new line character).
                                                                                                   -- [!] Return: concatenatedString - The string after concatenation.
    local stringTable = linesTable
    local concatenationMode = mode
    local concatenatedString = ""
    local concatenationLink = ""

    if (concatenationMode >= 0 and concatenationMode <= 3) then
      concatenationLink = (concatenationMode == 0 or concatenationMode == 1)
      and ' ' or (concatenationMode == 2) and '' or (concatenationMode == 3) and '\n'

      for key, value in pairs(linesTable) do
        concatenatedString = concatenatedString .. tostring(value) .. concatenationLink
      end

      concatenatedString = string.sub(concatenatedString, 1, unicode.wlen(concatenatedString) - unicode.wlen(concatenationLink))
      return concatenatedString
    else
      error("[XAF Error] Invalid concatenation mode")
    end
  end

  public.convertStringToLines = function(self, text, width)                      -- [!] Function: convertStringToLines(text, width) - Splits whole string into lines and returns them as table.
    assert(type(text) == "string", "[XAF Core] Expected STRING as argument #1")  -- [!] Parameter: text - Text string to split.
    assert(type(width) == "number", "[XAF Core] Expected NUMBER as argument #2") -- [!] Parameter: width - Fixed width of each line will be split in.
                                                                                 -- [!] Return: linesTable - Table of split lines from input string.
    local inputText = text
    local fixedWidth = width
    local linesTable = {}

    for text in textapi.wrappedLines(inputText, fixedWidth, fixedWidth) do
      table.insert(linesTable, text)
    end

    return linesTable
  end

  public.padCenter = function(self, text, width)                                                 -- [!] Function: padCenter(text, width) - Adds padding to given text to center it at specified width.
    assert(type(text) == "string", "[XAF Core] Expected STRING as argument #1")                  -- [!] Parameter: text - Text to add padding into.
    assert(type(width) == "number", "[XAF Core] Expected NUMBER as argument #2")                 -- [!] Parameter: width - To this fixed width text will be centered.
                                                                                                 -- [!] Return: paddedText - Centered text with fixed width.
    local fixedWidth = math.floor(width)
    local rawText = string.sub(text, 1, fixedWidth)
    local rawTextLength = unicode.wlen(rawText)
    local padding = fixedWidth - rawTextLength
    local paddingLeft = math.floor(padding / 2)
    local paddingRight = padding - paddingLeft
    local paddedText = string.rep(" ", paddingLeft) .. rawText .. string.rep(" ", paddingRight)

    return paddedText
  end

  public.padLeft = function(self, text, width)                                   -- [!] Function: padLeft(text, width) - Adds padding to given text to align it left-side at specified width.
    assert(type(text) == "string", "[XAF Core] Expected STRING as argument #1")  -- [!] Parameter: text - Text to be aligned left-side.
    assert(type(width) == "number", "[XAF Core] Expected NUMBER as argument #2") -- [!] Parameter: width - Fixed width to which text will be aligned.
                                                                                 -- [!] Return: paddedText - Left-side aligned text with fixed width.
    local fixedWidth = math.floor(width)
    local rawText = string.sub(text, 1, fixedWidth)
    local rawTextLength = unicode.wlen(rawText)
    local padding = fixedWidth - rawTextLength
    local paddedText = rawText .. string.rep(" ", padding)

    return paddedText
  end

  public.padRight = function(self, text, width)                                  -- [!] Function: padRight(text, width) - Adds padding to given text to align it right-side at specified width.
    assert(type(text) == "string", "[XAF Core] Expected STRING as argument #1")  -- [!] Parameter: text - Text to be aligned right-side.
    assert(type(width) == "number", "[XAF Core] Expected NUMBER as argument #2") -- [!] Parameter: width - Fixed width to which text will be aligned.
                                                                                 -- [!] Return: paddedText - Right-side aligned text with fixed width.
    local fixedWidth = math.floor(width)
    local rawText = string.sub(text, 1, fixedWidth)
    local rawTextLength = unicode.wlen(rawText)
    local padding = fixedWidth - rawTextLength
    local paddedText = string.rep(" ", padding) .. rawText

    return paddedText
  end

  public.split = function(self, text, delimiter, ignoreEmpty)                            -- [!] Function: split(text, delimiter, ignoreEmpty) - Splits given string to tokens by given delimiter.
    assert(type(text) == "string", "[XAF Core] Expected STRING as argument #1")          -- [!] Parameter: text - String data text to be split.
    assert(type(delimiter) == "string", "[XAF Core] Expected STRING as argument #2")     -- [!] Parameter: delimiter - Delimiter string used for splitting, may be multicharacter.
    assert(type(ignoreEmpty) == "boolean", "[XAF Core] Expected BOOLEAN as argument #3") -- [!] Parameter: ignoreEmpty - When 'true' value, ignores and discards found empty characters ('') between delimiters.
                                                                                         -- [!] Return: tokenTable - Table with split string as tokens.
    local inputLength = #text
    local tokenIndex = 0
    local tokenTable = {}

    while (true) do
      local delimiterFirst, delimiterLast = string.find(text, delimiter, tokenIndex, true)

      if (delimiterFirst and delimiterLast) then
        local tokenString = string.sub(text, tokenIndex, delimiterFirst - 1)

        if (tokenString == '') then
          if (ignoreEmpty == false) then
            table.insert(tokenTable, tokenString)
          end
        else
          table.insert(tokenTable, tokenString)
        end

        tokenIndex = delimiterLast + 1
      else
        if (tokenIndex - 1 < inputLength) then
          table.insert(tokenTable, string.sub(text, tokenIndex))
        else
          if (ignoreEmpty == false) then
            table.insert(tokenTable, '')
          end
        end

        break
      end
    end

    return tokenTable
  end

  return public
end

return XafCore
