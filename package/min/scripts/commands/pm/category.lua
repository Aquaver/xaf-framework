local a,b=...local c=require("component")local d=require("filesystem")local e=require("xaf/utility/httpstream")local f=require("xaf/utility/jsonparser")local g=require("xaf/core/xafcore")local h=g:getTableInstance()if b.h==true or b.help==true then print("----------------------------------")print("-- XAF Package Manager - Manual --")print("----------------------------------")print("  >> NAME")print("    >> xaf-pm category - Repository category viewer")print()print("  >> SYNOPSIS")print("    >> xaf-pm category")print("    >> xaf-pm category [-c | --content] <index> <name>")print("    >> xaf-pm category [-h | --help]")print("    >> xaf-pm category [-l | --list] <index>")print()print("  >> DESCRIPTION")print("    >> This command is mainly used to retrieve the XAF PM source repository category list, or get add-on list in specified category.")os.exit()end;if b.c==true or b.content==true or b.l==true or b.list==true then local i="aquaver.github.io"local j="xaf-framework"local k="data"local l="pm-source.info"local m=d.concat(i,j,k,l)local n={}if d.exists(m)==true then n=h:loadFromFile(m)else print("--------------------------------------")print("-- XAF Package Manager - Controller --")print("--------------------------------------")print("  >> Cannot find the source repositories list file")print("  >> Reinstall XAF package or download this file manually")print("  >> Missing file name: "..l)os.exit()end;if c.isAvailable("internet")==false then print("--------------------------------------")print("-- XAF Package Manager - Controller --")print("--------------------------------------")print("  >> Internet card component is not available")print("  >> Package Manager cannot connect to target repository")os.exit()else print("--------------------------------------")print("-- XAF Package Manager - Controller --")print("--------------------------------------")print("  >> Internet card component found")print("  >> Trying to connect to target repository")end;if b.c==true or b.content==true then local o=a[1]local p=0;local q=a[2]if tonumber(o)==nil and o~="default"then print("    >> Invalid repository index value")print("    >> This value must be natural number (of 'default')")print("    >> Use 'xaf-pm category [-c | --content]' again with proper index")os.exit()else p=tonumber(o)==nil and"default"or tonumber(o)end;if type(q)=="string"then if string.find(q,'/')then print("    >> Invalid repository category name")print("    >> Enter valid category name without '/' characters")os.exit()end else print("    >> Invalid repository category name - must not be empty")print("    >> Enter valid category name without '/' characters")os.exit()end;if n[p]==nil then print("    >> Repository with index '"..p.."' is not registered")print("    >> Register mote repositories using 'xaf-pm repository [-a | --add]'")else print("    >> Found repository with index: "..p)print("    >> Repository registered with this index: "..n[p])print("    >> Trying to retrieve category content list...")local r="https://api.github.com/repos/"local s="/git/trees/master"local t=r..n[p]..s;local u=c.getPrimary("internet")local v=e:new(u,t)if v:connect()==true then local w=0;local x=0;local y=''local z=nil;local A={}for B in v:getData()do y=y..B end;v:disconnect()z=f:new()A=z:parse(y)for C=1,#A["tree"]do if A["tree"][C]["path"]==q then t=A["tree"][C]["url"]v=e:new(u,t)if v:connect()==true then y=''A={}for B in v:getData()do y=y..B end;v:disconnect()A=z:parse(y)for C=1,#A["tree"]do local D=A["tree"][C]["path"]local E=A["tree"][C]["type"]if E=="tree"then local F="https://raw.githubusercontent.com/"local G="/master/"local H="/_config/package.info"t=F..n[p]..G..q..'/'..D..H;v=e:new(u,t)if v:connect()==true then print("      >> Object found: "..D.." (valid PM package)")w=w+1;x=x+1;v:disconnect()else print("      >> Object found: "..D.." (unknown item - missing configuration file)")x=x+1 end else print("      >> Object found: "..D.." (unknown object)")x=x+1 end end;print("    >> Valid XAF PM packages found: "..w)print("    >> Total (also unknown) objects found: "..x)os.exit()else print("      >> Cannot connect to category content package tree")print("      >> Ensure you have not lost internet access")end end end;print("      >> Cannot find the following category: "..q)print("      >> Ensure you have choosen right repository")print("      >> Try running 'xaf-pm category [-c | --content]' again with another parameters")else print("      >> Cannot connect to target repository")print("      >> Ensure you have not lost internet access")end end elseif b.l==true or b.list==true then local o=a[1]local p=0;if tonumber(o)==nil and o~="default"then print("    >> Invalid repository index value")print("    >> This value must be natural number (or 'default')")print("    >> Use 'xaf-pm category [-l | --list]' again with proper index")os.exit()else p=tonumber(o)==nil and"default"or tonumber(o)end;if n[p]==nil then print("    >> Repository with index '"..p.."' is not registered")print("    >> Register more repositories using 'xaf-pm repository [-a | -add]'")else print("    >> Found repository with index: "..p)print("    >> Repository registered with this index: "..n[p])print("    >> Trying to retrieve the category list...")local r="https://api.github.com/repos/"local s="/git/trees/master"local t=r..n[p]..s;local u=c.getPrimary("internet")local v=e:new(u,t)if v:connect()==true then local I=0;local y=''local z=nil;local A={}for B in v:getData()do y=y..B end;v:disconnect()z=f:new()A=z:parse(y)for C=1,#A["tree"]do local D=A["tree"][C]["path"]local E=A["tree"][C]["type"]if D~="_config"and E=="tree"then I=I+1;print("      >> Category found: "..D)end end;print("    >> Total categories found: "..I)else print("      >> Cannot connect to '"..n[p].."' repository")print("      >> Ensure you have not lost internet access")end end end;os.exit()end;print("--------------------------------------")print("-- XAF Package Manager - Controller --")print("--------------------------------------")print("  >> Package source repository category viewer")print("  >> Use 'xaf-pm category [-h | --help]' for command manual")
