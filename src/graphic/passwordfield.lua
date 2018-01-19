----------------------------------------
-- XAF Module - Graphic:PasswordField --
----------------------------------------
-- [>] That class describes a password field component - similar to text field but it hides its input.
-- [>] It has one difference, created components may have only one row.
-- [>] Entered text could be received not as table with text, but as single string value.
-- [!] Accepted events: 'click', 'key', 'clipboard'

local component = require("graphic/component")
local unicode = require("unicode")

local PasswordField = {
  C_NAME = "Generic GUI Password Field",
  C_INSTANCE = true,
  C_INHERIT = true,
  
  static = {}
}

function PasswordField:initialize()
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
  private.inputCharacter = '*'
  private.inputValue = ''
  private.showFlag = false
  
  public.getColorSelected = function(self) -- [!] Function: getColorSelected() - Returns password field input selection (highlight) color.
    return private.colorSelected           -- [!] Return: colorSelected - Current input highlight color as number.
  end
  
  public.getInput = function(self) -- [!] Function: getInput() - Returns password field hidden input string value.
    return private.inputValue      -- [!] Return: inputValue - Hidden string value of the password field.
  end
  
  public.getMaskingCharacter = function(self) -- [!] Function: getMaskingCharacter() - Returns current password masking character.
    return private.inputCharacter             -- [!] Return: inputCharacter - Current password masking character.
  end
  
  public.getShowPassword = function(self) -- [!] Function: getShowPassword() - Returns current password showing property.
    return private.showFlag               -- [!] Return: showFlag - Hidden value showing flag.
  end
  
  public.register = function(self, event)                                         -- [!] Function: register(event) - Registers the password field in main event loop.
    assert(type(event) == "table", "[XAF Graphic] Expected TABLE as argument #1") -- [!] Parameter: event - Event table from function 'event.pull()' in OC Event API.
                                                                                  -- [!] Return: ... - Results from registered event task functions if they exist.
    if (private.active == true) then
      if (event[1] == "clipboard") then
        local eventPaste = private.eventPaste
        local argumentsPaste = private.eventPasteArguments
        
        if (private.fieldFocus == true) then
          local inputLength = private.columns
          local render = private.renderMode
          local valueRaw = event[3]
          local value = string.gsub(valueRaw, "[\n]+", ' ')
          local rawInput = private.inputValue
          local oldInput = (rawInput == nil) and '' or tostring(rawInput)
          local newInput = oldInput .. value
          
          private.inputValue = unicode.sub(newInput, 1, inputLength)
          
          public:setRenderMode(3)
          public:view()
          public:setRenderMode(render)
          
          if (eventPaste) then
            return eventPaste(table.unpack(argumentsPaste))
          end
        end
      elseif (event[1] == "key_down") then
        local eventKey = private.eventKey
        local argumentsKey = private.eventKeyArguments
        
        if (private.fieldFocus == true) then
          local keyChar = event[3]
          local render = private.renderMode
          
          if (keyChar == 8) then
            local rawInput = private.inputValue
            local oldInput = (rawInput == nil) and '' or tostring(rawInput)
            local newInput = unicode.sub(oldInput, 1, unicode.wlen(oldInput) - 1)
            
            private.inputValue = newInput
          elseif (keyChar >= 32 and keyChar <= 126) then
            local inputLength = private.columns
            local rawInput = private.inputValue
            local oldInput = (rawInput == nil) and '' or tostring(rawInput)
            local newInput = oldInput .. string.char(keyChar)
            
            private.inputValue = unicode.sub(newInput, 1, inputLength)
          end
          
          public:setRenderMode(3)
          public:view()
          public:setRenderMode(render)
          
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
            private.fieldFocus = true
            
            public:setRenderMode(3)
            public:view()
            public:setRenderMode(render)
            
            if (eventClick) then
              return eventClick(table.unpack(argumentsClick))
            end
          else
            if (private.fieldFocus == true) then
              private.fieldFocus = false
              
              public:setRenderMode(3)
              public:view()
              public:setRenderMode(render)
            end
          end
        end
      end
    end
  end
  
  public.setColorSelected = function(self, color)                                   -- [!] Function: setColorSelected(color) - Changes password field selection (highlight) color.
    assert(type(color) == "number", "[XAF Graphic] Expected NUMBER as argument #1") -- [!] Parameter: color - New highlight color number.
                                                                                    -- [!] Return: 'true' - If new color has been set properly.
    if (color >= 0 and color <= 0xFFFFFF) then
      private.colorSelected = color
    else
      error("[XAF Error] Invalid password field selection color number")
    end
    
    return true
  end
  
  public.setInput = function(self, value)                                           -- [!] Function: setInput(value) - Changes password field current input value.
    assert(type(value) == "string", "[XAF Graphic] Expected STRING as argument #1") -- [!] Parameter: value - New input value as string.
                                                                                    -- [!] Return: 'true' - If new password value has been changed correctly.
    local valueInput = value
    local valueLength = private.columns
    
    if (valueInput == nil) then
      private.inputValue = ''
    else
      private.inputValue = unicode.sub(valueInput, 1, valueLength)
    end
    
    return true
  end
  
  public.setMaskingCharacter = function(self, character)                                -- [!] Function: setMaskingCharacter(character) - Changes password field masking character.
    assert(type(character) == "string", "[XAF Graphic] Expected STRING as argument #1") -- [!] Parameter: character - New password input masking character.
                                                                                        -- [!] Return: 'true' - If new password masking character has been changed successfully.
    if (character ~= '') then
      private.inputCharacter = unicode.sub(character, 1, 1)
    else
      error("[XAF Error] Password masking character cannot be empty")
    end
    
    return true
  end
  
  public.setOnClick = function(self, task, ...)                                        -- [!] Function: setOnClick(task, ...) - Sets new action task called on 'click' event.
    assert(type(task) == "function", "[XAF Graphic] Expected FUNCTION as argument #1") -- [!] Parameter: task - New task function.
                                                                                       -- [!] Parameter: ... - Action function parameter list.
    local eventTask = task                                                             -- [!] Return: 'true' - If new task function has been set properly.
    local eventArguments = {...}
    
    private.eventClick = eventTask
    private.eventClickArguments = eventArguments
    
    return true
  end
  
  public.setOnKey = function(self, task, ...)                                          -- [!] Function: setOnKey(task, ...) - Changes component function on 'key' (keyboard key press) event.
    assert(type(task) == "function", "[XAF Graphic] Expected FUNCTION as argument #1") -- [!] Parameter: task - New callback action function.
                                                                                       -- [!] Parameter: ... - Argument list passed to task function.
    local eventTask = task                                                             -- [!] Return: 'true' - If new callback function has been changed successfully.
    local eventArguments = {...}
    
    private.eventKey = eventTask
    private.eventKeyArguments = eventArguments
    
    return true
  end
  
  public.setOnPaste = function(self, task, ...)                                        -- [!] Function: setOnPaste(task, ...) - Sets password field task function on 'paste' (clipboard insert) event.
    assert(type(task) == "function", "[XAF Graphic] Expected FUNCTION as argument #1") -- [!] Parameter: task - Event function to set.
                                                                                       -- [!] Parameter: ... - Table with new event function parameters.
    local eventTask = task                                                             -- [!] Return: 'true' - If new event function has been set without errors.
    local eventArguments = {...}
    
    private.eventPaste = eventTask
    private.eventPasteArguments = eventArguments
    
    return true
  end
  
  public.setShowPassword = function(self, flag)                                      -- [!] Function: setShowPassword(flag) - Sets new password field showing property value.
    assert(type(flag) == "boolean", "[XAF Graphic] Expected BOOLEAN as argument #1") -- [!] Parameter: flag - New password showing flag.
                                                                                     -- [!] Return: 'true' - If new value has been changed properly.
    private.showFlag = flag
    
    return true
  end
  
  public.view = function(self)                                                                            -- [!] Function: view() - Renders password field on the screen.
    local renderer = private.renderer                                                                     -- [!] Return: 'true' - If the component has been rendered successfully.
    
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
      end
      
      if (render <= 2) then
        renderer.setBackground(private.colorBackground)
        
        renderer.set(posX + 1, posY + 1, ' ')
        renderer.set(posX + width - 2, posY + 1, ' ')
      end
      
      if (render <= 3) then
        local inputColor = (private.fieldFocus == true) and private.colorSelected or private.colorContent
        local inputRaw = private.inputValue
        local inputString = (inputRaw == nil) and '' or tostring(inputRaw)
        local inputShown = ''
        
        renderer.setBackground(private.colorBackground)
        renderer.fill(posX + 2, posY + 1, columns, height - 2, ' ')
        
        if (private.showFlag == false) then
          inputShown = string.gsub(inputString, ".", private.inputCharacter)
        else
          inputShown = inputString
        end
        
        if (unicode.wlen(inputShown) < columns and private.fieldFocus == true) then
          inputShown = inputShown .. '|'
        end
        
        renderer.setForeground(inputColor)
        renderer.set(posX + 2, posY + 1, inputShown)
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

function PasswordField:extend()
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

function PasswordField:new(positionX, positionY, columns)
  local class = self:initialize()
  local private = class.private
  local public = class.public
  
  public:setPosition(positionX, positionY)
  assert(type(columns) == "number", "[XAF Graphic] Expected NUMBER as argument #3")
  
  if (math.floor(columns) == columns and math.ceil(columns) == columns and columns > 0) then
    private.columns = columns
    private.totalWidth = columns + 4
    private.totalHeight = 3
  else
    error("[XAF Error] Invalid columns number - must be a positive integer")
  end
  
  if (self.C_INSTANCE == true) then
    return public
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be instanced")
  end
end

return PasswordField
