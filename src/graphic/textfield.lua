------------------------------------
-- XAF Module - Graphic:TextField --
------------------------------------
-- [>] That class describes the most common input graphic component - a text field.
-- [>] It stores its content as table with line-text pairs and it may be received as this table.
-- [>] Each text field's container dimensions is specified by columns and rows.
-- [!] Accepted events: 'click', 'key', 'clipboard'

local component = require("xaf/graphic/component")
local unicode = require("unicode")
local xafcore = require("xaf/core/xafcore")
local xafcoreMath = xafcore:getMathInstance()

local TextField = {
  C_NAME = "Generic GUI Text Field",
  C_INSTANCE = true,
  C_INHERIT = true,

  static = {}
}

function TextField:initialize()
  local parent = component:extend()
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}

  private.colorSelected = 0xFFFFFF
  private.eventClick = nil
  private.eventClickArguments = {}
  private.eventKey = nil
  private.eventKeyArguments = {}
  private.eventPaste = nil
  private.eventPasteArguments = {}
  private.fieldFocus = false
  private.lineExtension = 0
  private.selectedLine = 0
  private.textTable = {}

  private.refreshLine = function(self, line)                                                  -- [!] Function: refreshLine(line) - Refreshes one text line in field container.
    assert(type(line) == "number", "[XAF Graphic] Expected NUMBER as argument #1")            -- [!] Parameter: line - Line number which will be refreshed.
                                                                                              -- [!] Return: 'true' - If text line has been refreshed successfully.
    local posX = private.positionX
    local posY = private.positionY
    local maxWidth = private.columns
    local maxLine = private.rows
    local textLine = line
    local textTable = private.textTable
    local totalLength = private.columns + private.lineExtension
    local lineLength = unicode.wlen(textTable[textLine])

    if (textLine <= maxLine) then
      local renderer = private.renderer

      if (renderer) then
        local previousBackground = renderer.getBackground()
        local previousForeground = renderer.getForeground()

        renderer.setBackground(private.colorBackground)
        renderer.setForeground(private.colorSelected)

        renderer.set(posX + 2, posY + textLine, string.rep(' ', maxWidth))

        if (lineLength < maxWidth) then
          renderer.set(posX + 2, posY + textLine, unicode.sub(textTable[textLine] .. '|', 1, maxWidth))
        else
          local newText = textTable[textLine]

          if (lineLength < totalLength) then
            newText = newText .. '|'
          end

          renderer.set(posX + 2, posY + textLine, unicode.sub(newText, -maxWidth, -1))
        end

        renderer.setBackground(previousBackground)
        renderer.setForeground(previousForeground)
      else
        error("[XAF Error] Component GPU renderer has not been initialized")
      end
    else
      error("[XAF Error] Invalid text line number")
    end

    return true
  end

  public.clear = function(self) -- [!] Function: clear() - Clears the text field and resets its content.
    private.fieldFocus = false  -- [!] Return: 'true' - If text field has been cleared without errors.
    private.selectedLine = 0
    public:setText({})

    if (private.renderer) then -- Do not view if GPU renderer has not been set yet (for example, while configuring).
      public:view()
    end

    return true
  end

  public.getColorSelected = function(self) -- [!] Function: getColorSelected() - Returns text field selection (highlight) color.
    return private.colorSelected           -- [!] Return: colorSelected - Current text field highlight color as number.
  end

  public.getLineExtension = function(self) -- [!] Function: getLineExtension() - Returns current set line extension capacity value.
    return private.lineExtension           -- [!] Return: lineExtension - Value of text line extended capacity (in characters).
  end

  public.getText = function(self) -- [!] Function: getText() - Returns text field content table.
    return private.textTable      -- [!] Return: textTable - Table with text content lines.
  end

  public.getTrimmedText = function(self)                      -- [!] Function: getTrimmedText() - Returns text table trimmed trailing empty lines (nil or empty characters).
    local textTable = private.textTable                       -- [!] Return: trimmedText - Value of text table without last empty lines.
    local trimmedText = {}

    for i = 1, #textTable do
      table.insert(trimmedText, textTable[i])
    end

    for i = #textTable, 1, -1 do
      if (trimmedText[i] == '' or trimmedText[i] == nil) then
        trimmedText[i] = nil
      else
        break
      end
    end

    return trimmedText
  end

  public.register = function(self, event)                                         -- [!] Function: register(event) - Registers the text field component in main event loop.
    assert(type(event) == "table", "[XAF Graphic] Expected TABLE as argument #1") -- [!] Parameter: event - Event object table from 'event.pull()' function in OC Event API.
                                                                                  -- [!] Return: ... - Results from event task functions if they have been registered.
    if (private.active == true) then
      if (event[1] == "clipboard") then
        local eventPaste = private.eventPaste
        local argumentsPaste = private.eventPasteArguments

        if (private.fieldFocus == true) then
          local lineLength = private.columns + private.lineExtension
          local lineNumber = private.selectedLine
          local valueRaw = event[3]
          local value = string.gsub(valueRaw, "[\n]+", ' ')
          local rawLine = private.textTable[lineNumber]
          local oldLine = (rawLine == nil) and '' or tostring(rawLine)
          local newLine = oldLine .. value

          private.textTable[lineNumber] = unicode.sub(newLine, 1, lineLength)
          private:refreshLine(lineNumber)

          if (eventPaste) then
            return eventPaste(table.unpack(argumentsPaste))
          end
        end
      elseif (event[1] == "key_down") then
        local eventKey = private.eventKey
        local argumentsKey = private.eventKeyArguments

        if (private.fieldFocus == true) then
          local keyChar = event[3]
          local keyCode = event[4]
          local render = private.renderMode

          if (keyCode == 28 or keyCode == 208) then -- Key code 28 (enter) or 208 (downwards arrow) will switch to line below.
            if (private.selectedLine < private.rows) then
              private.selectedLine = private.selectedLine + 1

              public:setRenderMode(component.static.RENDER_CONTENT)
              public:view()
              public:setRenderMode(render)
            end
          elseif (keyCode == 200) then -- Key code 200 (upwards arrow) will switch to line above.
            if (private.selectedLine > 1) then
              private.selectedLine = private.selectedLine - 1

              public:setRenderMode(component.static.RENDER_CONTENT)
              public:view()
              public:setRenderMode(render)
            end
          else -- Other key codes (for printable characters).
            if (keyChar == 8) then
              local lineNumber = private.selectedLine
              local rawLine = private.textTable[lineNumber]
              local oldLine = (rawLine == nil) and '' or tostring(rawLine)
              local newLine = unicode.sub(oldLine, 1, unicode.wlen(oldLine) - 1)

              if (oldLine == '' and lineNumber > 1) then
                private.selectedLine = lineNumber - 1 -- Moves one line up when trying 'backspace' on empty line.
                public:view()
              else
                private.textTable[lineNumber] = newLine
                private:refreshLine(lineNumber)
              end
            elseif (keyChar == 127) then
              -- Possible future feature, using DELETE key to remove characters in forward.
              -- Before it, must introduce possibility to move caret to the left and right inline.
            elseif (keyChar >= 32) then
              local lineLength = private.columns + private.lineExtension
              local lineNumber = private.selectedLine
              local rawLine = private.textTable[lineNumber]
              local oldLine = (rawLine == nil) and '' or tostring(rawLine)
              local newLine = oldLine .. unicode.char(keyChar)

              if (lineLength == math.huge) then
                lineLength = nil -- Unicode/string 'sub()' method does not accept 'math.huge' as limit value.
              end

              private.textTable[lineNumber] = unicode.sub(newLine, 1, lineLength)
              private:refreshLine(lineNumber)
            end
          end

          if (eventKey) then
            return eventKey(table.unpack(argumentsKey))
          end
        end
      elseif (event[1] == "touch") then
        local eventClick = private.eventClick
        local argumentsClick = private.eventClickArguments
        local screenAddress = event[2]

        if (screenAddress == private.renderer.getScreen()) then
          local clickX = event[3]
          local clickY = event[4]
          local render = private.renderMode
          local startPositionX = 0
          local startPositionY = 0
          local endPositionX = 0
          local endPositionY = 0

          if (render <= component.static.RENDER_CONTENT) then
            startPositionX = private.positionX + 2
            startPositionY = private.positionY + 1
            endPositionX = private.positionX + private.totalWidth - 3
            endPositionY = private.positionY + private.totalHeight - 2
          end

          if ((clickX >= startPositionX and clickX <= endPositionX)
          and (clickY >= startPositionY and clickY <= endPositionY)) then
            local absoluteLine = clickY
            local relativeLine = absoluteLine - private.positionY

            private.fieldFocus = true
            private.selectedLine = relativeLine

            public:setRenderMode(component.static.RENDER_CONTENT)
            public:view()
            public:setRenderMode(render)

            if (eventClick) then
              return eventClick(table.unpack(argumentsClick))
            end
          else
            if (private.fieldFocus == true) then
              private.fieldFocus = false
              private.selectedLine = 0

              public:setRenderMode(component.static.RENDER_CONTENT)
              public:view()
              public:setRenderMode(render)
            end
          end
        end
      end
    end
  end

  public.setColorSelected = function(self, color)                                   -- [!] Function: setColorSelected(color) - Changes text field selection (highlight) number.
    assert(type(color) == "number", "[XAF Graphic] Expected NUMBER as argument #1") -- [!] Parameter: color - New line selection (highlight) color (in 0 - 0xFFFFFF range).
                                                                                    -- [!] Return: 'true' - If new color has been set properly.
    if (color >= 0 and color <= 0xFFFFFF) then
      private.colorSelected = color
    else
      error("[XAF Error] Invalid text field selection color number")
    end

    return true
  end

  public.setLineExtension = function(self, newValue)                                                  -- [!] Function: setLineExtension(newValue) - Extends total capacity of text line (in characters).
    assert(type(newValue) == "number", "[XAF Graphic] Expected NUMBER as argument #1")                -- [!] Parameter: newValue - Value of line extension (0 to disable, math.huge for no limit).
                                                                                                      -- [!] Return: 'true' - If new line extension value has been set.
    if (xafcoreMath:checkNatural(newValue, false) == true) then
      private.lineExtension = newValue
      public:clear()
    else
      error("[XAF Error] Invalid new line extension value - must be natural number (including zero)")
    end

    return true
  end

  public.setOnClick = function(self, task, ...)                                        -- [!] Function: setOnClick(task, ...) - Changes response action on 'click' event.
    assert(type(task) == "function", "[XAF Graphic] Expected FUNCTION as argument #1") -- [!] Parameter: task - New task function.
                                                                                       -- [!] Parameter: ... - New task parameters.
    local event = task                                                                 -- [!] Return: 'true' - If new event function has been set correctly.
    local arguments = {...}

    private.eventClick = event
    private.eventClickArguments = arguments

    return true
  end

  public.setOnKey = function(self, task, ...)                                          -- [!] Function: setOnKey(task, ...) - Sets new task function on 'key' (keyboard key press) event.
    assert(type(task) == "function", "[XAF Graphic] Expected FUNCTION as argument #1") -- [!] Parameter: task - New event task function.
                                                                                       -- [!] Parameter: ... - New event function parameter list.
    local event = task                                                                 -- [!] Return: 'true' - If the new function has been changed properly.
    local arguments = {...}

    private.eventKey = event
    private.eventKeyArguments = arguments

    return true
  end

  public.setOnPaste = function(self, task, ...)                                        -- [!] Function: setOnPaste(task, ...) - Changes task action function on 'paste' (clipboard insert) event.
    assert(type(task) == "function", "[XAF Graphic] Expected FUNCTION as argument #1") -- [!] Parameter: task - Task event function to replace.
                                                                                       -- [!] Parameter: ... - New task function parameters table.
    local event = task                                                                 -- [!] Return: 'true' - If new task action function has been set without errors.
    local arguments = {...}

    private.eventPaste = event
    private.eventPasteArguments = arguments

    return true
  end

  public.setText = function(self, text)                                          -- [!] Function: setText(text) - Sets new text field content table.
    assert(type(text) == "table", "[XAF Graphic] Expected TABLE as argument #1") -- [!] Parameter: text - Table with new text content table.
                                                                                 -- [!] Return: 'true' - If new text has been set correctly.
    local textWidth = private.columns + private.lineExtension
    local textLength = private.rows
    local textTable = {}

    private.selectedLine = 0
    private.textTable = {}

    for i = 1, textLength do
      local lineRaw = text[i]
      local line = (lineRaw == nil) and '' or unicode.sub(tostring(lineRaw), 1, textWidth)

      table.insert(textTable, line)
      textLength = textLength + 1
    end

    private.textTable = textTable
    return true
  end

  public.view = function(self)                                                                            -- [!] Function: view() - Renders text field on the screen.
    local renderer = private.renderer                                                                     -- [!] Return: 'true' - If the component has been rendered successfully.

    if (renderer) then
      local columns = private.columns
      local rows = private.rows
      local width = private.totalWidth
      local height = private.totalHeight
      local posX = private.positionX
      local posY = private.positionY
      local previousBackground = renderer.getBackground()
      local previousForeground = renderer.getForeground()
      local render = private.renderMode

      if (render <= component.static.RENDER_ALL) then
        renderer.setBackground(private.colorBackground)
        renderer.setForeground(private.colorBorder)

        renderer.fill(posX, posY, width - 1, 1, '─')
        renderer.fill(posX, posY + height - 1, width - 1, 1, '─')
        renderer.fill(posX, posY, 1, height - 1, '│')
        renderer.fill(posX + width - 1, posY, 1, height - 1, '│')

        renderer.set(posX, posY, '┌')
        renderer.set(posX + width - 1, posY, '┐')
        renderer.set(posX, posY + height - 1, '└')
        renderer.set(posX + width - 1, posY + height - 1, '┘')
      end

      if (render <= component.static.RENDER_INSETS) then
        renderer.setBackground(private.colorBackground)

        renderer.fill(posX + 1, posY + 1, 1, rows, ' ')
        renderer.fill(posX + columns + 2, posY + 1, 1, rows, ' ')
      end

      if (render <= component.static.RENDER_CONTENT) then
        local textLength = private.columns
        local textTable = private.textTable

        renderer.setBackground(private.colorBackground)
        renderer.fill(posX + 2, posY + 1, columns, rows, ' ')

        for i = 1, #textTable do
          local lineColor = (private.selectedLine == i) and private.colorSelected or private.colorContent
          local lineRaw = textTable[i]
          local line = (lineRaw == nil) and '' or tostring(lineRaw)

          if (private.selectedLine == i) then
            private:refreshLine(i)
          else
            renderer.setForeground(lineColor)
            renderer.set(posX + 2, posY + i, unicode.sub(line, 1, textLength))
          end
        end
      end

      renderer.setBackground(previousBackground)
      renderer.setForeground(previousForeground)

      return true
    else
      error("[XAF Error] Component GPU renderer has not been initialized")
    end
  end

  return {
    private = private,
    public = public
  }
end

function TextField:extend()
  local class = self:initialize()
  local private = class.private
  local public = class.public

  if (self.C_INHERIT == true) then
    return {
      private = private,
      public = public
    }
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be inherited")
  end
end

function TextField:new(positionX, positionY, columns, rows)
  local class = self:initialize()
  local private = class.private
  local public = class.public

  public:setPosition(positionX, positionY)
  assert(type(columns) == "number", "[XAF Graphic] Expected NUMBER as argument #3")

  if (xafcoreMath:checkNatural(columns, true) == true) then
    private.columns = columns
    private.totalWidth = columns + 4
  else
    error("[XAF Error] Invalid columns number - must be a positive integer")
  end

  assert(type(rows) == "number", "[XAF Graphic] Expected NUMBER as argument #4")

  if (xafcoreMath:checkNatural(rows, true) == true) then
    private.rows = rows
    private.totalHeight = rows + 2

    public:setText({})
  else
    error("[XAF Error] Invalid rows number - must be a positive integer")
  end

  if (self.C_INSTANCE == true) then
    return public
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be instanced")
  end
end

return TextField
