local a,b=...local c=require("component")local d=require("event")local e=require("filesystem")local f=require("xaf/utility/httpstream")local g=require("xaf/utility/jsonparser")local h=require("unicode")local i=require("xaf/core/xafcore")local j=i:getMathInstance()local k=i:getTableInstance()local l=_G._XAF;local m=l and l._VERSION or''local n=c.getPrimary("gpu")local o,p=n.getResolution()if b.h==true or b.help==true then print("----------------------------------")print("-- XAF Package Manager - Manual --")print("----------------------------------")print("  >> NAME")print("    >> xaf-pm package - Add-on packages management program")print()print("  >> SYNOPSIS")print("    >> xaf-pm package")print("    >> xaf-pm package [-a | --add] <identifier> [-r | --readme]")print("    >> xaf-pm package [-h | --help]")print("    >> xaf-pm package [-i | --info] <identifier>")print("    >> xaf-pm package [-l | --list] [page]")print("    >> xaf-pm package [-r | --remove] <identifier>")print()print("  >> DESCRIPTION")print("    >> This script allows the user XAF PM add-on packages management, like installation, uninstallation and retrieving information about specific package.")os.exit()end;if b.l==true or b.list==true or b.r==true or b.remove==true then local q="io.github.aquaver"local r="xaf-packages"if b.l==true or b.list==true then local s=a[1]local t=0;local u=0;local v=1;local w=10;local x=e.concat(q,r)local y=0;local z=0;if s==nil then t=1 elseif tonumber(s)==nil then print("--------------------------------------")print("-- XAF Package Manager - Controller --")print("--------------------------------------")print("  >> Invalid package list index value")print("  >> This value must be natural number (or empty as 1)")print("  >> Use 'xaf-pm package [-l | --list]' again with proper index")os.exit()else if j:checkNatural(tonumber(s),true)==false then print("--------------------------------------")print("-- XAF Package Manager - Controller --")print("--------------------------------------")print("  >> Invalid package list index value")print("  >> This value must be natural number (or empty as 1)")print("  >> Use 'xaf-pm package [-l | --list]' again with proper index")os.exit()else t=tonumber(s)v=(t-1)*10+1;w=(t-1)*10+10 end end;if e.exists(x)==false then print("--------------------------------------")print("-- XAF Package Manager - Controller --")print("--------------------------------------")print("  >> Cannot list XAF PM packages")print("  >> Unable to find master PM directory")print("  >> Missing directory name: "..r)else print("--------------------------------------")print("-- XAF Package Manager - Controller --")print("--------------------------------------")print("  >> Master PM directory found")print("  >> Listing installed PM add-on packages...")for A in e.list(x)do u=u+1;if string.sub(A,-1,-1)=='/'then A=string.sub(A,1,-2)end;if u>=v and u<=w then if e.exists(e.concat(x,A,"_config","package.info"))==true then print("    >> ["..u.."] "..A.." (valid PM package)")y=y+1;z=z+1 else print("    >> ["..u.."] "..A.." (unknown item - missing configuration file)")z=z+1 end end;if u==w+1 then print("  >> More packages on 'xaf-pm package [-l | --list] "..t+1 .."'")break end end;print("  >> Valid XAF PM packages found: "..y)print("  >> Total (also unknown) objects found: "..z)end elseif b.r==true or b.remove==true then local B=a[1]local C=''if B==nil then print("--------------------------------------")print("-- XAF Package Manager - Controller --")print("--------------------------------------")print("  >> Invalid package name for removal")print("  >> Use 'xaf-pm package [-r | --remove]' again with proper package name")os.exit()else C=e.concat(q,r,tostring(B))end;if e.exists(C)==false then print("--------------------------------------")print("-- XAF Package Manager - Controller --")print("--------------------------------------")print("  >> Package with entered name does not exist")print("  >> Use 'xaf-pm package [-r | --remove]' again with proper package name")os.exit()end;e.remove(C)print("--------------------------------------")print("-- XAF Package Manager - Controller --")print("--------------------------------------")print("  >> Successfully removed following XAF PM package: "..B)print("  >> This program could no longer be started via PM controller")print("  >> Another package with that name can be installed now")end;os.exit()end;if b.a==true or b.add==true or b.i==true or b.info==true then local q="io.github.aquaver"local D="xaf-framework"local r="xaf-packages"local E="data"local F="pm-source.info"local G=''local H=e.concat(q,D,E,F)local I={}local J=0;if e.exists(H)==true then I=k:loadFromFile(H)else print("--------------------------------------")print("-- XAF Package Manager - Controller --")print("--------------------------------------")print("  >> Cannot find the source repositories list file")print("  >> Reinstall XAF package or download this file manually")print("  >> Missing file name: "..F)os.exit()end;if c.isAvailable("internet")==false then print("--------------------------------------")print("-- XAF Package Manager - Controller --")print("--------------------------------------")print("  >> Internet card component is not available")print("  >> Package Manager cannot connect to target repository")os.exit()else print("--------------------------------------")print("-- XAF Package Manager - Controller --")print("--------------------------------------")print("  >> Internet card component found")print("  >> Trying to connect to target repository...")end;if b.a==true or b.add==true then local K="pm-update.info"local L=e.concat(q,D,E,K)local M=nil;local N=a[1]local O=string.find(tostring(N),'/')local P=O and string.sub(tostring(N),1,O-1)local B=O and string.sub(tostring(N),O+1,-1)or''local Q=nil;if N==nil or O==nil then print("    >> Invalid package identifier, must not be empty")print("    >> Required format: categoryName/packageName")os.exit()else print("    >> Searching for following package: "..N)end;if e.exists(e.concat(q,r,B))==true then print("    >> Package with name '"..B.."' is already installed")print("    >> Remove it first with 'xaf-pm remove' before installing this one")print("    >> Installation procedure has been interrupted")os.exit()end;if e.exists(L)==true then M=k:loadFromFile(L)else print("--------------------------------------")print("-- XAF Package Manager - Controller --")print("--------------------------------------")print("  >> Cannot find the package source list file")print("  >> Reinstall XAF package or download this file manually")print("  >> Missing file name: "..K)os.exit()end;for R,S in k:sortByKey(I,false)do local T="https://api.github.com/repos/"local U="/git/trees/master"local V="?recursive=1"local W=false;print("    >> Checking repository: "..S)local X=T..S..U..V;local Y=c.getPrimary("internet")local Z=f:new(Y,X)Z:setMaxTimeout(0.5)if Z:connect()==true then local _=''local a0=nil;local a1={}for a2 in Z:getData()do _=_..a2 end;Z:disconnect()a0=g:new()a1=a0:parse(_)for a3=1,#a1["tree"]do if a1["tree"][a3]["path"]==N then W=true;print("      >> Package '"..N.."' found on repository: "..S)print("      >> Would you like to install it from this source?")print("      >> Hit 'Y' to confirm, or 'N' to skip this repository")while true do local a4={d.pull("key_down")}if a4[3]==89 then print("        >> Installation confirmed, continuing...")Q=S;G=a1["tree"][a3]["url"]X=a1["tree"][a3]["url"]Z=f:new(Y,X)Z:setMaxTimeout(0.5)if Z:connect()==true then _=''a1={}for a2 in Z:getData()do _=_..a2 end;Z:disconnect()a1=a0:parse(_)if#a1["tree"]==2 and a1["tree"][1]["path"]=="_bin"and a1["tree"][2]["path"]=="_config"or#a1["tree"]==3 and a1["tree"][1]["path"]=="README.md"and a1["tree"][2]["path"]=="_bin"and a1["tree"][3]["path"]=="_config"then local a5="https://raw.githubusercontent.com/"local a6="_config/repository.info"local a7="/master/"X=a5 ..S..a7 ..a6;Z=f:new(Y,X)Z:setMaxTimeout(0.5)if Z:connect()==true then local a8=''local a9={}for a2 in Z:getData()do a8=a8 ..a2 end;a9=k:loadFromString(a8)a8=''if m>a9["repository-xaf"]then local aa="https://raw.githubusercontent.com/"local ab="/_config/package.info"local ac="/master/"X=aa..S..ac..N..ab;Z=f:new(Y,X)Z:setMaxTimeout(0.5)if Z:connect()==true then local ad=''local ae={}for a2 in Z:getData()do ad=ad..a2 end;ae=k:loadFromString(ad)ad=''if ae["package-description"]and ae["package-identifier"]and ae["package-index"]and ae["package-owner"]and ae["package-title"]and ae["package-version"]and ae["package-xaf"]then if B==ae["package-identifier"]then if m>ae["package-xaf"]then print("        >> Installing package '"..N.."' from repository: "..S)print("        >> All prerequisites have been checked")print("        >> Starting installation procedure...")X=G..V;Z=f:new(Y,X)Z:setMaxTimeout(0.5)if Z:connect()==true then _=''a1={}for a2 in Z:getData()do _=_..a2 end;Z:disconnect()a1=a0:parse(_)for af=1,#a1["tree"]do local ag=a1["tree"][af]["path"]local ah=a1["tree"][af]["type"]local q="io.github.aquaver"local D="xaf-packages"if ag~="README.md"or ag=="README.md"and(b.r==true or b.readme==true)then if ah=="tree"then e.makeDirectory(e.concat(q,D,B,ag))elseif ah=="blob"then local ai=e.concat(q,D,B,ag)local aj=nil;local ak=-1;X=aa..S..ac..N..'/'..ag;Z=f:new(Y,X)Z:setMaxTimeout(0.5)print("          >> Trying to download: "..B..'/'..ag)if Z:connect()==true then aj=e.open(ai,'w')ak=0;for a2 in Z:getData()do aj:write(a2)ak=ak+h.wlen(a2)end;J=J+ak;aj:close()print("            >> Downloaded file: "..B..'/'..ag.." ("..string.format("%.2f",ak/1024).." kB)")else print("            >> Cannot download '"..B..'/'..ag.."' file")end end end end;local al=e.open(L,'w')local am=B;local an=Q..':'..P;al:write("[#] Extensible Application Framework Package Manager application source."..'\n')al:write("[#] This file stores specific packages source identifiers which are used in updating."..'\n')al:write("[#] Data represented in XAF Table Format."..'\n'..'\n')al:close()M[am]=an;k:saveToFile(M,L,true)print("              >> Successfully downloaded package '"..N.."' from repository: "..S)print("              >> Downloaded package total size: "..string.format("%.2f",J/1024).." kB")print("              >> Installation procedure has been finished")print("              >> You can now use 'xaf-pm run "..B.."' to start the program")os.exit()else print("          >> Cannot connect to package installation content tree")print("          >> Ensure you have not lost internet access")print("          >> Installation procedure has been interrupted")os.exit()end else print("        >> This package requires newer XAF version ("..ae["package-xaf"]..')')print("        >> Detected local API version: "..m)print("        >> Please update XAF via 'xaf update' before package installation")print("        >> Installation procedure has been interrupted")os.exit()end else print("        >> Package identifier mismatch detected")print("        >> Identifier from configuration file and package directory name must be equal")print("        >> This package cannot be installed")os.exit()end else print("        >> Invalid package description file detected")print("        >> If this message appears again, contact the package owner")print("        >> Installation procedure has been interrupted")os.exit()end else print("        >> Cannot retrieve package description file")print("        >> Ensure you have not lost internet access")print("        >> Installation procedure has been interrupted")os.exit()end else print("        >> Repository '"..S.."' forces requirement to have newer XAF version")print("        >> Detected local API version: "..m.." (required by repository is: "..a9["repository-xaf"]..')')print("        >> Please update XAF via 'xaf update' before installing from this repository")print("        >> Installation procedure has been interrupted")os.exit()end else print("        >> Cannot retrieve repository description file")print("        >> Ensure you have not lost internet access")print("        >> Installation procedure has been interrupted")os.exit()end else print("        >> Invalid XAF PM package structure")print("        >> Encountered unexpected files in package master directory")print("        >> This package cannot be installed")os.exit()end else print("        >> Cannot connect to package content tree...")print("        >> Ensure you have not lost internet access")print("        >> Installation procedure has been interrupted")os.exit()end elseif a4[3]==78 then print("        >> Skipped the following repository: "..S)break end end end end else print("      >> Cannot connect to '"..S.."' repository")print("      >> Ensure you have not lost internet access")os.exit()end;if W==false then print("      >> Cannot find package '"..N.."' on repository: "..S)end end elseif b.i==true or b.info==true then local N=a[1]local O=string.find(tostring(N),'/')local B=O and string.sub(tostring(N),O+1,-1)or''if N==nil or O==nil then print("    >> Invalid package identifier, must not be empty")print("    >> Required format: categoryName/packageName")os.exit()else print("    >> Searching for following package: "..N)end;for R,S in k:sortByKey(I,false)do local T="https://api.github.com/repos/"local U="/git/trees/master"local V="?recursive=1"print("    >> Checking repository: "..S)local X=T..S..U..V;local Y=c.getPrimary("internet")local Z=f:new(Y,X)Z:setMaxTimeout(0.5)if Z:connect()==true then local _=''local a0=nil;local a1={}for a2 in Z:getData()do _=_..a2 end;Z:disconnect()a0=g:new()a1=a0:parse(_)for a3=1,#a1["tree"]do if a1["tree"][a3]["path"]==N then X=a1["tree"][a3]["url"]Z=f:new(Y,X)Z:setMaxTimeout(0.5)if Z:connect()==true then _=''a1={}for a2 in Z:getData()do _=_..a2 end;Z:disconnect()a1=a0:parse(_)if#a1["tree"]==2 and a1["tree"][1]["path"]=="_bin"and a1["tree"][2]["path"]=="_config"or#a1["tree"]==3 and a1["tree"][1]["path"]=="README.md"and a1["tree"][2]["path"]=="_bin"and a1["tree"][3]["path"]=="_config"then local aa="https://raw.githubusercontent.com/"local ab="/_config/package.info"local ac="/master/"X=aa..S..ac..N..ab;Z=f:new(Y,X)Z:setMaxTimeout(0.5)if Z:connect()==true then local ad=''local ae={}for a2 in Z:getData()do ad=ad..a2 end;ae=k:loadFromString(ad)ad=''if ae["package-description"]and ae["package-identifier"]and ae["package-index"]and ae["package-owner"]and ae["package-title"]and ae["package-version"]and ae["package-xaf"]then if B==ae["package-identifier"]then print("      >> Successfully found information data of package: "..N)print("      >> This package exists on repository: "..S)print("        >> Package title: "..ae["package-title"])print("        >> Package owner: "..ae["package-owner"])print("        >> Package version: "..ae["package-version"])print("        >> Package required XAF version: "..ae["package-xaf"])print(string.rep('-',o))print(ae["package-description"])os.exit()else print("      >> Package identifier mismatch detected")print("      >> Identifier from configuration file and package directory name must be equal")print("      >> This package cannot be installed")os.exit()end else print("      >> Invalid package description file detected")print("      >> If this message appears again, contact the package owner")os.exit()end else print("      >> Cannot retrieve package description file")print("      >> Ensure you have not lost internet access")os.exit()end else print("      >> Invalid XAF PM package structure")print("      >> Encountered unexpected files in package master directory")print("      >> This package cannot be installed")os.exit()end else print("      >> Cannot connect to package content tree...")print("      >> Ensure you have not lost internet access")os.exit()end end end else print("      >> Cannot connect to '"..S.."' repository")print("      >> Ensure you have not lost internet access")os.exit()end;print("      >> Cannot find package '"..N.."' on repository: "..S)end end;os.exit()end;print("--------------------------------------")print("-- XAF Package Manager - Controller --")print("--------------------------------------")print("  >> Add-on package management program")print("  >> Use 'xaf-pm package [-h | --help]' for command manual")
