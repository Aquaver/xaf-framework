# XAF Class Structure

XAF Class Structure is just a model for building classes that are used in range of this framework. It is compatible with the basics of object-oriented programming assumptions like encapsulation (class members privacy) or inheritance (extending classes from other ones). It also defines solution for static access fields, which are assigned for whole class, not to single objects. This structure is consists of five main modules.

* Module import statements - `require module = require("module")` - which must be at top of the class code.
* Class declaration table - `local MyClass = {C_NAME = "Class name", C_INSTANCE = true/false, C_INHERIT = true/false}` - the most important part of class, defines its name and general behavior. These fields are explained below:

  * `C_NAME` - This is just class name, which can contain white spaces, but must fit in one line.
  * `C_INSTANCE` - Class instantiability flag - it permits or prohibits creating object of this class.
  * `C_INHERIT` - Class inheritance flag - it works as above one, but it concerns inheritance.

* Main initialization function - `function MyClass:initialize()` - it is used for creating new class instances in constructing and inheriting. In its body class private or public variables and methods are defined. Note that object methods support class self-returning and it is possible to use the constructor with `return` keyword. For example if user wants to exchange data between different class instances.
* Class inheritance function - `function MyClass:extend()` - used obviously to inherit from this class. In this framework inheritance consists of copying all members (private and public) to the derived class. It will throw an error when try to inherit from class where it was disabled.
**Important!** Class static fields are not inherited, it concerns only object-related members.
* Class object constructor - `function MyClass:new(parameters)` - function used to create new class instances. It will throw an error when try to create object in class where instantiation is prohibited and disabled.

## Class structure code

```lua
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
  -- [>] Object's methods can return new objects using class constructor.
  -- [?] Example: private.myValue = 100
  -- [?] Example: public.getValue = function(self) return private.myValue end
  -- [?] Example: public.getObject = function(self) return MyClass:new(parameters) end
  
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
```

## Simple class and subclass example

To better understanding how these classes with inheritance works, I have written simple class tree which consists of four files: Shape class (which will be the base class), Rectangle class (which inherit from Shape class) and Square class (which inherit from Rectangle class), and obviously code where these classes will be tested. **Important!** In order to work, these files must be created all in one directory.

### Class: Shape - `shape.lua`

```lua
local Shape = {
  C_NAME = "Abstract Shape",
  C_INSTANCE = false, -- Shape cannot exist as such, that is why it cannot be instanced and presented as object.
  C_INHERIT = true,
  
  static = {}
}

function Shape:initialize()
  local parent = nil
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}

  private.area = -1 -- Despite it cannot be instanced, all shapes have its areas.
  private.width = -1
  private.height = -1

  public.getArea = function(self) -- As shape has area, we should can get it.
    return private.area
  end

  public.getWidth = function(self)
    return private.width
  end

  public.getHeight = function(self)
    return private.height
  end
  
  return {
    private = private,
    public = public
  }
end

function Shape:extend()
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

function Shape:new()
  local class = self:initialize()
  local private = class.private
  local public = class.public
  
  if (self.C_INSTANCE == true) then
    return public
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be instanced")
  end
end

return Shape
```

Firstly, class Shape in its declaration table has name - `Abstract Shape` - which helps to identify it while getting possible errors, but as you see, it has disabled instantiation, because as I wrote in comment - shapes cannot exist as such. However, we can define it dimensions and are despite it cannot be presented. Therefore, this class can only be extended and inherited.

### Class: Rectangle - `rectangle.lua`

