function processEvent(sourcePath, targetPath)

% reading cam file
RANGE = [];
MAX_READ = 400;

% video processing
TRIMMING=[];
TRIM_NOISY_EDGES=0;
MIN_SIGNAL=0.05;
MAX_SMOOTHING=5;
SOURCE_FREQUENCY=115;
SOURCE_FREQUENCY_WIDTH=1;

% video data
FRAMES_PER_MILLISECOND = 581;
PIXELS_PER_MICRON = 200000/1280;

disp(strcat('Processing event at : ', sourcePath));

[readStart,readEnd, vid] = readNearMotion(sourcePath, RANGE, MAX_READ);

vid=trimEdges(vid,TRIMMING);

vid=trimNoisyEdges(vid, TRIM_NOISY_EDGES, MIN_SIGNAL, MAX_SMOOTHING);

vid=nullifyNoisyPixels(vid, MIN_SIGNAL, MAX_SMOOTHING);

if(size(vid,2) == 0)
    disp('WARNING: Event is too noisy. No results obtained');
    return;
end

vid=removeSourceFrequency(vid, SOURCE_FREQUENCY,SOURCE_FREQUENCY_WIDTH, FRAMES_PER_MILLISECOND);

[crackStart,crackEnd,vid]=trimBeforeAndAfterMotion(vid,MAX_SMOOTHING,readStart,readEnd);

length = crackEnd - crackStart;

if length < MIN_LENGTH
    disp('WARNING: Event is too short. No results obtained.');
    return;
end

if crackStart < MAX_SMOOTHING
    disp('WARNING: nucleation near first frame');
end

if crackEnd > totalFrames - MAX_SMOOTHING
    disp('WARNING: nucleation near last frame');
end

displacement = getTipDisplacement();
plotDisplacement();


velocity = getTipVelocity();
plotVelocity();

lightXT = getLightXT();
plotLightXT();

lightPeriodiogram = getLightPeriodiogram();
plotLightPeriodiorgam();

lightInTime = getLightInTime();
plotLightInTime();

end