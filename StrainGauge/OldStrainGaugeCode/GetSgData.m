function data=GetSgData(exper,eventNum,shift,shear_fix,varargin)

Tstart='start';
Tend='end';
smt=1;
kind='Rayleigh';

exp_details=expDetailsRead(exper);
% exp_details=expDetailsRead_Ilya(exper);


data=acq132_event_get_data(exper,eventNum,Tstart,Tend,smt,'U1','U2','U3','x_sg','y_sg','sg_angle','F','N');

%% Shift U1&U3
if strcmp(shift,'shift')
    
    sub_sample_index=100;
    dt=(data.t(2)-data.t(1))/sub_sample_index;%(msec)
    if(strcmp(kind,'Super'))
        shift_t=1.6e-4;%0.3mm/2200m/s=0.14mus
    else
        shift_t=2.5e-4;%0.3mm/1200m/s=0.25mus
    end
    
    d=ceil(shift_t/dt);
    
    t_spline=(data.t(1):dt:data.t(end));
    for j=1:length(data.x_sg)
        if (exp_details.sg_angle(j)==0) %Otherwise some thing more elaborated should be done.
            U1_spline=spline(data.t,data.U1(:,j),t_spline)';
            U2_spline=spline(data.t,data.U2(:,j),t_spline)';
            U3_spline=spline(data.t,data.U3(:,j),t_spline)';
            
            U1_spline=circshift(U1_spline,d);
            U3_spline=circshift(U3_spline,-d);
            
            data.U1(:,j)=U1_spline(1:sub_sample_index:end);
            data.U2(:,j)=U2_spline(1:sub_sample_index:end);
            data.U3(:,j)=U3_spline(1:sub_sample_index:end);
        end
    end
else
    [~,~,~,data.Uxx,data.Uyy,data.Uxy,~]=calculate_stress_strain(data.U1,data.U2,data.U3,data.sg_angle);
    
end

%% fix shear sensitivity
if strcmp(shear_fix,'fix')
    data.gV=[0,0.1,0.95,-0.08];    % taken from Ilya's code anl_front_in_space
    
    [data.U1,data.U2,data.U3]=calc_shear_sensitivity4(data.U1,data.U2,data.U3,data.gV);
    disp('shear sensitivity was corrected' )
    [data.Sxx,data.Syy,data.Sxy,data.Uxx,data.Uyy,data.Uxy,data.note]=calculate_stress_strain(data.U1,data.U2,data.U3,data.sg_angle);
    
else
    [data.Sxx,data.Syy,data.Sxy,data.Uxx,data.Uyy,data.Uxy,data.note]=calculate_stress_strain(data.U1,data.U2,data.U3,data.sg_angle);
end


