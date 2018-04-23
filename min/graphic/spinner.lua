local a=require("xaf/graphic/component")local b={C_NAME="Generic GUI Spinner",C_INSTANCE=true,C_INHERIT=true,static={MODE_DEFAULT=0,MODE_COUNTER=1,MODE_ITERATOR=2}}function b:initialize()local c=a:extend()local d=c and c.private or{}local e=c and c.public or{}d.eventClick=nil;d.eventClickArguments={}d.eventScroll=nil;d.eventScrollArguments={}d.spinnerMode=0;d.contentIndex=1;d.contentLength=0;d.contentTable={}e.getValue=function(self)local f=d.contentIndex;local g=d.contentTable;local h=g[f]return h end;e.register=function(self,i)assert(type(i)=="table","[XAF Graphic] Expected TABLE as argument #1")if d.active==true then if i[1]=="touch"then local j=i[2]if j==d.renderer.getScreen()then local k=i[3]local l=i[4]local m=d.renderMode;if l==d.positionY+1 then local i=nil;local n={}if k==d.positionX+d.columns+4 then i=d.eventClick;n=d.eventClickArguments;if d.contentIndex>1 then d.contentIndex=d.contentIndex-1 end elseif k==d.positionX+d.columns+6 then i=d.eventClick;n=d.eventClickArguments;if d.contentIndex<d.contentLength then d.contentIndex=d.contentIndex+1 end end;e:setRenderMode(3)e:view()e:setRenderMode(m)if i then return i(table.unpack(n))end end end elseif i[1]=="scroll"then local j=i[2]if j==d.renderer.getScreen()then local o=i[3]local p=i[4]local q=i[5]local m=d.renderMode;local r=0;local s=0;local t=0;local u=0;if m<=1 then r=d.positionX;s=d.positionY;t=d.positionX+d.totalWidth-1;u=d.positionY+d.totalHeight-1 elseif m<=2 then r=d.positionX+1;s=d.positionY+1;t=d.positionX+d.totalWidth-2;u=d.positionY+d.totalHeight-2 elseif m<=3 then r=d.positionX+2;s=d.positionY+1;t=d.positionX+d.totalWidth-2;u=d.positionY+d.totalHeight-2 end;if o>=r and o<=t and(p>=s and p<=u)then local i=d.eventScroll;local n=d.eventScrollArguments;if d.contentIndex>1 and q<0 then d.contentIndex=d.contentIndex-1 elseif d.contentIndex<d.contentLength and q>0 then d.contentIndex=d.contentIndex+1 end;e:setRenderMode(3)e:view()e:setRenderMode(m)if i then return i(table.unpack(n))end end end end end end;e.setCounter=function(self,v,w,x)assert(type(v)=="number","[XAF Graphic] Expected NUMBER as argument #1")assert(type(w)=="number","[XAF Graphic] Expected NUMBER as argument #2")assert(type(x)=="number","[XAF Graphic] Expected NUMBER as argument #3")local y=v;local z=w;local A=x;local B=1;if d.spinnerMode==0 or d.spinnerMode==1 then if x<=0 then error("[XAF Error] Increment number must be positive")end;if y<z then d.contentTable={}d.contentIndex=1;d.contentValue=nil;d.contentLength=0;for C=y,z,A do d.contentTable[B]=C;d.contentLength=d.contentLength+1;B=B+1 end else error("[XAF Error] Minimum value must be lower than maximum")end else error("[XAF Error] Invalid spinner type - required DEFAULT or COUNTER")end;return true end;e.setIterator=function(self,g)assert(type(g)=="table","[XAF Graphic] Expected TABLE as argument #1")if d.spinnerMode==2 then d.contentTable={}d.contentIndex=1;d.contentValue=nil;d.contentLength=0;for D,E in ipairs(g)do d.contentTable[D]=E;d.contentLength=d.contentLength+1 end else error("[XAF Error] Invalid spinner type - required ITERATOR")end;return true end;e.setOnClick=function(self,F,...)assert(type(F)=="function","[XAF Graphic] Expected FUNCTION as argument #1")local G=F;local H={...}d.eventClick=G;d.eventClickArguments=H;return true end;e.setOnScroll=function(self,F,...)assert(type(F)=="function","[XAF Graphic] Expected FUNCTION as argument #1")local G=F;local H={...}d.eventScroll=G;d.eventScrollArguments=H;return true end;e.view=function(self)local I=d.renderer;if I then local J=d.columns;local K=d.totalWidth;local L=d.totalHeight;local M=d.positionX;local N=d.positionY;local O=I.getBackground()local P=I.getForeground()local m=d.renderMode;if m<=1 then I.setBackground(d.colorBackground)I.setForeground(d.colorBorder)I.fill(M,N,K-1,1,'─')I.fill(M,N+L-1,K-1,1,'─')I.fill(M,N,1,L-1,'│')I.fill(M+K-1,N,1,L-1,'│')I.set(M,N,'┌')I.set(M+K-1,N,'┐')I.set(M,N+L-1,'└')I.set(M+K-1,N+L-1,'┘')I.set(M+J+3,N+1,'│')I.set(M+J+5,N+1,'│')I.set(M+J+3,N,'┬')I.set(M+J+5,N,'┬')I.set(M+J+3,N+2,'┴')I.set(M+J+5,N+2,'┴')end;if m<=2 then I.setBackground(d.colorBackground)I.set(M+1,N+1,' ')I.set(M+J+2,N+1,' ')end;if m<=3 then local Q=d.contentTable[d.contentIndex]local R=Q==nil and''or tostring(Q)I.setBackground(d.colorBackground)I.setForeground(d.colorContent)I.fill(M+2,N+1,J,1,' ')I.set(M+J+4,N+1,'⇩')I.set(M+J+6,N+1,'⇧')I.set(M+2,N+1,string.sub(R,1,J))end;I.setBackground(O)I.setForeground(P)return true else error("[XAF Error] Component GPU renderer has not been initialized")end end;return{private=d,public=e}end;function b:extend()local S=self:initialize()local d=S.private;local e=S.public;if self.C_INHERIT==true then return{private=d,public=e}else error("[XAF Error] Class '"..tostring(self.C_NAME).."' cannot be inherited")end end;function b:new(T,U,J,V)local S=self:initialize()local d=S.private;local e=S.public;e:setPosition(T,U)assert(type(J)=="number","[XAF Graphic] Expected NUMBER as argument #3")if math.floor(J)==J and math.ceil(J)==J and J>0 then d.columns=J else error("[XAF Error] Invalid columns number - must be a positive integer")end;assert(type(V)=="number","[XAF Graphic] Expected NUMBER as argument #4")if V>=0 and V<=2 then if math.floor(V)==V and math.ceil(V)==V then d.spinnerMode=V else error("[XAF Error] Invalid spinner mode - must be a integer")end else error("[XAF Error] Invalid spinner mode")end;d.totalWidth=J+8;d.totalHeight=3;if self.C_INSTANCE==true then return e else error("[XAF Error] Class '"..tostring(self.C_NAME).."' cannot be instanced")end end;return b
