# XAF Module - Graphic:List

The list is first graphic component in XAF framework which has slightly more complexity than others. Entire list is built from two parts: text lines container and scroll bar which works as relative position indicator in these lines. That component also allows selecting and deselecting specific lines which may be received in two ways - as keys or as values - with built in functions. Content of the list is set as table of text lines, thus these lines are automatically sorted asciibetically. Moreover, the whole content may be reversed and shown in other order. Finally, the list responses on two types of events - `click` and `scroll`.

## Class documentation

* **Class name -** `Generic GUI List`, **instantiable -** `true`, **inheritable -** `true`
* **Static fields**

  * `SELECT_DEFAULT` - Constant used in `setSelectionModel(mode, color)` as `mode` parameter. It works the same as `SELECT_SINGLE` option.
  * `SELECT_SINGLE` - Constant used in `setSelectionModel(mode, color)` as `mode` parameter. When used, the list will accept only one selection at once, and automatically deselect the others.
  * `SELECT_MULTIPLE` - Constant used in `setSelectionModel(mode, color)` as `mode` parameter. With that option list will accept multiple selections simultaneously.

* **Constructor -** `List:new(positionX, positionY, columns, rows, showScroll)`
* **Dependencies -** `Core:XAFCore`, `Graphic:Component`

## Method documentation

* *All methods from* `Graphic:Component`

* **Function:** `getContent()` - Returns current list content table.

  * **Return:** `contentTable` - List content table.

* **Function:** `getSelectedKeys()` - Returns list selected line-keys pairs table.

  * **Return:** `selectedKeys` - Table with selected line-keys pairs.

* **Function:** `getSelectedValues()` - Returns list selected line-values pairs table.

  * **Return:** `selectedValues` - Table with selected line-values pairs.

* **Function:** `getSelectionModel()` - Returns current list selection model (mode number and color number).

  * **Return:** `selectionMode, colorSelected` - Parts of current list selection model.

* **Function:** `getShowKeys()` - Returns list's key showing flag on 'view()' function.

  * **Return:** `showKeys` - List showing flag as boolean.

* **Function:** `register(event)` - Register the list in main event loop.

  * **Parameter:** `event` - Event table from event.pull() function in OC Event API.
  * **Return:** `...` - Results from event function if it has been registered.

* **Function:** `setContent(content, reversed)` - Changes the list content table and sets key reversion flag.

  * **Parameter:** `content` - New content table.
  * **Parameter:** `reversed` - List key showing reversion flag.
  * **Return:** `'true'` - If new content has been set correctly.

* **Function:** `setOnClick(task, ...)` - Changes the list event task on 'click' event.

  * **Parameter:** `task` - New task function.
  * **Parameter:** `...` - Task function argument list.
  * **Return:** `'true'` - If new event task has been set successfully.

* **Function:** `setOnScroll(task, ...)` - Sets the new list event task on 'scroll' event.

  * **Parameter:** `task` - New task event function.
  * **Parameter:** `...` - New task argument list.
  * **Return:** `'true'` - If the new task function has been changed correctly.

* **Function:** `setSelectionModel(mode, color)` - Sets new list selection model (mode number and color number).

  * **Parameter:** `mode` - New selection mode (0 - default, 1 - single, 2 - multiple).
  * **Parameter:** `color` - New selected line highlight color.
  * **Return:** `'true'` - If the new selection model has been set properly.

* **Function:** `setShowKeys(flag)` - Changes list showing keys on 'view()' function before the value.

  * **Parameter:** `flag` - New key showing flag.
  * **Return:** `'true'` - If the new flag has been set correctly.

* **Function:** `view()` - Renders the list on screen.

  * **Return:** `'true'` - If the component has been rendered properly.
