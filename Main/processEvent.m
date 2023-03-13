function processEvent(sourcePath, sgSourcePath, sgEventNum, targetPath)
% reading cam file
RANGE = [];
MAX_READ = 200;

% video data
FRAMES_PER_MILLISECOND = 581;
PIXELS_PER_MICRON = 0.006315;
TOTAL_LENGTH=200000;
TRIGGER_FRAME=5500;
TRIGGER_DELAY=7.68;

% video processing
TRIMMING=[];
TRIM_NOISY_EDGES=0;
MIN_SIGNAL=0;
EDGE_DROP_RANGE=9;
REFERENCE_FRAMES=1:10;
MAX_SMOOTHING=5;
SOURCE_FREQUENCY=115;
SOURCE_FREQUENCY_WIDTH=1;

% crack tip
CRACK_TIP_THRESHOLD=0.985;
MIN_DROP=0.08;
MIN_DROP_RANGE=20;

% strain gauge
U_XX=1:19;
U_YY=1:19;

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

xAxis=getXAxisFromDarkEdges(vid, PIXELS_PER_MICRON, TOTAL_LENGTH, REFERENCE_FRAMES, EDGE_DROP_RANGE);

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

displacement = getTipDisplacement(vid,xAxis,REFERENCE_FRAMES,CRACK_TIP_THRESHOLD,MIN_DROP,MIN_DROP_RANGE);
displacement(1:25)=NaN(25,1);
plotDisplacement(displacement,timeline,targetPath);

lightXT = getNormalizedContactArea(vid,REFERENCE_FRAMES);
plotLightXT(lightXT,xAxis,timeline,targetPath);

sgData=GetSgData(sgSourcePath,sgEventNum,'shift','fix','');

for i=1:size(U_XX,2)
    Uxx=U_XX(i);
    [sgXAxis sgPosition]=getSgXAxis(sgData,Uxx,timeline,displacement);
    plotSgForDisplacement(sgData.Uxx(:,Uxx),sgXAxis,'U_{xx}','Uxx',sgPosition,targetPath);
end

for i=1:size(U_YY,2)
    Uyy=U_YY(i);
    [sgXAxis sgPosition]=getSgXAxis(sgData,Uyy,timeline,displacement);
    plotSgForDisplacement(sgData.Uyy(:,Uyy),sgXAxis,'U_{yy}','Uyy',sgPosition,targetPath);
end

end