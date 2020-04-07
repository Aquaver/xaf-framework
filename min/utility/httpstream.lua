local a=require("unicode")local b=require("xaf/core/xafcore")local c=b:getMathInstance()local d=b:getTextInstance()local e={C_NAME="Generic HTTP Stream",C_INSTANCE=true,C_INHERIT=true,static={}}function e:initialize()local f=nil;local g=f and f.private or{}local h=f and f.public or{}g.componentInternet=nil;g.connectionHandle=nil;g.isConnected=false;g.isSecure=false;g.maxTimeout=1;g.maxTries=3;g.postData=nil;g.requestHeaders={}g.responseCode=0;g.responseHeaders={}g.responseMessage=''g.targetUrl=''h.clearPostData=function(self)g.postData=nil;return true end;h.connect=function(self)local i=nil;local j=g.componentInternet;local k=g.postData;local l=g.requestHeaders;local m={}local n=false;local o=g.targetUrl;local p=g.maxTimeout;local q=g.maxTries;if k then i=j.request(o,k,l)else i=j.request(o,nil,l)end;if g.isConnected==false then for r=1,q do m={i.response()}if m[1]and m[2]and m[3]then g.connectionHandle=i;g.isConnected=true;g.responseCode=m[1]g.responseMessage=m[2]g.responseHeaders=m[3]n=true;return n else os.sleep(p)end end;return n else error("[XAF Error] Already connected")end end;h.disconnect=function(self)if g.isConnected==true then g.connectionHandle.close()g.connectionHandle=nil;g.isConnected=false;return true else error("[XAF Error] Already disconnected")end end;h.isConnected=function(self)return g.isConnected end;h.isSecure=function(self)return g.isSecure end;h.getCard=function(self)return g.componentInternet end;h.getData=function(self)if g.isConnected==true then local i=g.connectionHandle;local s=''return function()while s do s=i.read(math.huge)return s end end else error("[XAF Error] Not connected")end end;h.getDateObject=function(self)if g.isConnected==true then local t=g.responseHeaders["Date"][1]local u=t:gsub(' ','|'):gsub(',','|'):gsub(':','|')local v={}local w=d:split(u,'|',true)local x={["Mon"]=1,["Tue"]=2,["Wed"]=3,["Thu"]=4,["Fri"]=5,["Sat"]=6,["Sun"]=7}local y={["Jan"]=1,["Feb"]=2,["Mar"]=3,["Apr"]=4,["May"]=5,["Jun"]=6,["Jul"]=7,["Aug"]=8,["Sep"]=9,["Oct"]=10,["Nov"]=11,["Dec"]=12}v["WEEK_DAY"]=x[w[1]]v["MONTH_DAY"]=tonumber(w[2])v["MONTH"]=y[w[3]]v["YEAR"]=tonumber(w[4])v["TIME_HOUR"]=tonumber(w[5])v["TIME_MINUTE"]=tonumber(w[6])v["TIME_SECOND"]=tonumber(w[7])v["TIMEZONE"]=w[8]return v else error("[XAF Error] Not connected")end end;h.getMaxTimeout=function(self)return g.maxTimeout end;h.getMaxTries=function(self)return g.maxTries end;h.getResponseCode=function(self)if g.isConnected==true then return g.responseCode else error("[XAF Error] Not connected")end end;h.getResponseHeader=function(self,z)assert(type(z)=="string","[XAF Utility] Expected STRING as argument #1")if g.isConnected==true then if g.responseHeaders[z]then return g.responseHeaders[z][1]else return nil end else error("[XAF Error] Not connected")end end;h.getResponseHeaders=function(self)if g.isConnected==true then return g.responseHeaders else error("[XAF Error] Not connected")end end;h.getResponseMessage=function(self)if g.isConnected==true then return g.responseMessage else error("[XAF Error] Not connected")end end;h.setCard=function(self,j)assert(type(j)=="table","[XAF Utility] Expected TABLE as argument #1")if j.type=="internet"then g.componentInternet=j else error("[XAF Error] Invalid internet card component")end;return true end;h.setMaxTimeout=function(self,A)assert(type(A)=="number","[XAF Utility] Expected NUMBER as argument #1")g.maxTimeout=A;return true end;h.setMaxTries=function(self,B)assert(type(B)=="number","[XAF Utility] Expected NUMBER as argument #1")if c:checkNatural(B,true)==true then g.maxTries=B else error("[XAF Error] Invalid connection tries number - must be a positive integer")end;return true end;h.setPostData=function(self,k)assert(type(k)=="table","[XAF Utility] Expected TABLE as argument #1")local C=k;local D=''for E,F in pairs(C)do D=D..tostring(E)..'='D=D..tostring(F)..'&'end;D=a.sub(D,1,a.wlen(D)-1)g.postData=D;return true end;h.setRequestHeader=function(self,G,F)assert(type(G)=="string","[XAF Utility] Expected STRING as argument #1")local z=G;local H=F;g.requestHeaders[z]=H;return true end;return{private=g,public=h}end;function e:extend()local I=self:initialize()local g=I.private;local h=I.public;if self.C_INHERIT==true then return{private=g,public=h}else error("[XAF Error] Class '"..tostring(self.C_NAME).."' cannot be inherited")end end;function e:new(J,K)local I=self:initialize()local g=I.private;local h=I.public;h:setCard(J)assert(type(K)=="string","[XAF Utility] Expected STRING as argument #2")if string.sub(string.lower(K),1,7)=="http://"then g.targetUrl=K;g.isSecure=false elseif string.sub(string.lower(K),1,8)=="https://"then g.targetUrl=K;g.isSecure=true else error("[XAF Error] Invalid URL pattern - should start with 'http(s)://...'")end;if self.C_INSTANCE==true then return h else error("[XAF Error] Class '"..tostring(self.C_NAME).."' cannot be instanced")end end;return e
