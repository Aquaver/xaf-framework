# XAF Module - Utility:RedStream

RedStream (also referenced as Redstone Stream) is a class which generally makes using cards or another redstone input/output components more easy with simplified API based on original OC's Redstone ones. Each object of this class encloses standalone redstone signal 'stream' which is being described with its properties like input/output side or bundle color. To distinguish between analog (from vanilla redstone) and signal in bundled cables (like from ProjectRed addon), this module has built-in three modes: 0 - default (analog), 1 - analog signal and 2 - digital (also called as bundled or colored) signal. To start working with redstone streams you will need get attached redstone component, use it in object constructor to get its handle and set the input/output side. For using digital mode you must also set the bundle color. And that is all - use implemented function to control the signal - `on()` and `off()`. **Important!** One redstone component may support multiple redstone stream objects. Therefore, you should create more than one object if you would like to control few signals sides or colors within one component.

## Class documentation

* **Class name -** `Generic Redstone Stream`, **instantiable -** `true`, **inheritable -** `true`
* **Static fields**

  * `MODE_DEFAULT` - Constant used in constructor as `mode` parameter. Works exactly the same like `MODE_ANALOG` and sets the signal to analog mode (from vanilla redstone).
  * `MODE_ANALOG` - Constant used in constructor as `mode` parameter. Changes the redstone stream mode to analog.
  * `MODE_DIGITAL` - Constant used in constructor as `mode` parameter. Sets redstone stream to digital mode and allows using bundle colors from single side.

* **Constructor -** `RedStream:new(component, mode)`
* **Dependencies -** *no dependencies*

## Method documentation

* **Function:** `getBundleColor()` - Returns redstone stream bundle color in digital mode.

  * **Return:** `bundleColor` - Current stream bundle color name as number.

* **Function:** `getComponent()` - Returns redstone component used by this stream.

  * **Return:** `componentRedstone` - Stream's redstone component as its object (table).

* **Function:** `getInput()` - Returns current signal input value from specified side of the redstone component.

  * **Return:** `inputValue` - Detected redstone signal strength.

* **Function:** `getOutput()` - Returns current output redstone signal strength from specified side of the redstone component.

  * **Return:** `outputValue` - Detected output redstone signal power value.

* **Function:** `getStreamMode()` - Returns redstone stream mode.

  * **Return:** `streamMode` - Redstream mode value as number.

* **Function:** `getStreamSide()` - Returns current redstone stream side (of computer, Redstone Card or external IO block).

  * **Return:** `streamSide` - Redstream side value as its number.

* **Function:** `off()` - Switches off the redstone signal and sets it to 0 (zero).

  * **Return:** `'true'` - If the signal has been switched off without errors.

* **Function:** `on(value)` - Switches on redstone output signal and sets it to specified value.

  * **Parameter:** `value` - New redstone power value - if 'nil' then it will be the maximum available ('full on').
  * **Return:** `'true'` - If the redstone signal has been changed properly.

* **Function:** `setBundleColor(color)` - Changes redstone bundle color for digital mode.

  * **Parameter:** `color` - Plain color name as string (white, orange, light_blue, etc). All bundle colors have been shown below.
  * **Return:** `'true'` - If the color value has been set correctly.

| Color name | Numeric value | Color name | Numeric value | Color name | Numeric value | Color name | Numeric value |
| ---------- | ------------- | ---------- | ------------- | ---------- | ------------- | ---------- | ------------- |
| white      | 0             | yellow     | 4             | light_gray | 8             | brown      | 12            |
| orange     | 1             | lime       | 5             | cyan       | 9             | green      | 13            |
| magenta    | 2             | pink       | 6             | purple     | 10            | red        | 14            |
| light_blue | 3             | gray       | 7             | blue       | 11            | black      | 15            |

* **Function:** `setComponent(component)` - Sets stream's redstone component.

  * **Parameter:** `component` - New redstone component (card or external IO block).
  * **Return:** `'true'` - If the component has been set correctly.

* **Function:** `setStreamSide(side)` - Sets redstone stream side, from which the signal will be transmitted.

  * **Parameter:** `side` - New side as its name, may be absolute (like 'north') or relative (like 'right'). All supported sides have been shown below.
  * **Return:** `'true'` - If the side value has been changed properly.

    * `top`
    * `bottom`
    * `back (north)`
    * `front (south)`
    * `right (west)`
    * `left (east)`
