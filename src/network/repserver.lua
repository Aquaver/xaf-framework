------------------------------------
-- XAF Module - Network:REPServer --
------------------------------------
-- [>] This class represents the mechanism of server side of Remote Executor Protocol.
-- [>] It allows the user executing scripts on a remote machine through client's computer.
-- [>] That implementation possesses some options of executing like performing as command or no value returning.

local filesystem = require("filesystem")
local server = require("xaf/network/server")
local shell = require("shell")
local unicode = require("unicode")
local xafcore = require("xaf/core/xafcore")
local xafcoreExecutor = xafcore:getExecutorInstance()

local RepServer = {
  C_NAME = "Generic REP Server",
  C_INSTANCE = true,
  C_INHERIT = true,

  static = {}
}

function RepServer:initialize()
  local parent = server:extend()
  local private = (parent) and parent.private or {}
  local public = (parent) and parent.public or {}

  private.serverPaths = {}
  private.serverPaths["rep_root"] = '/'
  private.serverPaths["rep_scripts"] = "REP_SCRIPTS"

  return {
    private = private,
    public = public
  }
end

function RepServer:extend()
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

function RepServer:new(modem, rootPath)
  local class = self:initialize()
  local private = class.private
  local public = class.public

  public:setModem(modem)
  assert(type(rootPath) == "string", "[XAF Network] Expected STRING as argument #2")
  private:prepareWorkspace(rootPath)

  if (self.C_INSTANCE == true) then
    return public
  else
    error("[XAF Error] Class '" .. tostring(self.C_NAME) .. "' cannot be instanced")
  end
end

return RepServer
