-- Extensible Application Framework package installation program.
-- It is used in both first installation (via 'wget' command) and version updating.
-- This script only downloads and installs the package without initialization, it must be performed by the user by 'xaf init' command.

local component = require("component")
local event = require("event")
local filesystem = require("filesystem")
local unicode = require("unicode")
local internet = nil
local packageType = 'X'
local requiredSystem = "OpenOS"
local requiredVersion = "1.7"
local resolutionX, resolutionY = component.getPrimary("gpu").maxResolution()
local systemIdentifier = tostring(_G._OSVERSION)
local systemDelimiter = string.find(systemIdentifier, "[%d]+")
local systemName = string.sub(systemIdentifier, 1, systemDelimiter - 2)
local systemVersion = string.sub(systemIdentifier, systemDelimiter)

-- General XAF package installation properties.
local sourceProject = "https://raw.githubusercontent.com/Aquaver/xaf-framework/"
local sourceVersion = "master"
local sourcePackage = "/package"
local sourceModules = {}
local sourceScripts = {}

-- Project module table tree with file names.
sourceModules["core"] = {"xafcore"}
sourceModules["graphic"] = {"button", "checkbox", "component", "list", "passwordfield", "progressbar", "slider", "spinner", "switch", "textfield"}
sourceModules["network"] = {"client", "dnsclient", "dnsserver", "dtpclient", "dtpserver", "ftpclient", "ftpserver", "server"}
sourceModules["utility"] = {"httpstream", "redstream"}

-- Target installation directories in absolute paths.
local pathRoot = "aquaver.github.io"
local pathProject = "xaf-framework"
local pathClasses = "api"
local pathScripts = "scripts"

-- XAF scripts directories (for initializing, controlling, et cetera).
sourceScripts["bin"] = {"xaf"}
sourceScripts["commands"] = {"check", "init", "list", "remove", "update"}

-- Starting installation procedure.
print("-----------------------------------------------------")
print("-- Extensible Application Framework - Installation --")
print("-----------------------------------------------------")
print("  >> Installation from following release: " .. sourceVersion)
print("  >> Checking prerequisites...")

-- Checking for required operation system version.
if (systemName == requiredSystem) then
  if (systemVersion < requiredVersion) then
    print("    >> This version of " .. requiredSystem .. " is out of date, minimum required version is '" .. requiredVersion .. "'")
    os.exit()
  else
    print("    >> Supported version of " .. requiredSystem .. " system found")
  end
else
  print("    >> This system does not support XAF, the required one is '" .. requiredSystem .. "'")
  os.exit()
end

-- Checking maximum available resolution (required both T3 GPU and T3 screen).
if (resolutionX >= 160 or resolutionY >= 50) then
  print("    >> Required T3 GPU component found")
  print("    >> Required T3 screen component found")
else
  print("    >> Required T3 GPU and T3 screen component are not available")
  print("    >> Installation has been interrupted")
  os.exit()
end

-- Checking internet card availability.
if (component.isAvailable("internet") == true) then
  internet = component.getPrimary("internet")
  
  print("    >> Internet card component found")
else
  print("    >> Internet card component is not available")
  print("    >> Installation has been interrupted")
  os.exit()
end

-- Checking for required directories and creating the missing ones.
if (filesystem.exists(pathRoot) == false) then
  print("    >> Aquaver's root directory does not exist, creating new one...")
  filesystem.makeDirectory(pathRoot)
end

if (filesystem.exists(filesystem.concat(pathRoot, pathProject)) == false) then
  print("    >> Project directory does not exist, creating new one...")
  filesystem.makeDirectory(filesystem.concat(pathRoot, pathProject))
else
  print("    >> Project directory already exists, replace it?")
  print("      >> Hit 'Y' to accept or 'N' to interrupt the installation")
  print("      >> Warning! It will delete current XAF package if it is already installed")
  
  while (true) do
    local option = {event.pull("key_down")}
    
    if (option[3] == 89) then
      filesystem.remove(filesystem.concat(pathRoot, pathProject))
      filesystem.makeDirectory(filesystem.concat(pathRoot, pathProject))
      
      print("      >> Project directory replaced, continuing...")
      break
    elseif (option[3] == 78) then
      print("      >> Installation has been interrupted")
      os.exit()
    end
  end
end

if (filesystem.exists(filesystem.concat(pathRoot, pathProject, pathClasses)) == false) then
  print("    >> XAF package API directory does not exist, creating new one...")
  filesystem.makeDirectory(filesystem.concat(pathRoot, pathProject, pathClasses))
end

if (filesystem.exists(filesystem.concat(pathRoot, pathProject, pathScripts)) == false) then
  print("    >> XAF package scripts directory does not exist, creating new one...")
  filesystem.makeDirectory(filesystem.concat(pathRoot, pathProject, pathScripts))
