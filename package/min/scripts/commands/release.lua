local a,b=...local c=table.remove(a,1)local d=require("component")local e=require("xaf/utility/httpstream")local f=require("xaf/utility/jsonparser")local g=require("xaf/core/xafcore")local h=g:getMathInstance()local i=d.getPrimary("gpu")local j,k=i.getResolution()if b.h==true or b.help==true then print("-----------------------------------------------")print("-- Extensible Application Framework - Manual --")print("-----------------------------------------------")print("  >> NAME")print("    >> xaf release - XAF release information program")print()print("  >> SYNOPSIS")print("    >> xaf release")print("    >> xaf release [-h | --help]")print("    >> xaf release [-i | --info] <version>")print("    >> xaf release [-l | --list] [page]")print()print("  >> DESCRIPTION")print("    >> This program lets the user listing all current XAF releases and retrieving information about specified release version.")os.exit()end;if b.i==nil and b.info==nil and b.l==nil and b.list==nil then print("---------------------------------------------------")print("-- Extensible Application Framework - Controller --")print("---------------------------------------------------")print("  >> Release data retrieving program")print("  >> Use 'xaf release [-h | --help]' for command manual")os.exit()end;if d.isAvailable("internet")==false then print("---------------------------------------------------")print("-- Extensible Application Framework - Controller --")print("---------------------------------------------------")print("  >> Internet card component is not available")print("  >> Release data retrieving procedure cannot be continued")os.exit()else print("---------------------------------------------------")print("-- Extensible Application Framework - Controller --")print("---------------------------------------------------")print("  >> Internet card component found")print("  >> Trying to connect to project repository...")end;local l="https://api.github.com/repos/Aquaver/xaf-framework/"local m="releases"local n="tags"local o="?per_page=10&page="..tostring(c)local p=nil;local q=d.getPrimary("internet")local r=nil;if b.i==true or b.info==true then p=l..m..'/'..n..'/'..tostring(c)r=e:new(q,p)if c==nil then print("    >> Empty XAF version identifier")print("    >> Use correct 'xaf release [-i | --info]' with correct release tag")print("    >> Use 'xaf release [-h | --help] for command manual'")os.exit()end;if r:connect()==true then local s=''local t=nil;local u={}for v in r:getData()do s=s..v end;r:disconnect()t=f:new()u=t:parse(s)print("    >> Retrieved release data from version: "..c)print("      >> Release name: "..u["name"])print("      >> Release tag: "..u["tag_name"])print("      >> Release author: "..u["author"]["login"])print("      >> Release downloads: "..u["assets"][1]["download_count"])print("      >> Release installer size: "..string.format("%.2f",tonumber(u["assets"][1]["size"])/1024).." kB")print(string.rep('-',j))print(u["body"])else print("    >> Cannot connect to project repository")print("    >> Ensure the release identifier ("..c..") is correct")print("    >> Try running 'xaf release' again")end elseif b.l==true or b.list==true then p=l..m..o;r=e:new(q,p)if c==nil then c=1 elseif tonumber(c)==nil then print("    >> Invalid release list index, must be natural number")print("    >> Try running 'xaf release' again with correct index")os.exit()elseif h:checkNatural(tonumber(c),true)==false then print("    >> Invalid release list index, must be natural number")print("    >> Try running 'xaf release' again with correct index")os.exit()end;if r:connect()==true then local s=''local t=nil;local u={}local w=0;for v in r:getData()do s=s..v end;r:disconnect()t=f:new()u=t:parse(s)w=#u;for x=1,w do print("      >> Release: "..u[x]["tag_name"].." - "..u[x]["name"].." ("..u[x]["assets"][1]["download_count"]..')')if x==w and u[x]["tag_name"]~="1.0.0"then print()print("        >> Use 'xaf release [-l | --list] "..tonumber(c)+1 .."' for older releases")end end else print("    >> Cannot connect to project repository")print("    >> Try running 'xaf release' again")end end