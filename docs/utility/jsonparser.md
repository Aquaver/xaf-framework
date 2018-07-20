# XAF Module - Utility:JSONParser

Another class in category of utilities, which provides mechanism for reading data files saved in JSON (JavaScript Object Notation) format. It implements simple parser, which processes plain JSON text and returns ready object as Lua table or value (number, string, boolean or Lua `nil`). This module is undoubtedly useful in data interchange and client-server communication. Furthermore, this format is more common than its equivalent, the XML format, because JSON is more simple, clear and it is slightly faster to process.

## Class documentation

* **Class name -** `Generic JSON Parser`, **instantiable -** `true`, **inheritable -** `true`
* **Static fields**

  * *no static fields*

* **Constructor -** `JSONParser:new()`
* **Dependencies -** *no dependencies*

## Method documentation

* **Function:** `parse(inputJson)` - Starts JSON text processing procedure into Lua object.

  * **Parameter:** `inputJson` - JSON data as plain text string.
  * **Return:** `...` - Processed JSON object table or value (number, boolean, string, nil).

### Private in-class method documentation

* **Function:** `getNextCharacter()` - Returns next character from entire input string.

  * **Return:** `currentCharacter` - Next character from input JSON string.

* **Function:** `getValue()` - Detects following value type in input string and parses it.

* **Function:** `parseArray()` - Parses string token into JSON array type value.

  * **Return:** `valueArray` - Parsed JSON array as Lua table.

* **Function:** `parseBoolean()` - Parses string token into JSON boolean type value.

  * **Return:** `valueBoolean` - Parsed JSON boolean value ('true' or 'false').

* **Function:** `parseNull()` - Parses string token into JSON null type value.

  * **Return:** `valueNull` - Parsed JSON null value (as Lua 'nil').

* **Function:** `parseNumber()` - Parses string token into JSON number type value.

  * **Return:** `valueNumber` - Parsed JSON number value.

* **Function:** `parseObject()` - Parses string token into JSON object type value.

  * **Return:** `valueObject` - Parsed JSON object value as Lua table (with non-index keys).

* **Function:** `parseString` - Parses string token into JSON string type value.

  * **Return:** `valueString` - Parsed JSON string value.

* **Function:** `removeWhitespaces(jsonString)` - Minifies the JSON string on input by removing all whitespaces (except in string literals).

  * **Parameter:** `jsonString` - Input JSON string to minify.
  * **Return:** `transformedString` - Minified JSON string, ready to parse.
