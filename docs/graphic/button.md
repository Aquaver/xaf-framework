# XAF Module - Graphic:Button

That class describes a basic graphic component - clickable button, which may be also used as plain label if deactivated or its event has not been set. It reacts on two types of event: `click` and `double-click`. The dimensions of this component are automatically set while changing its label text, so you need not to worry about it. To act as a button and response on incoming events this class come with two methods to set corresponding task functions to its event types.

## Class documentation

* **Class name -** `Generic GUI Button`, **instantiable -** `true`, **inheritable -** `true`
* **Static fields**

  * `THRESHOLD_DEFAULT` - Constant used in method `setDoubleClickThreshold(newTime)` as `newTime` parameter. Its value equals 0.25 second.
  * `THRESHOLD_SLOW` - Constant used in method `setDoubleClickThreshold(newTime)` as `newTime` parameter. Its value equals 0.5 second and this is the slowest one from predefined values.
  * `THRESHOLD_NORMAL` - Constant used in method `setDoubleClickThreshold(newTime)` as `newTime` parameter. Its value equals 0.25 second exactly like the default one.
  * `THRESHOLD_FAST` - Constant used in method `setDoubleClickThreshold(newTime)` as `newTime` parameter. Its value equals 0.1 second and that is the fastest one from predefined constants.

* **Constructor -** `Button:new(positionX, positionY)`
* **Dependencies -** `Graphic:Component`

## Method documentation

* *All methods from* `Graphic:Component`
* **Function:** `getDoubleClickThreshold()` - Returns current button double click time threshold.

  * **Return:** `doubleClickThreshold` - Current threshold value.

* **Function:** `getLabel()` - Returns button's label lines as strings.

  * **Return:** `...` - Next label lines strings.

* **Function:** `register(event)` - Registers that component into main event table.

  * **Parameter:** `event` - Event table from function event.pull() in OC Event API.
  * **Return:** `...` - Results from event task function if it returns anything.

* **Function:** `setDoubleClickThreshold(newTime)` - Changes button double click event time threshold.

  * **Parameter:** `newTime` - new time threshold in seconds.
  * **Return:** `'true'` - If the new value has been set properly.

* **Function:** `setLabel(...)` - Changes current button label.

  * **Parameter:** `...` - Next button's label lines (strings, numbers and booleans are accepted).
  * **Return:** `'true'` - If the label has been set without errors.

* **Function:** `setOnClick(task, ...)` - Sets the button task which triggers on 'click' event.

  * **Parameter:** `task` - Function which will be called on event.
  * **Parameter:** `...` - Event function arguments.
  * **Return:** `'true'` - If the task has been set properly.

* **Function:** `setOnDoubleClick(task, ...)` - Sets the button task which triggers on 'double-click' event.

  * **Parameter:** `task` - Function which will be called on event.
  * **Parameter:** `...` - Event function argument list.
  * **Return:** `'true'` - If the task has been changed successfully.

* **Function:** `view()` - Renders button on the screen within set rendering mode.

  * **Return:** `'true'` - If button has been rendered properly.