```lua
local shape = require("shape") -- This class will be parent for Rectangle.

local Rectangle = {
  C_NAME = "Rectangle",
  C_INSTANCE = true, -- Rectangle is a shape which may exist. Therefore, it can be instanced.
  C_INHERIT = true,
  
  static = {}
}

function Rectangle:initialize()
  local parent = shape:extend() -- This line of code is most important in inheritance. It says which class is the parent.
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}
  
  -- Remember fields from class Shape? You need not write them here - they are inherited.
  -- Methods are also inherited, but we can modify them - it is called field 'overriding'.

  public.getArea = function(self)
    return "Hi! I am overridden and this is my area: " .. tostring(private.area)
  end
  
  return {
    private = private,
    public = public
  }
end

function Rectangle:extend()
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

function Rectangle:new(width, height)
  local class = self:initialize()
  local private = class.private
  local public = class.public
  
  private.width = width
  private.height = height
  private.area = width * height

  if (self.C_INSTANCE == true) then
    return public
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be instanced")
  end
end

return Rectangle
```

Class Rectangle it is already a subclass - it has parent. It generates us two changes in class structure which must be implemented to work properly: importing declaration - `local shape = require("shape")` - at top of the class and inheritance declaration in initialization function: `local parent = shape:extend()`. With these little changes we do not have to rewrite all fields from base class. They are invisible, but they are exist. However, these fields (public or private, variables or methods) are modifiable. In professional object-oriented programming this phenomenon is called overriding. That is the most powerful functionality of XAF framework. Obviously as this class can be instanced, we must add some changes to constructor. It would be good to pass arguments while creating new object. Therefore, we must add these parameters to constructor function signature: `function Rectangle:new(width, height)` and pass these values to object's fields: `private.width = width` and `private.height = height`. In this place we can also calculate the object's area field - `private.area = width * height`.

### Class: Square - `square.lua`

```lua
local rectangle = require("rectangle") -- Square class will inherit from Rectangle, it must be imported.

local Square = {
  C_NAME = "Square",
  C_INSTANCE = true,
  C_INHERIT = true,
  
  static = {}
}

function Square:initialize()
  local parent = rectangle:extend() -- Class Square is a child of class Rectangle.
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}
  
  return {
    private = private,
    public = public
  }
end

function Square:extend()
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

function Square:new(width) -- Squares have not different sides - they are equals. So we use only one parameter to create objects.
  local class = self:initialize()
  local private = class.private
  local public = class.public

  private.width = width
  private.height = width
  private.area = width * width

  if (self.C_INSTANCE == true) then
    return public
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be instanced")
  end
end

return Square
```

The last class in our tree is Square, which differs from Rectangle with constructor initializers and parameters. Square class constructor accepts only one parameter in contrast to Rectangle, which need two parameters. Also, area formula has changed to `private.field = width * width`.
But also here as in Rectangle, we do not have to rewrite methods from Shape class.

### Testing code

```lua
local shape = require("shape")
local rectangle = require("rectangle")
local square = require("square")

-- local myShape = shape:new() This code line will throw an error. Remember? This class cannot be instanced.
local myRectangle = rectangle:new(3, 5)
local mySquare = square:new(4)

print("Printing shapes dimensions:")
print("  [>] myRectangle width: " .. tostring(myRectangle:getWidth()))
print("  [>] myRectangle height: " .. tostring(myRectangle:getHeight()))
print("  [>] myRectangle area: " .. tostring(myRectangle:getArea()))
print()
print("  [>] mySquare width: " .. tostring(mySquare:getWidth()))
print("  [>] mySquare height: " .. tostring(mySquare:getHeight()))
print("  [>] mySquare area: " .. tostring(mySquare:getArea()))
```

Console output of this program is shown below:

```
Printing shapes dimension:
  [>] myRectangle width: 3
  [>] myRectangle height: 5
  [>] myRectangle area: Hi! I am overridden and this is my area: 15

  [>] mySquare width: 4
  [>] mySquare height: 4
  [>] mySquare area: Hi! I am overridden and this is my area: 16
```

I would you remind that classes Rectangle and Square have not declarations of functions like: `getArea()` or `getWidth()` - they are inherited. Furthermore, in class Rectangle function `getArea()` was overridden and it was inherited in Square class. Therefore, every change matters, but it is possible to override again and again.
