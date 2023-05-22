function acq132=acq132_convert_raw_to_data(exp_dir,ch_Master,ch_Slave)

% uses "exp_details.txt" to convert units , correct offset and s.g rotation, calculate stress and strain.
%It makes the final data
%exp_dir is needed to use event1 for offset substruction
%specific routine for the block 200mm with Vishay and Kulite. 
%Master = Kulite, Slave=Vishay.

%------------Read exp_details.txt
exp_details=expDetailsRead(exp_dir);
% exp_details=expDetailsRead_Ilya(exp_dir);

factor_Master=exp_details.factor_Master;
offset_Master=exp_details.offset_Master;
offset_Slave=exp_details.offset_Slave;
factor_Slave=exp_details.factor_Slave;
sg_Master_order=exp_details.sg_Master_order;
sg_Slave_order=exp_details.sg_Slave_order;
x_sg=exp_details.x_sg;
axis_sort_index=exp_details.axis_sort_index;
sg_angle=exp_details.sg_angle;
ch_Master_names=exp_details.ch_Master_names;
ch_Slave_names=exp_details.ch_Slave_names;
y_sg=exp_details.sg_height;

ch_Master_K=strncmp(ch_Master_names,'sgK',3);
ch_Slave_K=strncmp(ch_Slave_names,'sgK',3);

