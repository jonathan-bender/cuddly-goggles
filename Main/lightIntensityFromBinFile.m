

%% constants

% read video
VID_SOURCE_PATH='';
VID_EVENT_NUM=5;
RANGE = [];
MAX_READ = 400;

% video data
FRAMES_PER_MILLISECOND = 581.196;
PIXELS_PER_MICRON = 0.006315;
TOTAL_LENGTH=200000;
TRIGGER_FRAME=5500;

% video processing
EDGE_DROP_RANGE=9;
REFERENCE_FRAMES=1:30;
MOTION_STEP=10;
SOURCE_FREQUENCY=115;
SOURCE_FREQUENCY_WIDTH=1;
TRIM_EDGES=[];

% crack tip
CRACK_TIP_THRESHOLD=0.97;
MIN_DROP=0.0005;
MIN_DROP_RANGE=10;

% strain gauge
SG_SOURCE_PATH='D:\Experiments\2023-1-23\20-52-14';
SG_EVENT_SHIFT=1;
SG_EVENT_NUM=5;
U_XX=1:19;
U_YY=1:19;

% stress drop points
TIP_RANGE=50;

% target path
TARGET_PATH='C:\Users\owner\Documents\Jonathan\Experiments\Analysis\Photron2\Mar23\10';

%% read video
motionVid=phantomReadImsNew(VID_SOURCE_PATH,VID_EVENT_NUM,1,1,5e5,1,'all');

%% process video
vid=removeSourceFrequency(motionVid, SOURCE_FREQUENCY, SOURCE_FREQUENCY_WIDTH, FRAMES_PER_MILLISECOND);

[readStart,readEnd,vid]=trimBeforeAndAfterMotion(vid,MOTION_STEP,motionStart,motionEnd);

vid=trimEdges(vid,TRIM_EDGES);

timeline=getVideoTimeline(readStart,readEnd,TRIGGER_FRAME,TRIGGER_DELAY,FRAMES_PER_MILLISECOND);

[xAxis, vid]=getXAxisFromDarkEdges(vid, PIXELS_PER_MICRON, TOTAL_LENGTH, REFERENCE_FRAMES, EDGE_DROP_RANGE);


%% plot light xt
displacement = getTipDisplacement(vid,xAxis,REFERENCE_FRAMES,CRACK_TIP_THRESHOLD,MIN_DROP,MIN_DROP_RANGE);
plotDisplacement(displacement,timeline,TARGET_PATH);

lightXT = getNormalizedContactArea(vid,REFERENCE_FRAMES);
plotLightXT(lightXT,xAxis,timeline,TARGET_PATH);

%% get sg data
sgData=GetSgData(SG_SOURCE_PATH,SG_EVENT_NUM,'shift','fix','');

%% plot sg
for i=1:size(U_XX,2)
    Uxx=U_XX(i);
    [sgXAxis,sgPosition]=getSgXAxis(sgData,Uxx,timeline,displacement);
    plotSgForDisplacement(sgData.Uxx(:,Uxx),sgXAxis,'U_{xx}','Uxx',sgPosition,TARGET_PATH);
end

for i=1:size(U_YY,2)
    Uyy=U_YY(i);
    [sgXAxis,sgPosition]=getSgXAxis(sgData,Uyy,timeline,displacement);
    plotSgForDisplacement(sgData.Uyy(:,Uyy),sgXAxis,'U_{yy}','Uyy',sgPosition,TARGET_PATH);
end