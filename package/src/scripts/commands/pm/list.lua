-- Extensible Application Framework Package Manager controller command list.
-- This list does not have commands from XAF controller, only PM related commands.
-- Every subcommand option is standalone and needs to use flag to run itself.

local arguments, options = ...
local listPage = tonumber(table.remove(arguments, 1))
local listTable = {}
local maxListPages = 1

if (options.h == true or options.help == true) then
  print("----------------------------------")
  print("-- XAF Package Manager - Manual --")
  print("----------------------------------")
  print()
  print("  >> NAME")
  print("    >> xaf-pm list - Package Manager controller command list")
  print()
  print("  >> SYNOPSIS")
  print("    >> xaf-pm list")
  print("    >> xaf-pm list [page]")
  print("    >> xaf-pm list [-h | --help]")
  print()
  print("  >> DESCRIPTION")
  print("    >> This command prints information about all commands and keywords that allow controlling and managing the XAF Package Manager.")

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

print("--------------------------------------")
print("-- XAF Package Manager - Controller --")
print("--------------------------------------")
print("  >> XAF Package Manager controller command list, printed page " .. listPage .. " from " .. maxListPages .. " pages")
print("  >> Use command with '-h' or '--help' option for its manual")

listTable[1] = {
  "    >> xaf-pm category - Source repository category viewer.",
  "    >> xaf-pm list - Prints this command list.",
  "    >> xaf-pm package - Repository add-on packages manager.",
  "    >> xaf-pm repository - PM source repository managing program.",
  "    >> xaf-pm run - Package executing (starting) script."
}

for key, value in ipairs(listTable[listPage]) do
  print(value)
end
