---------------------------------
-- XAF Module - Graphic:Slider --
---------------------------------
-- [>] This class describes a slider - GUI component that allows choosing numerical value from adjustable slider.
-- [>] Each slider can change its value bounds and incremental skip of value and slider graphical switch.
-- [!] Accepted events: 'drag'

local component = require("xaf/graphic/component") -- As this class describes top-level graphic component it must inherit from Component class.
local xafcore = require("xaf/core/xafcore")
local xafcoreMath = xafcore:getMathInstance()

local Slider = {
  C_NAME = "Generic GUI Slider",
  C_INSTANCE = true,
  C_INHERIT = true,
  
  static = {
    ROTATE_DEFAULT = 0, -- Constants used for slider rotation: horizontal (default) or vertical.
    ROTATE_HORIZONTAL = 1,
    ROTATE_VERTICAL = 2
  }
}

function Slider:initialize()
  local parent = component:extend()
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}
  
  private.eventDrag = nil
  private.eventDragArguments = {}
  private.length = 0
  private.positionTable = {} -- Table which stores slider bar positions and its numerical values.
  private.rotation = 0
  private.value = 0
  
  public.getValue = function(self) -- [!] Function: getValue() - Returns current slider's value.
    return private.value           -- [!] Return: value - Current value of the slider as number.
  end
  
  public.register = function(self, event)                                                        -- [!] Function: register(event) - Registers slider in main event loop.
    assert(type(event) == "table", "[XAF Graphic] Expected TABLE as argument #1")                -- [!] Parameter: event - Event table from OC Event API in 'event.pull()' function.
                                                                                                 -- [!] Return: ... - Results from event task function if it has been set.
    if (private.active == true) then
      if (event[1] == "drag") then
        local screenAddress = event[2]
        
        if (screenAddress == private.renderer.getScreen()) then
          local dragX = event[3]
          local dragY = event[4]
          local render = private.renderMode
          local startPositionX = 0
          local startPositionY = 0
          local endPositionX = 0
          local endPositionY = 0
          
          if (render <= component.static.RENDER_ALL) then
            startPositionX = private.positionX
            startPositionY = private.positionY
            endPositionX = private.positionX + private.totalWidth - 1
            endPositionY = private.positionY + private.totalHeight - 1
          elseif (render <= component.static.RENDER_INSETS) then
            startPositionX = private.positionX + 1
            startPositionY = private.positionY + 1
            endPositionX = private.positionX + private.totalWidth - 2
            endPositionY = private.positionY + private.totalHeight - 2
          elseif (render <= component.static.RENDER_CONTENT) then
            startPositionX = private.positionX + 2
            startPositionY = private.positionY + 1
            endPositionX = private.positionX + private.totalWidth - 3
            endPositionY = private.positionY + private.totalHeight - 2
          end
          
          if ((dragX >= startPositionX and dragX <= endPositionX)
          and (dragY >= startPositionY and dragY <= endPositionY)) then
            local positionKey = tostring(dragX .. ':' .. dragY)
            local positionTable = private.positionTable
            
            if (positionTable[positionKey]) then
              local event = private.eventDrag
              local arguments = private.eventDragArguments
              local renderer = private.renderer
              
              if (renderer) then
                local posX = private.positionX
                local posY = private.positionY
                local previousBackground = renderer.getBackground()
                local previousForeground = renderer.getForeground()
                local lineChar = (private.rotation == Slider.static.ROTATE_DEFAULT or private.rotation == Slider.static.ROTATE_HORIZONTAL) and '─' or '│'
                
                public:setRenderMode(component.static.RENDER_CONTENT)
                public:view()
                public:setRenderMode(render)
                
                renderer.setBackground(private.colorBackground)
                renderer.setForeground(private.colorContent)
                
                if (private.rotation == Slider.static.ROTATE_DEFAULT or private.rotation == Slider.static.ROTATE_HORIZONTAL) then
                  private.value = positionTable[positionKey]
                  
                  renderer.set(posX + 3, posY + 1, lineChar)
                  renderer.set(dragX, dragY, '█')
                else
                  private.value = positionTable[positionKey]
                  
                  renderer.set(posX + 2, posY + 2, lineChar)
                  renderer.set(dragX, dragY, '█')
                end
                
                renderer.setBackground(previousBackground)
                renderer.setForeground(previousForeground)
              end
              
              if (event) then
                return event(table.unpack(arguments))
              end
            end
          end
        end
      end
    end
  end
  
  public.setOnDrag = function(self, task, ...)                                         -- [!] Function: setOnDrag(task, ...) - Changes slider response action on 'drag' event.
    assert(type(task) == "function", "[XAF Graphic] Expected FUNCTION as argument #1") -- [!] Parameter: task - New action task function.
                                                                                       -- [!] Parameter: ... - New action task argument list.
    local eventTask = task                                                             -- [!] Return: 'true' - If new event function has been set properly.
    local eventArguments = {...}
    
    private.eventDrag = eventTask
    private.eventDragArguments = eventArguments
    
    return true
  end
  
  public.setValues = function(self, start, increment, skip)                                   -- [!] Function: setValues(start, increment, skip) - Changes slider value bounds and bar incrementation number.
    assert(type(start) == "number", "[XAF Graphic] Expected NUMBER as argument #1")           -- [!] Parameter: start - Initial slider value.
    assert(type(increment) == "number", "[XAF Graphic] Expected NUMBER as argument #2")       -- [!] Parameter: increment - Slider value incremental number.
    assert(type(skip) == "number", "[XAF Graphic] Expected NUMBER as argument #3")            -- [!] Parameter: skip - Slider bar shift (skip) value.
                                                                                              -- [!] Return: 'true' - If every value has been set correctly.
    local valueInitial = start
    local valueIncrement = increment
    local valueIndex = 0
    local sliderShift = skip
    local sliderMaxShift = private.length
    local posX = private.positionX
    local posY = private.positionY
    
    if (xafcoreMath:checkNatural(skip, true) == true) then
      sliderShift = skip
    else
      error("[XAF Error] Invalid slider bar incremental number - must be a positive integer")
    end
    
    if (private.rotation == Slider.static.ROTATE_DEFAULT or private.rotation == Slider.static.ROTATE_HORIZONTAL) then
      for i = posX + 3, posX + sliderMaxShift + 2, sliderShift do
        local key = tostring(i .. ':' .. posY + 1)
        local value = valueInitial + (valueIncrement * valueIndex)
        
        private.positionTable[key] = value
        valueIndex = valueIndex + 1
      end
    else
      for i = posY + 2, posY + sliderMaxShift + 1, sliderShift do
        local key = tostring(posX + 2 .. ':' .. i)
        local value = valueInitial + (valueIncrement * valueIndex)
        
        private.positionTable[key] = value
        valueIndex = valueIndex + 1
      end
    end
    
    return true
  end
  
  public.view = function(self)                                        -- [!] Function: view() - Renders slider on the screen.
    local renderer = private.renderer                                 -- [!] Return: 'true' - If component has been rendered properly.
    
    if (renderer) then
      local width = private.totalWidth
      local height = private.totalHeight
      local length = private.length
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
        
        renderer.fill(posX + 1, posY + 1, 1, height - 2, ' ')
        renderer.fill(posX + width - 2, posY + 1, 1, height - 2, ' ')
      end
      
      if (render <= component.static.RENDER_CONTENT) then
        renderer.setBackground(private.colorBackground)
        renderer.setForeground(private.colorContent)
        
        if (private.rotation == Slider.static.ROTATE_DEFAULT or private.rotation == Slider.static.ROTATE_HORIZONTAL) then
          renderer.fill(posX + 3, posY + 1, length, 1, '─')
          
          renderer.set(posX + 2, posY + 1, '├')
          renderer.set(posX + length + 3, posY + 1, '┤')
          renderer.set(posX + 3, posY + 1, '█')
        else
          renderer.fill(posX + 2, posY + 2, 1, length, '│')
          
          renderer.set(posX + 2, posY + 1, '┬')
          renderer.set(posX + 2, posY + length + 2, '┴')
          renderer.set(posX + 2, posY + 2, '█')
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

