function SlowAqStruct=GetSlowAquisition(exp_dir,varargin)
%%% This function gets the data of the slow aquisition (labeled as event '0')
%%% Shahar June 2020


Camera='Big';
card1='093';
card2='094';

sync_event=2;

%% SG data
%--get SG stream
SG_path1=[exp_dir '\acq132_' card1 '\stream'];
[ch_Master,t_Master]=acq132_stream_read(SG_path1);
SG_path2=[exp_dir '\acq132_' card2 '\stream'];
[ch_Slave,t_Slave]=acq132_stream_read(SG_path2);

%-- In case one of the cards started measuring earlier - take the common measurements only 
l1=length(t_Master);
l2=length(t_Slave);
if l1<l2
    ch_Slave=ch_Slave(l2-l1+1:l2,:);
    t_Slave=t_Slave(l2-l1+1:l2);
else
    ch_Master=ch_Master(l1-l2+1:l1,:);
    t_Master=t_Master(l1-l2+1:l1);
end

SG=acq132_convert_raw_to_data(exp_dir,ch_Master,ch_Slave);
SG.t_Slave=t_Slave;
SG.t_Master=t_Master;

SG.time=t_Slave;            %   take the slave time vector because the trig measurement is currently there

%--sync using first event
df=diff(SG.Trig);
f=find(df<-0.1);

t_0=SG.time(f(sync_event));
TrigerTimes=SG.time(f)-t_0;
SG.time=SG.time-t_0;
SG.t_Slave=SG.t_Slave-t_0;
SG.t_Master=SG.t_Master-t_0;

%% save
lastSlashPosition = find(exp_dir == '\', 1, 'last');
if ~isempty(lastSlashPosition)
    SlowAqStruct.Date = exp_dir(lastSlashPosition+1:end);
else
    SlowAqStruct.Date = exp_dir;
end

SlowAqStruct.SG=SG;
SlowAqStruct.sync_event=sync_event;
SlowAqStruct.TrigerTimes=TrigerTimes;

