------------------------------------
-- XAF Module - Graphic:Component --
------------------------------------
-- [>] That module is an abstract class for graphic components - top base class in GUI-related hierarchy.
-- [>] It provides generic functions that are used by all graphic component classes.
-- [>] This class behaves as interface - it cannot be instanced, only for extending.

local xafcore = require("xaf/core/xafcore")
local xafcoreMath = xafcore:getMathInstance()

local Component = {
  C_NAME = "Abstract Graphic Component",
  C_INSTANCE = false,
  C_INHERIT = true,
  
  static = {
    RENDER_DEFAULT = 0,
    RENDER_ALL = 1,
    RENDER_INSETS = 2,
    RENDER_CONTENT = 3
  }
}

function Component:initialize()
  local parent = nil
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}
  
  private.active = true              -- [!] Default component activity state - if 'false' then component will not response on events.
  private.colorBackground = 0x000000 -- [!] Default background color - black (RGB: 0, 0, 0)
  private.colorBorder = 0xFFFFFF     -- [!] Default border color - white (RGB: 255, 255, 255)
  private.colorContent = 0xFFFFFF    -- [!] Default content (text) color - white (RGB: 255, 255, 255)
  private.totalWidth = -1            -- [!] Default component width: -1 means that component does not exist (cannot be visible).
  private.totalHeight = -1           -- [!] Default component height: -1 means that component does not exist (cannot be visible).
  private.positionX = nil            -- [!] Default horizontal position - 'nil' means that component has not been initialized.
  private.positionY = nil            -- [!] Default vertical position - 'nil' means that component has not been initialized.
  private.renderMode = 0             -- [!] Default render mode - RENDER_DEFAULT (value: 0)
  private.renderer = nil             -- [!] Default component render engine: if 'nil' then component has not associated GPU.
  
  public.getActive = function(self) -- [!] Function: getActive() - Returns current component activity state.
    return private.active           -- [!] Return: active - Boolean flag whether component is currently active.
  end
  
  public.getColors = function(self)                                           -- [!] Function: getColors() - Returns current used component primary colors.
    return private.colorBorder, private.colorBackground, private.colorContent -- [!] Return: colorBorder, colorBackground, colorContent - Next component primary colors as numbers.
  end
  
  public.getPosition = function(self)           -- [!] Function: getPosition() - Returns component absolute position on the screen in pixels.
    return private.positionX, private.positionY -- [!] Return: positionX, positionY - Component absolute coordinates in pixels.
  end
  
  public.getRenderMode = function(self) -- [!] Function: getRenderMode() - Returns current component rendering mode.
    return private.renderMode           -- [!] Return: renderMode - Component rendering mode as number.
  end
  
  public.getRenderer = function(self) -- [!] Function: getRenderer() - Returns component's GPU render engine.
    return private.renderer           -- [!] Return: renderer - Current component's render engine.
  end
  
  public.getTotalSize = function(self)             -- [!] Function: getTotalSize() - Returns total component size (width and height) in pixels.
    return private.totalWidth, private.totalHeight -- [!] Return: totalWidth, totalHeight - Total size of the component in pixels.
  end
  
  public.setActive = function(self, state)                                            -- [!] Function: setActive(state) - Changes component activity state to new one.
    assert(type(state) == "boolean", "[XAF Graphic] Expected BOOLEAN as argument #1") -- [!] Parameter: state - New activity state of the component.
                                                                                      -- [!] Return: 'true' - If new component activity state has been changed successfully.
    private.active = state
    
    return true
  end
  
  public.setColors = function(self, border, background, content)                               -- [!] Function: setColors(border, background, content) - Changes current component primary colors.
    assert(type(border) == "number", "[XAF Graphic] Expected NUMBER as argument #1")           -- [!] Parameter: border - New border color number in 0x000000 - 0xFFFFFF range.
    assert(type(background) == "number", "[XAF Graphic] Expected NUMBER as argument #2")       -- [!] Parameter: background - New background color number in 0x000000 - 0xFFFFFF range.
    assert(type(content) == "number", "[XAF Graphic] Expected NUMBER as argument #3")          -- [!] Parameter: content - New content (text) color number in 0x000000 - 0xFFFFFF range.
                                                                                               -- [!] Return: 'true' - If all colors were set correctly.
    if (border <= 0xFFFFFF and border >= 0) then
      private.colorBorder = border
    else
      error("[XAF Error] Invalid component border color")
    end
    
    if (background <= 0xFFFFFF and background >= 0) then
      private.colorBackground = background
    else
      error("[XAF Error] Invalid component background color")
    end
    
    if (content <= 0xFFFFFF and background >= 0) then
      private.colorContent = content
    else
      error("[XAF Error] Invalid component content color")
    end
    
    return true
  end
  
  public.setPosition = function(self, newX, newY)                                  -- [!] Function: setPosition(newX, newY) - Changes the component's coordinates to new ones.
    assert(type(newX) == "number", "[XAF Graphic] Expected NUMBER as argument #1") -- [!] Parameter: newX - New horizontal position number.
    assert(type(newY) == "number", "[XAF Graphic] Expected NUMBER as argument #2") -- [!] Parameter: newY - New vertical position number.
                                                                                   -- [!] Return: 'true' - If new coordinates have been changed successfully.
    if (xafcoreMath:checkInteger(newX) == true) then
      private.positionX = newX
    else
      error("[XAF Error] Invalid X position number - must be an integer")
    end
    
    if (xafcoreMath:checkInteger(newY) == true) then
      private.positionY = newY
    else
      error("[XAF Error] Invalid Y position number - must be an integer")
    end
    
    return true
  end
  
  public.setRenderMode = function(self, mode)                                      -- [!] Function: setRenderMode(mode) - Switches current component rendering mode.
    assert(type(mode) == "number", "[XAF Graphic] Expected NUMBER as argument #1") -- [!] Parameter: mode - New rendering mode (0 - default, 1 - all, 2 - insets only, 3 - content only).
                                                                                   -- [!] Return: 'true' - If new rendering mode was set correctly.
    if (mode >= 0 and mode <= 3) then
      private.renderMode = mode
    else
      error("[XAF Error] Invalid component rendering mode")
    end
    
    return true
  end
  
  public.setRenderer = function(self, gpu)                                      -- [!] Function: setRenderer(gpu) - Sets new GPU as render engine for component.
    assert(type(gpu) == "table", "[XAF Graphic] Expected TABLE as argument #1") -- [!] Parameter: gpu - New component's render engine.
                                                                                -- [!] Return: 'true' - If new renderer has been set properly.
    if (gpu.type == "gpu") then
      private.renderer = gpu
    else
      error("[XAF Error] Invalid GPU component")
    end
    
    return true
  end
  
  public.view = function(self)                                                                   -- [!] Function: view() - Default rendering function, which always throw an error.
    error("[XAF Error] Component rendering function has not been initialized - running default")
  end
  
  return {
    private = private,
    public = public
  }
end

function Component:extend()
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

function Component:new()
  local class = self:initialize()
  local private = class.private
  local public = class.public
  
  if (self.C_INSTANCE == true) then
    return public
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be instanced")
  end
end

return Component
