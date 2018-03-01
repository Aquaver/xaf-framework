# XAF Module - Graphic:Slider

The slider component comes with one but very useful functionality - it allows storing adjustable value, which may be changed with slider bar by dragging it. That numerical value is described with its initial and incremental value. Slider can also change its bar increment property, so it could have only two states even if it is longer than two pixels. That component currently responses only on `drag` event, which the most commonly is used to get changed value.

## Class documentation

* **Class name -** `Generic GUI Slider`, **instantiable -** `true`, **inheritable -** `true`
* **Static fields**

  * `ROTATE_DEFAULT` - Constant used in constructor as `sliderRotation` parameter. With this option, slider will behave exactly the same as with `ROTATE_HORIZONTAL` option.
  * `ROTATE_HORIZONTAL` - Constant used in constructor as `sliderRotation` parameter. When used, slider will render horizontally to right.
  * `ROTATE_VERTICAL` - Constant used in constructor as `sliderRotation` parameter. With this option, the slider renders vertically to down.

* **Constructor -** `Slider:new(positionX, positionY, sliderLength, sliderRotation)`
* **Dependencies -** `Graphic:Component`

## Method documentation

* *All methods from* `Graphic:Component`

* **Function:** `getValue()` - Returns current slider's value.

  * **Return:** `value` - Current value of the slider as number.

* **Function:** `register(event)` - Registers slider in main event loop.

  * **Parameter:** `event` - Event table from OC Event API in 'event.pull()' function.
  * **Return:** `...` - Results from event task function if it has been set.

* **Function:** `setOnDrag(task, ...)` - Changes slider response action on 'drag' event.

  * **Parameter:** `task` - New action task function.
  * **Parameter:** `...` - New action task argument list.
  * **Return:** `'true'` - If new event function has been set properly.

* **Function:** `setValues(start, increment, skip)` - Changes slider value bounds and bar incrementation number.

  * **Parameter:** `start` - Initial slider value.
  * **Parameter:** `increment` - Slider value incremental number.
  * **Parameter:** `skip` - Slider bar shift (skip) value.
  * **Return:** `'true'` - If every value has been set correctly.

* **Function:** `view()` - Renders slider on the screen.

  * **Return:** `'true'` - If component has been rendered properly.
