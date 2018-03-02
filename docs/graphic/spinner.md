# XAF Module - Graphic:Spinner

Another component and integral part of XAF framework GUI library - the Spinner class. That element generally does one thing - stores values table and shows one from them as selected one. It works in two ways: as 'counter' or 'iterator'. The first type lets you to scroll in bounds of numerical values from `minimum` to `maximum` by `increment` number, which do not have to be integer, floating-point numbers are also accepted but must fit in given limits. The second mode of spinner is an `iterator` which works almost same as first but its value is not number but table with lines (may be strings, numbers and booleans too, but in spinner box they are automatically converted to string). This component listens for `click` and `scroll` events when registered.

## Class documentation

* **Class name -** `Generic GUI Spinner`, **instantiable -** `true`, **inheritable -** `true`
* **Static fields**

  * `MODE_DEFAULT` - Constant used in constructor as `mode` parameter. Changes spinner's working mode to 'counter' exactly like `MODE_COUNTER` does.
  * `MODE_COUNTER` - Constant used in constructor as `mode` parameter. When used, you may set numerical values only to the spinner.
  * `MODE_ITERATOR` - Constant used in constructor as `mode` parameter. If that option is passed, spinner accepts table with value lines to traverse through it when scrolling.

* **Constructor -** `Spinner:new(positionX, positionY, columns, mode)`
* **Dependencies -** `Graphic:Component`

## Method documentation

* *All methods from* `Graphic:Component`
* **Function:** `getValue()` - Returns current spinner value.

  * **Return:** `currentValue` - Current value of the spinner.

* **Function:** `register(event)` - Registers the spinner in main event loop.

  * **Parameter:** `event` - Event table from 'event.pull()' in OC Event API.
  * **Return:** `...` - Results from event task function if it has been registered.

* **Function:** `setCounter(minimum, maximum, increment)` - Changes spinner value bounds and increment (only for counters).

  * **Parameter:** `minimum` - Minimum value bound.
  * **Parameter:** `maximum` - Maximum value bound.
  * **Parameter:** `increment` - Value incrementation number.
  * **Return:** `'true'` - If new values have been set successfully.

* **Function:** `setIterator(content)` - Sets spinner new content table (only for iterators).

  * **Parameter:** `content` - New table with content.
  * **Return:** `'true'` - If new content table has been set correctly.

* **Function:** `setOnClick(task, ...)` - Changes spinner task executed on successful 'click' event.

  * **Parameter:** `task` - New task function.
  * **Parameter:** `...` - Event function arguments.
  * **Return:** `'true'` - If new event task has been set correctly.

* **Function:** `setOnScroll(task, ...)` - Changes spinner event function performed on proper 'scroll' event.

  * **Parameter:** `task` - New task event function.
  * **Parameter:** `...` - Event task function arguments.
  * **Return:** `'true'` - If new event function has been changed properly.

* **Function:** `view()` - Renders spinner on the screen.

  * **Return:** `'true'` - If the spinner has been rendered without errors.
