# XAF Module - Core:XAFCore

XAFCore is framework core library as its name says. This class provides five sub-cores (called *instances*), where each of them has several useful functionalities for executing specific tasks. It includes among others executing external programs in protected mode, generating secure random hexadecimal strings, searching for control characters, sorting tables by key or wrapping text string into table. These modules are listed below with short description:

* **Executor instance** - `XAFCore:getExecutorInstance()` - This sub-core is responsible for executing program internal functions safely in protected mode (that prevents your program from being unexpectedly interrupted and let you handle potential errors), running scripts from external files (also in protected mode) and stopping programs safely and exiting to shell. The last one is perfect alternative to native `os.exit()` - it stops current coroutine and runs new one.
* **Security instance** - `XAFCore:getSecurityInstance()` - Instance which provides data security related functionality like converting plain binary strings to its hexadecimal representation, generating secure (but not true) pseudorandom hexadecimal strings (called *hashes*) with specified length, generating and checking universally unique identifiers.
* **String instance** - `XAFCore:getStringInstance()` - That small module comes with three functions for searching strings for control non-printable ASCII characters (from range 0 to 31 and 127), finding special pattern-related characters like `\n`, `\t` or `\\` and also checking strings for white spaces.
* **Table instance** - `XAFCore:getTableInstance()` - It seems to me that this instance is the most functional in that library. It provides many table manipulation methods like sorting by key, searching for specific value, checking total length of the table (with indexed and non-indexed keys) which may replace the standard `#` operator and the most useful functionality - saving tables to external files and reading from them. Very nice solution when building some kind of key-value pairs database.
* **Text instance** - `XAFCore:getTextInstance()` - This part of library is responsible for doing text-related tasks like converting table with string lines to one concatenated string and vice-versa - wrapping one string to table with split lines with specified width. It also has three methods for text padding - to left, center and right - at fixed width.

## Class documentation

* **Class name** - `XAF Core`, **instantiable** - `false`, **inheritable** - `false`
* **Static fields**

  * `CONCAT_DEFAULT` - constant used in text instance function `convertLinesToString(linesTable, mode)` where `mode` is the concatenation mode. When used, that method will insert one space character between each line.
  * `CONCAT_SPACE` - constant used in text instance function `convertLinesToString(linesTable, mode)` where `mode` is the concatenation mode. That option will work exactly the same like that above, inserts spaces to each line.
  * `CONCAT_NOSPACE` - constant used in text instance function `convertLinesToString(linesTable, mode)` where `mode` is the concatenation mode. If passed as `mode` then all lines will be concatenated as they are, without adding anything to them.
  * `CONCAT_NEWLINE` - constant used in text instance function `convertLinesToString(linesTable, mode)` where `mode` is the concatenation mode. With that option, method inserts new line character between each line.

* **Constructor** - *class is not instantiable - no constructor*
* **Dependencies** - *no dependencies*

## Instance documentation

### Executor instance

* **Function:** `run(task, ...)` - Runs a protected task from given function and argument list.

  * **Parameter:** `task` - A function to run script from.
  * **Parameter:** `...` - Argument list that pass into function.
  * **Return:** `...` - Result values - first value is always a status of execution, may be 'true' or 'false'.

* **Function:** `runExternal(path, ...)` - Runs a protected task from external file and argument list.

  * **Parameter:** `filePath` - Absolute path to Lua script file.
  * **Parameter:** `...` - Argument list (with extension) passed into script function.
  * **Return:** `...` - Result values - first value is always a status of execution, may be 'true' or 'false'.

* **Function:** `stop(clear)` - Stops running program and safely exits it.

  * **Parameter:** `clear` - Terminal clearing flag: if 'true' then screen will clear itself.

### Security instance

* **Function:** `convertBinaryToHex(binary, uppercase)` - Converts binary string to its hexadecimal representation.

  * **Parameter:** `binary` - Binary string to convert it.
  * **Parameter:** `uppercase` - Uppercase flag of output hexadecimal string.
  * **Return:** `hexString` - Hexadecimal representation of binary string.

* **Function:** `getRandomHash(length, uppercase)` - Generates random hex-string at specified length.

  * **Parameter:** `length` - Total length of the generated string in chars.
  * **Parameter:** `uppercase` - Uppercase flag, if 'true' then all letters will convert to its uppercase.
  * **Return:** `hashString` - Generated hexadecimal randomized string.

* **Function:** `getRandomUuid(uppercase)` - Generates random UUID version 4 string.

  * **Parameter:** `uppercase` - String uppercase flag, if 'true' then chars will be converted to uppercase.
  * **Return:** `uuid` - Generated UUID version 4 string.

