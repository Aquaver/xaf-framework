local a,b=...local c=require("filesystem")local d=_G._XAF;local e="aquaver.github.io"local f="xaf-framework"if b.h==true or b.help==true then print("-----------------------------------------------")print("-- Extensible Application Framework - Manual --")print("-----------------------------------------------")print("  >> NAME")print("    >> xaf init - Command used for package API initialization")print()print("  >> SYNOPSIS")print("    >> xaf init")print("    >> xaf init [-h | --help]")print()print("  >> DESCRIPTION")print("    >> Activates initialization procedure which allows using entire XAF interface and loads all required elements to _XAF global table.")os.exit()end;if d then print("---------------------------------------------------")print("-- Extensible Application Framework - Controller --")print("---------------------------------------------------")print("  >> XAF interface is already initialized")print("  >> You could use 'xaf list' - for available command list")else local g=c.concat(e,f)local h=g.."/?.lua"local i=';/'..h;package.path=package.path..i;_G._XAF={}_G._XAF._APPDATA={}_G._XAF._VERSION="1.0.1"print("---------------------------------------------------")print("-- Extensible Application Framework - Controller --")print("---------------------------------------------------")print("  >> XAF has been initialized successfully and it is ready to use...")print("  >> You can now use 'xaf list' - for available command list")end
