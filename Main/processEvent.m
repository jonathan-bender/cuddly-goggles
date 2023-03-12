function processEvent(sourcePath, sgSourcePath, sgEventNum, targetPath)

% reading cam file
RANGE = [];
MAX_READ = 400;

% video data
FRAMES_PER_MILLISECOND = 581;
PIXELS_PER_MICRON = 200000/1280;
TOTAL_LENGTH=200000;
TRIGGER_FRAME=5500;
TRIGGER_DELAY=7.86;

% video processing
TRIMMING=[];
TRIM_NOISY_EDGES=0;
MIN_SIGNAL=0.05;
MIN_LIGHT=50;
REFERENCE_FRAMES=1:30;
MAX_SMOOTHING=5;
SOURCE_FREQUENCY=115;
SOURCE_FREQUENCY_WIDTH=1;

% crack tip
CRACK_TIP_THRESHOLD=0.97;

% strain gauge
U_XX=[2 3 5 7];
U_YY=[];

disp(strcat('Processing event at : ', sourcePath));

[readStart,readEnd, vid] = readNearMotion(sourcePath, RANGE, MAX_READ);

timeline=getVideoTimeline(readStart,readEnd,TRIGGER_FRAME,TRIGGER_DELAY,FRAMES_PER_MILLISECOND);

vid=trimEdges(vid,TRIMMING);

vid=trimNoisyEdges(vid, TRIM_NOISY_EDGES, MIN_SIGNAL, MAX_SMOOTHING);

if(size(vid,2) == 0)
    disp('WARNING: Event is too noisy. No results obtained');
    return;
end

vid=nullifyNoisyPixels(vid, MIN_SIGNAL, MAX_SMOOTHING);

xAxis=getXAxisFromDarkEdges(vid, PIXELS_PER_MICRON, TOTAL_LENGTH, REFERENCE_FRAMES, MIN_LIGHT);

vid=removeSourceFrequency(vid, SOURCE_FREQUENCY, SOURCE_FREQUENCY_WIDTH, FRAMES_PER_MILLISECOND);

% this should be done further down
if 0
[crackStart,crackEnd,vid]=trimBeforeAndAfterMotion(vid,MAX_SMOOTHING,readStart,readEnd);

length = crackEnd - crackStart;

if length < MIN_LENGTH
    disp('WARNING: Event is too short. No results obtained.');
    return;
end

if crackStart < MAX_SMOOTHING
    disp('WARNING: nucleation near first frame');
end

end

displacement = getTipDisplacement(vid,xAxis,REFERENCE_FRAMES,CRACK_TIP_THRESHOLD);
plotDisplacement(displacement,timeline);

lightXT = getNormalizedContactArea(vid,REFERENCE_FRAMES);
plotLightXT(lightXT,xAxis,timeline);

sgData=getStrainGaugeData(sgSourcePath,sgEventNum);
sgForDisplacement=getStrainGaugeForDisplacement(sgData,U_XX,U_YY,timeline,displacement);

plotSgForDisplacement();

end