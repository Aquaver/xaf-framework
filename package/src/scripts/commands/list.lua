-- Extensible Application Framework controller command list.
-- It will be printed after using 'xaf list' command.
-- Every new command added to XAF in next updates will be also added here.

local arguments, options = ...
local listPage = tonumber(table.remove(arguments, 1))
local listTable = {}
local maxListPages = 1

if (options.h == true or options.help == true) then
  print("-----------------------------------------------")
  print("-- Extensible Application Framework - Manual --")
  print("-----------------------------------------------")
  print("  >> NAME")
  print("    >> xaf list - XAF built-in command for printing available command list")
  print()
  print("  >> SYNOPSIS")
  print("    >> xaf list")
  print("    >> xaf list [-h | --help]")
  print()
  print("  >> DESCRIPTION")
  print("    >> This command is mainly used for getting more information about commands and keywords which allows controlling and managing the XAF package.")

  os.exit()
end

if (listPage == nil) then
  listPage = 1
else
  if (listPage > maxListPages) then
    listPage = maxListPages
  elseif (listPage < 1) then
    listPage = 1
  else
    listPage = math.floor(listPage)
  end
end

print("---------------------------------------------------")
print("-- Extensible Application Framework - Controller --")
print("---------------------------------------------------")
print("  >> XAF controller command list, printed page " .. listPage .. " from " .. maxListPages .. " pages")
print("  >> Use command with '-h' or '--help' option for its manual")

listTable[1] = {
  "    >> xaf check - Tries to check for potential updates.",
  "    >> xaf init - Initializes XAF package API. Always use before other commands.",
  "    >> xaf list - Prints this command list.",
  "    >> xaf release - Retrieves XAF release data and prints it.",
  "    >> xaf remove - Uninstalls the XAF package with its API and configuration.",
  "    >> xaf update - Downloads XAF package in specified version and automatically installs it."
}

for key, value in ipairs(listTable[listPage]) do
  print(value)
end
