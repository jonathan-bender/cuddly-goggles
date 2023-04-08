function Ims = phantomReadImsNew(path,eventNum,startl,interval,endl,smt,lineNum)
%eventNum=0 is slow acquisition. 
%lineNum -> the vector of numbers of rows from the image.
%returns 3 dim Ims. dim=3 is imIndex
%note that all the pixels are included


%--- Read Phantom Meta
PhMeta = phantomReadMeta(path);


if (nargin<6)
    smt=1;
end

if (nargin<7 || strcmp(lineNum,'all')) %the full image is taken
    lineNum=(1:PhMeta.ImageHeight);
end

%-----
% f = fopen([path '\' num2str(eventNum) '.bin'],'r');
f = fopen([path '/' num2str(eventNum) '.bin'],'r');
imSize=PhMeta.ImageHeight*PhMeta.ImageWidth;
Ims=zeros(length(lineNum),PhMeta.ImageWidth,floor((endl-startl)/interval)+1);

fseek(f,(startl-1)*imSize*2,'bof'); %2 for 16 bit images
for ind=startl:interval:endl
    
    Im=fread(f,imSize,'uint16');
    Imr=reshape(Im',PhMeta.ImageWidth,PhMeta.ImageHeight)';
    Imr=Imr(lineNum,:);
    Imr=my_smooth(Imr',smt)'; %my_smooth is coloumn oriented. I want to smooth with row orientetion
    Ims(:,:,floor((ind-(startl))/interval)+1)=Imr;       
    
    %we already read one line, only jump interval-1...
    if interval>1
        fseek(f,(interval-1)*imSize*2,'cof');%2 for 16 bit images
    end
    
end
fclose(f);


