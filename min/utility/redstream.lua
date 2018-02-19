local a={C_NAME="Generic Redstone Stream",C_INSTANCE=true,C_INHERIT=true,static={MODE_DEFAULT=0,MODE_ANALOG=1,MODE_DIGITAL=2}}function a:initialize()local b=nil;local c=b and b.private or{}local d=b and b.public or{}c.componentRedstone=nil;c.bundleColor=-1;c.streamMode=0;c.streamSide=-1;c.tableColors={["white"]=0,["orange"]=1,["magenta"]=2,["light_blue"]=3,["yellow"]=4,["lime"]=5,["pink"]=6,["gray"]=7,["light_gray"]=8,["cyan"]=9,["purple"]=10,["blue"]=11,["brown"]=12,["green"]=13,["red"]=14,["black"]=15}c.tableSides={["bottom"]=0,["top"]=1,["back"]=2,["north"]=2,["front"]=3,["south"]=3,["right"]=4,["west"]=4,["left"]=5,["east"]=5}d.getBundleColor=function(self)if c.streamMode==2 then return c.bundleColor else error("[XAF Error] Bundle colors available in digital mode only")end end;d.getComponent=function(self)return c.componentRedstone end;d.getInput=function(self)if c.componentRedstone then local e=c.bundleColor;local f=c.streamSide;if f>-1 then if c.streamMode==0 or c.streamMode==1 then return c.componentRedstone.getInput(f)elseif c.streamMode==2 then if e>-1 then return c.componentRedstone.getBundledInput(f,e)else error("[XAF Error] Bundle color has not been initialized")end else error("[XAF Error] Invalid redstone stream mode")end else error("[XAF Error] Stream side has not been initialized")end else error("[XAF Error] Redstone component has not been initialized")end end;d.getOutput=function(self)if c.componentRedstone then local e=c.bundleColor;local f=c.streamSide;if f>-1 then if c.streamMode==0 or c.streamMode==1 then return c.componentRedstone.getOutput(f)elseif c.streamMode==2 then if e>-1 then return c.componentRedstone.getBundledOutput(f,e)else error("[XAF Error] Bundle color has not been initialized")end else error("[XAF Error] Invalid redstone stream mode")end else error("[XAF Error] Stream side has not been initialized")end else error("[XAF Error] Redstone component has not been initialized")end end;d.getStreamMode=function(self)return c.streamMode end;d.getStreamSide=function(self)return c.streamSide end;d.off=function(self)if c.componentRedstone then local e=c.bundleColor;local f=c.streamSide;if f>-1 then if c.streamMode==0 or c.streamMode==1 then c.componentRedstone.setOutput(f,0)elseif c.streamMode==2 then if e>-1 then c.componentRedstone.setBundledOutput(f,e,0)else error("[XAF Error] Bundle color has not been initialized")end else error("[XAF Error] Invalid redstone stream mode")end else error("[XAF Error] Stream side has not been initialized")end else error("[XAF Error] Redstone component has not been initialized")end;return true end;d.on=function(self,g)local h=c.componentRedstone;local i=type(g)=="number"and g or 255;if h then local e=c.bundleColor;local f=c.streamSide;if f>-1 then if c.streamMode==0 or c.streamMode==1 then h.setOutput(f,i)elseif c.streamMode==2 then if e>-1 then h.setBundledOutput(f,e,i)else error("[XAF Error] Bundle color has not been initialized")end else error("[XAF Error] Invalid redstone stream mode")end else error("[XAF Error] Stream side has not been initialized")end else error("[XAF Error] Redstone component has not been initialized")end;return true end;d.setBundleColor=function(self,e)assert(type(e)=="string","[XAF Utility] Expected STRING as argument #1")if c.streamMode==2 then if c.tableColors[e]then c.bundleColor=c.tableColors[e]else error("[XAF Error] Invalid color value")end else error("[XAF Error] Bundle colors available in digital mode only")end;return true end;d.setComponent=function(self,j)assert(type(j)=="table","[XAF Utility] Expected TABLE as argument #1")if j.type=="redstone"then c.componentRedstone=j else error("[XAF Error] Invalid redstone component")end;return true end;d.setStreamSide=function(self,f)assert(type(f)=="string","[XAF Utility] Expected STRING as argument #1")if c.tableSides[f]then c.streamSide=c.tableSides[f]else error("[XAF Error] Invalid side value")end;return true end;return{private=c,public=d}end;function a:extend()local k=self:initialize()local c=k.private;local d=k.public;if self.C_INHERIT==true then return{private=c,public=d}else error("[XAF Error] Class '"..tostring(self.C_NAME).."' cannot be inherited")end end;function a:new(j,l)local k=self:initialize()local c=k.private;local d=k.public;d:setComponent(j)assert(type(l)=="number","[XAF Utility] Expected NUMBER as argument #2")if l>=0 and l<=2 then c.streamMode=l else error("[XAF Error] Invalid redstone stream mode")end;if self.C_INSTANCE==true then return d else error("[XAF Error] Class '"..tostring(self.C_NAME).."' cannot be instanced")end end;return a
