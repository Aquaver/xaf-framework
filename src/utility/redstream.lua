------------------------------------
-- XAF Module - Utility:RedStream --
------------------------------------
-- [>] This class describes behavior of the Redstone Stream object, which simplifies using Redstone Cards.
-- [>] As it supports analog signal manipulation from tier 1 as bundled (colored) signals from tier 2 too.
-- [>] To use this module there is no original OC Redstone API knowledge needed - for plain 'switches' you will need only two functions from this module.

local RedStream = {
  C_NAME = "Generic Redstone Stream",
  C_INSTANCE = true,
  C_INHERIT = true,
  
  static = {
    MODE_DEFAULT = 0, -- Constants used in constructor as 'mode' parameter. Used for defining redstone stream type. To choose between simple (analog) and digital (colored, bundled) redstone signal type.
    MODE_ANALOG = 1,
    MODE_DIGITAL = 2,
  }
}

function RedStream:initialize()
  local parent = nil
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}
  
  private.componentRedstone = nil
  private.bundleColor = -1
  private.streamMode = 0
  private.streamSide = -1
  private.tableColors = {["white"] = 0, ["orange"] = 1, ["magenta"] = 2, ["light_blue"] = 3, ["yellow"] = 4, ["lime"] = 5, ["pink"] = 6, ["gray"] = 7, ["light_gray"] = 8, ["cyan"] = 9, ["purple"] = 10, ["blue"] = 11, ["brown"] = 12, ["green"] = 13, ["red"] = 14, ["black"] = 15}
  private.tableSides = {["bottom"] = 0, ["top"] = 1, ["back"] = 2, ["north"] = 2, ["front"] = 3, ["south"] = 3, ["right"] = 4, ["west"] = 4, ["left"] = 5, ["east"] = 5}
  
  public.getBundleColor = function(self)                                -- [!] Function: getBundleColor() - Returns redstone stream bundle color in digital mode.
    if (private.streamMode == 2) then                                   -- [!] Return: bundleColor - Current stream bundle color name as number.
      return private.bundleColor
    else
      error("[XAF Error] Bundle colors available in digital mode only")
    end
  end
  
  public.getComponent = function(self) -- [!] Function: getComponent() - Returns redstone component used by this stream.
    return private.componentRedstone   -- [!] Return: componentRedstone - Stream's redstone component as its object (table).
  end
  
  public.getInput = function(self)                                        -- [!] Function: getInput() - Returns current signal input value from specified side of the redstone component.
    if (private.componentRedstone) then                                   -- [!] Return: inputValue - Detected redstone signal strength.
      local color = private.bundleColor
      local side = private.streamSide
      
      if (side > -1) then
        if (private.streamMode == 0 or private.streamMode == 1) then
          return private.componentRedstone.getInput(side)
        elseif (private.streamMode == 2) then
          if (color > -1) then
            return private.componentRedstone.getBundledInput(side, color)
          else
            error("[XAF Error] Bundle color has not been initialized")
          end
        else
          error("[XAF Error] Invalid redstone stream mode")
        end
      else
        error("[XAF Error] Stream side has not been initialized")
      end
    else
      error("[XAF Error] Redstone component has not been initialized")
    end
  end
  
  public.getOutput = function(self)                                         -- [!] Function: getOutput() - Returns current output redstone signal strength from specified side of the redstone component.
    if (private.componentRedstone) then                                     -- [!] Return: outputValue - Detected output redstone signal power value.
      local color = private.bundleColor
      local side = private.streamSide
      
      if (side > -1) then
        if (private.streamMode == 0 or private.streamMode == 1) then
          return private.componentRedstone.getOutput(side)
        elseif (private.streamMode == 2) then
          if (color > -1) then
            return private.componentRedstone.getBundledOutput(side, color)
          else
            error("[XAF Error] Bundle color has not been initialized")
          end
        else
          error("[XAF Error] Invalid redstone stream mode")
        end
      else
        error("[XAF Error] Stream side has not been initialized")
      end
    else
      error("[XAF Error] Redstone component has not been initialized")
    end
  end
  
  public.getStreamMode = function(self) -- [!] Function: getStreamMode() - Returns redstone stream mode.
    return private.streamMode           -- [!] Return: streamMode - Redstream mode value as number.
  end
  
  public.getStreamSide = function(self) -- [!] Function: getStreamSide() - Returns current redstone stream side (of computer, Redstone Card or external IO block).
    return private.streamSide           -- [!] Return: streamSide - Redstream side value as its number.
  end
  
  public.off = function(self)                                          -- [!] Function: off() - Switches off the redstone signal and sets it to 0 (zero).
    if (private.componentRedstone) then                                -- [!] Return: 'true' - If the signal has been switched off without errors.
      local color = private.bundleColor
      local side = private.streamSide
      
      if (side > -1) then
        if (private.streamMode == 0 or private.streamMode == 1) then
          private.componentRedstone.setOutput(side, 0)
        elseif (private.streamMode == 2) then
          if (color > -1) then
            private.componentRedstone.setBundledOutput(side, color, 0)
          else
            error("[XAF Error] Bundle color has not been initialized")
          end
        else
          error("[XAF Error] Invalid redstone stream mode")
        end
      else
        error("[XAF Error] Stream side has not been initialized")
      end
    else
      error("[XAF Error] Redstone component has not been initialized")
    end
    
    return true
  end
  
  public.on = function(self, value)                                     -- [!] Function: on(value) - Switches on redstone output signal and sets it to specified value.
    local componentRedstone = private.componentRedstone                 -- [!] Parameter: value - New redstone power value - if 'nil' then it will be the maximum available ('full on').
    local powerValue = (type(value) == "number") and value or 255       -- [!] Return: 'true' - If the redstone signal has been changed properly.
    
    if (componentRedstone) then
      local color = private.bundleColor
      local side = private.streamSide
      
      if (side > -1) then
        if (private.streamMode == 0 or private.streamMode == 1) then
          componentRedstone.setOutput(side, powerValue)
        elseif (private.streamMode == 2) then
          if (color > -1) then
            componentRedstone.setBundledOutput(side, color, powerValue)
          else
            error("[XAF Error] Bundle color has not been initialized")
          end
        else
          error("[XAF Error] Invalid redstone stream mode")
        end
      else
        error("[XAF Error] Stream side has not been initialized")
      end
    else
      error("[XAF Error] Redstone component has not been initialized")
    end
    
    return true
  end
  
  public.setBundleColor = function(self, color)                                     -- [!] Function: setBundleColor(color) - Changes redstone bundle color for digital mode.
    assert(type(color) == "string", "[XAF Utility] Expected STRING as argument #1") -- [!] Parameter: color - Plain color name as string (white, orange, light_blue, etc).
                                                                                    -- [!] Return: 'true' - If the color value has been set correctly.
    if (private.streamMode == 2) then
      if (private.tableColors[color]) then
        private.bundleColor = private.tableColors[color]
      else
        error("[XAF Error] Invalid color value")
      end
    else
      error("[XAF Error] Bundle colors available in digital mode only")
    end
    
    return true
  end
  
  public.setComponent = function(self, component)                                     -- [!] Function: setComponent(component) - Sets stream's redstone component.
    assert(type(component) == "table", "[XAF Utility] Expected TABLE as argument #1") -- [!] Parameter: component - New redstone component (card or external IO block).
                                                                                      -- [!] Return: 'true' - If the component has been set correctly.
    if (component.type == "redstone") then
      private.componentRedstone = component
    else
      error("[XAF Error] Invalid redstone component")
    end
      
    return true
  end
  
  public.setStreamSide = function(self, side)                                      -- [!] Function: setStreamSide(side) - Sets redstone stream side, from which the signal will be transmitted.
    assert(type(side) == "string", "[XAF Utility] Expected STRING as argument #1") -- [!] Parameter: side - New side as its name, may be absolute (like 'north') or relative (like 'right').
                                                                                   -- [!] Return: 'true' - If the side value has been changed properly.
    if (private.tableSides[side]) then
      private.streamSide = private.tableSides[side]
    else
      error("[XAF Error] Invalid side value")
    end
    
    return true
  end

  return {
    private = private,
    public = public
  }
end

function RedStream:extend()
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

function RedStream:new(component, mode)
  local class = self:initialize()
  local private = class.private
  local public = class.public
  
  public:setComponent(component)
  assert(type(mode) == "number", "[XAF Utility] Expected NUMBER as argument #2")
  
  if (mode >= 0 and mode <= 2) then
    private.streamMode = mode
  else
    error("[XAF Error] Invalid redstone stream mode")
  end

  if (self.C_INSTANCE == true) then
    return public
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be instanced")
  end
end

return RedStream
