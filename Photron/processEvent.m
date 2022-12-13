function processEvent(sourcePath, targetPath)
RANGE = [];
SMOOTHING = 3;
INCLUDE_MAX_READ = 0;
TRIMMING = [500 1150];
LIGHT_UPPER_LIMIT = 0.6;
LIGHT_LOWER_LIMIT = 0.15;
LIGHT_BINNING = 2;
FRAMES_PER_MILLISECOND = 581;
PIXELS_PER_MICRON = 200000/1280;
SAVE_VIDEO = 1;
PLOT_COORDINATES = [30 60 90];
SHOW_VELOCITY_PLOT = 1;
LIGHT_PERIODIOGRAM_RANGE = [];
MIN_LENGTH = 20;
MAX_SMOOTHING = 5;
MAX_READ = 180;
MIN_SIGNAL = 0.03; % mininum signal to noise ratio for noisy pixels

disp(strcat('Processing event at : ', sourcePath));

reader = VideoReader(sourcePath);

totalFrames = int64(reader.NumberOfFrames);

if size(RANGE,1)==0
    RANGE = [1 totalFrames];
end

firstFrame = read(reader, RANGE(1));
lastFrame = read(reader, RANGE(2));

firstAmplitude = getLightFromFrame(firstFrame);
lastAmplitude = getLightFromFrame(lastFrame);

midAmplitude = (firstAmplitude+lastAmplitude)/2;

midTime = findFirstAmplitude(midAmplitude, reader, RANGE(1), RANGE(2));

readStart = midTime - MAX_READ/2;
readEnd = midTime + MAX_READ/2;

if readStart < RANGE(1)
    readStart = RANGE(1);
    readEnd = RANGE(1) + MAX_READ;
end

if readEnd > RANGE(2)
    readStart = RANGE(2) - MAX_READ;
    if readStart < 1 % could be replaced by comparing the length of the video to the max length
        readStart = 1;
    end
    readEnd = RANGE(2);
end

vid = read(reader, [readStart,readEnd]);

vid = squeeze(vid(:,:,1,:));

if size(TRIMMING,1) ~= 0
    vid = vid(:,TRIMMING(1):TRIMMING(2),:);
end

currentColumn = 1;
while currentColumn < size(vid,2)
    if ~isNoisyColumn(vid(:,currentColumn,:),MIN_SIGNAL, MAX_SMOOTHING)
        break;
    end

    currentColumn=currentColumn+1;
end

vid = vid(:,currentColumn+1:end,:);

currentColumn = size(vid,2);
while currentColumn > 0
    if ~isNoisyColumn(vid(:,currentColumn,:), MIN_SIGNAL, MAX_SMOOTHING)
        break;
    end

    currentColumn=currentColumn-1;
end

vid = vid(:,1:currentColumn-1,:);

if(size(vid,2) == 0)
    disp('WARNING: Event is too noisy. No results obtained');
    return;
end

for i=1:size(vid,1)
    for j=1:size(vid,2)
        if isNoisy(vid(i,j,:), MIN_SIGNAL, MAX_SMOOTHING)
            vid(i,j,:) = 0;
        end
    end
end

vid = permute(vid, [3 1 2]);
vid = removeSourceFrequency(double(vid), FRAMES_PER_MILLISECOND);
vid = permute(vid, [2 3 1]);

crackStart = readStart;
crackEnd = readEnd;

if(~INCLUDE_MAX_READ)
    [crackStart, crackEnd] = getCrackStartAndEnd(vid, MAX_SMOOTHING, readStart, readEnd);
    vid = vid(:,:,(crackStart-readStart+1):(end-readEnd+crackEnd));
end

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

oneDimLight = sum(vid,1);
oneDimLight = squeeze(normalizeVid(oneDimLight, 0));

normalizedVid = -double(vid);
normalizedVid = normalizeVid(normalizedVid, -1);

