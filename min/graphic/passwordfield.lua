local a=require("xaf/graphic/component")local b=require("unicode")local c={C_NAME="Generic GUI Password Field",C_INSTANCE=true,C_INHERIT=true,static={}}function c:initialize()local d=a:extend()local e=d and d.private or{}local f=d and d.public or{}e.colorSelected=0xFFFFFF;e.eventClick=nil;e.eventClickArguments={}e.eventKey=nil;e.eventKeyArguments={}e.eventPaste=nil;e.eventPasteArguments={}e.fieldFocus=false;e.inputCharacter='*'e.inputValue=''e.showFlag=false;f.getColorSelected=function(self)return e.colorSelected end;f.getInput=function(self)return e.inputValue end;f.getMaskingCharacter=function(self)return e.inputCharacter end;f.getShowPassword=function(self)return e.showFlag end;f.register=function(self,g)assert(type(g)=="table","[XAF Graphic] Expected TABLE as argument #1")if e.active==true then if g[1]=="clipboard"then local h=e.eventPaste;local i=e.eventPasteArguments;if e.fieldFocus==true then local j=e.columns;local k=e.renderMode;local l=g[3]local m=string.gsub(l,"[\n]+",' ')local n=e.inputValue;local o=n==nil and''or tostring(n)local p=o..m;e.inputValue=b.sub(p,1,j)f:setRenderMode(3)f:view()f:setRenderMode(k)if h then return h(table.unpack(i))end end elseif g[1]=="key_down"then local q=e.eventKey;local r=e.eventKeyArguments;if e.fieldFocus==true then local s=g[3]local k=e.renderMode;if s==8 then local n=e.inputValue;local o=n==nil and''or tostring(n)local p=b.sub(o,1,b.wlen(o)-1)e.inputValue=p elseif s>=32 and s<=126 then local j=e.columns;local n=e.inputValue;local o=n==nil and''or tostring(n)local p=o..string.char(s)e.inputValue=b.sub(p,1,j)end;f:setRenderMode(3)f:view()f:setRenderMode(k)if q then return q(table.unpack(r))end end elseif g[1]=="touch"then local t=e.eventClick;local u=e.eventClickArguments;local v=g[2]if v==e.renderer.getScreen()then local w=g[3]local x=g[4]local k=e.renderMode;local y=0;local z=0;local A=0;local B=0;if k<=1 then y=e.positionX;z=e.positionY;A=e.positionX+e.totalWidth-1;B=e.positionY+e.totalHeight-1 elseif k<=2 then y=e.positionX+1;z=e.positionY+1;A=e.positionX+e.totalWidth-2;B=e.positionY+e.totalHeight-2 elseif k<=3 then y=e.positionX+2;z=e.positionY+1;A=e.positionX+e.totalWidth-3;B=e.positionY+e.totalHeight-2 end;if w>=y and w<=A and(x>=z and x<=B)then e.fieldFocus=true;f:setRenderMode(3)f:view()f:setRenderMode(k)if t then return t(table.unpack(u))end else if e.fieldFocus==true then e.fieldFocus=false;f:setRenderMode(3)f:view()f:setRenderMode(k)end end end end end end;f.setColorSelected=function(self,C)assert(type(C)=="number","[XAF Graphic] Expected NUMBER as argument #1")if C>=0 and C<=0xFFFFFF then e.colorSelected=C else error("[XAF Error] Invalid password field selection color number")end;return true end;f.setInput=function(self,m)assert(type(m)=="string","[XAF Graphic] Expected STRING as argument #1")local D=m;local E=e.columns;if D==nil then e.inputValue=''else e.inputValue=b.sub(D,1,E)end;return true end;f.setMaskingCharacter=function(self,F)assert(type(F)=="string","[XAF Graphic] Expected STRING as argument #1")if F~=''then e.inputCharacter=b.sub(F,1,1)else error("[XAF Error] Password masking character cannot be empty")end;return true end;f.setOnClick=function(self,G,...)assert(type(G)=="function","[XAF Graphic] Expected FUNCTION as argument #1")local H=G;local I={...}e.eventClick=H;e.eventClickArguments=I;return true end;f.setOnKey=function(self,G,...)assert(type(G)=="function","[XAF Graphic] Expected FUNCTION as argument #1")local H=G;local I={...}e.eventKey=H;e.eventKeyArguments=I;return true end;f.setOnPaste=function(self,G,...)assert(type(G)=="function","[XAF Graphic] Expected FUNCTION as argument #1")local H=G;local I={...}e.eventPaste=H;e.eventPasteArguments=I;return true end;f.setShowPassword=function(self,J)assert(type(J)=="boolean","[XAF Graphic] Expected BOOLEAN as argument #1")e.showFlag=J;return true end;f.view=function(self)local K=e.renderer;if K then local L=e.columns;local M=e.totalWidth;local N=e.totalHeight;local O=e.positionX;local P=e.positionY;local Q=K.getBackground()local R=K.getForeground()local k=e.renderMode;if k<=1 then K.setBackground(e.colorBackground)K.setForeground(e.colorBorder)K.fill(O,P,M-1,1,'─')K.fill(O,P+N-1,M-1,1,'─')K.fill(O,P,1,N-1,'│')K.fill(O+M-1,P,1,N-1,'│')K.set(O,P,'┌')K.set(O+M-1,P,'┐')K.set(O,P+N-1,'└')K.set(O+M-1,P+N-1,'┘')end;if k<=2 then K.setBackground(e.colorBackground)K.set(O+1,P+1,' ')K.set(O+M-2,P+1,' ')end;if k<=3 then local S=e.fieldFocus==true and e.colorSelected or e.colorContent;local T=e.inputValue;local U=T==nil and''or tostring(T)local V=''K.setBackground(e.colorBackground)K.fill(O+2,P+1,L,N-2,' ')if e.showFlag==false then V=string.gsub(U,".",e.inputCharacter)else V=U end;if b.wlen(V)<L and e.fieldFocus==true then V=V..'|'end;K.setForeground(S)K.set(O+2,P+1,V)end;K.setBackground(Q)K.setForeground(R)return true else error("[XAF Error] Component GPU renderer has not been initialized")end end;return{private=e,public=f}end;function c:extend()local W=self:initialize()local e=W.private;local f=W.public;if self.C_INHERIT==true then return{private=e,public=f}else error("[XAF Error] Class '"..tostring(self.C_NAME).."' cannot be inherited")end end;function c:new(X,Y,L)local W=self:initialize()local e=W.private;local f=W.public;f:setPosition(X,Y)assert(type(L)=="number","[XAF Graphic] Expected NUMBER as argument #3")if math.floor(L)==L and math.ceil(L)==L and L>0 then e.columns=L;e.totalWidth=L+4;e.totalHeight=3 else error("[XAF Error] Invalid columns number - must be a positive integer")end;if self.C_INSTANCE==true then return f else error("[XAF Error] Class '"..tostring(self.C_NAME).."' cannot be instanced")end end;return c
