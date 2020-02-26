local a=require("xaf/graphic/component")local b=require("xaf/core/xafcore")local c=b:getMathInstance()local d={C_NAME="Generic GUI Slider",C_INSTANCE=true,C_INHERIT=true,static={ROTATE_DEFAULT=0,ROTATE_HORIZONTAL=1,ROTATE_VERTICAL=2}}function d:initialize()local e=a:extend()local f=e and e.private or{}local g=e and e.public or{}f.eventDrag=nil;f.eventDragArguments={}f.length=0;f.positionTable={}f.rotation=0;f.value=0;g.getValue=function(self)return f.value end;g.register=function(self,h)assert(type(h)=="table","[XAF Graphic] Expected TABLE as argument #1")if f.active==true then if h[1]=="drag"then local i=h[2]if i==f.renderer.getScreen()then local j=h[3]local k=h[4]local l=f.renderMode;local m=0;local n=0;local o=0;local p=0;if l<=a.static.RENDER_ALL then m=f.positionX;n=f.positionY;o=f.positionX+f.totalWidth-1;p=f.positionY+f.totalHeight-1 elseif l<=a.static.RENDER_INSETS then m=f.positionX+1;n=f.positionY+1;o=f.positionX+f.totalWidth-2;p=f.positionY+f.totalHeight-2 elseif l<=a.static.RENDER_CONTENT then m=f.positionX+2;n=f.positionY+1;o=f.positionX+f.totalWidth-3;p=f.positionY+f.totalHeight-2 end;if j>=m and j<=o and(k>=n and k<=p)then local q=tostring(j..':'..k)local r=f.positionTable;if r[q]then local h=f.eventDrag;local s=f.eventDragArguments;local t=f.renderer;if t then local u=f.positionX;local v=f.positionY;local w=t.getBackground()local x=t.getForeground()local y=(f.rotation==d.static.ROTATE_DEFAULT or f.rotation==d.static.ROTATE_HORIZONTAL)and'─'or'│'g:setRenderMode(a.static.RENDER_CONTENT)g:view()g:setRenderMode(l)t.setBackground(f.colorBackground)t.setForeground(f.colorContent)if f.rotation==d.static.ROTATE_DEFAULT or f.rotation==d.static.ROTATE_HORIZONTAL then f.value=r[q]t.set(u+3,v+1,y)t.set(j,k,'█')else f.value=r[q]t.set(u+2,v+2,y)t.set(j,k,'█')end;t.setBackground(w)t.setForeground(x)end;if h then return h(table.unpack(s))end end end end end end end;g.setOnDrag=function(self,z,...)assert(type(z)=="function","[XAF Graphic] Expected FUNCTION as argument #1")local A=z;local B={...}f.eventDrag=A;f.eventDragArguments=B;return true end;g.setValues=function(self,C,D,E)assert(type(C)=="number","[XAF Graphic] Expected NUMBER as argument #1")assert(type(D)=="number","[XAF Graphic] Expected NUMBER as argument #2")assert(type(E)=="number","[XAF Graphic] Expected NUMBER as argument #3")local F=C;local G=D;local H=0;local I=E;local J=f.length;local u=f.positionX;local v=f.positionY;if c:checkNatural(E,true)==true then I=E else error("[XAF Error] Invalid slider bar incremental number - must be a positive integer")end;if f.rotation==d.static.ROTATE_DEFAULT or f.rotation==d.static.ROTATE_HORIZONTAL then for K=u+3,u+J+2,I do local L=tostring(K..':'..v+1)local M=F+G*H;f.positionTable[L]=M;H=H+1 end else for K=v+2,v+J+1,I do local L=tostring(u+2 ..':'..K)local M=F+G*H;f.positionTable[L]=M;H=H+1 end end;return true end;g.view=function(self)local t=f.renderer;if t then local N=f.totalWidth;local O=f.totalHeight;local P=f.length;local u=f.positionX;local v=f.positionY;local w=t.getBackground()local x=t.getForeground()local l=f.renderMode;if l<=a.static.RENDER_ALL then t.setBackground(f.colorBackground)t.setForeground(f.colorBorder)t.fill(u,v,N-1,1,'─')t.fill(u,v+O-1,N-1,1,'─')t.fill(u,v,1,O-1,'│')t.fill(u+N-1,v,1,O-1,'│')t.set(u,v,'┌')t.set(u+N-1,v,'┐')t.set(u,v+O-1,'└')t.set(u+N-1,v+O-1,'┘')end;if l<=a.static.RENDER_INSETS then t.setBackground(f.colorBackground)t.fill(u+1,v+1,1,O-2,' ')t.fill(u+N-2,v+1,1,O-2,' ')end;if l<=a.static.RENDER_CONTENT then t.setBackground(f.colorBackground)t.setForeground(f.colorContent)if f.rotation==d.static.ROTATE_DEFAULT or f.rotation==d.static.ROTATE_HORIZONTAL then t.fill(u+3,v+1,P,1,'─')t.set(u+2,v+1,'├')t.set(u+P+3,v+1,'┤')t.set(u+3,v+1,'█')else t.fill(u+2,v+2,1,P,'│')t.set(u+2,v+1,'┬')t.set(u+2,v+P+2,'┴')t.set(u+2,v+2,'█')end end;t.setBackground(w)t.setForeground(x)return true else error("[XAF Error] Component GPU renderer has not been initialized")end end;return{private=f,public=g}end;function d:extend()local Q=self:initialize()local f=Q.private;local g=Q.public;if self.C_INHERIT==true then return{private=f,public=g}else error("[XAF Error] Class '"..tostring(self.C_NAME).."' cannot be inherited")end end;function d:new(R,S,T,U)local Q=self:initialize()local f=Q.private;local g=Q.public;g:setPosition(R,S)assert(type(T)=="number","[XAF Graphic] Expected NUMBER as argument #3")if c:checkNatural(T,true)==true then f.length=T else error("[XAF Error] Invalid slider length number - must be a positive integer")end;assert(type(U)=="number","[XAF Graphic] Expected NUMBER as argument #4")if c:checkInteger(U)==true and(U>=d.static.ROTATE_DEFAULT and U<=d.static.ROTATE_VERTICAL)then f.rotation=U else error("[XAF Error] Invalid slider rotation mode")end;f.totalWidth=(U==d.static.ROTATE_DEFAULT or U==d.static.ROTATE_HORIZONTAL)and T+6 or 5;f.totalHeight=(U==d.static.ROTATE_DEFAULT or U==d.static.ROTATE_HORIZONTAL)and 3 or T+4;if self.C_INSTANCE==true then return g else error("[XAF Error] Class '"..tostring(self.C_NAME).."' cannot be instanced")end end;return d