maxSmoothed = permute(normalizedVid, [3 1 2]);
smoothFilt = ones(1, MAX_SMOOTHING)/MAX_SMOOTHING;
maxSmoothed = filtfilt(smoothFilt, 1, maxSmoothed);
maxSmoothed = permute(maxSmoothed, [2 3 1]);

noise = normalizedVid - maxSmoothed;
meanNoise = prctile(noise(:), 90);
signalToNoiseRatio = 1/meanNoise;

fprintf(strcat('Crack start: ', num2str(crackStart),'.\t Total frames: ', num2str(length), '.\t Signal to noise ratio: ', num2str(signalToNoiseRatio), '\r'));

%-- TODO: smoothing should be done by the S/N ratio 
if SMOOTHING > 1
    smoothed = permute(normalizedVid, [3 1 2]);
    smoothFilt = ones(1, SMOOTHING)/SMOOTHING;
    smoothed = filtfilt(smoothFilt, 1, smoothed);
    smoothed = permute(smoothed, [2 3 1]);
else
    smoothed = normalizedVid;
end

transformed = vidTransform(smoothed, LIGHT_UPPER_LIMIT, LIGHT_LOWER_LIMIT, LIGHT_BINNING);

oneDimVid = sum(smoothed,1);
oneDimVid = normalizeVid(oneDimVid,-1);
oneDimVidTransformed = squeeze(vidTransform(oneDimVid, LIGHT_UPPER_LIMIT, LIGHT_LOWER_LIMIT, LIGHT_BINNING));

displacement = squeeze(sum(oneDimVidTransformed,1)) * PIXELS_PER_MICRON;
velocity = getVelocity(displacement, FRAMES_PER_MILLISECOND);

disp(strcat('Saving results to: ', targetPath));

if SAVE_VIDEO == 1
    exportCrackColormap(transformed, targetPath);
end

if size(PLOT_COORDINATES,1) ~= 0
    plotLightInTime(oneDimLight, targetPath, PLOT_COORDINATES, FRAMES_PER_MILLISECOND, PIXELS_PER_MICRON);
end

if SHOW_VELOCITY_PLOT == 1
    plotDisplacement(displacement, targetPath, FRAMES_PER_MILLISECOND);
    plotVelocity(velocity, targetPath, FRAMES_PER_MILLISECOND);
end

if size(LIGHT_PERIODIOGRAM_RANGE,1) ~= 0
    showPeriodiogram(sourcePath, lightPeriodiogramRange, FRAMES_PER_MILLISECOND);
end
end

function Light=getLightFromFrame(vidFrame)
Light = sum(sum(vidFrame(:,:,1),'double'),'double');
end

function FrameIndex=findFirstAmplitude(amplitude, reader, firstFrame, lastFrame)
FrameIndex = firstFrame;

while abs(firstFrame-lastFrame)>2

    currentAmplitude = getLightFromFrame(read(reader, FrameIndex));
    if(currentAmplitude > amplitude)
        firstFrame =  FrameIndex;
    end

    if(currentAmplitude < amplitude)
        lastFrame = FrameIndex;
    end

    if (currentAmplitude == amplitude)

        return;
    end

    FrameIndex = floor((firstFrame + lastFrame) / 2);
end
end

function Normalized=normalizeVid(vid, absMin)

Normalized = zeros(size(vid));

for i=1:size(vid,1)
    for j=1:size(vid,2)

        minValue = vid(i,j,1);
        maxValue = vid(i,j,1);

        for k=1:size(vid,3)
            current = vid(i,j,k);
            if(current < minValue)
                minValue = current;
            end

            if(current > maxValue)
                maxValue = current;
            end
        end

        if absMin >= 0
            minValue = absMin;
        end

        drop = double(maxValue - minValue);
        if drop == 0
            drop = 1;
        end

        for k=1:size(vid,3)
            current = vid(i,j,k);
            Normalized(i,j,k) = double(current - minValue)/drop;
        end
    end
end

end

function Result=removeSourceFrequency(mat, framesPerMillisecond)
if size(mat, 1) < 5
    Result = mat;
    return;
end