end

-- Choosing suitable package type.
print("  >> Choose suitable package type:")
print("    >> 1 - Minified (compressed) version, for normal users")
print("    >> 2 - Full source version, for developers or collaborators")
print("    >> q - Interrupt and exit the installation...")

while (true) do
  local option = {event.pull("key_down")}
  
  if (option[3] == 49) then
    print("      >> You chose the following package type: Minified source")
    packageType = "/min/"
    break
  elseif (option[3] == 50) then
    print("      >> You chose the following package type: Full source")
    packageType = "/src/"
    break
  elseif (option[3] == 113) then
    print("      >> Installation has been interrupted")
    os.exit()
  end
end

-- Starting downloading and installation procedure.
local scriptsAddress = sourceProject .. sourceVersion .. sourcePackage
local scriptsTarget = filesystem.concat(pathRoot, pathProject, pathScripts)
local scriptsTotalSize = 0 
local sourceAddress = sourceProject .. sourceVersion .. packageType
local sourceTarget = filesystem.concat(pathRoot, pathProject, pathClasses)
local sourceTotalSize = 0

print("  >> Preparing to installation...")
print("  >> Connecting to project repository...")

local filesystem, internet = require("filesystem"), require("internet")
local function httpget(remotepath, localpath, localfile, maxattempt) maxattempts = maxattempts or 3
local gsub, cout, fs, ie = string.gsub, io.write, filesystem, internet
if fs.exists(localpath) == false then fs.makeDirectory(localpath) end
local f, reason = fs.open(fs.concat(localpath, localfile), "w") 
if not f then cout("\nFailed opening file for writing: " .. reason) return false end
cout("    >> Downloading \n      FROM " .. remotepath .. " \n      TO " .. fs.concat(localpath, localfile))
local con = ie.request(remotepath) os.sleep(1) local a, res = 0, con.response()
while res ~= 200 and ( a < maxattempts ) do con = ie.request(remotepath) os.sleep(1) res = con.response() a = a + 1 end
if res == 200 then cout(" OK\n      Saving ")for c in con do cout(".")gsub(c,"\r\n","\n")f:write(c)end cout(" DONE\n") return true
else cout(" failed\n") f:close() fs.remove(fs.concat(localpath, localfile)) cout("    >>FAILED "..res) return false end
end

for scriptType, scriptTable in pairs(sourceScripts) do
  local remotePath = scriptsAddress .. packageType .. pathScripts .. '/' .. scriptType
  local localPath = '/'
  
  if (scriptType == "bin") then
    localPath = filesystem.concat(localPath, scriptType)
  elseif (scriptType == "commands") then
    localPath = filesystem.concat(localPath, scriptsTarget)
  end
  
  print("    >> Downloading script type: " .. scriptType)
  
  if (filesystem.exists(localPath) == false) then
    filesystem.makeDirectory(localPath)
  end
  
  for scriptIdentifier, scriptName in ipairs(scriptTable) do
    local internalRemote = remotePath .. '/' .. scriptName .. ".lua"
    local internalLocal = filesystem.concat(localPath, scriptName .. ".lua")

    --print("      >> Downloading script: " .. scriptType .. '/' .. scriptName)
    os.sleep(1) httpget(internalRemote, localPath, scriptName..".lua")
  end
  print("    >> Downloading script type '" .. scriptType .. "' finished")
end

for moduleName, moduleTable in pairs(sourceModules) do
  print("    >> Downloading module: " .. moduleName)
  
  if (filesystem.exists(filesystem.concat(pathRoot, pathProject, pathClasses, moduleName)) == false) then
    filesystem.makeDirectory(filesystem.concat(pathRoot, pathProject, pathClasses, moduleName))
  end
  
  for classIdentifier, className in ipairs(moduleTable) do

    local remotePath = sourceAddress .. moduleName .. '/' .. className .. ".lua"
    local localPath = filesystem.concat("/", sourceTarget, moduleName)
    
    --print("      >> Downloading class: " .. moduleName .. '/' .. className)
    os.sleep(1) httpget(remotePath, localPath, className .. ".lua")
  end
  print("    >> Downloading module '" .. moduleName .. "' finished")
end

if (_G._XAF) then
  _G._XAF = nil
  
  print("    >> XAF configuration table already exists")
  print("    >> Existing configuration table has been cleared")
end

print("  >> Installation completed")
print("  >> Total downloaded data size: " .. string.format("%.2f", (sourceTotalSize + scriptsTotalSize) / 1024) .. " kB")
print("  >> Please initialize XAF before using it with 'xaf init' command")
