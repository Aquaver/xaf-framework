-- Extensible Application Framework Package Manager program starting script.
-- This command is generally used for executing add-on package program.
-- Every subcommand option is standalone and needs to use flag to run itself.

local arguments, options = ...
local filesystem = require("filesystem")
local xafcore = require("xaf/core/xafcore")
local xafcoreExecutor = xafcore:getExecutorInstance()
local xafcoreTable = xafcore:getTableInstance()

if (options.h == true or options.help == true) then
end

local pathRoot = "aquaver.github.io"
local pathPackages = "xaf-packages"
local pathPackageBin = "_bin"
local pathPackageConfig = "_config"
local pathConfigName = "package.info"

if (arguments[1] == nil) then
  print("--------------------------------------")
  print("-- XAF Package Manager - Controller --")
  print("--------------------------------------")
  print("  >> Invalid package name to execute (start)")
  print("  >> Use 'xaf-pm package [-l | --list]' for available package list")

  os.exit()
end

local sourceName = tostring(table.remove(arguments, 1))
local sourcePath = filesystem.concat(pathRoot, pathPackages, sourceName, pathPackageConfig, pathConfigName)
local sourceData = {}

if (filesystem.exists(sourcePath) == true) then
  sourceData = xafcoreTable:loadFromFile(sourcePath)
else
  print("--------------------------------------")
  print("-- XAF Package Manager - Controller --")
  print("--------------------------------------")
  print("  >> Cannot find package configuration file")
  print("  >> This program cannot be executed")
  print("  >> Missing file name: " .. pathConfigName)

  os.exit()
end

local configXaf = sourceData["package-xaf"]
local configTable = _G._XAF
local configVersion = configTable._VERSION

if (configVersion < configXaf) then
  print("--------------------------------------")
  print("-- XAF Package Manager - Controller --")
  print("--------------------------------------")
  print("  >> Installed XAF version does not support this package")
  print("  >> Required XAF: " .. configXaf .. " (local XAF: " .. configVersion .. ')')
  print("  >> Please update the API on this computer via 'xaf update'")

  os.exit()
end

local indexName = sourceData["package-index"]
local indexPath = filesystem.concat(pathRoot, pathPackages, sourceName, pathPackageBin, indexName)

if (filesystem.exists(indexPath) == false) then
  print("--------------------------------------")
  print("-- XAF Package Manager - Controller --")
  print("--------------------------------------")
  print("  >> Cannot find package index (starter) file")
  print("  >> Try removing and downloading this package again")
  print("  >> Missing file name: " .. indexName)
else
  if (options.p == true or options.pass == true) then
  end
end
