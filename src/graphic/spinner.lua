----------------------------------
-- XAF Module - Graphic:Spinner --
----------------------------------
-- [>] This class represents a generic graphical spinner - component that lets you to choose one value from scrollable box.
-- [>] It possesses two modes: counter (default) - spinner stores only numbers in given bounds, and iterator - only values from additional table.
-- [>] It may be scrolled by mouse wheel or two buttons (up and down).
-- [!] Accepted events: 'click', 'scroll'

local component = require("xaf/graphic/component")
local xafcore = require("xaf/core/xafcore")
local xafcoreMath = xafcore:getMathInstance()

local Spinner = {
  C_NAME = "Generic GUI Spinner",
  C_INSTANCE = true,
  C_INHERIT = true,

  static = {
    MODE_DEFAULT = 0, -- Constants used as spinner mode values in constructor.
    MODE_COUNTER = 1,
    MODE_ITERATOR = 2
  }
}

function Spinner:initialize()
  local parent = component:extend()
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}

  private.eventClick = nil
  private.eventClickArguments = {}
  private.eventScroll = nil
  private.eventScrollArguments = {}
  private.spinnerMode = 0
  private.contentIndex = 1
  private.contentLength = 0
  private.contentTable = {}

  public.getValue = function(self)            -- [!] Function: getValue() - Returns current spinner value.
    local index = private.contentIndex        -- [!] Return: currentValue - Current value of the spinner.
    local content = private.contentTable
    local currentValue = content[index]

    return currentValue
  end

  public.register = function(self, event)                                                       -- [!] Function: register(event) - Registers the spinner in main event loop.
    assert(type(event) == "table", "[XAF Graphic] Expected TABLE as argument #1")               -- [!] Parameter: event - Event table from 'event.pull()' in OC Event API.
                                                                                                -- [!] Return: ... - Results from event task function if it has been registered.
    if (private.active == true) then
      if (event[1] == "touch") then
        local screenAddress = event[2]

        if (screenAddress == private.renderer.getScreen()) then
          local clickX = event[3]
          local clickY = event[4]
          local render = private.renderMode

          if (clickY == private.positionY + 1) then
            local event = nil
            local arguments = {}

            if (clickX == private.positionX + private.columns + 4) then
              event = private.eventClick
              arguments = private.eventClickArguments

              if (private.spinnerMode == 2) then -- Reversed scrolling (click up) direction in 'MODE_ITERATOR' spinner mode.
                if (private.contentIndex < private.contentLength) then
                  private.contentIndex = private.contentIndex + 1
                end
              else
                if (private.contentIndex > 1) then
                  private.contentIndex = private.contentIndex - 1
                end
              end
            elseif (clickX == private.positionX + private.columns + 6) then
              event = private.eventClick
              arguments = private.eventClickArguments

              if (private.spinnerMode == 2) then -- Reversed scrolling (click down).
                if (private.contentIndex > 1) then
                  private.contentIndex = private.contentIndex - 1
                end
              else
                if (private.contentIndex < private.contentLength) then
                  private.contentIndex = private.contentIndex + 1
                end
              end
            end

            public:setRenderMode(3)
            public:view()
            public:setRenderMode(render)

            if (event) then
              return event(table.unpack(arguments))
            end
          end
        end
      elseif (event[1] == "scroll") then
        local screenAddress = event[2]

        if (screenAddress == private.renderer.getScreen()) then
          local scrollX = event[3]
          local scrollY = event[4]
          local scrollDirection = event[5]
          local render = private.renderMode
          local startPositionX = 0
          local startPositionY = 0
          local endPositionX = 0
          local endPositionY = 0

          if (render <= 1) then
            startPositionX = private.positionX
            startPositionY = private.positionY
            endPositionX = private.positionX + private.totalWidth - 1
            endPositionY = private.positionY + private.totalHeight - 1
          elseif (render <= 2) then
            startPositionX = private.positionX + 1
            startPositionY = private.positionY + 1
            endPositionX = private.positionX + private.totalWidth - 2
            endPositionY = private.positionY + private.totalHeight - 2
          elseif (render <= 3) then
            startPositionX = private.positionX + 2
            startPositionY = private.positionY + 1
            endPositionX = private.positionX + private.totalWidth - 2
            endPositionY = private.positionY + private.totalHeight - 2
          end

          if ((scrollX >= startPositionX and scrollX <= endPositionX)
          and (scrollY >= startPositionY and scrollY <= endPositionY)) then
            local event = private.eventScroll
            local arguments = private.eventScrollArguments

            if (private.spinnerMode == 2) then
              if (private.contentIndex > 1 and scrollDirection > 0) then -- Reversed scrolling (scroll up).
                private.contentIndex = private.contentIndex - 1
              elseif (private.contentIndex < private.contentLength and scrollDirection < 0) then -- Reversed scrolling (scroll down).
                private.contentIndex = private.contentIndex + 1
              end
            else
              if (private.contentIndex > 1 and scrollDirection < 0) then
                private.contentIndex = private.contentIndex - 1
              elseif (private.contentIndex < private.contentLength and scrollDirection > 0) then
                private.contentIndex = private.contentIndex + 1
              end
            end

            public:setRenderMode(3)
            public:view()
            public:setRenderMode(render)

            if (event) then
              return event(table.unpack(arguments))
            end
          end
        end
      end
    end
  end

  public.setCounter = function(self, minimum, maximum, increment)                       -- [!] Function: setCounter(minimum, maximum, increment) - Changes spinner value bounds and increment (only for counters).
    assert(type(minimum) == "number", "[XAF Graphic] Expected NUMBER as argument #1")   -- [!] Parameter: minimum - Minimum value bound.
    assert(type(maximum) == "number", "[XAF Graphic] Expected NUMBER as argument #2")   -- [!] Parameter: maximum - Maximum value bound.
    assert(type(increment) == "number", "[XAF Graphic] Expected NUMBER as argument #3") -- [!] Parameter: increment - Value incrementation number.
                                                                                        -- [!] Return: 'true' - If new values have been set successfully.
    local minimumValue = minimum
    local maximumValue = maximum
    local incrementValue = increment
    local tableIndex = 1

    if (private.spinnerMode == 0 or private.spinnerMode == 1) then
      if (increment <= 0) then
        error("[XAF Error] Increment number must be positive")
      end

      if (minimumValue < maximumValue) then
        private.contentTable = {}
        private.contentIndex = 1
        private.contentValue = nil
        private.contentLength = 0

        for i = minimumValue, maximumValue, incrementValue do
          private.contentTable[tableIndex] = i
          private.contentLength = private.contentLength + 1

          tableIndex = tableIndex + 1
        end
      else
        error("[XAF Error] Minimum value must be lower than maximum")
      end
    else
      error("[XAF Error] Invalid spinner type - required DEFAULT or COUNTER")
    end

    return true
  end

  public.setIterator = function(self, content)                                      -- [!] Function: setIterator(content) - Sets spinner new content table (only for iterators).
    assert(type(content) == "table", "[XAF Graphic] Expected TABLE as argument #1") -- [!] Parameter: content - New table with content.
                                                                                    -- [!] Return: 'true' - If new content table has been set correctly.
    if (private.spinnerMode == 2) then
      private.contentTable = {}
      private.contentIndex = 1
      private.contentValue = nil
      private.contentLength = 0

      for key, value in pairs(content) do
        private.contentTable[key] = value
        private.contentLength = private.contentLength + 1
      end
    else
      error("[XAF Error] Invalid spinner type - required ITERATOR")
    end

    return true
  end

  public.setOnClick = function(self, task, ...)                                        -- [!] Function: setOnClick(task, ...) - Changes spinner task executed on successful 'click' event.
    assert(type(task) == "function", "[XAF Graphic] Expected FUNCTION as argument #1") -- [!] Parameter: task - New task function.
                                                                                       -- [!] Parameter: ... - Event function arguments.
    local eventTask = task                                                             -- [!] Return: 'true' - If new event task has been set correctly.
    local eventArguments = {...}

    private.eventClick = eventTask
    private.eventClickArguments = eventArguments

    return true
  end

  public.setOnScroll = function(self, task, ...)                                       -- [!] Function: setOnScroll(task, ...) - Changes spinner event function performed on proper 'scroll' event.
    assert(type(task) == "function", "[XAF Graphic] Expected FUNCTION as argument #1") -- [!] Parameter: task - New task event function.
                                                                                       -- [!] Parameter: ... - Event task function arguments.
    local eventTask = task                                                             -- [!] Return: 'true' - If new event function has been changed properly.
    local eventArguments = {...}

    private.eventScroll = eventTask
    private.eventScrollArguments = eventArguments

    return true
  end

  public.setValue = function(self, newValue)                                          -- [!] Function: setValue(newValue) - Forces to change current spinner value (not index) independently on its type (counter or iterator).
    assert(type(newValue) ~= "nil", "[XAF Graphic] Expected ANYTHING as argument #1") -- [!] Parameter: newValue - New value to set - must belong to current set of spinner values.
                                                                                      -- [!] Return: 'true' or 'false' - If the new value has been set correctly - 'false' on bad new value, which does not belong to current set.
    for key, value in pairs(private.contentTable) do
      if (value == newValue) then
        private.contentIndex = key
        private.contentValue = value

        return true
      end
    end

    return false
  end

  public.view = function(self)                                                -- [!] Function: view() - Renders spinner on the screen.
    local renderer = private.renderer                                         -- [!] Return: 'true' - If the spinner has been rendered without errors.

    if (renderer) then
      local columns = private.columns
      local width = private.totalWidth
      local height = private.totalHeight
      local posX = private.positionX
      local posY = private.positionY
      local previousBackground = renderer.getBackground()
      local previousForeground = renderer.getForeground()
      local render = private.renderMode

      if (render <= 1) then
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

        renderer.set(posX + columns + 3, posY + 1, '│')
        renderer.set(posX + columns + 5, posY + 1, '│')
        renderer.set(posX + columns + 3, posY, '┬')
        renderer.set(posX + columns + 5, posY, '┬')
        renderer.set(posX + columns + 3, posY + 2, '┴')
        renderer.set(posX + columns + 5, posY + 2, '┴')
      end

      if (render <= 2) then
        renderer.setBackground(private.colorBackground)

        renderer.set(posX + 1, posY + 1, ' ')
        renderer.set(posX + columns + 2, posY + 1, ' ')
      end

      if (render <= 3) then
        local valueRaw = private.contentTable[private.contentIndex]
        local valueString = (valueRaw == nil) and '' or tostring(valueRaw)

        renderer.setBackground(private.colorBackground)
        renderer.setForeground(private.colorContent)

        renderer.fill(posX + 2, posY + 1, columns, 1, ' ')
        renderer.set(posX + columns + 4, posY + 1, '⇩')
        renderer.set(posX + columns + 6, posY + 1, '⇧')

        renderer.set(posX + 2, posY + 1, string.sub(valueString, 1, columns))
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

function Spinner:extend()
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

function Spinner:new(positionX, positionY, columns, mode)
  local class = self:initialize()
  local private = class.private
  local public = class.public

  public:setPosition(positionX, positionY)
  assert(type(columns) == "number", "[XAF Graphic] Expected NUMBER as argument #3")

  if (xafcoreMath:checkNatural(columns, true) == true) then
    private.columns = columns
  else
    error("[XAF Error] Invalid columns number - must be a positive integer")
  end

  assert(type(mode) == "number", "[XAF Graphic] Expected NUMBER as argument #4")

  if (mode >= 0 and mode <= 2) then
    if (xafcoreMath:checkInteger(mode) == true) then
      private.spinnerMode = mode
    else
      error("[XAF Error] Invalid spinner mode - must be a integer")
    end
  else
    error("[XAF Error] Invalid spinner mode")
  end

  private.totalWidth = columns + 8
  private.totalHeight = 3

  if (self.C_INSTANCE == true) then
    return public
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be instanced")
  end
end

return Spinner
