local a,b=...local c=require("filesystem")local d=require("xaf/core/xafcore")local e=d:getExecutorInstance()local f=d:getTableInstance()if b.h==true or b.help==true then print("----------------------------------")print("-- XAF Package Manager - Manual --")print("----------------------------------")print("  >> NAME")print("    >> xaf-pm run - Package program starting script")print()print("  >> SYNOPSIS")print("    >> xaf-pm run")print("    >> xaf-pm run <name>")print("    >> xaf-pm run [-h | --help]")print("    >> xaf-pm run [-p | --pass] <name> [arguments] [options]")print()print("  >> DESCRIPTION")print("    >> This program is generally used for PM add-on package starting, and passing optional arguments or flags to it.")os.exit()end;local g="io.github.aquaver"local h="xaf-packages"local i="_bin"local j="_config"local k="package.info"if a[1]==nil then print("--------------------------------------")print("-- XAF Package Manager - Controller --")print("--------------------------------------")print("  >> Invalid package name to execute (start)")print("  >> Use 'xaf-pm package [-l | --list]' for available package list")os.exit()end;local l=tostring(table.remove(a,1))local m=c.concat(g,h,l,j,k)local n={}if c.exists(m)==true then n=f:loadFromFile(m)else print("--------------------------------------")print("-- XAF Package Manager - Controller --")print("--------------------------------------")print("  >> Cannot find package configuration file")print("  >> This program cannot be executed")print("  >> Missing file name: "..k)os.exit()end;local o=n["package-xaf"]local p=_G._XAF;local q=p._VERSION;if q<o then print("--------------------------------------")print("-- XAF Package Manager - Controller --")print("--------------------------------------")print("  >> Installed XAF version does not support this package")print("  >> Required XAF: "..o.." (local XAF: "..q..')')print("  >> Please update the API on this computer via 'xaf update'")os.exit()end;local r=n["package-index"]local s=c.concat(g,h,l,i,r)if c.exists(s)==false then print("--------------------------------------")print("-- XAF Package Manager - Controller --")print("--------------------------------------")print("  >> Cannot find package index (starter) file")print("  >> Try removing and downloading this package again")print("  >> Missing file name: "..r)else if b.p==true or b.pass==true then b.p=nil;b.pass=nil;return e:runExternal(s,a,b)else return e:runExternal(s)end end