* **Function:** `isUuid(uuid)` - Checks if given string is an UUID.

  * **Parameter:** `uuid` - UUID string to check it.
  * **Return:** `isUuid` - Boolean flag if passed string is an UUID.

### String instance

* **Function:** `checkControlCharacter(data)` - Searches a string data to find control and unprintable characters (ASCII 0 - 31 and 127 code).

  * **Parameter:** `data` - String to check by containing control characters.
  * **Return:** `containCharacter` - Boolean flag is string contains control characters.

* **Function:** `checkSpecialCharacter(data)` - Checks whether argument string contains special character.

  * **Parameter:** `data` - String to check by containing special characters.
  * **Return:** `containCharacter` - Boolean flag is string containing special characters.

* **Function:** `checkWhitespace(data)` - Checks whether given string contains a white space.

  * **Parameter:** `data` - String data to check it by white spaces.
  * **Return:** `containCharacter` - Boolean flag is string contain white spaces.

### Table instance

* **Function:** `getLength(array)` - Returns total length of given table (index and non-index keys).

  * **Parameter:** `array` - Table to get length from.
  * **Return:** `arrayLength` - Total length of given array.

* **Function:** `loadFromFile(filePath)` - Returns a table from file where it was previously saved.

  * **Parameter:** `filePath` - Absolute path of file where table was saved.
  * **Return:** `loadTable` - Successfully loaded table.

* **Function:** `saveToFile(array, filePath, append)` - Saves table in a file with specified path.

  * **Parameter:** `array` - Table which will be saved in file.
  * **Parameter:** `filePath` - Absolute path of file in which table will be saved.
  * **Parameter:** `append` - Boolean flag whether new table will override existing or will be appended to it.
  * **Return:** `'true'` - If table was saved successfully.

* **Function:** `searchByValue(array, value, option)` - Returns table of keys of whose values meets search criteria.

  * **Parameter:** `array` - Table to search for values.
  * **Parameter:** `value` - For this value function will search.
  * **Parameter:** `option` - Searching option: 0 - equals values, positive (n > 0) - values more than given, negative (n < 0) - values less than given.
  * **Return:** `keyTable` - Table with keys to which found values are assigned.

* **Function:** `sortByKey(unsorted, reversed)` - Returns an iterator which returns next key-value pairs from given table in sorted order.

  * **Parameter:** `unsorted` - Table to sort.
  * **Parameter:** `reversed` - Reversion flag - if 'true' then iterator will return next pairs in reversed Z-A order, if 'false' then A-Z order.
  * **Return:** `key, value` - Next key-value pairs in sorted order.

### Text instance

* **Function:** `convertLinesToString(linesTable, mode)` - Converts table with string lines to one concatenated string.

  * **Parameter:** `linesTable` - Table with lines to concatenate.
  * **Parameter:** `mode` - Concatenation mode (0 - default, 1 - space, 2 - no space, 3 - new line character)
  * **Return:** `concatenatedString` - The string after concatenation.

* **Function:** `convertStringToLines(text, width)` - Splits whole string into lines and returns them as table.

  * **Parameter:** `text` - Text string to split.
  * **Parameter:** `width` - Fixed width of each line will be split in.
  * **Return:** `linesTable` - Table of split lines from input string.

* **Function:** `padCenter(text, width)` - Adds padding to given text to center it at specified width.

  * **Parameter:** `text` - Text to add padding into.
  * **Parameter:** `width` - To this fixed width text will be centered.
  * **Return:** `paddedText` - Centered text with fixed width.

* **Function:** `padLeft(text, width)` - Adds padding to given text to align it left-side at specified width.

  * **Parameter:** `text` - Text to be aligned left-side.
  * **Parameter:** `width` - Fixed width to which text will be aligned.
  * **Return:** `paddedText` - Left-side aligned text with fixed width.

* **Function:** `padRight(text, width)` - Adds padding to given text to align it right-side at specified width.

  * **Parameter:** `text` - Text to be aligned right-side.
  * **Parameter:** `width` - Fixed width to which text will be aligned.
  * **Return:** `paddedText` - Right-side aligned text with fixed width.

* **Function:** `split(text, delimiter)` - Splits given string to tokens by given delimiters.

  * **Parameter:** `text` - String data text to be split.
  * **Parameter:** `delimiter` - String which contains set of delimiters to splitting (for space use - ' ').
  * **Return:** `tokensTable` - Table with split string as tokens.