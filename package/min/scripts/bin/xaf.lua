local a=require("filesystem")local b=require("shell")local c,d=b.parse(...)local e=table.remove(c,1)local f=_G._XAF;local g=f and f._VERSION or''if e then local h="io.github.aquaver"local i="xaf-framework"local j="scripts"if e=="init"then if a.exists(a.concat(h,i,j,e..".lua"))then local k=a.open(a.concat(h,i,j,e..".lua"),'r')local l=nil;local m=''local n=k:read(math.huge)while n do m=m..n;n=k:read(math.huge)end;k:close()l=load(m)l(c,d)else print("---------------------------------------------------")print("-- Extensible Application Framework - Controller --")print("---------------------------------------------------")print("  >> Cannot find XAF initialization script")print("  >> Try installing entire package again or download the script manually")end else if f then if a.exists(a.concat(h,i,j,e..".lua"))==true then local o=a.open(a.concat(h,i,j,e..".lua"),'r')local p=nil;local q=''local r=o:read(math.huge)local s={}while r do q=q..r;r=o:read(math.huge)end;o:close()p=load(q)s={p(c,d)}return table.unpack(s)else print("---------------------------------------------------")print("-- Extensible Application Framework - Controller --")print("---------------------------------------------------")print("  >> Cannot find following command 'xaf "..e.."'")print("  >> Use 'xaf list' - for available command list")end else print("---------------------------------------------------")print("-- Extensible Application Framework - Controller --")print("---------------------------------------------------")print("  >> Cannot execute following command 'xaf "..e.."'")print("  >> Please initialize the API first using 'xaf init'")end end else if f then print("---------------------------------------------------")print("-- Extensible Application Framework - Controller --")print("---------------------------------------------------")print("  >> XAF has been initialized successfully and it is ready to use...")print("  >> Package global API version: "..g)print("  >> Use 'xaf list' - for available command list")else print("---------------------------------------------------")print("-- Extensible Application Framework - Controller --")print("---------------------------------------------------")print("  >> XAF has not been initialized yet...")print("  >> Use 'xaf init' - to initialize the API")end end
