function e=acq132_event_get_data(exp_dir,event,Tstart,Tend,smt,varargin)
%varargin : 'x_sg','Uxx','Uyy','Uxy','Sxx','Syy','Sxy','N','F','ch_094_ex'
%if nargout=0,the function using assign to assign to the 'caller' varargin,t and t_trig
%if nargin=1 the function returns structure
%pre=post='max'  ->  maximum post and maximum pre
%t[msec] ,t_trig[sec]
%v_smt is string contains what objects are smoothed
%use odd smt!!
%event- may be vector. but if argout=0, only last event is returned

event_vec=event;

lastSlashPosition = find(exp_dir == '\', 1, 'last');
Date = exp_dir(lastSlashPosition+1:end);


for k=1:length(event_vec)
    event=event_vec(k);
    %--------------read the data and correct offset units
%     path=[current_dir '\' exp_dir '\acq132_093\multivent'];
    path=[exp_dir '/acq132_093/multivent'];
    [ch_Master,t_Master,t_trig_Master]=acq132_event_read(path,event);
%     path=[current_dir '\' exp_dir '\acq132_094\multivent'];
    path=[exp_dir '/acq132_094/multivent'];
    [ch_Slave,t,t_trig]=acq132_event_read(path,event);
    
    %---check if there is no missing data
    % Sometimes one of the cards miss the event. 
    
    if (isnan(t_trig_Master))||(isnan(t_trig))
        
        if (isnan(t_trig_Master))&&(isnan(t_trig))
            e=0;
            display([exp_dir ' - event - ' num2str(event) ' doesnt exist'])
            return;
        
        elseif (isnan(t_trig))
            t=t_Master;
            t_trig=t_trig_Master;
            ch_Slave=ch_Master*0;
        
        else
            
            ch_Master=ch_Slave*0;
        end
        
    end
    
    
    %----read exp_details, and apply trigger delay from NiDaq
    exp_details=expDetailsRead(exp_dir);
%     exp_details=expDetailsRead_Ilya(exp_dir);
    t=t+exp_details.triggerDelay*1e3; %[msec]
    
    %------make the time base
    if(strcmp('start',Tstart)||Tstart<min(t))
        startl=1;
    elseif(Tstart>max(t))
        error('Tstart out of limits');
    else
        [~,startl]=min(abs(t-Tstart));
    end
    
    if(strcmp('end',Tend)||Tend>max(t))
        endl=length(t);
    elseif(Tend<min(t))
        error('Tend out of limits');
    else
        [~,endl]=min(abs(t-Tend));
    end
    
    %     if (strcmp(Tinterval,'min'))
    %         interval=1;
    %     else
    %         interval=ceil(Tinterval/mean(diff(t(1:20))));
    %     end
    
    %------cut the data
    ch_Master=ch_Master(startl:endl,:);
    ch_Slave=ch_Slave(startl:endl,:);
    t=t(startl:endl,:);
    %----create acq132 event data structure
    acq132=acq132_convert_raw_to_data(exp_dir,ch_Master,ch_Slave);
    acq132.t=t;
    acq132.t_trig=t_trig;
    
    %--------Smooth the data and creat the partial output -> acq132_out.
    to=length(acq132.t)-(smt-1)/2;
    from=(smt-1)/2+1;
    
    acq132_out.Date=Date;
    acq132_out.exp=exp_dir;
    acq132_out.event=event;
    acq132_out.t_trig=acq132.t_trig; %t, and t_trig are allways included at the output
    acq132_out.t=acq132.t(from:to,:);
    acq132_out.note=acq132.note;
    
%-----added for Vishay+Kulite----    
    acq132_out.V=acq132.V;
    if length(acq132.V)<length(acq132.x_sg)
        acq132_out.K=acq132.K;
    end
%----------    

    
    for j=1: length(varargin)
        if length(acq132.(varargin{j})(:,1))==length(t(:,1)); %smooth and cut the time dependent variables.i.e , all the fields with dim=1 as long as t
%             acq132_out.(varargin{j})=smoothts(acq132.(varargin{j})','b',smt)';
            acq132_out.(varargin{j})=acq132.(varargin{j});
            acq132_out.(varargin{j})=acq132_out.(varargin{j})(from:to,:);
        else
            acq132_out.(varargin{j})=acq132.(varargin{j});
       end
    end
    %preallocation needed
    e(k)=acq132_out;
end


%--- assignin the acq132_out to the caller
if nargout==0
    field_names=fieldnames(acq132_out);
    for j=1:length(field_names)
        assignin('caller',field_names{j},e(k).(field_names{j})); %if length(event)>1 -> only last event is returned
        
    end
    clear acq132_out;
end





