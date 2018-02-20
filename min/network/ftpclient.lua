local a=require("network/client")local b=require("filesystem")local c=require("unicode")local d={C_NAME="Generic FTP Client",C_INSTANCE=true,C_INHERIT=true,static={}}function d:initialize()local e=a:extend()local f=e and e.private or{}local g=e and e.public or{}g.directoryCreate=function(self,h,i)assert(type(h)=="string","[XAF Network] Expected STRING as argument #1")assert(type(i)=="string","[XAF Network] Expected STRING as argument #2")local j=h;local k=i;return f:sendRawRequest("FTP_DIRECTORY_CREATE",j,k)end;g.fileDownload=function(self,l,m,n)assert(type(l)=="string","[XAF Network] Expected STRING as argument #1")assert(type(m)=="string","[XAF Network] Expected STRING as argument #2")assert(type(n)=="string","[XAF Network] Expected STRING as argument #3")local o=l;local p=m;local q=n;local r=b.concat(p,q)if b.exists(m)==false then error("[XAF Error] Directory '"..m.."' does not exist")elseif b.isDirectory(m)==false then error("[XAF Error] Path '"..m.."' is not a directory")elseif b.exists(r)==true then error("[XAF Error] File '"..r.."' already exists")else local s=b.open(r,'w')local t,u=f:sendRawRequest("FTP_FILE_DOWNLOAD_START",o)if t==true then local v=nil;local w=''local x=''repeat v,w,x=f:sendRawRequest("FTP_FILE_DOWNLOAD_CONTINUE",o)s:write(x)until w=="OK (Stop)"s:close()return v,w else s:close()b.remove(r)return t,u end end end;g.fileMove=function(self,y,h)assert(type(y)=="string","[XAF Network] Expected STRING as argument #1")assert(type(h)=="string","[XAF Network] Expected STRING as argument #2")local z=y;local A=h;return f:sendRawRequest("FTP_FILE_MOVE",z,A)end;g.fileRemove=function(self,h)assert(type(h)=="string","[XAF Network] Expected STRING as argument #1")local B=h;return f:sendRawRequest("FTP_FILE_REMOVE",B)end;g.fileRename=function(self,h,i)assert(type(h)=="string","[XAF Network] Expected STRING as argument #1")assert(type(i)=="string","[XAF Network] Expected STRING as argument #2")local B=h;local C=i;return f:sendRawRequest("FTP_FILE_RENAME",B,C)end;g.fileUpload=function(self,D,E,F)assert(type(D)=="string","[XAF Network] Expected STRING as argument #1")assert(type(E)=="string","[XAF Network] Expected STRING as argument #2")assert(type(F)=="string","[XAF Network] Expected STRING as argument #3")local G=D;local H=E;local I=F;if b.exists(G)==false then error("[XAF Error] File '"..G.."' does not exist")else local J={}local s=b.open(G,'r')local K=''local L=''local M=33+c.wlen(H)+c.wlen(I)local N=f.componentModem.maxPacketSize()-M;local t,u=f:sendRawRequest("FTP_FILE_UPLOAD_START",H,I)if t==true then while K do L=L..K;K=s:read(math.huge)end;for O=1,c.wlen(L),N do local P=O;local Q=O+N-1;local R=string.sub(L,P,Q)table.insert(J,R)end;while t==true and J[1]do local S=J[1]local v,w=f:sendRawRequest("FTP_FILE_UPLOAD_CONTINUE",H,I,S)if v==true then table.remove(J,1)else return v,w end end;s:close()return f:sendRawRequest("FTP_FILE_UPLOAD_STOP",H,I)else s:close()return t,u end end end;return{private=f,public=g}end;function d:extend()local T=self:initialize()local f=T.private;local g=T.public;if self.C_INHERIT==true then return{private=f,public=g}else error("[XAF Error] Class '"..tostring(self.C_NAME).."' cannot be inherited")end end;function d:new(U)local T=self:initialize()local f=T.private;local g=T.public;g:setModem(U)if self.C_INSTANCE==true then return g else error("[XAF Error] Class '"..tostring(self.C_NAME).."' cannot be instanced")end end;return d