----------------------------------
-- XAF Standard Class Structure --
----------------------------------
-- [>] This is a structure which is used by all modules and classes in XAF framework.
-- [>] It meets primary object-oriented programming assumptions: encapsulation and also inheritance.
-- [>] It is strongly recommended implementing it in your extension classes/modules.

-- [!] There (before class definition) is a place for importing external libraries and base 'parent' classes.
-- [?] Example: local myBaseClass = require("myBaseClass")
-- [?] Example: local myLibrary = require("myLibrary")

local MyClass = {
  C_NAME = "My Class",     -- [!] Class custom name, may contain white spaces, it is used to identify this class in errors.
  C_INSTANCE = true/false, -- [!] Instantiation flag: 'true' class may create objects, 'false' class is not instantiable.
  C_INHERIT = true/false,  -- [!] Inheritance flag: 'true' class may be extended, 'false' class cannot be inherited.
  
  static = {
    -- [>] This table is intended for static non-object fields. It means that those values are not assigned to specific object.
    -- [>] Static members have not privacy modifiers, they are all public.
    -- [>] Usually static fields are class constants and constant value by convention are written in capital letters and spaced by underscore.
    -- [>] To get a static value from specific class use: className.static.fieldName.
    -- [?] Example: myStaticValue = "This value is the same in all objects"
    -- [?] Example: MY_CONST = 100
  }
}

function MyClass:initialize()                       -- [!] Internal class initialization function, used in creating objects and inheritance.
  local parent = nil                                -- [!] Class parent: place for 'inheriting' from base class. Usage: 'nil' or 'myBaseClass:extend()'
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}
  
  -- [>] Place for class members: fields, methods in class visibility.
  -- [>] Usage: modifier.name = value/function()
  -- [?] Example: private.myValue = 100
  -- [?] Example: public.getValue = function(self) return private.myValue end
  
  return {
    private = private,
    public = public
  }
end

function MyClass:extend()
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

function MyClass:new()
  local class = self:initialize()
  local private = class.private
  local public = class.public
  
  -- [>] Place for object constructor initializers.
  -- [>] Usage: modifier.name = argumentFromConstructor
  -- [?] Example: private.name = inputName (with constructor MyClass:new(inputName))
  
  if (self.C_INSTANCE == true) then
    return public
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be instanced")
  end
end

return MyClass