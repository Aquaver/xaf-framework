# XAF Module - API:PackageManager

This class is the first in new `API` module group which contains classes that helps in integration between XAF internal software and external user built applications. This one module provides mechanisms for creating programs hooked up with XAF Package Manager. It allows inter-package communication by means of XAF PM application data tables. These table just store simple key-value pairs for specified package and may be used for passing data to other packages' tables, and communicate with them. This class also comes with useful functions that help with switching between scripts in one application package.

## Class documentation

* **Class name -** `XAF Package Manager API`, **instantiable -** `true`, **inheritable -** `true`
* **Static fields**

  * *no static fields*

* **Constructor -** `PackageManager:new(packageIdentifier)`
* **Dependencies -** *no dependencies*

## Method documentation

* **Function:** `checkTable()` - Checks whether XAF application data table of this package exists.

  * **Return:** `'true' or 'false'` - If present package's table exists.

* **Function:** `createTable()` - Tries to create XAF application data table for this package.

  * **Return:** `'true' or 'false'` - If the table has been created successfully.

* **Function:** `dropTable()` - Tries to remove XAF application data table for this package.

  * **Return:** `'true' or 'false'` - If the table has been dropped (removed) without errors.

* **Function:** `getPackagePath(relativePath)` - Returns absolute path of this package built on parameter relative path.

  * **Parameter:** `relativePath` - Relative path of given target file.
  * **Return:** `pathBinary` - Created absolute path of given target object file.

* **Function:** `getTableValue(tableKey)` - Returns specified data value from XAF application data table of this package.

  * **Parameter:** `tableKey` - Table index (key) of data value you would like to get from.
  * **Return:** `'true' or 'false'` - Boolean flag is the application data table exists (If 'true' then second returned value is retrieved data value).

* **Function:** `setTableValue(tableKey, tableValue)` - Changes (sets or removes) value stored under specified key in package's XAF application data table.

  * **Parameter:** `tableKey` - Table index (key) under which the new data will be stored.
  * **Parameter:** `tableValue` - New data value that will be stored under given key, leave empty (`nil`) to remove.
