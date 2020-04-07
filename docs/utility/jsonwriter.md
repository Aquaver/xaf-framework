# XAF Module - Utility:JSONWriter

Output counterpart utility module to `Utility:JSONParser` which provides saving data from Lua types to JSON format text. It may be used in data interchange between programs, client-server communication or even fast data structure copying (for example complex tables, objects, et cetera) by saving to JSON and reparsing the result. However, it has one little but obvious disadvantage. On encountering JSON non-processable object (like Lua functions) writing attempt will throw an error.

## Class documentation

* **Class name -** `Generic JSON Writer`, **instantiable -** `true`, **inheritable -** `true`
* **Static fields**

  * *no static fields*

* **Constructor -** `JSONWriter:new(defaultIndent)`
* **Dependencies -** `Core:XAFCore`

## Method documentation

* **Function:** `write(inputData, minifyData)` - Tries to convert given Lua object to JSON string.

  * **Parameter:** `inputData` - Lua input data to convert to JSON, may be anything JSON valid value, including nil (null).
  * **Parameter:** `minifyData` - Boolean flag to specify the result string should be minified.
  * **Return:** `jsonValue` - Converted JSON string.

### Private in-class method documentation

* **Function:** `checkDataType(data)` - Checks input data type according to JSON.

  * **Parameter:** `data` - Input data with any type (may be nil).
  * **Return:** `dataType` - String name of checked data type (or nil on invalid data, for instance: Lua functions).

* **Function:** `getValue(dataString, dataValue, messageErrorType)` - Determines passed data type and tries to convert it to JSON string.

  * **Parameter:** `dataString` - Raw JSON string partially converted.
  * **Parameter:** `dataValue` - Next data value to convert.
  * **Parameter:** `messageErrorType` - Internal value to determine where the error occurred.
  * **Return:** `dataString` - Partially converted JSON data string.

* **Function:** `removeWhitespaces(jsonString)` - Minifies the JSON string on input by removing all whitespaces (except in string literals).

  * **Parameter:** `jsonString` - Input JSON string to minify.
  * **Return:** `transformedString` - Minified JSON string, ready to output.

* **Function:** `writeArray(inputArray)` - Converts array raw data to proper JSON string.

  * **Parameter:** `inputArray` - Input data to convert.
  * **Return:** `stringArray` - Converted string from input array data.

* **Function:** `writeBoolean(inputBoolean)` - Converts boolean raw data to proper JSON string.

  * **Parameter:** `inputBoolean` - Input data to convert.
  * **Return:** `stringBoolean` - Converted string from input boolean data.

* **Function:** `writeNull(inputNull)` - Converts null raw data to proper JSON string.

  * **Parameter:** `inputNull` - Input data to convert.
  * **Return:** `stringNull` - Converted string from input nil (null) data.

* **Function:** `writeNumber(inputNumber)` - Converts number raw data to proper JSON string.

  * **Parameter:** `inputNumber` - Input data to convert.
  * **Return:** `stringNumber` - Converted string from input number data (or null on infinite or NaN).

* **Function:** `writeObject(inputObject)` - Converts object raw data to proper JSON string.

  * **Parameter:** `inputObject` - Input data to convert.
  * **Return:** `stringObject` - Converted string from input object data.

* **Function:** `writeString(inputString)` - Converts string raw data to proper JSON string.

  * **Parameter:** `inputString` - Input data to convert.
  * **Return:** `stringString` - Converted string from input string data.
