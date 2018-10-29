-------------------------------------
-- XAF Module - API:PackageManager --
-------------------------------------
-- [>] This class defines an Application Programming Interface for XAF Package Manager programs.
-- [>] It helps inter-package communication (using XAF application data table) or retrieving absolute package path (for switching between scripts in one package).
-- [>] That module is a part of Extensible Application Framework API, built for PM software.

local configTable = _G._XAF
local configAppdata = (type(configTable) == "table") and configTable._APPDATA or nil
local filesystem = require("filesystem")

local PackageManager = {
  C_NAME = "XAF Package Manager API",
  C_INSTANCE = true,
  C_INHERIT = true,

  static = {}
}

function PackageManager:initialize()
  local parent = nil
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}

  private.pathRoot = "aquaver.github.io"
  private.pathPackage = ''
  private.pathPackages = "xaf-packages"
  private.pathPackageBinary = "_bin"
  private.pathPackageConfig = "_config"

  return {
    private = private,
    public = public
  }
end

function PackageManager:extend()
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

function PackageManager:new(packageIdentifier)
  local class = self:initialize()
  local private = class.private
  local public = class.public

  assert(type(packageIdentifier) == "string", "[XAF Core] Expected STRING as argument #1")
  private.pathPackage = packageIdentifier

  if (configTable == nil or configAppdata == nil) then
    error("[XAF Error] Package Manager API cannot be initialized")
  end

  if (self.C_INSTANCE == true) then
    return public
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be instanced")
  end
end

return PackageManager
