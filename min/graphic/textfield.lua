local a=require("graphic/component")local b=require("unicode")local c={C_NAME="Generic GUI Text Field",C_INSTANCE=true,C_INHERIT=true,static={}}function c:initialize()local d=a:extend()local e=d and d.private or{}local f=d and d.public or{}e.colorSelected=0xFFFFFF;e.eventClick=nil;e.eventClickArguments={}e.eventKey=nil;e.eventKeyArguments={}e.eventPaste=nil;e.eventPasteArguments={}e.fieldFocus=false;e.selectedLine=0;e.textTable={}e.refreshLine=function(self,g)assert(type(g)=="number","[XAF Graphic] Expected NUMBER as argument #1")local h=e.positionX;local i=e.positionY;local j=e.columns;local k=e.rows;local l=g;local m=e.textTable;if l<=k then local n=e.renderer;if n then local o=n.getBackground()local p=n.getForeground()n.setBackground(e.colorBackground)n.setForeground(e.colorSelected)n.set(h+2,i+l,string.rep(' ',j))n.set(h+2,i+l,b.sub(m[l]..'|',1,j))n.setBackground(o)n.setForeground(p)else error("[XAF Error] Component GPU renderer has not been initialized")end else error("[XAF Error] Invalid text line number")end;return true end;f.clear=function(self)e.fieldFocus=false;f:setText({})f:view()return true end;f.getColorSelected=function(self)return e.colorSelected end;f.getText=function(self)return e.textTable end;f.register=function(self,q)assert(type(q)=="table","[XAF Graphic] Expected TABLE as argument #1")if e.active==true then if q[1]=="clipboard"then local r=e.eventPaste;local s=e.eventPasteArguments;if e.fieldFocus==true then local t=e.columns;local u=e.selectedLine;local v=q[3]local w=string.gsub(v,"[\n]+",' ')local x=e.textTable[u]local y=x==nil and''or tostring(x)local z=y..w;e.textTable[u]=b.sub(z,1,t)e:refreshLine(u)if r then return r(table.unpack(s))end end elseif q[1]=="key_down"then local A=e.eventKey;local B=e.eventKeyArguments;if e.fieldFocus==true then local C=q[3]local D=q[4]local E=e.renderMode;if D==28 or D==208 then if e.selectedLine<e.rows then e.selectedLine=e.selectedLine+1;f:setRenderMode(3)f:view()f:setRenderMode(E)end elseif D==200 then if e.selectedLine>1 then e.selectedLine=e.selectedLine-1;f:setRenderMode(3)f:view()f:setRenderMode(E)end else if C==8 then local u=e.selectedLine;local x=e.textTable[u]local y=x==nil and''or tostring(x)local z=b.sub(y,1,b.wlen(y)-1)e.textTable[u]=z;e:refreshLine(u)elseif C>=32 and C<=126 then local t=e.columns;local u=e.selectedLine;local x=e.textTable[u]local y=x==nil and''or tostring(x)local z=y..string.char(C)e.textTable[u]=b.sub(z,1,t)e:refreshLine(u)end end;if A then return A(table.unpack(B))end end elseif q[1]=="touch"then local F=e.eventClick;local G=e.eventClickArguments;local H=q[2]if H==e.renderer.getScreen()then local I=q[3]local J=q[4]local E=e.renderMode;local K=0;local L=0;local M=0;local N=0;if E<=3 then K=e.positionX+2;L=e.positionY+1;M=e.positionX+e.totalWidth-3;N=e.positionY+e.totalHeight-2 end;if I>=K and I<=M and(J>=L and J<=N)then local O=J;local P=O-e.positionY;e.fieldFocus=true;e.selectedLine=P;f:setRenderMode(3)f:view()f:setRenderMode(E)if F then return F(table.unpack(G))end else if e.fieldFocus==true then e.fieldFocus=false;e.selectedLine=0;f:setRenderMode(3)f:view()f:setRenderMode(E)end end end end end end;f.setColorSelected=function(self,Q)assert(type(Q)=="number","[XAF Graphic] Expected NUMBER as argument #1")if Q>=0 and Q<=0xFFFFFF then e.colorSelected=Q else error("[XAF Error] Invalid text field selection color number")end;return true end;f.setOnClick=function(self,R,...)assert(type(R)=="function","[XAF Graphic] Expected FUNCTION as argument #1")local q=R;local S={...}e.eventClick=q;e.eventClickArguments=S;return true end;f.setOnKey=function(self,R,...)assert(type(R)=="function","[XAF Graphic] Expected FUNCTION as argument #1")local q=R;local S={...}e.eventKey=q;e.eventKeyArguments=S;return true end;f.setOnPaste=function(self,R,...)assert(type(R)=="function","[XAF Graphic] Expected FUNCTION as argument #1")local q=R;local S={...}e.eventPaste=q;e.eventPasteArguments=S;return true end;f.setText=function(self,T)assert(type(T)=="table","[XAF Graphic] Expected TABLE as argument #1")local U=e.columns;local V=e.rows;local m={}e.selectedLine=0;e.textTable={}for W=1,V do local X=T[W]local g=X==nil and''or b.sub(tostring(X),1,U)table.insert(m,g)V=V+1 end;e.textTable=m;return true end;f.view=function(self)local n=e.renderer;if n then local Y=e.columns;local Z=e.rows;local _=e.totalWidth;local a0=e.totalHeight;local h=e.positionX;local i=e.positionY;local o=n.getBackground()local p=n.getForeground()local E=e.renderMode;if E<=1 then n.setBackground(e.colorBackground)n.setForeground(e.colorBorder)n.fill(h,i,_-1,1,'─')n.fill(h,i+a0-1,_-1,1,'─')n.fill(h,i,1,a0-1,'│')n.fill(h+_-1,i,1,a0-1,'│')n.set(h,i,'┌')n.set(h+_-1,i,'┐')n.set(h,i+a0-1,'└')n.set(h+_-1,i+a0-1,'┘')end;if E<=2 then n.setBackground(e.colorBackground)n.fill(h+1,i+1,1,Z,' ')n.fill(h+Y+2,i+1,1,Z,' ')end;if E<=3 then local V=e.columns;local m=e.textTable;n.setBackground(e.colorBackground)n.fill(h+2,i+1,Y,Z,' ')for W=1,V do local a1=e.selectedLine==W and e.colorSelected or e.colorContent;local X=m[W]local g=X==nil and''or tostring(X)if b.wlen(g)<Y and e.selectedLine==W then g=g..'|'end;n.setForeground(a1)n.set(h+2,i+W,g)end end;n.setBackground(o)n.setForeground(p)return true else error("[XAF Error] Component GPU renderer has not been initialized")end end;return{private=e,public=f}end;function c:extend()local a2=self:initialize()local e=a2.private;local f=a2.public;if self.C_INHERIT==true then return{private=e,public=f}else error("[XAF Error] Class '"..tostring(self.C_NAME).."' cannot be inherited")end end;function c:new(a3,a4,Y,Z)local a2=self:initialize()local e=a2.private;local f=a2.public;f:setPosition(a3,a4)assert(type(Y)=="number","[XAF Graphic] Expected NUMBER as argument #3")if math.floor(Y)==Y and math.ceil(Y)==Y and Y>0 then e.columns=Y;e.totalWidth=Y+4 else error("[XAF Error] Invalid columns number - must be a positive integer")end;assert(type(Z)=="number","[XAF Graphic] Expected NUMBER as argument #4")if math.floor(Z)==Z and math.ceil(Z)==Z and Z>0 then e.rows=Z;e.totalHeight=Z+2;f:setText({})else error("[XAF Error] Invalid rows number - must be a positive integer")end;if self.C_INSTANCE==true then return f else error("[XAF Error] Class '"..tostring(self.C_NAME).."' cannot be instanced")end end;return c