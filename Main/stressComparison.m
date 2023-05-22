
%% read video
SOURCE_PATH='D:\Experiments\2023-5-15\13-26-48';
EVENT_NUM=4;
READ_START=-5000;
READ_LENGTH=5000;
TRIGGER_DELAY=7;
FRAMES_PER_MILLISECOND = 581.196;

rawVideo=readBinVideo([SOURCE_PATH '\ph'],EVENT_NUM, READ_START,READ_LENGTH);
timeline=getVideoTimeline(READ_START,READ_LENGTH,TRIGGER_DELAY,FRAMES_PER_MILLISECOND);

%% process video
% video data
PIXELS_PER_MICRON = 0.006315;
TOTAL_LENGTH=200000;

% video processing
EDGE_DROP_RANGE=10;
REFERENCE_FRAMES=1:30;
SOURCE_FREQUENCY=115;
SOURCE_FREQUENCY_WIDTH=1;
TRIM_EDGES=[200 1250];

vid=removeSourceFrequency(rawVideo, SOURCE_FREQUENCY, SOURCE_FREQUENCY_WIDTH, FRAMES_PER_MILLISECOND);
vid=trimEdges(vid,TRIM_EDGES);
[xAxis, vid]=getXAxisFromDarkEdges(vid, PIXELS_PER_MICRON, TOTAL_LENGTH, REFERENCE_FRAMES, EDGE_DROP_RANGE);

%% get displacement
CRACK_TIP_THRESHOLD=0.97;

displacement = getTipDisplacement(vid,xAxis,REFERENCE_FRAMES,CRACK_TIP_THRESHOLD);

%% trim before and after motion
motionInd=find(isfinite(displacement));
displacement=displacement(motionInd);
timeline=timeline(motionInd);
vid=vid(:,:,motionInd);

%% get velocity
VELOCITY_SMOOTH=3;

velocity = getTipVelocity(displacement,timeline,VELOCITY_SMOOTH);

%% set target path
TARGET_PATH='';

currentTargetPath='';
if ~strcmp(TARGET_PATH,'')
    currentTargetPath=[TARGET_PATH num2str(EVENT_NUM)];
    mkdir(currentTargetPath);
end

%% plot displacement, velocity, light intensity & light in time
LIGHT_INTENSITY_REFERENCE_FRAMES=1:5;
PLOT_LIGHT_IN_TIME=[70 90 110 130 150];
CRACK_TIME_THRESHOLD=0.004;
CRACK_TIME_SMOOTHING=[17 7];

plotDisplacement(displacement,timeline,currentTargetPath);
plotVelocity(velocity,timeline,currentTargetPath);

lightXT = getNormalizedContactArea(vid,LIGHT_INTENSITY_REFERENCE_FRAMES);
plotLightXT(lightXT,xAxis,timeline,currentTargetPath);
return;
plotLightInTime(lightXT, xAxis, timeline, PLOT_LIGHT_IN_TIME,currentTargetPath);

crackTime=getCrackTime(vid,LIGHT_INTENSITY_REFERENCE_FRAMES,CRACK_TIME_THRESHOLD,CRACK_TIME_SMOOTHING);
plotCrackTime(crackTime,xAxis,timeline,currentTargetPath);
plotCrackTimeForDisplacement(crackTime,xAxis,FRAMES_PER_MILLISECOND,currentTargetPath);

%% get sg data

sgData=GetSgData(SOURCE_PATH,EVENT_NUM,'shift','fix','');

sgTimeline=sgData.t;
sgTimelineRange=find(sgTimeline>timeline(1)&sgTimeline<timeline(end));
sgTimeline=sgTimeline(sgTimelineRange);
Uxx=sgData.Uxx(sgTimelineRange,:);
Syy=sgData.Syy(sgTimelineRange,:);
displacementForSG=changeAxis(timeline,sgTimeline,displacement);

%% plot sg for displacement
SG_INDICES=[1 2 4 5 7 8 9 10 11 12 13 14 15 16 17 18 19];

for i=1:size(SG_INDICES,2)   
    %% plot sg for displacement
    currentIndex=SG_INDICES(i);
    
    currentUxx=Uxx(:,currentIndex);
    currentSyy=Syy(:,currentIndex);
    
    sgX=sgData.x_sg(:,currentIndex);
    sgH=sgData.y_sg(currentIndex);
    xMinusXTip=sgX*1000-displacementForSG;
    
    [minUxx minUxxInd]=min(currentUxx);
    [maxUxx maxUxxInd]=max(currentUxx);
    [minSyy minSyyInd]=min(currentSyy);
    [maxSyy maxSyyInd]=max(currentSyy);

    DeltaOfUxx=maxUxx-minUxx;
    DeltaOfSyy=maxSyy-minSyy;
    
    %% add deltas to result
    currentIndex=size(result,1)+1;
    result(currentIndex,:)=[DeltaOfUxx,DeltaOfSyy];
    
    %% plots
    plotSgForDisplacement(currentUxx,[minUxxInd,maxUxxInd],xMinusXTip,'U_{xx}','Uxx',sgX,currentTargetPath);
    plotSgForDisplacement(currentSyy,[minSyyInd maxSyyInd],xMinusXTip,'\sigma_{yy}','Syy',sgX,currentTargetPath);
end