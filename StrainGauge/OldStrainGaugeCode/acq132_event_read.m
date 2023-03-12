function [ch,t,t_trig]=acq132_event_read(path,event)
%[ch,t,t_trig]=acq132_event_read(path,event)
%path - the full path of the cooked directories.example: c:\frics\2011-04-24\12-33-46\acq132_093\multivent
%path = [pwd '\12-33-46\acq132_093\multivent'];

last_channel=32;% start read from channel 1 to last_channel

if event<10
    event=int2str(event);
    event=['0' event];
else
    event=int2str(event);
end
% path=[path '\' event '.COOKED\']; %Enter path
path=[path '/' event '.COOKED/'];

%--------------format file read
%check the directory exist
 if  exist(path,'dir')~=7
     display([path '-Doesnt exist'])
     t=NaN;
     t_trig=NaN;
     ch=NaN;
     return
 end
 
%--find norm_coeff
newData1 = importdata([path 'format'],'\t',42);
vars = fieldnames(newData1);
for i = 1:length(vars)
 vars{i}= newData1.(vars{i});
end
norm_coeff=vars{1,1};

%---find pre&post
textdata=vars{2,1};
str=textdata{3,1};
s1=strfind(str,'--pre');
%s2=strfind(str,'--post');
pre=sscanf(str(s1:end),'--pre %d');
%post=sscanf(str(s2:end),'--post %d');% is not used later
%---find HOSTNAME
 str=textdata{6,1};
 s1=strfind(str,'acq132');
 host=sscanf(str(s1:end),'%s');


%----------------Time base read--------
file=[path host '.EV' event '.TBD'];
fid= fopen(file,'r');
t=fread(fid, 'float64');
if length(t)>pre
    t_trig=t(pre-2)+(t(pre-1)-t(pre-2))/2;%[sec] Strange!! but was checked. would expect t_trig=t(pre)+(t(pre+1)-t(pre))/2;
%t_trig=t(pre-1)+(t(pre)-t(pre-1))/2;%[sec]
%t_trig=t(pre)+(t(pre+1)-t(pre))/2;%[sec]

    t=(t-t_trig)*10^3; %[msec], relative to trigger 
else 
    sprintf('length(t) < number of samples pretrigger, trigger time is not deduced')
    return
end
fclose(fid);

%---------------channel read------------
ch=zeros(length(t),last_channel);    %preallocation

for j=1:last_channel
    if j<10
    ch_char=['0' int2str(j)];
    else
        ch_char=int2str(j);
    end
file=[path host '.EV' event '.CH' ch_char];
fid= fopen(file,'r');
ch(:,j)= fread(fid,'int16');
ch(:,j)=ch(:,j)*norm_coeff(j,1)+norm_coeff(j,2);
fclose(fid);
end
