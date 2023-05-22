
%% constants

% read video
SOURCE_PATH='C:\Users\owner\Documents\Jonathan\Experiments\RawResults\May14\Exp_Cam_10832_Cine5.avi';
RANGE = [];
MAX_READ = 500;

% video data
FRAMES_PER_MILLISECOND = 581.196;
PIXELS_PER_MICRON = 0.006315;
TOTAL_LENGTH=200000;
TRIGGER_FRAME=5500;
TRIGGER_DELAY=7.262;

% video processing
EDGE_DROP_RANGE=9;
REFERENCE_FRAMES=1:30;
MOTION_STEP=10;
SOURCE_FREQUENCY=115;
SOURCE_FREQUENCY_WIDTH=1;
TRIM_EDGES=[300 1250];

% crack tip
CRACK_TIP_THRESHOLD=0.97;
MIN_DROP=0.0005;
MIN_DROP_RANGE=10;

% strain gauge

SG_SOURCE_PATH='D:\Experiments\2023-3-23\14-3-28';
SG_EVENT_NUM=13;
U_XX=[];
U_YY=[];

% stress drop points
STRESS_DROP_INDICES = [];
STRESS_DROP_RANGE=0.02;

% target path
TARGET_PATH='';

%% read video
[motionStart,motionEnd, motionVid] = readNearMotion(SOURCE_PATH, RANGE, MAX_READ);

%% process video
vid=removeSourceFrequency(motionVid, SOURCE_FREQUENCY, SOURCE_FREQUENCY_WIDTH, FRAMES_PER_MILLISECOND);

[readStart,readEnd,vid]=trimBeforeAndAfterMotion(vid,MOTION_STEP,motionStart,motionEnd);

vid=trimEdges(vid,TRIM_EDGES);

timeline=getVideoTimeline(readStart,MAX_READ,TRIGGER_DELAY,FRAMES_PER_MILLISECOND);

%[xAxis, vid]=getXAxisFromDarkEdges(vid, PIXELS_PER_MICRON, TOTAL_LENGTH, REFERENCE_FRAMES, EDGE_DROP_RANGE);

%% strain gauge
sgData=GetSgData(SG_SOURCE_PATH,SG_EVENT_NUM,'shift','fix','');

%% plots
%displacement = getTipDisplacement(vid,xAxis,REFERENCE_FRAMES,CRACK_TIP_THRESHOLD,MIN_DROP,MIN_DROP_RANGE);
%plotDisplacement(displacement,timeline,TARGET_PATH);

lightXT = getNormalizedContactArea(vid,REFERENCE_FRAMES);
plotLightXT(lightXT,xAxis,timeline,TARGET_PATH);


if size(STRESS_DROP_INDICES) > 0
    [deltaUxx,deltaSyy] = getStressDrops(sgData,STRESS_DROP_INDICES, timeline, displacement, STRESS_DROP_RANGE);
    plotStressDrop(deltaUxx,deltaSyy, TARGET_PATH);
end