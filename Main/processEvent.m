
%% constants

% read video
SOURCE_PATH='C:\Users\owner\Documents\Jonathan\Experiments\RawResults\Feb19\Exp_Cam_10832_Cine17.avi';
RANGE = [];
MAX_READ = 250;

% video data
FRAMES_PER_MILLISECOND = 581;
PIXELS_PER_MICRON = 0.006315;
TOTAL_LENGTH=200000;
TRIGGER_FRAME=5500;
TRIGGER_DELAY=7.77;

% video processing
EDGE_DROP_RANGE=9;
REFERENCE_FRAMES=1:30;
MOTION_STEP=0;
SOURCE_FREQUENCY=115;
SOURCE_FREQUENCY_WIDTH=1;

% crack tip
CRACK_TIP_THRESHOLD=0.999;
MIN_DROP=0.1;
MIN_DROP_RANGE=5;

% strain gauge
SG_SOURCE_PATH='D:/Experiments/2023-2-19/19-10-38';
SG_EVENT_NUM=17;
U_XX=1:19;
U_YY=1:19;

% target path
TARGET_PATH='C:\Users\owner\Documents\Jonathan\Experiments\Analysis\Photron2\Feb19\17';


%% read video
[readStart,readEnd, vid] = readNearMotion(SOURCE_PATH, RANGE, MAX_READ);

%% process video
vid=removeSourceFrequency(vid, SOURCE_FREQUENCY, SOURCE_FREQUENCY_WIDTH, FRAMES_PER_MILLISECOND);

[readStart,readEnd,vid]=trimBeforeAndAfterMotion(vid,MOTION_STEP,readStart,readEnd);

timeline=getVideoTimeline(readStart,readEnd,TRIGGER_FRAME,TRIGGER_DELAY,FRAMES_PER_MILLISECOND);

xAxis=getXAxisFromDarkEdges(vid, PIXELS_PER_MICRON, TOTAL_LENGTH, REFERENCE_FRAMES, EDGE_DROP_RANGE);

%% strain gauge
sgData=GetSgData(SG_SOURCE_PATH,SG_EVENT_NUM,'shift','fix','');

%% plots
displacement = getTipDisplacement(vid,xAxis,REFERENCE_FRAMES,CRACK_TIP_THRESHOLD,MIN_DROP,MIN_DROP_RANGE);
plotDisplacement(displacement,timeline,TARGET_PATH);

lightXT = getNormalizedContactArea(vid,REFERENCE_FRAMES);
plotLightXT(lightXT,xAxis,timeline,TARGET_PATH);

for i=1:size(U_XX,2)
    Uxx=U_XX(i);
    [sgXAxis sgPosition]=getSgXAxis(sgData,Uxx,timeline,displacement);
    plotSgForDisplacement(sgData.Uxx(:,Uxx),sgXAxis,'U_{xx}','Uxx',sgPosition,TARGET_PATH);
end

for i=1:size(U_YY,2)
    Uyy=U_YY(i);
    [sgXAxis sgPosition]=getSgXAxis(sgData,Uyy,timeline,displacement);
    plotSgForDisplacement(sgData.Uyy(:,Uyy),sgXAxis,'U_{yy}','Uyy',sgPosition,TARGET_PATH);
end