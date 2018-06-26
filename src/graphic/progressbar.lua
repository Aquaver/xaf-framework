--------------------------------------
-- XAF Module - Graphic:ProgressBar --
--------------------------------------
-- [>] This class represents simple progress bar - component which shows graphically progress of some process.
-- [>] It has generally three variables: minimum and maximum value bound and obviously current value.
-- [!] Accepted events: no events

local component = require("xaf/graphic/component")
local xafcore = require("xaf/core/xafcore")
local xafcoreMath = xafcore:getMathInstance()

local ProgressBar = {
  C_NAME = "Generic GUI Progress Bar",
  C_INSTANCE = true,
  C_INHERIT = true,
  
  static = {
    LAYOUT_DEFAULT = 0, -- Constants used in constructor or 'setLayoutMode(mode)' function as 'mode' parameter.
    LAYOUT_HORIZONTAL = 1,
    LAYOUT_VERTICAL = 2
  }
}

function ProgressBar:initialize()
  local parent = component:extend()
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}
  
  private.currentValue = 0
  private.minimumValue = 0
  private.maximumValue = 1
  private.barLayout = 0
  private.horizontalParts = {'▏', '▎', '▍', '▌', '▋', '▊', '▉', '█'}
  private.horizontalParts[0] = ' '
  private.verticalParts = {'▁', '▂', '▃', '▄', '▅', '▆', '▇', '█'}
  private.verticalParts[0] = ' '
  
  public.getLayoutMode = function(self) -- [!] Function: getLayoutMode() - Returns progress bar component layout mode.
    return private.barLayout            -- [!] Return: barLayout - Current progress bar layout mode number.
  end
  
  public.getValue = function(self) -- [!] Function: getValue() - Returns current progress bar value.
    return private.currentValue    -- [!] Return: currentValue - Current progress bar numerical value.
  end
  
  public.set = function(self, value)                                                -- [!] Function: set(value) - Changes current progress value.
    assert(type(value) == "number", "[XAF Graphic] Expected NUMBER as argument #1") -- [!] Parameter: value - New progress value.
                                                                                    -- [!] Return: 'true' - If the new progress bar value has been set successfully.
    if (value < private.minimumValue) then
      private.currentValue = private.minimumValue
    elseif (value > private.maximumValue) then
      private.currentValue = private.maximumValue
    else
      private.currentValue = value
    end
    
    return true
  end
  
  public.setLayoutMode = function(self, mode)                                      -- [!] Function: setLayoutMode(mode) - Changes progress bar component layout mode.
    assert(type(mode) == "number", "[XAF Graphic] Expected NUMBER as argument #1") -- [!] Parameter: mode - New progress bar layout mode (0 - default, 1 - horizontal, 2 - vertical).
                                                                                   -- [!] Return: 'true' - If the new progress bar layout mode has been set correctly.
    if (mode >= 0 and mode <= 2) then
      if (xafcoreMath:checkInteger(mode) == true) then
        private.barLayout = mode
      else
        error("[XAF Error] Invalid progress bar layout mode - must be an integer")
      end
    else
      error("[XAF Error] Invalid progress bar layout mode")
    end
    
    return true
  end
  
  public.setValues = function(self, minimum, maximum, initial)                        -- [!] Function: setValues(minimum, maximum, initial) - Sets new progress bar value bounds with initial value.
    assert(type(minimum) == "number", "[XAF Graphic] Expected NUMBER as argument #1") -- [!] Parameter: minimum - New minimum value bound.
    assert(type(maximum) == "number", "[XAF Graphic] Expected NUMBER as argument #2") -- [!] Parameter: maximum - New maximum value bound.
    assert(type(initial) == "number", "[XAF Graphic] Expected NUMBER as argument #3") -- [!] Parameter: initial - New current value set as initial.
                                                                                      -- [!] Return: 'true' - If all values have been changed properly and without errors.
    if (minimum < maximum) then
      private.minimumValue = minimum
      private.maximumValue = maximum
    else
      error("[XAF Error] Minimum value must be lower than maximum")
    end
    
    if (initial < minimum) then
      private.currentValue = minimum
    elseif (initial > maximum) then
      private.currentValue = maximum
    else
      private.currentValue = initial
    end
    
    return true
  end
  
  public.refresh = function(self)             -- [!] Function: refresh() - Refreshes the progress bar without rendering entire component (it is slightly faster than 'view()' function).
    local previousRender = private.renderMode -- [!] Return: 'true' - Returned if component has been refreshed properly.
    
    public:setRenderMode(3)
    public:view()
    public:setRenderMode(previousRender)
    
    return true
  end
  
  public.view = function(self)                                                                                        -- [!] Function: view() - Renders progress bar on the screen.
    local renderer = private.renderer                                                                                 -- [!] Return: 'true' - If the component has been rendered correctly.
    
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
        local valueOffset = private.minimumValue
        local valueMinimumOffset = 0
        local valueMaximumOffset = private.maximumValue - valueOffset
        local valueCurrentOffset = private.currentValue - valueOffset
        local valueFactor = valueCurrentOffset / valueMaximumOffset
        local partsTotal = (private.barLayout == 0 or private.barLayout == 1) and (8 * columns) or (8 * rows)
        local partingsTotal = valueFactor * partsTotal
        local partingsFull = math.floor(partingsTotal / 8)
        local partingsUnit = math.floor(partingsTotal % 8)
        
        renderer.setBackground(private.colorBackground)
        renderer.setForeground(private.colorContent)
        renderer.fill(posX + 2, posY + 1, columns, rows, ' ')
        
        if (private.barLayout == 0 or private.barLayout == 1) then
          renderer.fill(posX + 2, posY + 1, partingsFull, rows, private.horizontalParts[8])
          
          if (partingsUnit > 0) then
            renderer.fill(posX + partingsFull + 2, posY + 1, 1, rows, private.horizontalParts[partingsUnit])
          end
        elseif (private.barLayout == 2) then
          renderer.fill(posX + 2, posY + (rows - partingsFull + 1), columns, partingsFull, private.verticalParts[8])
          
          if (partingsUnit > 0) then
            renderer.fill(posX + 2, posY + (rows - partingsFull), columns, 1, private.verticalParts[partingsUnit])
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

function ProgressBar:extend()
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

function ProgressBar:new(positionX, positionY, columns, rows, layoutMode)
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
  
  assert(type(rows) == "number", "[XAF Graphic] Expected NUMBER as argument #4")
  
  if (xafcoreMath:checkNatural(rows, true) == true) then
    private.rows = rows
  else
    error("[XAF Error] Invalid rows number - must be a positive integer")
  end
  
  assert(type(layoutMode) == "number", "[XAF Graphic] Expected NUMBER as argument #5")
  
  if (layoutMode >= 0 and layoutMode <= 2) then
    if (xafcoreMath:checkInteger(layoutMode) == true) then
      private.barLayout = layoutMode
    else
      error("[XAF Error] Invalid bar layout mode - must be a integer")
    end
  else
    error("[XAF Error] Invalid bar layout mode")
  end
  
  private.totalWidth = columns + 4
  private.totalHeight = rows + 2
  
  if (self.C_INSTANCE == true) then
    return public
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be instanced")
  end
end

return ProgressBar