%Calculation of gains of Master (Kulite)
% factor_Master([1:15 17:31])=factor_Master([1:15 17:31]).*MasterCurrent;% it has to be multiplied by the gain (NL) and resistances.
%factor_Master([1:15 17:31])=factor_Master([1:15 17:31]).*MasterResistances*MasterCurrent*1e-6;% it has to be multiplied by the gain (NL).
%---------------offset correction
dirCell=path2cell(exp_dir);
calFlag=strcmp(dirCell,'cal');
cal_dir='';
if (sum(calFlag)) %if path is cal directory so this is also cal_dir
    for j=1:find(calFlag==1) cal_dir=[cal_dir '\' dirCell{j}]; end
else
    cal_dir=[dirCell{1} '\cal'];
end

% if cal directory exists offset correction taken from there, otherwise from the first event
if  exist(cal_dir,'dir')==7
    path_Master=[cal_dir '\acq132_093\multivent'];
    path_Slave=[cal_dir '\acq132_094\multivent'];
else
%     path_Master=[exp_dir '\acq132_093\multivent'];
%     path_Slave=[exp_dir '\acq132_094\multivent'];
    path_Master=[exp_dir '/acq132_093/multivent'];
    path_Slave=[exp_dir '/acq132_094/multivent'];
    cal_dir=(exp_dir);
end

event4offset=1;         %using event1 for offset correction
%--offset for Master
ch_offset=acq132_event_read(path_Master,event4offset);
ch_offset=mean(ch_offset);ch_offset_Master=ch_offset;
ch_number_for_offset = find(offset_Master==0);
ch_Master(:,ch_number_for_offset)=ch_Master(:,ch_number_for_offset)-repmat(ch_offset(ch_number_for_offset),length(ch_Master(:,1)),1);%offset correction// comment this line for disable
ch_number_for_offset = find(offset_Master~=0);
ch_Master(:,ch_number_for_offset)=ch_Master(:,ch_number_for_offset)-repmat(offset_Master(ch_number_for_offset),length(ch_Master(:,1)),1);%offset correction with specified values// comment this line for disable
ch_Master=ch_Master./repmat(factor_Master,length(ch_Master(:,1)),1);%unit conversion notice the using "./" instead ".*", empty channels will be "inf"

%--offset for Slave
ch_offset=acq132_event_read(path_Slave,event4offset);
ch_offset=mean(ch_offset);ch_offset_Slave=ch_offset;
ch_number_for_offset = find(offset_Slave==0);
ch_Slave(:,ch_number_for_offset)=ch_Slave(:,ch_number_for_offset)-repmat(ch_offset(ch_number_for_offset),length(ch_Slave(:,1)),1);%offset correction// comment this line for disable
ch_number_for_offset = find(offset_Slave~=0);
ch_Slave(:,ch_number_for_offset)=ch_Slave(:,ch_number_for_offset)-repmat(offset_Slave(ch_number_for_offset),length(ch_Slave(:,1)),1);%offset correction with specified values// comment this line for disable
ch_Slave=ch_Slave./repmat(factor_Slave,length(ch_Slave(:,1)),1);

%--------------------organize the data
sg_names=[ch_Master_K(sg_Master_order)' ch_Slave_K(sg_Slave_order)'];
sg=[ch_Master(:,sg_Master_order) ch_Slave(:,sg_Slave_order)]; %ordered strain gages
order=ones(1,length(sg(1,1:3:end))); order(sg_names(1:3:end))=0;
order=order(axis_sort_index);
[~,V]=find(order==1);
[~,K]=find(order==0);
   
if find(sg_names~=1)
    %------Vishay------
    sgtmp=sg;sgtmp(:,sg_names)=0;
    %------order the strain gages
    U1=sgtmp(:,1:3:end);
    U1=U1(:,axis_sort_index)*1000; %[mStrain]
    U2=sgtmp(:,2:3:end);
    U2=U2(:,axis_sort_index)*1000; %[mStrain]
    U3=sgtmp(:,3:3:end);
    U3=U3(:,axis_sort_index)*1000; %[mStrain]
% %%% Ilya's correction of shear sensitivity%%%%%%   Done in GetSgData 
%     gV=[0,0.1,0.95,-0.08];
%     [U1,U2,U3]=calc_shear_sensitivity4(U1,U2,U3,gV);
%     disp('shear sensitivity was corrected from acq132_convert_raw_to_data' )
% %%%%%%%
    [Sxx,Syy,Sxy,Uxx,Uyy,Uxy,note,Ymod]=calculate_stress_strain(U1,U2,U3,sg_angle);
end    
if find(sg_names==1)
    sK=treatment_Kul(ch_Master,ch_Slave,ch_offset_Master,ch_offset_Slave,exp_details,sg_names);
end
if exist('sK','var') && exist('Sxx','var') %Vishay and Kulite
    acq132.Sxx=Sxx+sK.Sxx;
    acq132.Syy=Syy+sK.Syy;
    acq132.Sxy=Sxy+sK.Sxy;
    acq132.Uxx=Uxx+sK.Uxx;
    acq132.Uyy=Uyy+sK.Uyy;
    acq132.Uxy=Uxy+sK.Uxy;
    acq132.K=K;
    acq132.V=V;
    acq132.note=note;
elseif exist('sK','var') % Kulite only
    acq132=sK;
    acq132.K=K;
    acq132.V=V;
else % Vishay only
    acq132=struct('V',V,'x_sg',x_sg,'U1',U1,'U2',U2,'U3',U3,'Uxx',Uxx,'Uyy',Uyy,'Uxy',Uxy,'Sxx',Sxx,'Syy',Syy,'Sxy',Sxy,'note',note,'Ymod',Ymod*1e9,'sg_angle',sg_angle,'y_sg',y_sg);
end
% acq132.note=note;
acq132.x_sg=x_sg;
%---------isolate the external channels
ch_Master(:,sg_Master_order)=[];
ch_Master_names(sg_Master_order)=[];
ch_Slave(:,sg_Slave_order)=[];
ch_Slave_names(sg_Slave_order)=[];

ch_ex=[ch_Master,ch_Slave];
clear ch_Master;
clear ch_Slave;
ch_ex_names=[ch_Master_names;ch_Slave_names];

%---Extra channels

index=min([40 length(ch_ex(:,1))]);
for j=1:length(ch_ex(1,:))
    
    if(~ strcmp('None',ch_ex_names{j}))
        
        if( strfind(ch_ex_names{j},'ds'))
            if(strcmp(ch_ex_names{j}(1:2),'ds'))
%                 ch_ex(:,j)=ds_v2mu(ch_ex(:,j),ch_ex_names{j}(3:end));
%                 ch_ex(:,j)=ch_ex(:,j)-mean(ch_ex(1:index,j)); % %Substruct the initial values
            elseif(strcmp(ch_ex_names{j}(1:3),'Ods'))
                filename=[ch_ex_names{j} '_cal.mat'];
                if exist([cal_dir '\' filename],'file')~=0
                    ch_ex(:,j)=Odsv_2mu([cal_dir '\' filename],ch_ex(:,j));
                    ch_ex(:,j)=ch_ex(:,j)-mean(ch_ex(1:index,j)); % %Substruct the initial values
                end
            end
        end
        acq132=setfield(acq132,ch_ex_names{j},ch_ex(:,j));
    end
end





