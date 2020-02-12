-----------------------------------
-- XAF Module - Graphic:Checkbox --
-----------------------------------
-- [>] This class represents a checkbox, graphical component which behaves similar to switch.
-- [>] It also has two states (selected/deselected), however, it looks differently.
-- [!] Accepted events: 'select', 'deselect'

local component = require("xaf/graphic/component")
local unicode = require("unicode")

local Checkbox = {
  C_NAME = "Generic GUI Checkbox",
  C_INSTANCE = true,
  C_INHERIT = true,
  
  static = {}
}

function Checkbox:initialize()
  local parent = component:extend()
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}
  
  private.eventSelect = nil
  private.eventSelectArguments = {}
  private.eventDeselect = nil
  private.eventDeselectArguments = {}
  private.label = ""
  private.labelLength = 0
  private.selected = false
  private.showLabel = false
  
  public.getLabel = function(self) -- [!] Function: getLabel() - Returns current checkbox's label line.
    return private.label           -- [!] Return: label - Label line used by the checkbox.
  end
  
  public.getSelected = function(self) -- [!] Function: getSelected() - Returns checkbox selection state.
    return private.selected           -- [!] Return: selected - Selection flag.
  end
  
  public.register = function(self, event)                                         -- [!] Function: register(event) - Register the checkbox into the main event loop.
    assert(type(event) == "table", "[XAF Graphic] Expected TABLE as argument #1") -- [!] Parameter: event - Event table from event.pull() function in OC Event API.
                                                                                  -- [!] Return: ... - Result from component event functions if present.
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
          
          if ((clickX >= startPositionX and clickX <= endPositionX)
          and (clickY >= startPositionY and clickY <= endPositionY)) then
            if (private.selected == true) then
              local event = private.eventDeselect
              local arguments = private.eventDeselectArguments
              
              private.selected = false
              public:view()
              
              if (event) then
                return event(table.unpack(arguments))
              end
            else
              local event = private.eventSelect
              local arguments = private.eventSelectArguments
              
              private.selected = true
              public:view()
              
              if (event) then
                return event(table.unpack(arguments))
              end
            end
          end
        end
      end
    end
  end
  
  public.setLabel = function(self, labelLine)                                          -- [!] Function: setLabel(labelLine) - Changes current checkbox label line.
    assert(type(labelLine) ~= "nil", "[XAF Graphic] Expected ANYTHING as argument #1") -- [!] Parameter: labelLine - Component label line (accepts strings, numbers or booleans).
                                                                                       -- [!] Return: 'true' - If the new label has been set successfully.
    local label = tostring(labelLine)
    local labelLength = unicode.wlen(label)
    
    private.label = label
    private.labelLength = labelLength
    
    if (private.showLabel == true) then
      private.totalWidth = 8 + labelLength
    end
    
    return true
  end
  
  public.setOnDeselect = function(self, task, ...)                                     -- [!] Function: setOnDeselect(task, ...) - Sets new task function on 'deselect' event.
    assert(type(task) == "function", "[XAF Graphic] Expected FUNCTION as argument #1") -- [!] Parameter: task - New task function.
                                                                                       -- [!] Parameter: ... - Task function arguments.
    local eventTask = task                                                             -- [!] Return: 'true' - If the new task has been set correctly.
    local eventArguments = {...}
    
    private.eventDeselect = eventTask
    private.eventDeselectArguments = eventArguments
    
    return true
  end
  
  public.setOnSelect = function(self, task, ...)                                       -- [!] Function: setOnSelect(task, ...) - Sets new task function on checkbox 'select' event.
    assert(type(task) == "function", "[XAF Graphic] Expected FUNCTION as argument #1") -- [!] Parameter: task - New event task function.
                                                                                       -- [!] Parameter: ... - Event task function argument list.
    local eventTask = task                                                             -- [!] Return: 'true' - If new function has been set successfully.
    local eventArguments = {...}
    
    private.eventSelect = task
    private.eventSelectArguments = eventArguments
    
    return true
  end
  
  public.setSelected = function(self, state)                                          -- [!] Function: setSelected(state) - Changes checkbox selection state.
    assert(type(state) == "boolean", "[XAF Graphic] Expected BOOLEAN as argument #1") -- [!] Parameter: state - New selection flag as boolean.
                                                                                      -- [!] Return: 'true' - If the new selection state has been set properly.
    private.selected = state
    
    return true
  end
  
  public.view = function(self)                                              -- [!] Function: view() - Renders checkbox on the screen.
    local renderer = private.renderer                                       -- [!] Return: 'true' - If that component has been rendered correctly.
    
    if (renderer) then
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
        
        if (private.showLabel == true) then
          renderer.set(posX + 4, posY, '┬')
          renderer.set(posX + 4, posY + 1, '│')
          renderer.set(posX + 4, posY + 2, '┴')
        end
      end
      
      if (render <= component.static.RENDER_INSETS) then
        renderer.setBackground(private.colorBackground)
        
        renderer.set(posX + 1, posY + 1, ' ')
        renderer.set(posX + 3, posY + 1, ' ')
        renderer.set(posX + width - 2, posY + 1, ' ')
        
        if (private.showLabel == true) then
          renderer.set(posX + 5, posY + 1, ' ')
        end
      end
      
      if (render <= component.static.RENDER_CONTENT) then
        local checkTick = (private.selected == true) and 'X' or ' '
        local labelLine = private.label
        
        renderer.setBackground(private.colorBackground)
        renderer.setForeground(private.colorContent)
        
        renderer.set(posX + 2, posY + 1, checkTick)
        
        if (private.showLabel == true) then
          renderer.set(posX + 6, posY + 1, labelLine)
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

function Checkbox:extend()
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

function Checkbox:new(positionX, positionY, showLabel)
  local class = self:initialize()
  local private = class.private
  local public = class.public
  
  public:setPosition(positionX, positionY)
  private.totalWidth = (showLabel == true) and 8 or 5
  private.totalHeight = 3
  
  assert(type(showLabel) == "boolean", "[XAF Graphic] Expected BOOLEAN as argument #3")
  private.showLabel = showLabel
  
  if (self.C_INSTANCE == true) then
    return public
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be instanced")
  end
end

return Checkbox
