# XAF Module - Graphic:Checkbox

Checkbox is a graphical component which acts near identically to switch, but it has different look. Its current state is shown as `X` in center of tick box. Checkbox constructor also accepts `showLabel` parameter, which enables one line of label with the `X` box. Dimensions of whole checkbox are automatically changed to fit well. That component actually responses on `select` and `deselect` events.

## Class documentation

* **Class name -** `Generic GUI Checkbox`, **instantiable -** `true`, **inheritable -** `true`
* **Static fields**

  * *no static fields*

* **Constructor -** `Checkbox:new(positionX, positionY, showLabel)`
* **Dependencies -** `Graphic:Component`

## Method documentation

* *All methods from* `Graphic:Component`

* **Function:** `getLabel()` - Returns current checkbox's label line.

  * **Return:** `label` - Label line used by the checkbox.

* **Function:** `getSelected()` - Returns checkbox selection state.

  * **Return:** `selected` - Selection flag.

* **Function:** `register(event)` - Register the checkbox into the main event loop.

  * **Parameter:** `event` - Event table from event.pull() function in OC Event API.
  * **Return:** `...` - Result from component event functions if present.

* **Function:** `setLabel(labelLine)` - Changes current checkbox label line.

  * **Parameter:** `labelLine` - Component label line (accepts strings, numbers or booleans).
  * **Return:** `'true'` - If the new label has been set successfully.

* **Function:** `setOnDeselect(task, ...)` - Sets new task function on 'deselect' event.

  * **Parameter:** `task` - New task function.
  * **Parameter:** `...` - Task function arguments.
  * **Return:** `'true'` - If the new task has been set correctly.

* **Function:** `setOnSelect(task, ...)` - Sets new task function on checkbox 'select' event.

  * **Parameter:** `task` - New event task function.
  * **Parameter:** `...` - Event task function argument list.
  * **Return:** `'true'` - If new function has been set successfully.

* **Function:** `setSelected(state)` - Changes checkbox selection state.

  * **Parameter:** `state` - New selection flag as boolean.
  * **Return:** `'true'` - If the new selection state has been set properly.

* **Function:** `view()` - Renders checkbox on the screen.

  * **Return:** `'true'` - If that component has been rendered correctly.
