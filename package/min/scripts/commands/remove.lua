local a,b=...local c=require("computer")local d=require("event")local e=require("filesystem")if b.h==true or b.help==true then print("-----------------------------------------------")print("-- Extensible Application Framework - Manual --")print("-----------------------------------------------")print("  >> NAME")print("    >> xaf remove - Program for XAF package removal and uninstallation")print()print("  >> SYNOPSIS")print("    >> xaf remove")print("    >> xaf remove [-h | --help]")print()print("  >> DESCRIPTION")print("    >> This script is used for complete uninstallation of XAF package and configuration removal. Automatically reboots the computer after successful uninstallation process. That program will not delete user's created applications based on XAF and its API.")os.exit()end;print("---------------------------------------------------")print("-- Extensible Application Framework - Controller --")print("---------------------------------------------------")print("  >> Starting XAF uninstallation procedure...")print("  >> Hit 'Y' to confirm or 'N' to abort this process")print("  >> Warning! This program will remove XAF completely!")while true do local f={d.pull("key_down")}if f[3]==89 then print("  >> Continuing deinstallation process...")break elseif f[3]==78 then print("  >> Deinstallation process has been interrupted")os.exit()end end;local g="aquaver.github.io"local h="xaf-framework"local i="bin"local j="xaf.lua"if e.remove(e.concat(g,h))==true then print("    >> XAF project directory has been removed")end;if e.remove(e.concat(i,j))==true then print("    >> XAF controller script has been removed")end;if _G._XAF then _G._XAF=nil;print("    >> XAF configuration table has been cleared")end;print("      >> Deinstallation procedure has been finished")print("      >> Rebooting computer in 5 seconds...")os.sleep(5)c.shutdown(true)
