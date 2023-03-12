function exp_details=expDetailsRead(exp_dir)
%%% This function reads all the data about the system from the exp_details
%%% file attached to every experiment. This includes the Strain-Gages data
%%% (location,order..), Camera data (type,resolution,1/2 cameras,trigger delay), and
%%% Block data (dimensions, barrier information, laser location).
%%% The function was adapted for the case of two optical pathes and for the
%%% presence of 1D barriers that can be added to the surface. There is also
%%% an adaption for Kulite Sg's that was added by Ilya but I never checked.
%%% All units here (and in the exp_details file) are [mm], [sec]


%------------Read exp_details.txt
% path_exp_details=[exp_dir '\exp_details.txt'];
path_exp_details=[exp_dir '/exp_details.txt'];
fid=fopen(path_exp_details);

%--SG data
exp_details.factor_Master=str2num(fgetl(fid));
exp_details.factor_Slave=str2num(fgetl(fid));
exp_details.offset_Master=str2num(fgetl(fid));
exp_details.offset_Slave=str2num(fgetl(fid));
exp_details.sg_Master_order=str2num(fgetl(fid));
exp_details.sg_Slave_order=str2num(fgetl(fid));
exp_details.rosette_number=str2num(fgetl(fid));
exp_details.sg_angle=(str2num(fgetl(fid)))*pi/180;
exp_details.sg_angle=exp_details.sg_angle(exp_details.rosette_number);
exp_details.x_sg=str2num(fgetl(fid));
exp_details.x_sg=exp_details.x_sg(exp_details.rosette_number);
exp_details.sg_height=str2num(fgetl(fid));
exp_details.sg_height=exp_details.sg_height(exp_details.rosette_number);
ch_names=textscan(fid,'%s',32);
exp_details.ch_Master_names=ch_names{1};
ch_names=textscan(fid,'%s',32);
exp_details.ch_Slave_names=ch_names{1};
str2num(fgetl(fid));

%--Camera Data (and trigger)
str2num(fgetl(fid));
exp_details.triggerDelay=str2num(fgetl(fid));
tmp=str2num(fgetl(fid));
exp_details.BigPicRes=tmp(1);
exp_details.SmallPicRes=tmp(2);
tmp=textscan(fid,'%s',2);
exp_details.BigPicCam=tmp{1}{1};
exp_details.SmallPicCam=tmp{1}{2};
str2num(fgetl(fid));

%--Block Data
str2num(fgetl(fid));
tmp=str2num(fgetl(fid));
exp_details.UpperBlockLength=tmp(1);
exp_details.UpperBlockWidth=tmp(2);
exp_details.BarrierLoc=str2num(fgetl(fid));
exp_details.BarrierSign=str2num(fgetl(fid));
exp_details.LaserLoc=str2num(fgetl(fid));

%--added for Kulite
str2num(fgetl(fid));
vref=str2num(fgetl(fid));
if ~isempty(vref)
    exp_details.config=1;
    exp_details.Vref_Master=vref(1:2);
    exp_details.Vref_Slave=vref(3:4);
    %the angle of components 1 and 3 with respect to comp 1
    angle(1,:)=(str2num(fgetl(fid)))*pi/180;
    angle(1,:)=angle(1,exp_details.rosette_number);
    angle(3,:)=(str2num(fgetl(fid)))*pi/180;
    angle(3,:)=angle(3,exp_details.rosette_number);
    angle(2,:)=exp_details.sg_angle;
    exp_details.angle=angle;
else
    exp_details.config=0;
    exp_details.Vref_Master=[0 0];
    exp_details.Vref_Slave=[0 0];
    %the angle of components 1 and 3 with respect to comp 1
    angle(1,:)=pi/4*ones(1,length(exp_details.sg_angle));
    angle(3,:)=pi/4*ones(1,length(exp_details.sg_angle));
    angle(2,:)=exp_details.sg_angle;
    exp_details.angle=angle;
end
fclose(fid);

%-----sort by x_sg location
[exp_details.x_sg,exp_details.axis_sort_index]=sort(exp_details.x_sg);
exp_details.sg_angle=exp_details.sg_angle(exp_details.axis_sort_index);
exp_details.sg_height=exp_details.sg_height(exp_details.axis_sort_index);

