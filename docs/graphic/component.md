# XAF Module - Graphic:Component

Component class is the abstract top-level interface for graphic components hierarchy. This library provides basic functions that describe the same behavior of all components controlled by XAF framework. If you would like to create brand new graphic controller, you should extend this class - all functions will implement automatically. However, if you are going to extend specific existing component, you may extend this component - not need to inherit from Component class in this case.

## Class documentation

* **Class name -** `Abstract Graphic Component`, **instantiable -** `false`, **inheritable -** `true`
* **Static fields**

  * `RENDER_DEFAULT` - Constant used in function `setRenderMode(mode)` as `mode` parameter. When used, the whole component will be rendered within its border, insets and content.
  * `RENDER_ALL` - Constant used in function `setRenderMode(mode)` as `mode` parameter. It works exactly the same as `RENDER_DEFAULT` option.
  * `RENDER_INSETS` - Constant used in function `setRenderMode(mode)` as `mode` parameter. With this argument, component will only render internal content (text) and background area directly around it - without the border. **Important!** In spite of component will not render its border, its position also will not change. You must consider position offset when placing.
  * `RENDER_CONTENT` - Constant used in function `setRenderMode(mode)` as `mode` parameter. It will render component's content only - text without insets and border.

* **Constructor** - *class is not instantiable - no constructor*
* **Dependencies** - *no dependencies*

## Method documentation

* **Function:** `getActive()` - Returns current component activity state.

  * **Return:** `active` - Boolean flag whether component is currently active.

* **Function:** `getColors()` - Returns current used component primary colors.

  * **Return:** `colorBorder, colorBackground, colorContent` - Next component primary colors as numbers.

* **Function:** `getPosition()` - Returns component absolute position on the screen in pixels.

  * **Return:** `positionX, positionY` - Component absolute coordinates in pixels.

* **Function:** `getRenderMode()` - Returns current component rendering mode.

  * **Return:** `renderMode` - Component rendering mode as number.

* **Function:** `getRenderer()` - Returns component's GPU render engine.

  * **Return:** `renderer` - Current component's render engine.

* **Function:** `getTotalSize()` - Returns total component size (width and height) in pixels.

  * **Return:** `totalWidth, totalHeight` - Total size of the component in pixels.

* **Function:** `setActive(state)` - Changes component activity state to new one.

  * **Parameter:** `state` - New activity state of the component.
  * **Return:** `'true'` - If new component activity state has been changed successfully.

* **Function:** `setColors(border, background, content)` - Changes current component primary colors.

  * **Parameter:** `border` - New border color number in 0x000000 - 0xFFFFFF range.
  * **Parameter:** `background` - New background color number in 0x000000 - 0xFFFFFF range.
  * **Parameter:** `content` - New content (text) color number in 0x000000 - 0xFFFFFF range.
  * **Return:** `'true'` - If all colors were set correctly.

* **Function:** `setPosition(newX, newY)` - Changes the component's coordinates to new ones.

  * **Parameter:** `newX` - New horizontal position number.
  * **Parameter:** `newY` - New vertical position number.
  * **Return:** `'true'` - If new coordinates have been changed successfully.

* **Function:** `setRenderMode(mode)` - Switches current component rendering mode.

  * **Parameter:** `mode` - New rendering mode (all modes are defined as static constants).
  * **Return:** `'true'` - If new rendering mode was set correctly.

* **Function:** `setRenderer(gpu)` - Sets new GPU as render engine for component.

  * **Parameter:** `gpu` - New component's render engine.
  * **Return:** `'true'` - If new renderer has been set properly.

* **Function:** `view()` - Default rendering function, which always throw an error. It was created to remind that every component must override this method.
