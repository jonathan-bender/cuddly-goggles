%% read video
VID_SOURCE_PATH='D:\Experiments\2023-5-16\16-20-16\Ph';
VID_EVENT_NUM=3;
READ_START=-5500;
READ_LENGTH=2000;
TRIGGER_DELAY=7;
FRAMES_PER_MILLISECOND = 581.196;

rawVideo=readBinVideo(VID_SOURCE_PATH,VID_EVENT_NUM, READ_START,READ_LENGTH);
timeline=getVideoTimeline(READ_START,READ_LENGTH,TRIGGER_DELAY,FRAMES_PER_MILLISECOND);

% process video
% video data
PIXELS_PER_MICRON = 0.006315;
TOTAL_LENGTH=200000;

% video processing
EDGE_DROP_RANGE=10;
REFERENCE_FRAMES=1:50;
SOURCE_FREQUENCY=115;
SOURCE_FREQUENCY_WIDTH=1;
TRIM_EDGES=[100 1250];

vid=removeSourceFrequency(rawVideo, SOURCE_FREQUENCY, SOURCE_FREQUENCY_WIDTH, FRAMES_PER_MILLISECOND);
vid=trimEdges(vid,TRIM_EDGES);
[xAxis, vid]=getXAxisFromDarkEdges(vid, PIXELS_PER_MICRON, TOTAL_LENGTH, REFERENCE_FRAMES, EDGE_DROP_RANGE);

% get displacement
CRACK_TIP_THRESHOLD=0.97;

displacement = getTipDisplacement(vid,xAxis,REFERENCE_FRAMES,CRACK_TIP_THRESHOLD);

% trim before and after motion
motionInd=find(isfinite(displacement));
displacement=displacement(motionInd);
timeline=timeline(motionInd);
vid=vid(:,:,motionInd);

% get velocity
VELOCITY_SMOOTH=3;

velocity = getTipVelocity(displacement,timeline,VELOCITY_SMOOTH);

% set target path
TARGET_PATH=['C:\Users\owner\Documents\Jonathan\Experiments\Analysis\Photron2\May16\' num2str(VID_EVENT_NUM)];

if ~strcmp(TARGET_PATH,'')
    mkdir(TARGET_PATH);
end

% plot displacement, velocity, light intensity & light in time
LIGHT_INTENSITY_REFERENCE_FRAMES=1:5;
PLOT_LIGHT_IN_TIME=[70 90 110 130 150];
CRACK_TIME_THRESHOLD=0.004;
CRACK_TIME_SMOOTHING=[17 7];

plotDisplacement(displacement,timeline,TARGET_PATH);
plotVelocity(velocity,timeline,TARGET_PATH);

lightXT = getNormalizedContactArea(vid,LIGHT_INTENSITY_REFERENCE_FRAMES);
plotLightXT(lightXT,xAxis,timeline,TARGET_PATH);

plotLightInTime(lightXT, xAxis, timeline, PLOT_LIGHT_IN_TIME,TARGET_PATH);

crackTime=getCrackTime(vid,LIGHT_INTENSITY_REFERENCE_FRAMES,CRACK_TIME_THRESHOLD,CRACK_TIME_SMOOTHING);
plotCrackTime(crackTime,xAxis,timeline,TARGET_PATH);
plotCrackTimeForDisplacement(crackTime,xAxis,FRAMES_PER_MILLISECOND,TARGET_PATH);
