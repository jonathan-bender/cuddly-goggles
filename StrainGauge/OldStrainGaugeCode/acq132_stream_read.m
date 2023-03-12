function [ch,t]=acq132_stream_read(path)
%[ch,t]=acq132_stream_read(path)
%path- The full path . example 'c:\frics\2011-05-24\20-22-48\acq132_094\stream'
%path=[pwd '\20-22-48\acq132_094\stream']

max_index=max(strfind(path,'\')); %Find the dir path from the full path 
path_dir=path(1:max_index-1);
path_format=[path_dir '\multivent\01.COOKED\format'];%the format file is taken from the first event

if  exist(path_format,'file')~=2  %if there is no event in the dir, use format file next to strem file/
    clear path_format;
path_format=[path_dir '\format'];%the format file is taken from the first event
end

% %--------------format file read
DELIMITER = '\t';
HEADERLINES = 42;
newData1 = importdata(path_format, DELIMITER, HEADERLINES);
vars = fieldnames(newData1);
for i = 1:length(vars)
    vars{i}= newData1.(vars{i});
end
norm_coeff=vars{1,1};
%--------------data read
fid= fopen(path,'r');
ch_multiplex= fread(fid,'int16');
fclose(fid);
%------------- decoding multiplexed data
ch=zeros(length(ch_multiplex)/33,32);
for j=2:33                 %starting from j=2 because the first 2byte word is sample tag
    ch(:,j-1)=ch_multiplex(j:33:end);
end
ch1_16=ch(:,1:2:end);
ch17_32=ch(:,2:2:end);
ch=[ch1_16 ch17_32];
for j=1:32
    ch(:,j)=ch(:,j)*norm_coeff(j,1)+norm_coeff(j,2);
end
%--------------decoding time base
chunk_num_max=length(ch(:,1))/64;  %each chunk contains 64 samples
t=zeros(1,chunk_num_max); % sec
fid= fopen(path,'r');
%preallocation
t_chunk=zeros(1,chunk_num_max);
tt=zeros(64,16);

for k=1:chunk_num_max      %chunk number
    for j=1:64   %sample in the 64 sample chunk
        fseek(fid,(k-1)*2*33*64+(j-1)*2*33,'bof'); %fseek works in bytes
        tt(j,:)=fread(fid,16,'ubit1')';
        tt(j,:)=tt(j,16:-1:1);
    end
    tbin=tt(1:48,1);
    tbin=tbin(48:-1:1);
    tbin=num2str(tbin);
    t_chunk(k)=bin2dec(tbin')/10^6; %in sec
end
fclose(fid);

%--------------construct absolute time base not us
%the last chunk is inacurate
for k=1:chunk_num_max-1
    t((k-1)*64+1:k*64)=(0:1:63)*(t_chunk(k+1)-t_chunk(k))/64+t_chunk(k);
end
k=k+1;
t((k-1)*64+1:k*64)=(0:1:63)/244+t_chunk(k);



%-------------decoding time base another way
% tt=ch_multiplex(1:33:end);%+2^15; %convert from signed to unsigned
% for k=1:1
%     for j=1:48
%         ttbin(j,:)=dec2bin(tt((k-1)*64+j),16)';
%        %ttbin(j,:)=ttbin(j,48:-1:1);
%     end
%     tbin=ttbin(:,1);
%     
% end


