
%% constants
% read video
SOURCE_PATH='C:\Users\owner\Documents\Jonathan\Experiments\RawResults\Mar30';
RANGE = [];
MAX_READ = 400;

% video data
FRAMES_PER_MILLISECOND = 581.196;
PIXELS_PER_MICRON = 0.006315;
TOTAL_LENGTH=200000;
TRIGGER_FRAME=5500;
TRIGGER_DELAY=7.69;

% video processing
EDGE_DROP_RANGE=5;
REFERENCE_FRAMES=1:10;
MOTION_STEP=20;
SOURCE_FREQUENCY=115;
SOURCE_FREQUENCY_WIDTH=1;
TRIM_EDGES=[1 1280];

% crack tip
CRACK_TIP_THRESHOLD=0.97;
MIN_DROP=0.0005;
MIN_DROP_RANGE=100;

% light in time
LIGHT_IN_TIME=[60 80 100 120 140 160];

% target path
TARGET_PATH='C:\Users\owner\Documents\Jonathan\Experiments\Analysis\Photron2\Mar30';

%% folder details
fileNames = cellstr(ls(SOURCE_PATH));
aviFiles = fileNames(cell2mat(cellfun(@(x) size(regexp(x, '(\.avi)$'),1) > 0, fileNames,'UniformOutput', false)));

fileNum = size(aviFiles);

disp(strcat('Processing files for: ', SOURCE_PATH));

%% process folder
for i=1:fileNum
   iStr = num2str(i);
   currentSourceFilename = char(aviFiles(cell2mat(cellfun(@(x) size(regexp(x, ['\D' iStr '(\.avi)$']),1) > 0, aviFiles,'UniformOutput', false))));
   
    currentPath = strcat(SOURCE_PATH, '\', currentSourceFilename);
    currentTargetPath = strcat(TARGET_PATH, '\', iStr);
    mkdir(currentTargetPath);
    %% read video
    [motionStart,motionEnd, motionVid] = readNearMotion(currentPath, RANGE, MAX_READ);

    %% process video
    vid=removeSourceFrequency(motionVid, SOURCE_FREQUENCY, SOURCE_FREQUENCY_WIDTH, FRAMES_PER_MILLISECOND);

    vid=trimEdges(vid,TRIM_EDGES);
    
    [readStart,readEnd,vid]=trimBeforeAndAfterMotion(vid,MOTION_STEP,motionStart,motionEnd);

    timeline=getVideoTimeline(readStart,readEnd,TRIGGER_FRAME,TRIGGER_DELAY,FRAMES_PER_MILLISECOND);

    [xAxis, vid]=getXAxisFromDarkEdges(vid, PIXELS_PER_MICRON, TOTAL_LENGTH, REFERENCE_FRAMES, EDGE_DROP_RANGE);
    
    if size(vid,2) == 1
        continue;
    end 

    %% plots
    
    %displacement = getTipDisplacement(vid,xAxis,REFERENCE_FRAMES,CRACK_TIP_THRESHOLD,MIN_DROP,MIN_DROP_RANGE);
    %plotDisplacement(displacement,timeline,currentTargetPath);

    lightXT = getNormalizedContactArea(vid,REFERENCE_FRAMES);
    plotLightXT(lightXT,xAxis,timeline,currentTargetPath);
    
    crackVid = getNormalizedDrop(vid);
    exportColormap(crackVid,currentTargetPath);
    
    %plotLightInTime(lightXT,xAxis,timeline, LIGHT_IN_TIME,currentTargetPath);
end