Hd = filterDesign(114,116, framesPerMillisecond);
Result = filtfilt(Hd.sosMatrix,Hd.ScaleValues,mat);
end


function [CrackStart,CrackEnd]=getCrackStartAndEnd(vid, maxSmoothing, readStart, readEnd)
midTime = round(size(vid,3)/2);

currentAmp = sum(sum(vid(:,:,midTime), 'double'), 'double');
for i=midTime+maxSmoothing:maxSmoothing:size(vid,3)
    prevAmp = currentAmp;
    currentAmp = sum(sum(vid(:,:,i)));
    if prevAmp <= currentAmp
        CrackEnd = readEnd - size(vid,3) + i;
        break;
    end
end

currentAmp = sum(sum(vid(:,:,midTime)));
for i=midTime-maxSmoothing:-maxSmoothing:1
    prevAmp = currentAmp;
    currentAmp = sum(sum(vid(:,:,i)));
    if prevAmp >= currentAmp
        CrackStart = readStart + i;
        break;
    end
end
end

function Velocity=getVelocity(displacement, framesPerMillisecond)
timeSize = size(displacement,2);
Velocity = zeros(timeSize, 1);

for i=2:timeSize
    Velocity(i) = (displacement(i) - displacement(i-1)) * framesPerMillisecond / 1000;
end
end

function Hd = filterDesign(from,to, framesPerMillisecond)
Fs = framesPerMillisecond;  % Sampling Frequency

N   = 4;      % Order
Fc1 = from;  % First Cutoff Frequency
Fc2 = to;  % Second Cutoff Frequency

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.bandstop('N,F3dB1,F3dB2', N, Fc1, Fc2, Fs);
Hd = design(h, 'butter');
end

function showPeriodiogram(sourcePath, range, framesPerMillisecond)
reader = VideoReader(sourcePath);

if size(range,1)==0
    range = [1 double(reader.NumberOfFrames)];
end

numOfPoints = 201;

lightPoints = linspace(range(1),range(2),numOfPoints);

totalLight = zeros(numOfPoints,1);

for i=1:numOfPoints
    frame = read(reader, lightPoints(i));

    totalLight(i) = getLightFromFrame(frame(:,:,:));
end

totalLight = totalLight - mean(totalLight);

Hd = filterDesign(115.3,115.7, framesPerMillisecond);
filteredLight = filtfilt(Hd.sosMatrix,Hd.ScaleValues,totalLight);

[pxxOriginal,w] = periodogram(totalLight);

[pxx,w] = periodogram(filteredLight);


figure;

xAxis = w*framesPerMillisecond/(2*pi);

plot(xAxis, 10*log10(pxxOriginal), xAxis, 10*log10(pxx));

legend('original','filtered');
end

function IsNoisy=isNoisy(arr,minRatio,spread)
drop = mean(arr(1:spread)) - mean(arr(end-spread:end));
arrMean = mean(arr);

IsNoisy = double(drop) / arrMean < minRatio;
end

function IsNoisy=isNoisyColumn(vid, minRatio, spread)
noisyPixels =0;
for i=1:size(vid,1)
    if isNoisy(vid(i,1,:), minRatio, spread)
        noisyPixels = noisyPixels +1;
    end
end

IsNoisy = noisyPixels > size(vid,1)/2;
end

function Vid=vidTransform(vid,upperLimit, lowerLimit, binning)
for i=1:size(vid,1)
    for j=1:size(vid,2)
        for k=1:size(vid,3)
            if vid(i,j,k) > upperLimit
                vid(i,j,k) = upperLimit;
            end

            if vid(i,j,k) < lowerLimit
                vid(i,j,k) = lowerLimit;
            end
        end
    end
end

vid=normalizeVid(vid,-1);
Vid = vid;
if binning == 0
    return;
end

for i=1:size(vid,1)
    for j=1:size(vid,2)
        for k=1:size(vid,3)
            Vid(i,j,k) = round(Vid(i,j,k) * binning)/binning; 
        end
    end
end

end