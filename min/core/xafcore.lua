local a=require("computer")local b=require("filesystem")local c=require("term")local d=require("text")local e=require("unicode")local f={C_NAME="XAF Core",C_INSTANCE=false,C_INHERIT=false,static={CONCAT_DEFAULT=0,CONCAT_SPACE=1,CONCAT_NOSPACE=2,CONCAT_NEWLINE=3}}function f:getExecutorInstance()local g={}g.run=function(self,h,...)assert(type(h)=="function","[XAF Core] Expected FUNCTION as argument #1")local i={...}local j=h;local k={}k={pcall(j,table.unpack(i))}return table.unpack(k)end;g.runExternal=function(self,l,...)assert(type(l)=="string","[XAF Core] Expected STRING as argument #1")local m=l;local j=nil;local i={...}local k={}if b.exists(m)==true then local n=b.open(m,'r')local o=""local p=n:read(math.huge)while p do o=o..tostring(p)p=n:read(math.huge)end;n:close()j=load(o)k={pcall(j,table.unpack(i))}return table.unpack(k)else error("[XAF Error] File '"..m.."' does not exist")end end;g.stop=function(self,q)assert(type(q)=="boolean","[XAF Core] Expected BOOLEAN as argument #1")if q==true then c.clear()end;a.pushSignal("")coroutine.yield()os.exit()end;return g end;function f:getMathInstance()local g={}g.checkInteger=function(self,r)assert(type(r)=="number","[XAF Core] Expected NUMBER as argument #1")local s=math.floor(r)local t=math.ceil(r)if s==t then return true else return false end end;g.checkNatural=function(self,r,u)assert(type(r)=="number","[XAF Core] Expected NUMBER as argument #1")assert(type(u)=="boolean","[XAF Core] Expected BOOLEAN as argument #2")local s=math.floor(r)local t=math.ceil(r)if s==t then if u==true then return r>0 else return r>=0 end else return false end end;g.getAdditiveInverse=function(self,r)assert(type(r)=="number","[XAF Core] Expected NUMBER as argument #1")local v=r;local w=v*-1;return w end;g.getGreatestCommonDivisor=function(self,x,y)assert(type(x)=="number","[XAF Core] Expected NUMBER as argument #1")assert(type(y)=="number","[XAF Core] Expected NUMBER as argument #2")if g:checkInteger(x)==false or g:checkInteger(y)==false then error("[XAF Error] Greatest common divisor must be calculated on integer numbers")else local z=0;local A=x;while y~=0 do z=A%y;A=y;y=z end;return math.abs(A)end end;g.getLowestCommonMultiple=function(self,x,y)assert(type(x)=="number","[XAF Core] Expected NUMBER as argument #1")assert(type(y)=="number","[XAF Core] Expected NUMBER as argument #2")if g:checkInteger(x)==false or g:checkInteger(y)==false then error("[XAF Error] Lowest common multiple must be calculated on integer numbers")else local B=math.abs(x*y)local C=B/g:getGreatestCommonDivisor(x,y)return C end end;g.getMultiplicativeInverse=function(self,r)assert(type(r)=="number","[XAF Core] Expected NUMBER as argument #1")local v=r;local D=1/v;return D end;return g end;function f:getSecurityInstance()local g={}g.convertBinaryToHex=function(self,E,F)assert(type(E)=="string","[XAF Core] Expected STRING as argument #1")assert(type(F)=="boolean","[XAF Core] Expected BOOLEAN as argument #2")local G=E;local H=e.wlen(G)local I={string.byte(G,1,H)}local J=""local K=F;for L=1,H do J=J..string.format("%02x",I[L])end;if K==true then J=string.upper(J)end;return J end;g.getRandomHash=function(self,M,F)assert(type(M)=="number","[XAF Core] Expected NUMBER as argument #1")assert(type(F)=="boolean","[XAF Core] Expected BOOLEAN as argument #2")local N={'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'}local O=M;local P=""local Q=F;for L=1,O do P=P..N[math.random(1,16)]end;if Q==true then P=string.upper(P)end;return P end;g.getRandomUuid=function(self,F)assert(type(F)=="boolean","[XAF Core] Expected BOOLEAN as argument #1")local R={'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'}local S=""local T=""local U=F;for L=1,30 do T=T..R[math.random(1,16)]end;S=S..string.sub(T,1,8)S=S.."-"..string.sub(T,9,12)S=S.."-4"..string.sub(T,13,15)S=S.."-"..R[math.random(9,12)]..string.sub(T,16,18)S=S.."-"..string.sub(T,19,30)if U==true then S=string.upper(S)end;return S end;g.isUuid=function(self,S)assert(type(S)=="string","[XAF Core] Expected STRING as argument #1")local V=S;local W=e.wlen(S)local X="(%x%x%x%x%x%x%x%x[-]%x%x%x%x[-]%x%x%x%x[-]%x%x%x%x[-]%x%x%x%x%x%x%x%x%x%x%x%x)"local Y=false;if W==36 and string.match(V,X)==V then Y=true end;return Y end;return g end;function f:getStringInstance()local g={}g.checkControlCharacter=function(self,Z)assert(type(Z)=="string","[XAF Core] Expected STRING as argument #1")local _=Z;local a0="[\0-\31\127]"local a1=false;if string.find(_,a0)then a1=true end;return a1 end;g.checkSpecialCharacter=function(self,Z)assert(type(Z)=="string","[XAF Core] Expected STRING as argument #1")local _=Z;local a2="[\a\b\f\n\r\t\v\\\"\'/]"local a1=false;if string.find(_,a2)then a1=true end;return a1 end;g.checkWhitespace=function(self,Z)assert(type(Z)=="string","[XAF Core] Expected STRING as argument #1")local _=Z;local a3="[\n\r\t\v ]"local a1=false;if string.find(_,a3)then a1=true end;return a1 end;return g end;function f:getTableInstance()local g={}g.getLength=function(self,a4)assert(type(a4)=="table","[XAF Core] Expected TABLE as argument #1")local a5=a4;local a6=0;for a7,a8 in pairs(a5)do a6=a6+1 end;return a6 end;g.loadFromFile=function(self,l)assert(type(l)=="string","[XAF Core] Expected STRING as argument #1")local a9=string.char(13,10)local aa=l;local ab={}if b.exists(aa)==true then local ac=b.open(aa,'r')local ad=''local ae=''while ae do ad=ad..ae;ae=ac:read(math.huge)end;ae=''ac:close()ab=g:loadFromString(ad)else error("[XAF Error] File '"..aa.."' does not exist")end;return ab end;g.loadFromString=function(self,af)assert(type(af)=="string","[XAF Core] Expected STRING as argument #1")local a9=string.char(13,10)local ag=af;local ab={}for ah in string.gmatch(ag,"[^"..a9 .."]+")do local ai=string.find(ah," = ")local a7=nil;local a8=nil;if string.sub(ah,1,3)~="[#]"then if ai then local aj=string.sub(ah,1,3)local ak=string.sub(ah,5,ai-1)local al=string.sub(ah,ai+3,ai+5)local am=string.sub(ah,ai+7)if aj=="[S]"then a7=tostring(ak)elseif aj=="[N]"then a7=tonumber(ak)elseif aj=="[B]"then if ak=="true"then a7=true elseif ak=="false"then a7=false end elseif aj=="[?]"then else error("[XAF Error] Invalid table line syntax - invalid key marker")end;if al=="[S]"then a8=tostring(am)elseif al=="[N]"then a8=tonumber(am)elseif al=="[B]"then if am=="true"then a8=true elseif am=="false"then a8=false end elseif al=="[?]"then a8=nil else error("[XAF Error] Invalid table line syntax - invalid value marker")end;if a7 then ab[a7]=a8 end else error("[XAF Error] Invalid table data syntax - delimiter not found")end end end;return ab end;g.saveToFile=function(self,a4,l,an)assert(type(a4)=="table","[XAF Core] Expected TABLE as argument #1")assert(type(l)=="string","[XAF Core] Expected STRING as argument #2")assert(type(an)=="boolean","[XAF Core] Expected BOOLEAN as argument #3")local ao=a4;local ap=l;local aq=an==true and'a'or'w'local ar=b.open(ap,aq)for a7,a8 in g:sortByKey(ao,false)do local as=type(a7)local aj=''local at=type(a8)local al=''aj=as=="string"and"[S]"or as=="number"and"[N]"or as=="boolean"and"[B]"or"[?]"al=at=="string"and"[S]"or at=="number"and"[N]"or at=="boolean"and"[B]"or"[?]"ar:write(aj..' '..tostring(a7).." = ")ar:write(al..' '..tostring(a8)..'\n')end;ar:close()return true end;g.searchByValue=function(self,a4,a8,au)assert(type(a4)=="table","[XAF Core] Expected TABLE as argument #1")assert(type(a8)~="nil","[XAF Core] Expected ANYTHING as argument #2")assert(type(au)=="number","[XAF Core] Expected NUMBER as argument #3")local av=a4;local aw=a8;local ax=au;local ay={}for a7,a8 in pairs(av)do if ax==0 then if a8==aw then table.insert(ay,a7)end elseif ax>0 then if a8>aw then table.insert(ay,a7)end elseif ax<0 then if a8<aw then table.insert(ay,a7)end end end;return ay end;g.sortByKey=function(self,az,aA)assert(type(az)=="table","[XAF Core] Expected TABLE as argument #1")assert(type(aA)=="boolean","[XAF Core] Expected BOOLEAN as argument #2")local aB=az;local aC=aA;local aD={}local aE={}local aF={}local aG={}local aH=function(aI,aJ)return aI<aJ end;local aK=function(aI,aJ)return aI>aJ end;local aL={}local aM=1;local aN=0;for a7,a8 in pairs(aB)do local as=type(a7)if as=="number"then table.insert(aD,a7)elseif as=="string"then table.insert(aE,a7)elseif as=="boolean"then table.insert(aF,tostring(a7))else table.insert(aG,a7)end;aM=aM+1 end;if aC==true then table.sort(aD,aK)table.sort(aE,aK)table.sort(aF,aK)else table.sort(aD,aH)table.sort(aE,aH)table.sort(aF,aH)end;if aC==true then for a7,a8 in ipairs(aG)do table.insert(aL,a8)end;for a7,a8 in ipairs(aF)do if a8=="true"then table.insert(aL,true)elseif a8=="false"then table.insert(aL,false)end end;for a7,a8 in ipairs(aE)do table.insert(aL,a8)end;for a7,a8 in ipairs(aD)do table.insert(aL,a8)end else for a7,a8 in ipairs(aD)do table.insert(aL,a8)end;for a7,a8 in ipairs(aE)do table.insert(aL,a8)end;for a7,a8 in ipairs(aF)do if a8=="true"then table.insert(aL,true)elseif a8=="false"then table.insert(aL,false)end end;for a7,a8 in ipairs(aG)do table.insert(aL,a8)end end;return function()aN=aN+1;if aN<aM then local a7=aL[aN]local a8=aB[a7]return a7,a8 end end end;return g end;function f:getTextInstance()local g={}g.convertLinesToString=function(self,aO,aP)assert(type(aO)=="table","[XAF Core] Expected TABLE as argument #1")assert(type(aP)=="number","[XAF Core] Expected NUMBER as argument #2")local aQ=aO;local aR=aP;local aS=""local aT=""if aR>=0 and aR<=3 then aT=(aR==0 or aR==1)and' 'or aR==2 and''or aR==3 and'\n'for a7,a8 in pairs(aO)do aS=aS..tostring(a8)..aT end;aS=string.sub(aS,1,e.wlen(aS)-e.wlen(aT))return aS else error("[XAF Error] Invalid concatenation mode")end end;g.convertStringToLines=function(self,aU,aV)assert(type(aU)=="string","[XAF Core] Expected STRING as argument #1")assert(type(aV)=="number","[XAF Core] Expected NUMBER as argument #2")local aW=aU;local aX=aV;local aO={}for aU in d.wrappedLines(aW,aX,aX)do table.insert(aO,aU)end;return aO end;g.padCenter=function(self,aU,aV)assert(type(aU)=="string","[XAF Core] Expected STRING as argument #1")assert(type(aV)=="number","[XAF Core] Expected NUMBER as argument #2")local aX=math.floor(aV)local aY=string.sub(aU,1,aX)local aZ=e.wlen(aY)local a_=aX-aZ;local b0=math.floor(a_/2)local b1=a_-b0;local b2=string.rep(" ",b0)..aY..string.rep(" ",b1)return b2 end;g.padLeft=function(self,aU,aV)assert(type(aU)=="string","[XAF Core] Expected STRING as argument #1")assert(type(aV)=="number","[XAF Core] Expected NUMBER as argument #2")local aX=math.floor(aV)local aY=string.sub(aU,1,aX)local aZ=e.wlen(aY)local a_=aX-aZ;local b2=aY..string.rep(" ",a_)return b2 end;g.padRight=function(self,aU,aV)assert(type(aU)=="string","[XAF Core] Expected STRING as argument #1")assert(type(aV)=="number","[XAF Core] Expected NUMBER as argument #2")local aX=math.floor(aV)local aY=string.sub(aU,1,aX)local aZ=e.wlen(aY)local a_=aX-aZ;local b2=string.rep(" ",a_)..aY;return b2 end;g.split=function(self,aU,ai,b3)assert(type(aU)=="string","[XAF Core] Expected STRING as argument #1")assert(type(ai)=="string","[XAF Core] Expected STRING as argument #2")assert(type(b3)=="boolean","[XAF Core] Expected BOOLEAN as argument #3")local b4=#aU;local b5=0;local b6={}while true do local b7,b8=string.find(aU,ai,b5)if b7 and b8 then local b9=string.sub(aU,b5,b7-1)if b9==''then if b3==false then table.insert(b6,b9)end else table.insert(b6,b9)end;b5=b8+1 else if b5-1<b4 then table.insert(b6,string.sub(aU,b5))else if b3==false then table.insert(b6,'')end end;break end end;return b6 end;return g end;return f
