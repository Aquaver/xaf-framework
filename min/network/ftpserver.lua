local a=require("component")local b=require("filesystem")local c=require("network/server")local d=require("unicode")local e=require("core/xafcore")local f=e:getStringInstance()local g=e:getTableInstance()local h=e:getTextInstance()local i={C_NAME="Generic FTP Server",C_INSTANCE=true,C_INHERIT=true,static={}}function i:initialize()local j=c:extend()local k=j and j.private or{}local l=j and j.public or{}k.fileBuffer={}k.mountCounter=0;k.mountPrefix="FS:%s"k.serverPaths={}k.serverPaths["ftp_root"]='/'k.serverPaths["ftp_storage"]="FTP_STORAGE"k.workspaceMap={}k.doDirectoryCreate=function(self,m)assert(type(m)=="table","[XAF Network] Expected TABLE as argument #1")local n=k.componentModem;local o=k.port;local p=m[3]local q=b.canonical(m[7])local r=m[8]local s=b.concat(k.serverPaths["ftp_storage"],k.mountPrefix,q)local t=b.concat(s,r)local u=string.format(s,1)local v=string.format(t,1)if b.exists(u)==false then n.send(p,o,false,"Path Not Exists")elseif b.exists(v)==true then n.send(p,o,false,"Directory Already Exists")elseif b.isDirectory(u)==false then n.send(p,o,false,"Path Is Not A Directory")elseif r==nil or f:checkControlCharacter(r)==true or f:checkSpecialCharacter(r)==true or f:checkWhitespace(r)==true then n.send(p,o,false,"Invalid Directory Name")else for w=1,k.mountCounter do b.makeDirectory(string.format(t,w))end;n.send(p,o,true,"OK")end end;k.doFileDownloadContinue=function(self,m)assert(type(m)=="table","[XAF Network] Expected TABLE as argument #1")local n=k.componentModem;local o=k.port;local p=m[3]local x=b.canonical(m[7])local y=b.concat(k.serverPaths["ftp_storage"],k.mountPrefix,x)if k.fileBuffer[p]then if k.fileBuffer[p]["file_path"]==y then local z=k.fileBuffer[p]["file_data"][1]local A=k.fileBuffer[p]["file_data"][2]if A then table.remove(k.fileBuffer[p]["file_data"],1)n.send(p,o,true,"OK (Next)",z)else k.fileBuffer[p]=nil;n.send(p,o,true,"OK (Stop)",z)end else n.send(p,o,false,"File Buffer Already Exists")end else n.send(p,o,false,"File Buffer Not Exists")end end;k.doFileDownloadStart=function(self,m)assert(type(m)=="table","[XAF Network] Expected TABLE as argument #1")local n=k.componentModem;local o=k.port;local p=m[3]local x=b.canonical(m[7])local y=b.concat(k.serverPaths["ftp_storage"],k.mountPrefix,x)local B=string.format(y,1)if b.exists(B)==false then n.send(p,o,false,"File Not Exists")elseif b.isDirectory(B)==true then n.send(p,o,false,"Invalid File")elseif x==''or x=='/'then n.send(p,o,false,"Access Denied")else local C=19;local D=n.maxPacketSize()-C;local E=''k.fileBuffer[p]={}k.fileBuffer[p]["file_path"]=y;k.fileBuffer[p]["file_data"]={}for w=1,k.mountCounter do local F=string.format(y,w)local G=b.open(F,'r')local H=''while H do E=E..H;H=G:read(math.huge)end;G:close()end;for w=1,d.wlen(E),D do local I=w;local J=w+D-1;local K=string.sub(E,I,J)table.insert(k.fileBuffer[p]["file_data"],K)end;n.send(p,o,true,"OK")end end;k.doFileMove=function(self,m)assert(type(m)=="table","[XAF Network] Expected TABLE as argument #1")local n=k.componentModem;local o=k.port;local p=m[3]local L=b.canonical(m[7])local M=b.canonical(m[8])local N=b.concat(k.serverPaths["ftp_storage"],k.mountPrefix,L)local O=b.concat(k.serverPaths["ftp_storage"],k.mountPrefix,M)local P=string.format(N,1)local Q=string.format(O,1)if b.exists(P)==false then n.send(p,o,false,"File Not Exists")elseif b.exists(Q)==false then n.send(p,o,false,"Path Not Exists")elseif b.isDirectory(Q)==false then n.send(p,o,false,"Path Is Not A Directory")elseif L==''or L=='/'then n.send(p,o,false,"Access Denied")else local R=h:split(N,'/')local S=#R;local T=R[S]local U=b.concat(O,T)for w=1,k.mountCounter do b.rename(string.format(N,w),string.format(U,w))end;n.send(p,o,true,"OK")end end;k.doFileRemove=function(self,m)assert(type(m)=="table","[XAF Network] Expected TABLE as argument #1")local n=k.componentModem;local o=k.port;local p=m[3]local F=b.canonical(m[7])local V=b.concat(k.serverPaths["ftp_storage"],k.mountPrefix,F)local W=string.format(V,1)if b.exists(W)==false then n.send(p,o,false,"File Not Exists")elseif F==''or F=='/'then n.send(p,o,false,"Access Denied")else for w=1,k.mountCounter do b.remove(string.format(V,w))end;n.send(p,o,true,"OK")end end;k.doFileRename=function(self,m)assert(type(m)=="table","[XAF Network] Expected TABLE as argument #1")local n=k.componentModem;local o=k.port;local p=m[3]local F=b.canonical(m[7])local X=m[8]local V=b.concat(k.serverPaths["ftp_storage"],k.mountPrefix,F)local W=string.format(V,1)if b.exists(W)==false then n.send(p,o,false,"File Not Exists")elseif F==''or F=='/'then n.send(p,o,false,"Access Denied")elseif X==nil or f:checkControlCharacter(X)==true or f:checkSpecialCharacter(X)==true or f:checkWhitespace(X)==true then n.send(p,o,false,"Invalid File New Name")else local R=h:split(V,'/')local S=#R;local U=''local Y=''for w=1,S-1 do U=U..R[w]U=U..'/'end;U=U..X;Y=string.format(U,1)if b.exists(Y)==true then n.send(p,o,false,"New Name Already Occupied")else for w=1,k.mountCounter do b.rename(string.format(V,w),string.format(U,w))end;n.send(p,o,true,"OK")end end end;k.doFileUploadContinue=function(self,m)assert(type(m)=="table","[XAF Network] Expected TABLE as argument #1")local n=k.componentModem;local o=k.port;local p=m[3]local q=b.canonical(m[7])local T=m[8]local Z=m[9]local s=b.concat(k.serverPaths["ftp_storage"],k.mountPrefix,q)local V=b.concat(s,T)if k.fileBuffer[p]then if k.fileBuffer[p]["file_path"]==V then table.insert(k.fileBuffer[p]["file_data"],Z)n.send(p,o,true,"OK")else n.send(p,o,false,"File Buffer Already Exists")end else n.send(p,o,false,"File Buffer Not Exists")end end;k.doFileUploadStart=function(self,m)assert(type(m)=="table","[XAF Network] Expected TABLE as argument #1")local n=k.componentModem;local o=k.port;local p=m[3]local q=b.canonical(m[7])local T=m[8]local s=b.concat(k.serverPaths["ftp_storage"],k.mountPrefix,q)local V=b.concat(s,T)local u=string.format(s,1)local W=string.format(V,1)if b.exists(u)==false then n.send(p,o,false,"Directory Not Exists")elseif b.exists(W)==true then n.send(p,o,false,"File Already Exists")elseif T==nil or f:checkControlCharacter(T)==true or f:checkSpecialCharacter(T)==true or f:checkWhitespace(T)==true then n.send(p,o,false,"Invalid File Name")else for w=1,k.mountCounter do b.open(string.format(V,w),'w'):close()end;k.fileBuffer[p]={}k.fileBuffer[p]["file_path"]=V;k.fileBuffer[p]["file_data"]={}n.send(p,o,true,"OK")end end;k.doFileUploadStop=function(self,m)assert(type(m)=="table","[XAF Network] Expected TABLE as argument #1")local n=k.componentModem;local o=k.port;local p=m[3]local q=b.canonical(m[7])local T=m[8]local s=b.concat(k.serverPaths["ftp_storage"],k.mountPrefix,q)local V=b.concat(s,T)if k.fileBuffer[p]then if k.fileBuffer[p]["file_path"]==V then local _=k.fileBuffer[p]["file_data"]local a0=''for w=1,#_ do a0=a0 .._[w]end;if d.wlen(a0)>=k.mountCounter then local a1=math.ceil(d.wlen(a0)/k.mountCounter)for w=1,k.mountCounter do local a2=string.format(V,w)local a3=b.open(a2,'w')a3:write(string.sub(a0,1+(w-1)*a1,a1+(w-1)*a1))a3:close()end else for w=1,d.wlen(a0)do local a2=string.format(V,w)local a3=b.open(a2,'w')a3:write(string.sub(a0,w,w))a3:close()end;for w=d.wlen(a0)+1,k.mountCounter do local a2=string.format(V,w)local a3=b.open(a2,'w')a3:close()end end;k.fileBuffer[p]=nil;n.send(p,o,true,"OK")else n.send(p,o,false,"File Buffer Already Exists")end else n.send(p,o,false,"File Buffer Not Exists")end end;k.prepareWorkspace=function(self,a4)assert(type(a4)=="string","[XAF Network] Expected STRING as argument #1")k.serverPaths["ftp_root"]=a4;k.serverPaths["ftp_storage"]=b.concat(k.serverPaths["ftp_root"],k.serverPaths["ftp_storage"])if b.exists(k.serverPaths["ftp_root"])==false then b.makeDirectory(k.serverPaths["ftp_root"])end;if b.exists(k.serverPaths["ftp_storage"])==false then b.makeDirectory(k.serverPaths["ftp_storage"])end;return true end;k.setWorkspace=function(self,a5)assert(type(a5)=="table","[XAF Network] Expected TABLE as argument #1")local a6=a5;local a7={}local a8={}for a9,aa in pairs(a6)do a7[aa]=0 end;for a9,aa in g:sortByKey(a7,false)do local ab=a9;local ac=a.type(ab)if ac=="filesystem"then table.insert(a8,ab)else error("[XAF Error] Invalid filesystem component")end end;for w=1,#a8 do local ad=a8[w]local ae=string.format(k.mountPrefix,w)local af=b.concat(k.serverPaths["ftp_storage"],ae)b.mount(ad,af)end;k.mountCounter=#a8;k.workspaceMap=a8;return true end;l.process=function(self,m)assert(type(m)=="table","[XAF Network] Expected TABLE as argument #1")local n=k.componentModem;local o=k.port;local ag=n.address;if k.active==true then if n then if m[1]=="modem_message"then if m[2]==ag and m[4]==o then local ah=m[6]if ah=="FTP_DIRECTORY_CREATE"then return true,k:doDirectoryCreate(m)elseif ah=="FTP_FILE_DOWNLOAD_CONTINUE"then return true,k:doFileDownloadContinue(m)elseif ah=="FTP_FILE_DOWNLOAD_START"then return true,k:doFileDownloadStart(m)elseif ah=="FTP_FILE_MOVE"then return true,k:doFileMove(m)elseif ah=="FTP_FILE_REMOVE"then return true,k:doFileRemove(m)elseif ah=="FTP_FILE_RENAME"then return true,k:doFileRename(m)elseif ah=="FTP_FILE_UPLOAD_CONTINUE"then return true,k:doFileUploadContinue(m)elseif ah=="FTP_FILE_UPLOAD_START"then return true,k:doFileUploadStart(m)elseif ah=="FTP_FILE_UPLOAD_STOP"then return true,k:doFileUploadStop(m)end;return false end end else error("[XAF Error] Server network modem component has not been initialized")end else error("[XAF Error] Server is already stopped")end end;return{private=k,public=l}end;function i:extend()local ai=self:initialize()local k=ai.private;local l=ai.public;if self.C_INHERIT==true then return{private=k,public=l}else error("[XAF Error] Class '"..tostring(self.C_NAME).."' cannot be inherited")end end;function i:new(n,a4,a5)local ai=self:initialize()local k=ai.private;local l=ai.public;l:setModem(n)assert(type(a4)=="string","[XAF Network] Expected STRING as argument #2")k:prepareWorkspace(a4)assert(type(a5)=="table","[XAF Network] Expected TABLE as argument #3")k:setWorkspace(a5)if self.C_INSTANCE==true then return l else error("[XAF Error] Class '"..tostring(self.C_NAME).."' cannot be instanced")end end;return i