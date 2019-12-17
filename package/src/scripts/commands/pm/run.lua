-- Extensible Application Framework Package Manager program starting script.
-- This command is generally used for executing add-on package program.
-- Every subcommand option is standalone and needs to use flag to run itself.

local arguments, options = ...
local filesystem = require("filesystem")
local xafcore = require("xaf/core/xafcore")
local xafcoreExecutor = xafcore:getExecutorInstance()
local xafcoreTable = xafcore:getTableInstance()

if (options.h == true or options.help == true) then
  print("----------------------------------")
  print("-- XAF Package Manager - Manual --")
  print("----------------------------------")
  print("  >> NAME")
  print("    >> xaf-pm run - Package program starting script")
  print()
  print("  >> SYNOPSIS")
  print("    >> xaf-pm run")
  print("    >> xaf-pm run <name>")
  print("    >> xaf-pm run [-h | --help]")
  print("    >> xaf-pm run [-p | --pass] <name> [arguments] [options]")
  print()
  print("  >> DESCRIPTION")
  print("    >> This program is generally used for PM add-on package starting, and passing optional arguments or flags to it.")

  os.exit()
end

local pathRoot = "io.github.aquaver"
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
local sourceFile = filesystem.concat(pathRoot, pathPackages, sourceName)
local sourceData = {}

if (filesystem.exists(sourceFile) == false or filesystem.isDirectory(sourceFile) == false) then
  print("--------------------------------------")
  print("-- XAF Package Manager - Controller --")
  print("--------------------------------------")
  print("  >> Cannot find package with entered name")
  print("  >> Install it via 'xaf-pm package [-a | -add]'")
  print("  >> Or use 'xaf-pm package [-l | --list]' for available package list")

  os.exit()
end

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
    options.p = nil
    options.pass = nil

    return xafcoreExecutor:runExternal(indexPath, arguments, options)
  else
    return xafcoreExecutor:runExternal(indexPath)
  end
end
