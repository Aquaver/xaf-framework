local a=require("network/client")local b=require("core/xafcore")local c=b:getSecurityInstance()local d={C_NAME="Generic DNSP Client",C_INSTANCE=true,C_INHERIT=true,static={}}function d:initialize()local e=a:extend()local f=e and e.private or{}local g=e and e.public or{}g.register=function(self,h,i)assert(type(h)=="string","[XAF Network] Expected STRING as argument #1")assert(type(i)=="string","[XAF Network] Expected STRING as argument #2")local j=h;local k=i;if c:isUuid(j)==true then return f:sendRawRequest("DNS_REGISTER",j,k)else error("[XAF Error] Invalid address syntax")end end;g.translateForward=function(self,i)assert(type(i)=="string","[XAF Network] Expected STRING as argument #1")local l=i;return f:sendRawRequest("DNS_TRANSLATE_FORWARD",l)end;g.translateReverse=function(self,h)assert(type(h)=="string","[XAF Network] Expected STRING as argument #1")local m=h;if c:isUuid(m)==true then return f:sendRawRequest("DNS_TRANSLATE_REVERSE",m)else error("[XAF Error] Invalid address syntax")end end;g.unregister=function(self,n)assert(type(n)=="string","[XAF Network] Expected STRING as argument #1")local o=n;return f:sendRawRequest("DNS_UNREGISTER",o)end;return{private=f,public=g}end;function d:extend()local p=self:initialize()local f=p.private;local g=p.public;if self.C_INHERIT==true then return{private=f,public=g}else error("[XAF Error] Class '"..tostring(self.C_NAME).."' cannot be inherited")end end;function d:new(q)local p=self:initialize()local f=p.private;local g=p.public;g:setModem(q)if self.C_INSTANCE==true then return g else error("[XAF Error] Class '"..tostring(self.C_NAME).."' cannot be instanced")end end;return d