# XAF Module - Graphic:PasswordField

Password Field is a graphic component which works similarly to Text Field, but it has one difference - it may have only one row and its input is hidden with masking character, thus the password is not visible on screen directly. This masking character is an asterisk `(*)` by default, but it may be changed as you wish. While it is working, it accepts three types of events like the Text Field does - `click`, `key` and `paste`. More information about these two last you find in Text Field documentation.

## Class documentation

* **Class name -** `Generic GUI Password Field`, **instantiable -** `true`, **inheritable -** `true`
* **Static fields**

  * *no static fields*

* **Constructor -** `PasswordField:new(positionX, positionY, columns)`
* **Dependencies -** `Graphic:Component`

## Method documentation

* *All methods from* `Graphic:Component`
* **Function:** `getColorSelected()` - Returns password field input selection (highlight) color.

  * **Return:** `colorSelected` - Current input highlight color as number.

* **Function:** `getInput()` - Returns password field hidden input string value.

  * **Return:** `inputValue` - Hidden string value of the password field.

* **Function:** `getMaskingCharacter()` - Returns current password masking character.

  * **Return:** `inputCharacter` - Current password masking character.

* **Function:** `getShowPassword()` - Returns current password showing property.

  * **Return:** `showFlag` - Hidden value showing flag.

* **Function:** `register(event)` - Registers the password field in main event loop.

  * **Parameter:** `event` - Event table from function 'event.pull()' in OC Event API.
  * **Return:** `...` - Results from registered event task functions if they exist.

* **Function:** `setColorSelected(color)` - Changes password field selection (highlight) color.

  * **Parameter:** `color` - New highlight color number.
  * **Return:** `'true'` - If new color has been set properly.

* **Function:** `setInput(value)` - Changes password field current input value.

  * **Parameter:** `value` - New input value as string.
  * **Return:** `'true'` - If new password value has been changed correctly.

* **Function:** `setMaskingCharacter(character)` - Changes password field masking character.

  * **Parameter:** `character` - New password input masking character.
  * **Return:** `'true'` - If new password masking character has been changed successfully.

* **Function:** `setOnClick(task, ...)` - Sets new action task called on 'click' event.

  * **Parameter:** `task` - New task function.
  * **Parameter:** `...` - Action function parameter list.
  * **Return:** `'true'` - If new task function has been set properly.

* **Function:** `setOnKey(task, ...)` - Changes component function on 'key' (keyboard key press) event.

  * **Parameter:** `task` - New callback action function.
  * **Parameter:** `...` - Argument list passed to task function.
  * **Return:** `'true'` - If new callback function has been changed successfully.

* **Function:** `setOnPaste(task, ...)` - Sets password field task function on 'paste' (clipboard insert) event.

  * **Parameter:** `task` - Event function to set.
  * **Parameter:** `...` - Table with new event function parameters.
  * **Return:** `'true'` - If new event function has been set without errors.

* **Function:** `setShowPassword(flag)` - Sets new password field showing property value.

  * **Parameter:** `flag` - New password showing flag.
  * **Return:** `'true'` - If new value has been changed properly.

* **Function:** `view()` - Renders password field on the screen.

  * **Return:** `'true'` - If the component has been rendered successfully.
