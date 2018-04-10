---------------------------------
-- XAF Module - Graphic:Button --
---------------------------------
-- [>] This class represents basic graphic component - clickable button.
-- [>] It could be used as plain label if deactivated or event has not been set.
-- [!] Accepted events: 'click', 'double-click'

local component = require("xaf/graphic/component")
local computer = require("computer")
local unicode = require("unicode")

local Button = {
  C_NAME = "Generic GUI Button",
  C_INSTANCE = true,
  C_INHERIT = true,
  
  static = {
    THRESHOLD_DEFAULT = 0.25, -- Predefined values of double click time threshold. To use in setDoubleClickThreshold(newTime) function as 'newTime' parameter.
    THRESHOLD_SLOW = 0.5,
    THRESHOLD_NORMAL = 0.25,
    THRESHOLD_FAST = 0.1
  }
}

function Button:initialize()
  local parent = component:extend() -- This class describes top-level component, it inherits directly from Component class.
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}
  
  private.doubleClickThreshold = 0.25
  private.eventClick = nil
  private.eventClickArguments = {}
  private.eventDoubleClick = nil
  private.eventDoubleClickArguments = {}
  private.labelTable = {}
  private.lastClickTime = -math.huge
  
  public.getDoubleClickThreshold = function(self) -- [!] Function: getDoubleClickThreshold() - Returns current button double click time threshold.
    return private.doubleClickThreshold           -- [!] Return: doubleClickThreshold - Current threshold value.
  end
  
  public.getLabel = function(self)          -- [!] Function: getLabel() - Returns button's label lines as strings.
    return table.unpack(private.labelTable) -- [!] Return: ... - Next label lines strings.
  end
  
  public.register = function(self, event)                                         -- [!] Function: register(event) - Registers that component into main event table.
    assert(type(event) == "table", "[XAF Graphic] Expected TABLE as argument #1") -- [!] Parameter: event - Event table from function event.pull() in OC Event API.
                                                                                  -- [!] Return: ... - Results from event task function if it returns anything.
    if (private.active == true) then
      if (event[1] == "touch") then
        local screenAddress = event[2]
        
        if (screenAddress == private.renderer.getScreen()) then
          local clickX = event[3]
          local clickY = event[4]
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
            endPositionX = private.positionX + private.totalWidth - 3
            endPositionY = private.positionY + private.totalHeight - 2
          end
          
          if ((clickX >= startPositionX and clickX <= endPositionX)
          and (clickY >= startPositionY and clickY <= endPositionY)) then
            local clickTime = computer.uptime()
            local lastClickTime = private.lastClickTime
            
            private.lastClickTime = clickTime
            
            if ((clickTime - lastClickTime) > private.doubleClickThreshold) then
              local event = private.eventClick
              local arguments = private.eventClickArguments
              
              if (event) then
                return event(table.unpack(arguments))
              end
            else
              local event = private.eventDoubleClick
              local arguments = private.eventDoubleClickArguments
              
              if (event) then
                return event(table.unpack(arguments))
              end
            end
          end
        end
      end
    end
  end
  
  public.setDoubleClickThreshold = function(self, newTime)                            -- [!] Function: setDoubleClickThreshold(newTime) - Changes button double click event time threshold.
    assert(type(newTime) == "number", "[XAF Graphic] Expected NUMBER as argument #1") -- [!] Parameter: newTime - new time threshold in seconds.
                                                                                      -- [!] Return: 'true' - If the new value has been set properly.
    private.doubleClickThreshold = newTime
    
    return true
  end
  
  public.setLabel = function(self, ...)                                                 -- [!] Function: setLabel(...) - Changes current button label.
    local labelLines = {...}                                                            -- [!] Parameter: ... - Next button's label lines (strings, numbers and booleans are accepted).
    local labelCount = 0                                                                -- [!] Return: 'true' - If the label has been set without errors.
    local totalLength = 0
    
    for key, value in ipairs(labelLines) do -- [!] Warning! This method uses 'ipairs()' function. Therefore, 'nil' value will break next label lines parameters.
      local labelLine = labelLines[key]
      local labelLength = (labelLine == nil) and 0 or unicode.wlen(tostring(labelLine))
      
      private.labelTable[key] = (labelLine == nil) and '' or tostring(labelLine)
      totalLength = (labelLength > totalLength) and labelLength or totalLength
      labelCount = labelCount + 1
    end
    
    private.totalWidth = totalLength + 4
    private.totalHeight = labelCount + 2
    
    return true
  end
  
  public.setOnClick = function(self, task, ...)                                        -- [!] Function: setOnClick(task, ...) - Sets the button task which triggers on 'click' event.
    assert(type(task) == "function", "[XAF Graphic] Expected FUNCTION as argument #1") -- [!] Parameter: task - Function which will be called on event.
                                                                                       -- [!] Parameter: ... - Event function arguments.
    local eventTask = task                                                             -- [!] Return: 'true' - If the task has been set properly.
    local eventArguments = {...}
    
    private.eventClick = eventTask
    private.eventClickArguments = eventArguments
    
    return true
  end
  
  public.setOnDoubleClick = function(self, task, ...)                                  -- [!] Function: setOnDoubleClick(task, ...) - Sets the button task which triggers on 'double-click' event.
    assert(type(task) == "function", "[XAF Graphic] Expected FUNCTION as argument #1") -- [!] Parameter: task - Function which will be called on event.
                                                                                       -- [!] Parameter: ... - Event function argument list.
    local eventTask = task                                                             -- [!] Return: 'true' - If the task has been changed successfully.
    local eventArguments = {...}
    
    private.eventDoubleClick = eventTask
    private.eventDoubleClickArguments = eventArguments
    
    return true
  end
  
  public.view = function(self)                                              -- [!] Function: view() - Renders button on the screen within set rendering mode.
    local renderer = private.renderer                                       -- [!] Return: 'true' - If button has been rendered properly.
    
    if (renderer) then
      local label = private.labelTable
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
      end
      
      if (render <= 2) then
        renderer.setBackground(private.colorBackground)
        
        renderer.fill(posX + 1, posY + 1, 1, height - 2, ' ')
        renderer.fill(posX + width - 2, posY + 1, 1, height - 2, ' ')
      end
      
      if (render <= 3) then
        renderer.setBackground(private.colorBackground)
        renderer.setForeground(private.colorContent)
        
        renderer.fill(posX + 2, posY + 1, width - 4, height - 2, ' ')
        
        for key, value in ipairs(label) do
          renderer.set(posX + 2, posY + key, value)
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

function Button:extend()
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

function Button:new(positionX, positionY)
  local class = self:initialize()
  local private = class.private
  local public = class.public
  
  public:setPosition(positionX, positionY)
  private.totalWidth = 4
  private.totalHeight = 2
  
  if (self.C_INSTANCE == true) then
    return public
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be instanced")
  end
end

return Button
