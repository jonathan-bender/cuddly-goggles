function outdata=phantomReadMeta(path)
%full path of the directories
if nargin<1
    path='';
end

% txtData=dlmread([path '\Ph_meta.txt'],'',1,0);
txtData=dlmread([path '/Ph_meta.txt'],'',1,0);
outdata.NumEvents=txtData(1);
outdata.FrameRate=txtData(2);
outdata.FrameT=1/outdata.FrameRate*1e6;%[musec]
%outdata.EventNumBuffers=txtData(2);
%outdata.BufferNumImages=txtData(3);
outdata.ImageHeight=txtData(4);
outdata.ImageWidth=txtData(5);
outdata.NumIms=txtData(6);
outdata.PostIms=txtData(7);
