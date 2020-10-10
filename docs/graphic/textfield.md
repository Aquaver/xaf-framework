# XAF Module - Graphic:TextField

Text field module is the most common graphical component which allows entering data into application for further processing. It stores its content as table of lines and it may be retrieved as that table. That element also gives possibility to set current text, but it must be passed also as a table. Text field size is defined in constructor by `columns` and `rows` dimensions. It accepts three types of events: `click` - which responses on focus, `key` - that reacts on keyboard key press, and `paste` - which responds on clipboard insertions.

## Class documentation

* **Class name -** `Generic GUI Text Field`, **instantiable -** `true`, **inheritable -** `true`
* **Static fields**

  * *no static fields*

* **Constructor -** `TextField:new(positionX, positionY, columns, rows)`
* **Dependencies -** `Graphic:Component`

## Method documentation

* *All methods from* `Graphic:Component`

* **Function:** `clear()` - Clears the text field and resets its content.

  * **Return:** `'true'` - If text field has been cleared without errors.

* **Function:** `focus(lineNumber)` - Sets text field object's state to focused on given line and allow typing directly.

  * **Parameter:** `lineNumber` - Target field line number value.
  * **Return:** `oldLine` - Old value of selected line, if zero then the field was not focused on.

* **Function:** `getColorSelected()` - Returns text field selection (highlight) color.

  * **Return:** `colorSelected` - Current text field highlight color as number.

* **Function:** `getLineExtension()` - Returns current set line extension capacity value.

  * **Return:** `lineExtension` - Value of text line extended capacity (in characters).

* **Function:** `getText()` - Returns text field content table.

  * **Return:** `textTable` - Table with text content lines.

* **Function:** `getTrimmedText()` - Returns text table trimmed trailing empty lines (nil or empty characters).

  * **Return:** `trimmedText` - Value of text table without last empty lines.

* **Function:** `register(event)` - Registers the text field component in main event loop.

  * **Parameter:** `event` - Event object table from 'event.pull()' function in OC Event API.
  * **Return:** `...` - Results from event task functions if they have been registered.

* **Function:** `setColorSelected(color)` - Changes text field selection (highlight) number.

  * **Parameter:** `color` - New line selection (highlight) color (in 0 - 0xFFFFFF range).
  * **Return:** `'true'` - If new color has been set properly.

* **Function:** `setLineExtension(newValue)` - Extends total capacity of text line (in characters).

  * **Parameter:** `newValue` - Value of line extension (0 to disable, math.huge for no limit).
  * **Return:** `'true'` - If new line extension value has been set.

* **Function:** `setOnClick(task, ...)` - Changes response action on 'click' event.

  * **Parameter:** `task` - New task function.
  * **Parameter:** `...` - New task parameters.
  * **Return:** `'true'` - If new event function has been set correctly.

* **Function:** `setOnKey(task, ...)` - Sets new task function on 'key' (keyboard key press) event.

  * **Parameter:** `task` - New event task function.
  * **Parameter:** `...` - New event function parameter list.
  * **Return:** `'true'` - If the new function has been changed properly.

* **Function:** `setOnPaste(task, ...)` - Changes task action function on 'paste' (clipboard insert) event.

  * **Parameter:** `task` - Task event function to replace.
  * **Parameter:** `...` - New task function parameters table.
  * **Return:** `'true'` - If new task action function has been set without errors.

* **Function:** `setText(text)` - Sets new text field content table.

  * **Parameter:** `text` - Table with new text content table.
  * **Return:** `'true'` - If new text has been set correctly.

* **Function:** `unfocus()` - Sets text field object's state to unfocused and blocks further typing.

  * **Return:** `'true'` - If this method has been executed without errors.

* **Function:** `view()` - Renders text field on the screen.

  * **Return:** `'true'` - If the component has been rendered successfully.

### Private in-class method documentation

* **Function:** `refreshLine(line)` - Refreshes one text line in field container.

  * **Parameter:** `line` - Line number which will be refreshed.
  * **Return:** `'true'` - If text line has been refreshed successfully.
