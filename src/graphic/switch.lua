---------------------------------
-- XAF Module - Graphic:Switch --
---------------------------------
-- [>] This class represents the component similar to button - toggleable switch.
-- [>] Each switch changes its colors on state toggle and executes corresponding function.
-- [>] It accepts either inactive (default) and active state.
-- [!] Accepted events: 'active', 'inactive'

local component = require("graphic/component") -- Class Component is a parent for this class.
local unicode = require("unicode")

local Switch = {
  C_NAME = "Generic GUI 2-state Switch",
  C_INSTANCE = true,
  C_INHERIT = true,
  
  static = {}
}

function Switch:initialize()
  local parent = component:extend()
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}
  
  private.activeState = false              -- By default, the switch is inactive.
  private.colorBackgroundActive = 0x000000 -- Default switch colors (in activated state).
  private.colorBorderActive = 0xFFFFFF
  private.colorContentActive = 0xFFFFFF
  private.eventActive = nil
  private.eventActiveArguments = {}
  private.eventInactive = nil
  private.eventInactiveArguments = {}
  private.labelTable = {}
  
  public.getActivated = function(self) -- [!] Function: getActivated() - Returns switch's activated state ('true' or 'false').
    return private.activeState         -- [!] Return: activeState - Current active state as boolean value.
  end
  
  public.getColorsActive = function(self)                                                       -- [!] Function: getColorsActive() - Returns switch's colors (in activated state).
    return private.colorBorderActive, private.colorBackgroundActive, private.colorContentActive -- [!] Return: colorBorderActive, colorBackgroundActive, colorContentActive - Next primary switch's colors (activated state).
  end
  
  public.getLabel = function(self)          -- [!] Function: getLabel() - Returns switch's label as strings.
    return table.unpack(private.labelTable) -- [!] Return: ... - Next label lines strings.
  end
  
  public.register = function(self, event)                                         -- [!] Function: register(event) - Registers switch in main event loop.
    assert(type(event) == "table", "[XAF Graphic] Expected TABLE as argument #1") -- [!] Parameter: event - Event table from event.pull() in OC Event API.
                                                                                  -- [!] Return: ... - Results from registered function if they are.
    if (private.active == true) then
      if (event[1] == "touch") then
        local address = event[2]
        
        if (address == private.renderer.getScreen()) then
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
            if (private.activeState == true) then
              local event = private.eventInactive
              local arguments = private.eventInactiveArguments
              
              private.activeState = false
              public:view()
              
              if (event) then
                return event(table.unpack(arguments))
              end
            else
              local event = private.eventActive
              local arguments = private.eventInactiveArguments
              
              private.activeState = true
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
  
  public.setActivated = function(self, state)                                         -- [!] Function: setActivated(state) - Changes switch activity state.
    assert(type(state) == "boolean", "[XAF Graphic] Expected BOOLEAN as argument #1") -- [!] Parameter: state - New activated state as boolean.
                                                                                      -- [!] Return: 'true' - If the new state has been set correctly.
    private.activeState = state
    
    return true
  end
  
  public.setColorsActive = function(self, border, background, content)                   -- [!] Function: setColorsActive(background, border, content) -- Sets new switch's primary colors (in activated state).
    assert(type(border) == "number", "[XAF Graphic] Expected NUMBER as argument #1")     -- [!] Parameter: border - New border color (in 0 - 0xFFFFFF range).
    assert(type(background) == "number", "[XAF Graphic] Expected NUMBER as argument #2") -- [!] Parameter: background - New background color (in 0 - 0xFFFFFF range).
    assert(type(content) == "number", "[XAF Graphic] Expected NUMBER as argument #3")    -- [!] Parameter: content - New content color (in 0 - 0xFFFFFF range).
                                                                                         -- [!] Return: 'true' - If the new colors (of activated state switch) have been changed properly.
    if (border <= 0xFFFFFF and border >= 0) then
      private.colorBorderActive = border
    else
      error("[XAF Error] Invalid component border color")
    end
    
    if (background <= 0xFFFFFF and background >= 0) then
      private.colorBackgroundActive = background
    else
      error("[XAF Error] Invalid component background color")
    end
    
    if (content <= 0xFFFFFF and content >= 0) then
      private.colorContentActive = content
    else
      error("[XAF Error] Invalid component content color")
    end
    
    return true
  end
  
  public.setLabel = function(self, ...)                                      -- [!] Function: setLabel(...) - Changes switch's label lines.
    local labelLines = {...}                                                 -- [!] Parameter: ... - Next label lines.
    local labelCount = 0                                                     -- [!] Return: 'true' - If the label has been set properly.
    local labelLength = 0
    
    for key, value in ipairs(labelLines) do
      local line = value
      local lineLength = (line == nil) and 0 or unicode.wlen(tostring(line))
      
      private.labelTable[key] = tostring(line)
      labelLength = (lineLength > labelLength) and lineLength or labelLength
      labelCount = labelCount + 1
    end
    
    private.totalWidth = labelLength + 4
    private.totalHeight = labelCount + 2
    
    return true
  end
  
  public.setOnActive = function(self, task, ...)                                       -- [!] Function: setOnActive(task, ...) - Changes the function called on 'active' event and its arguments.
    assert(type(task) == "function", "[XAF Graphic] Expected FUNCTION as argument #1") -- [!] Parameter: task - Task function.
                                                                                       -- [!] Parameter: ... - Task function arguments.
    local taskFunction = task                                                          -- [!] Return: 'true' - If new task has been set correctly.
    local taskArguments = {...}
    
    private.eventActive = taskFunction
    private.eventActiveArguments = taskArguments
    
    return true
  end
  
  public.setOnInactive = function(self, task, ...)                                     -- [!] Function: setOnInactive(task, ...) - Changes the function called on 'inactive' event and its arguments.
    assert(type(task) == "function", "[XAF Graphic] Expected FUNCTION as argument #1") -- [!] Parameter: task - New task function.
                                                                                       -- [!] Parameter: ... - New task function arguments.
    local taskFunction = task                                                          -- [!] Return: 'true' - If the new task function has been set successfully.
    local taskArguments = {...}
    
    private.eventInactive = task
    private.eventInactiveArguments = taskArguments
    
    return true
  end
  
  public.view = function(self)                                                                                    -- [!] Function: view() - Renders switch on the screen.
    local renderer = private.renderer                                                                             -- [!] Return: 'true' - If the component has been renderer successfully.
    
    if (renderer) then
      local activeState = private.activeState
      local colorBackground = (activeState == true) and private.colorBackgroundActive or private.colorBackground
      local colorBorder = (activeState == true) and private.colorBorderActive or private.colorBorder
      local colorContent = (activeState == true) and private.colorContentActive or private.colorContent
      local label = private.labelTable
      local posX = private.positionX
      local posY = private.positionY
      local width = private.totalWidth
      local previousBackground = renderer.getBackground()
      local previousForeground = renderer.getForeground()
      local height = private.totalHeight
      local render = private.renderMode
      
      if (render <= 1) then
        renderer.setBackground(colorBackground)
        renderer.setForeground(colorBorder)
        
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
        renderer.setBackground(colorBackground)
        
        renderer.fill(posX + 1, posY + 1, 1, height - 2, ' ')
        renderer.fill(posX + width - 2, posY + 1, 1, height - 2, ' ')
      end
      
      if (render <= 3) then
        renderer.setBackground(colorBackground)
        renderer.setForeground(colorContent)
        
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

function Switch:extend()
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

function Switch:new(positionX, positionY)
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

return Switch
