# XAF Module - Graphic:Switch

Switch is a next common graphic component which allows toggling between two states - active and inactive. It switches in response on single click on it and executes task function that is corresponding to each state. That class comes with two methods responsible for setting behavior functions and assigning them to `active` or `inactive` events. Furthermore, on each toggle the switch will change its primary colors.

## Class documentation

* **Class name -** `Generic GUI 2-state Switch`, **instantiable -** `true`, **inheritable -** `true`
* **Static fields**

  * *no static fields*

* **Constructor -** `Switch:new(positionX, positionY)`
* **Dependencies -** `Graphic:Component`

## Method documentation

* *All methods from* `Graphic:Component`
* **Function:** `getActivated()` - Returns switch's activated state ('true' or 'false').

  * **Return:** `activeState` - Current active state as boolean value.

* **Function:** `getColorsActive()` - Returns switch's colors (in activated state).

  * **Return:** `colorBorderActive, colorBackgroundActive, colorContentActive` - Next primary switch's colors (activated state).

* **Function:** `register(event)` - Registers switch in main event loop.

  * **Parameter:** `event` - Event table from event.pull() in OC Event API.
  * **Return:** `...` - Results from registered function if they are.

* **Function:** `setActivated(state)` - Changes switch activity state.

  * **Parameter:** `state` - New activated state as boolean.
  * **Return:** `'true'` - If the new state has been set correctly.

* **Function:** `setColorsActive(background, border, content)` -- Sets new switch's primary colors (in activated state).

  * **Parameter:** `border` - New border color (in 0 - 0xFFFFFF range).
  * **Parameter:** `background` - New background color (in 0 - 0xFFFFFF range).
  * **Parameter:** `content` - New content color (in 0 - 0xFFFFFF range).
  * **Return:** `'true'` - If the new colors (of activated state switch) have been changed properly.

* **Function:** `setLabel(...)` - Changes switch's label lines.

  * **Parameter:** `...` - Next label lines.
  * **Return:** `'true'` - If the label has been set properly.

* **Function:** `setOnActive(task, ...)` - Changes the function called on 'active' event and its arguments.

  * **Parameter:** `task` - Task function.
  * **Parameter:** `...` - Task function arguments.
  * **Return:** `'true'` - If new task has been set correctly.

* **Function:** `setOnInactive(task, ...)` - Changes the function called on 'inactive' event and its arguments.

  * **Parameter:** `task` - New task function.
  * **Parameter:** `...` - New task function arguments.
  * **Return:** `'true'` - If the new task function has been set successfully.

* **Function:** `view()` - Renders switch on the screen.

  * **Return:** `'true'` - If the component has been renderer successfully.
