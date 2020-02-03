local a=require("xaf/core/xafcore")local b=a:getMathInstance()local c={C_NAME="Generic Redstone Stream",C_INSTANCE=true,C_INHERIT=true,static={MODE_DEFAULT=0,MODE_ANALOG=1,MODE_DIGITAL=2}}function c:initialize()local d=nil;local e=d and d.private or{}local f=d and d.public or{}e.componentRedstone=nil;e.bundleColor=-1;e.streamMode=0;e.streamSide=-1;e.tableColors={["white"]=0,["orange"]=1,["magenta"]=2,["light_blue"]=3,["yellow"]=4,["lime"]=5,["pink"]=6,["gray"]=7,["light_gray"]=8,["cyan"]=9,["purple"]=10,["blue"]=11,["brown"]=12,["green"]=13,["red"]=14,["black"]=15}e.tableSides={["bottom"]=0,["top"]=1,["back"]=2,["north"]=2,["front"]=3,["south"]=3,["right"]=4,["west"]=4,["left"]=5,["east"]=5}f.getBundleColor=function(self)if e.streamMode==2 then return e.bundleColor else error("[XAF Error] Bundle colors available in digital mode only")end end;f.getComponent=function(self)return e.componentRedstone end;f.getInput=function(self)if e.componentRedstone then local g=e.bundleColor;local h=e.streamSide;if h>-1 then if e.streamMode==0 or e.streamMode==1 then return e.componentRedstone.getInput(h)elseif e.streamMode==2 then if g>-1 then return e.componentRedstone.getBundledInput(h,g)else error("[XAF Error] Bundle color has not been initialized")end else error("[XAF Error] Invalid redstone stream mode")end else error("[XAF Error] Stream side has not been initialized")end else error("[XAF Error] Redstone component has not been initialized")end end;f.getOutput=function(self)if e.componentRedstone then local g=e.bundleColor;local h=e.streamSide;if h>-1 then if e.streamMode==0 or e.streamMode==1 then return e.componentRedstone.getOutput(h)elseif e.streamMode==2 then if g>-1 then return e.componentRedstone.getBundledOutput(h,g)else error("[XAF Error] Bundle color has not been initialized")end else error("[XAF Error] Invalid redstone stream mode")end else error("[XAF Error] Stream side has not been initialized")end else error("[XAF Error] Redstone component has not been initialized")end end;f.getStreamMode=function(self)return e.streamMode end;f.getStreamSide=function(self)return e.streamSide end;f.off=function(self)if e.componentRedstone then local g=e.bundleColor;local h=e.streamSide;if h>-1 then if e.streamMode==0 or e.streamMode==1 then e.componentRedstone.setOutput(h,0)elseif e.streamMode==2 then if g>-1 then e.componentRedstone.setBundledOutput(h,g,0)else error("[XAF Error] Bundle color has not been initialized")end else error("[XAF Error] Invalid redstone stream mode")end else error("[XAF Error] Stream side has not been initialized")end else error("[XAF Error] Redstone component has not been initialized")end;return true end;f.on=function(self,i)local j=e.componentRedstone;local k=type(i)=="number"and i or 0;local l=0;if e.streamMode==0 or e.streamMode==1 then if i==nil then l=15 elseif k>=0 and k<=15 and b:checkInteger(k)==true then l=k else error("[XAF Error] Invalid analog power value - must be integer from 0 to 15")end elseif e.streamMode==2 then if i==nil then l=255 elseif k>=0 and k<=255 and b:checkInteger(k)==true then l=k else error("[XAF Error] Invalid digital power value - must be integer from 0 to 255")end else error("[XAF Error] Invalid redstone stream mode")end;if j then local g=e.bundleColor;local h=e.streamSide;if h>-1 then if e.streamMode==0 or e.streamMode==1 then j.setOutput(h,l)elseif e.streamMode==2 then if g>-1 then j.setBundledOutput(h,g,l)else error("[XAF Error] Bundle color has not been initialized")end else error("[XAF Error] Invalid redstone stream mode")end else error("[XAF Error] Stream side has not been initialized")end else error("[XAF Error] Redstone component has not been initialized")end;return true end;f.setBundleColor=function(self,g)assert(type(g)=="string","[XAF Utility] Expected STRING as argument #1")if e.streamMode==2 then if e.tableColors[g]then e.bundleColor=e.tableColors[g]else error("[XAF Error] Invalid color value")end else error("[XAF Error] Bundle colors available in digital mode only")end;return true end;f.setComponent=function(self,m)assert(type(m)=="table","[XAF Utility] Expected TABLE as argument #1")if m.type=="redstone"then e.componentRedstone=m else error("[XAF Error] Invalid redstone component")end;return true end;f.setStreamSide=function(self,h)assert(type(h)=="string","[XAF Utility] Expected STRING as argument #1")if e.tableSides[h]then e.streamSide=e.tableSides[h]else error("[XAF Error] Invalid side value")end;return true end;return{private=e,public=f}end;function c:extend()local n=self:initialize()local e=n.private;local f=n.public;if self.C_INHERIT==true then return{private=e,public=f}else error("[XAF Error] Class '"..tostring(self.C_NAME).."' cannot be inherited")end end;function c:new(m,o)local n=self:initialize()local e=n.private;local f=n.public;f:setComponent(m)assert(type(o)=="number","[XAF Utility] Expected NUMBER as argument #2")if o>=0 and o<=2 and b:checkInteger(o)==true then e.streamMode=o else error("[XAF Error] Invalid redstone stream mode")end;if self.C_INSTANCE==true then return f else error("[XAF Error] Class '"..tostring(self.C_NAME).."' cannot be instanced")end end;return c