function Slider:extend()
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

function Slider:new(positionX, positionY, sliderLength, sliderRotation)
  local class = self:initialize()
  local private = class.private
  local public = class.public
  
  public:setPosition(positionX, positionY)
  assert(type(sliderLength) == "number", "[XAF Graphic] Expected NUMBER as argument #3")
  
  if (xafcoreMath:checkNatural(sliderLength, true) == true) then
    private.length = sliderLength
  else
    error("[XAF Error] Invalid slider length number - must be a positive integer")
  end
  
  assert(type(sliderRotation) == "number", "[XAF Graphic] Expected NUMBER as argument #4")
  
  if ((xafcoreMath:checkInteger(sliderRotation) == true) and (sliderRotation >= Slider.static.ROTATE_DEFAULT and sliderRotation <= Slider.static.ROTATE_VERTICAL)) then
    private.rotation = sliderRotation
  else
    error("[XAF Error] Invalid slider rotation mode")
  end
  
  private.totalWidth = (sliderRotation == Slider.static.ROTATE_DEFAULT or sliderRotation == Slider.static.ROTATE_HORIZONTAL) and sliderLength + 6 or 5
  private.totalHeight = (sliderRotation == Slider.static.ROTATE_DEFAULT or sliderRotation == Slider.static.ROTATE_HORIZONTAL) and 3 or sliderLength + 4
  
  if (self.C_INSTANCE == true) then
    return public
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be instanced")
  end
end

return Slider
