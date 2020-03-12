local a=require("xaf/graphic/component")local b=require("computer")local c=require("unicode")local d={C_NAME="Generic GUI Button",C_INSTANCE=true,C_INHERIT=true,static={THRESHOLD_DEFAULT=0.25,THRESHOLD_SLOW=0.5,THRESHOLD_NORMAL=0.25,THRESHOLD_FAST=0.1}}function d:initialize()local e=a:extend()local f=e and e.private or{}local g=e and e.public or{}f.doubleClickThreshold=d.static.THRESHOLD_DEFAULT;f.eventClick=nil;f.eventClickArguments={}f.eventDoubleClick=nil;f.eventDoubleClickArguments={}f.labelTable={}f.lastClickTime=-math.huge;g.getDoubleClickThreshold=function(self)return f.doubleClickThreshold end;g.getLabel=function(self)return table.unpack(f.labelTable)end;g.register=function(self,h)assert(type(h)=="table","[XAF Graphic] Expected TABLE as argument #1")if f.active==true then if h[1]=="touch"then local i=h[2]if i==f.renderer.getScreen()then local j=h[3]local k=h[4]local l=f.renderMode;local m=0;local n=0;local o=0;local p=0;if l<=a.static.RENDER_ALL then m=f.positionX;n=f.positionY;o=f.positionX+f.totalWidth-1;p=f.positionY+f.totalHeight-1 elseif l<=a.static.RENDER_INSETS then m=f.positionX+1;n=f.positionY+1;o=f.positionX+f.totalWidth-2;p=f.positionY+f.totalHeight-2 elseif l<=a.static.RENDER_CONTENT then m=f.positionX+2;n=f.positionY+1;o=f.positionX+f.totalWidth-3;p=f.positionY+f.totalHeight-2 end;if j>=m and j<=o and(k>=n and k<=p)then local q=b.uptime()local r=f.lastClickTime;f.lastClickTime=q;if q-r>f.doubleClickThreshold then local h=f.eventClick;local s=f.eventClickArguments;if h then return h(table.unpack(s))end else local h=f.eventDoubleClick;local s=f.eventDoubleClickArguments;if h then return h(table.unpack(s))end end end end end end end;g.setDoubleClickThreshold=function(self,t)assert(type(t)=="number","[XAF Graphic] Expected NUMBER as argument #1")f.doubleClickThreshold=t;return true end;g.setLabel=function(self,...)local u={...}local v=0;local w=0;for x,y in ipairs(u)do local z=u[x]local A=z==nil and 0 or c.wlen(tostring(z))f.labelTable[x]=z==nil and''or tostring(z)w=A>w and A or w;v=v+1 end;f.totalWidth=w+4;f.totalHeight=v+2;return true end;g.setOnClick=function(self,B,...)assert(type(B)=="function","[XAF Graphic] Expected FUNCTION as argument #1")local C=B;local D={...}f.eventClick=C;f.eventClickArguments=D;return true end;g.setOnDoubleClick=function(self,B,...)assert(type(B)=="function","[XAF Graphic] Expected FUNCTION as argument #1")local C=B;local D={...}f.eventDoubleClick=C;f.eventDoubleClickArguments=D;return true end;g.view=function(self)local E=f.renderer;if E then local F=f.labelTable;local G=f.totalWidth;local H=f.totalHeight;local I=f.positionX;local J=f.positionY;local K=E.getBackground()local L=E.getForeground()local l=f.renderMode;if l<=a.static.RENDER_ALL then E.setBackground(f.colorBackground)E.setForeground(f.colorBorder)E.fill(I,J,G-1,1,'─')E.fill(I,J+H-1,G-1,1,'─')E.fill(I,J,1,H-1,'│')E.fill(I+G-1,J,1,H-1,'│')E.set(I,J,'┌')E.set(I+G-1,J,'┐')E.set(I,J+H-1,'└')E.set(I+G-1,J+H-1,'┘')end;if l<=a.static.RENDER_INSETS then E.setBackground(f.colorBackground)E.fill(I+1,J+1,1,H-2,' ')E.fill(I+G-2,J+1,1,H-2,' ')end;if l<=a.static.RENDER_CONTENT then E.setBackground(f.colorBackground)E.setForeground(f.colorContent)E.fill(I+2,J+1,G-4,H-2,' ')for x,y in ipairs(F)do E.set(I+2,J+x,y)end end;E.setBackground(K)E.setForeground(L)return true else error("[XAF Error] Component GPU renderer has not been initialized")end end;return{private=f,public=g}end;function d:extend()local M=self:initialize()local f=M.private;local g=M.public;if self.C_INHERIT==true then return{private=f,public=g}else error("[XAF Error] Class '"..tostring(self.C_NAME).."' cannot be inherited")end end;function d:new(N,O)local M=self:initialize()local f=M.private;local g=M.public;g:setPosition(N,O)f.totalWidth=4;f.totalHeight=2;if self.C_INSTANCE==true then return g else error("[XAF Error] Class '"..tostring(self.C_NAME).."' cannot be instanced")end end;return d
