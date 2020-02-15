local a=require("xaf/core/xafcore")local b=a:getMathInstance()local c={C_NAME="Abstract Graphic Component",C_INSTANCE=false,C_INHERIT=true,static={RENDER_DEFAULT=0,RENDER_ALL=1,RENDER_INSETS=2,RENDER_CONTENT=3}}function c:initialize()local d=nil;local e=d and d.private or{}local f=d and d.public or{}e.active=true;e.colorBackground=0x000000;e.colorBorder=0xFFFFFF;e.colorContent=0xFFFFFF;e.totalWidth=-1;e.totalHeight=-1;e.positionX=nil;e.positionY=nil;e.renderMode=c.static.RENDER_DEFAULT;e.renderer=nil;f.getActive=function(self)return e.active end;f.getColors=function(self)return e.colorBorder,e.colorBackground,e.colorContent end;f.getPosition=function(self)return e.positionX,e.positionY end;f.getRenderMode=function(self)return e.renderMode end;f.getRenderer=function(self)return e.renderer end;f.getTotalSize=function(self)return e.totalWidth,e.totalHeight end;f.setActive=function(self,g)assert(type(g)=="boolean","[XAF Graphic] Expected BOOLEAN as argument #1")e.active=g;return true end;f.setColors=function(self,h,i,j)assert(type(h)=="number","[XAF Graphic] Expected NUMBER as argument #1")assert(type(i)=="number","[XAF Graphic] Expected NUMBER as argument #2")assert(type(j)=="number","[XAF Graphic] Expected NUMBER as argument #3")if h<=0xFFFFFF and h>=0 then e.colorBorder=h else error("[XAF Error] Invalid component border color")end;if i<=0xFFFFFF and i>=0 then e.colorBackground=i else error("[XAF Error] Invalid component background color")end;if j<=0xFFFFFF and i>=0 then e.colorContent=j else error("[XAF Error] Invalid component content color")end;return true end;f.setPosition=function(self,k,l)assert(type(k)=="number","[XAF Graphic] Expected NUMBER as argument #1")assert(type(l)=="number","[XAF Graphic] Expected NUMBER as argument #2")if b:checkInteger(k)==true then e.positionX=k else error("[XAF Error] Invalid X position number - must be an integer")end;if b:checkInteger(l)==true then e.positionY=l else error("[XAF Error] Invalid Y position number - must be an integer")end;return true end;f.setRenderMode=function(self,m)assert(type(m)=="number","[XAF Graphic] Expected NUMBER as argument #1")if m>=c.static.RENDER_DEFAULT and m<=c.static.RENDER_CONTENT then e.renderMode=m else error("[XAF Error] Invalid component rendering mode")end;return true end;f.setRenderer=function(self,n)assert(type(n)=="table","[XAF Graphic] Expected TABLE as argument #1")if n.type=="gpu"then e.renderer=n else error("[XAF Error] Invalid GPU component")end;return true end;f.view=function(self)error("[XAF Error] Component rendering function has not been initialized - running default")end;return{private=e,public=f}end;function c:extend()local o=self:initialize()local e=o.private;local f=o.public;if self.C_INHERIT==true then return{private=e,public=f}else error("[XAF Error] Class '"..tostring(self.C_NAME).."' cannot be inherited")end end;function c:new()local o=self:initialize()local e=o.private;local f=o.public;if self.C_INSTANCE==true then return f else error("[XAF Error] Class '"..tostring(self.C_NAME).."' cannot be instanced")end end;return c
