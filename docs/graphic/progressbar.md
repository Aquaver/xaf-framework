# XAF Module - Graphic:ProgressBar

Progress Bar is a simple graphic component which does not accept any events. It is only used for showing progress of some process graphically. Its container is defined by `columns` and `rows` dimensions in constructor, while the internal progress bar orientation is specified also in constructor as `layoutMode` parameter and it accepts currently either two states: horizontal (default) or vertical, and it is independent of container's size.

## Class documentation

* **Class name -** `Generic GUI Progress Bar`
* **Static fields**

  * `LAYOUT_DEFAULT` - Constant used in constructor or in function `setLayout(mode)` as `mode` parameter. It works exactly the same as `LAYOUT_HORIZONTAL` option.
  * `LAYOUT_HORIZONTAL` - Constant used in constructor or in function `setLayout(mode)` as `mode` parameter. When used, internal progress bar renders horizontally from left to right.
  * `LAYOUT_VERTICAL` - Constant used in constructor or in function `setLayout(mode)` as `mode` parameter. If this option is passed, then bar will render vertically from bottom to top.

* **Constructor -** `ProgressBar:new(positionX, positionY, columns, rows, layoutMode)`
* **Dependencies -** `Graphic:Component`

## Method documentation

* *All methods from* `Graphic:Component`

* **Function:** `getLayoutMode()` - Returns progress bar component layout mode.

  * **Return:** `barLayout` - Current progress bar layout mode number.

* **Function:** `getValue()` - Returns current progress bar value.

  * **Return:** `currentValue` - Current progress bar numerical value.

* **Function:** `set(value)` - Changes current progress value.

  * **Parameter:** `value` - New progress value.
  * **Return:** `'true'` - If the new progress bar value has been set successfully.

* **Function:** `setLayoutMode(mode)` - Changes progress bar component layout mode.

  * **Parameter:** `mode` - New progress bar layout mode (all modes are defined as static constants).
  * **Return:** `'true'` - If the new progress bar layout mode has been set correctly.

* **Function:** `setValues(minimum, maximum, initial)` - Sets new progress bar value bounds with initial value.

  * **Parameter:** `minimum` - New minimum value bound.
  * **Parameter:** `maximum` - New maximum value bound.
  * **Parameter:** `initial` - New current value set as initial.
  * **Return:** `'true'` - If all values have been changed properly and without errors.

* **Function:** `refresh()` - Refreshes the progress bar without rendering entire component (it is slightly faster than 'view()' function).

  * **Return:** `'true'` - Returned if component has been refreshed properly.

* **Function:** `view()` - Renders progress bar on the screen.

  * **Return:** `'true'` - If the component has been rendered correctly.
