-------------------------------
-- XAF Module - Graphic:List --
-------------------------------
-- [>] That class represents a list - component which allows showing multiple text lines in smaller place.
-- [>] It also has a scrollbar which indicates current relative position in the list container.
-- [>] Furthermore that component allows selecting and deselecting specific text lines (single or multiple at once).
-- [!] Accepted events: 'click', 'scroll'

local component = require("xaf/graphic/component")
local xafcore = require("xaf/core/xafcore")
local xafcoreTable = xafcore:getTableInstance()

local List = {
  C_NAME = "Generic GUI List",
  C_INSTANCE = true,
  C_INHERIT = true,
  
  static = {
    SELECT_DEFAULT = 0, -- Constants used for choosing selection mode. They allow single or multiple selecting.
    SELECT_SINGLE = 1,
    SELECT_MULTIPLE = 2
  }
}

function List:initialize()
  local parent = component:extend()
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}
  
  private.eventClick = nil
  private.eventClickArguments = {}
  private.eventScroll = nil
  private.eventScrollArguments = {}
  private.colorSelected = 0xFFFFFF
  private.contentLength = 0
  private.contentTable = {}
  private.contentTableKeys = {}
  private.columns = 0
  private.rows = 0
  private.scrollbarPosition = 0
  private.selectedKeys = {}
  private.selectedValues = {}
  private.selectionMode = 0
  private.showScrollbar = false
  private.showKeys = false
  private.relativeIndex = 0
  private.relativeMaxIndex = 0
  
  public.getContent = function(self) -- [!] Function: getContent() - Returns current list content table.
    return private.contentTable      -- [!] Return: contentTable - List content table.
  end
  
  public.getSelectedKeys = function(self) -- [!] Function: getSelectedKeys() - Returns list selected line-keys pairs table.
    return private.selectedKeys           -- [!] Return: selectedKeys - Table with selected line-keys pairs.
  end
  
  public.getSelectedValues = function(self) -- [!] Function: getSelectedValues() - Returns list selected line-values pairs table.
    return private.selectedValues           -- [!] Return: selectedValues - Table with selected line-values pairs.
  end
  
  public.getSelectionModel = function(self)             -- [!] Function: getSelectionModel() - Returns current list selection model (mode number and color number).
    return private.selectionMode, private.colorSelected -- [!] Return: selectionMode, colorSelected - Parts of current list selection model.
  end
  
  public.getShowKeys = function(self) -- [!] Function: getShowKeys() - Returns list's key showing flag on 'view()' function.
    return private.showKeys           -- [!] Return: showKeys - List showing flag as boolean.
  end
  
  public.register = function(self, event)                                                           -- [!] Function: register(event) - Register the list in main event loop.
    assert(type(event) == "table", "[XAF Graphic] Expected TABLE as argument #1")                   -- [!] Parameter: event - Event table from event.pull() function in OC Event API.
                                                                                                    -- [!] Return: ... - Results from event function if it has been registered.
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

          if (render <= 3) then -- List will react on clicks only inside the internal container because of click line index.
            startPositionX = private.positionX + 2
            startPositionY = private.positionY + 1
            endPositionX = private.positionX + private.totalWidth - 3
            endPositionY = private.positionY + private.totalHeight - 2
          end
          
          if ((clickX >= startPositionX and clickX <= endPositionX)
          and (clickY >= startPositionY and clickY <= endPositionY)) then
            local absoluteClickLine = clickY - private.positionY
            local relativeClickLine = absoluteClickLine + private.relativeIndex
            local eventClick = private.eventClick
            local arguments = private.eventClickArguments
            
            if (private.selectionMode == 0 or private.selectionMode == 1) then
              local key = private.contentTableKeys[relativeClickLine]
              local value = private.contentTable[key]
              
              if (private.selectedKeys[relativeClickLine]) then
                private.selectedKeys[relativeClickLine] = nil
                private.selectedValues[relativeClickLine] = nil
              else
                private.selectedKeys = {}
                private.selectedValues = {}
                
                private.selectedKeys[relativeClickLine] = key
                private.selectedValues[relativeClickLine] = value
              end
            elseif (private.selectionMode == 2) then
              local key = private.contentTableKeys[relativeClickLine]
              local value = private.contentTable[key]
              
              if (private.selectedKeys[relativeClickLine]) then
                private.selectedKeys[relativeClickLine] = nil
                private.selectedValues[relativeClickLine] = nil
              else
                private.selectedKeys[relativeClickLine] = key
                private.selectedValues[relativeClickLine] = value
              end
            else
              error("[XAF Error] Invalid list selection mode")
            end
            
            public:setRenderMode(3)
            public:view(private.showKeys)
            public:setRenderMode(render)
        
            if (eventClick) then
              return eventClick(table.unpack(arguments))
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
            endPositionY = private.positionX + private.totalHeight - 1
          elseif (render <= 2) then
            startPositionX = private.positionX + 1
            startPositionY = private.positionY + 1
            endPositionX = private.positionX + private.totalWidth - 2
            endPositionY = private.positionX + private.totalHeight - 2
          elseif (render <= 3) then
            startPositionX = private.positionX + 2
            startPositionY = private.positionY + 1
            endPositionX = private.positionX + private.totalWidth - 3
            endPositionY = private.positionX + private.totalHeight - 2
          end
          
          if ((scrollX >= startPositionX and scrollX <= endPositionX)
          and (scrollY >= startPositionY and scrollY <= endPositionY)) then
            local eventScroll = private.eventScroll
            local arguments = private.eventScrollArguments
            local scrollFactor = 0
            local scrollPosition = 0
            
            if (scrollDirection > 0 and private.relativeIndex > 0) then
              private.relativeIndex = private.relativeIndex - 1
            elseif (scrollDirection < 0 and private.relativeIndex < private.relativeMaxIndex) then
              private.relativeIndex = private.relativeIndex + 1
            end
            
            scrollFactor = private.relativeIndex / private.relativeMaxIndex
            scrollPosition = math.floor(scrollFactor * (private.rows - 1))
            private.scrollbarPosition = scrollPosition
            
            public:setRenderMode(3)
            public:view(private.showKeys)
            public:setRenderMode(render)
        
            if (eventScroll) then
              return eventScroll(table.unpack(arguments))
            end
          end
        end
      end
    end
  end
  
  public.setContent = function(self, content, reversed)                                  -- [!] Function: setContent(content, reversed) - Changes the list content table and sets key reversion flag.
    assert(type(content) == "table", "[XAF Graphic] Expected TABLE as argument #1")      -- [!] Parameter: content - New content table.
    assert(type(reversed) == "boolean", "[XAF Graphic] Expected BOOLEAN as argument #2") -- [!] Parameter: reversed - List key showing reversion flag.
                                                                                         -- [!] Return: 'true' - If new content has been set correctly.
    private.contentLength = 0
    private.contentTable = {}
    private.contentTableKeys = {}
    private.selectedKeys = {}
    private.selectedValues = {}
    
    for key, value in xafcoreTable:sortByKey(content, reversed) do
      private.contentLength = private.contentLength + 1
      private.contentTable[key] = value
      
      table.insert(private.contentTableKeys, key)
    end
    
    private.relativeIndex = 0
    private.relativeMaxIndex = private.contentLength - private.rows
    
    return true
  end
  
  public.setOnClick = function(self, task, ...)                                        -- [!] Function: setOnClick(task, ...) - Changes the list event task on 'click' event.
    assert(type(task) == "function", "[XAF Graphic] Expected FUNCTION as argument #1") -- [!] Parameter: task - New task function.
                                                                                       -- [!] Parameter: ... - Task function argument list.
    local eventTask = task                                                             -- [!] Return: 'true' - If new event task has been set successfully.
    local eventArguments = {...}
    
    private.eventClick = eventTask
    private.eventClickArguments = eventArguments
    
    return true
  end
  
  public.setOnScroll = function(self, task, ...)                                       -- [!] Function: setOnScroll(task, ...) - Sets the new list event task on 'scroll' event.
    assert(type(task) == "function", "[XAF Graphic] Expected FUNCTION as argument #1") -- [!] Parameter: task - New task event function.
                                                                                       -- [!] Parameter: ... - New task argument list.
    local eventTask = task                                                             -- [!] Return: 'true' - If the new task function has been changed correctly.
    local eventArguments = {...}
    
    private.eventScroll = eventTask
    private.eventScrollArguments = eventArguments
    
    return true
  end
  
  public.setSelectionModel = function(self, mode, color)                            -- [!] Function: setSelectionModel(mode, color) - Sets new list selection model (mode number and color number).
    assert(type(mode) == "number", "[XAF Graphic] Expected NUMBER as argument #1")  -- [!] Parameter: mode - New selection mode (0 - default, 1 - single, 2 - multiple).
    assert(type(color) == "number", "[XAF Graphic] Expected NUMBER as argument #2") -- [!] Parameter: color - New selected line highlight color.
                                                                                    -- [!] Return: 'true' - If the new selection model has been set properly.
    if (mode >= 0 and mode <= 2) then
      private.selectionMode = mode
    else
      error("[XAF Error] Invalid list selection mode number")
    end
    
    if (color >= 0 and color <= 0xFFFFFF) then
      private.colorSelected = color
    else
      error("[XAF Error] Invalid list selected color number")
    end
    
    return true
  end
  
  public.setShowKeys = function(self, flag)                                          -- [!] Function: setShowKeys(flag) - Changes list showing keys on 'view()' function before the value.
    assert(type(flag) == "boolean", "[XAF Graphic] Expected BOOLEAN as argument #1") -- [!] Parameter: flag - New key showing flag.
                                                                                     -- [!] Return: 'true' - If the new flag has been set correctly.
    private.showKeys = flag
    
    return true
  end
  
  public.view = function(self)                                                                            -- [!] Function: view() - Renders the list on screen.
    local renderer = private.renderer                                                                     -- [!] Return: 'true' - If the component has been rendered properly.
    
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
        
        if (private.showScrollbar) then
          renderer.fill(posX + width - 3, posY, 1, height - 1, '│')
          
          renderer.set(posX + width - 3, posY, '┬')
          renderer.set(posX + width - 3, posY + height - 1, '┴')
        end
      end
      
      if (render <= 2) then
        renderer.setBackground(private.colorBackground)
        
        renderer.fill(posX + 1, posY + 1, 1, height - 2, ' ')
        renderer.fill(posX + columns + 2, posY + 1, 1, height - 2, ' ')
      end
      
      if (render <= 3) then
        local contentTable = private.contentTable
        local contentKeys = private.contentTableKeys
        local contentLength = private.contentLength
        local columns = private.columns
        local rows = private.rows
        local iterations = (contentLength < rows) and contentLength or rows
        local showKey = private.showKeys
        
        renderer.setBackground(private.colorBackground)
        renderer.setForeground(private.colorContent)
        renderer.fill(posX + 2, posY + 1, columns, rows, ' ')
        
        if (private.showScrollbar == true) then
          renderer.fill(posX + columns + 4, posY + 1, 1, height - 2, ' ')
          renderer.set(posX + columns + 4, posY + private.scrollbarPosition + 1, '█')
        end
        
        for i = 1, iterations do
          local index = private.relativeIndex + i
          local color = (private.selectedKeys[index]) and private.colorSelected or private.colorContent
          local lineRaw = contentTable[contentKeys[index]]
          local line = (lineRaw == nil) and '' or tostring(lineRaw)
          
          line = (showKey == true) and tostring(private.contentTableKeys[index]) .. ' | ' .. line or line
          
          renderer.setForeground(color)
          renderer.set(posX + 2, posY + i, string.sub(line, 1, columns))
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

function List:extend()
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

function List:new(positionX, positionY, columns, rows, showScroll)
  local class = self:initialize()
  local private = class.private
  local public = class.public
  
  public:setPosition(positionX, positionY)
  assert(type(columns) == "number", "[XAF Graphic] Expected NUMBER as argument #3")
  
  if (math.floor(columns) == columns and math.ceil(columns) == columns and columns > 0) then
    private.columns = columns
  else
    error("[XAF Error] Invalid columns number - must be a positive integer")
  end
  
  assert(type(rows) == "number", "[XAF Graphic] Expected NUMBER as argument #4")
  
  if (math.floor(rows) == rows and math.ceil(rows) == rows and rows > 0) then
    private.rows = rows
  else
    error("[XAF Error] Invalid rows number - must be a positive integer")
  end
  
  assert(type(showScroll) == "boolean", "[XAF Graphic] Expected BOOLEAN as argument #5")
  private.showScrollbar = showScroll
  
  private.totalWidth = (showScroll == true) and (columns + 6) or (columns + 4)
  private.totalHeight = rows + 2
  
  if (self.C_INSTANCE == true) then
    return public
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be instanced")
  end
end

return List
