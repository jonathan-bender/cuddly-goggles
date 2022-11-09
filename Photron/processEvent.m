function processEvent(sourcePath, targetPath, range, smoothing, trimming, framesPerMillisecond, pixelsPerMicrons, saveVideo, plotCoordinates, showVelocityPlot, lightPeriodiogramRange)
    NORM_MARGIN = 20;
    MIN_LENGTH = 15;

    disp(strcat('Processing event at : ', sourcePath));

    reader = VideoReader(sourcePath);
    
    totalFrames = int64(reader.NumberOfFrames);
    
    if size(range,1)==0
        range = [1 totalFrames];
    end
    
    [Start, End]= getCrackTimes(reader, range(1), range(2));
    
    length = End - Start;
    
    if length < MIN_LENGTH
        disp('WARNING: Event is too short. No results obtained.');
        return;
    end
    
    margin = floor(length/4);
    rangeStart = range(1);
    readStart = rangeStart + Start - margin  - NORM_MARGIN;
    readEnd = rangeStart  + End;
    
    if readStart < 1
        readStart = 1;
        disp('WARNING: nucleation near first frame');
    end
    
    if readEnd > totalFrames
        readEnd = totalFrames;
        disp('WARNING: nucleation near last frame');
    end
    
    frames = read(reader, [readStart, readEnd]);
    
    vid = squeeze(frames(:,:,1,:));
    
    if size(trimming,1) ~= 0
        vid = vid(:,trimming(1):trimming(2),:);
    end
    
    vid = -double(vid);
    vid = normalize(vid, []);
    crackTime = getCrackTime(vid) - NORM_MARGIN;
    vid = vid(:,:,1:crackTime+NORM_MARGIN);
    vid = permute(vid, [3 1 2]);
    vid = removeSourceFrequency(vid, framesPerMillisecond);
    if smoothing > 1
        smoothFilt = ones(1, smoothing)/smoothing;
        vid = filtfilt(smoothFilt, 1, vid);
    end
    vid = permute(vid, [2 3 1]);
    
    vid = normalize(vid, 1:NORM_MARGIN);
    
    signalToNoiseRatio = 1/mean(max(max(abs(vid(:,:,1:NORM_MARGIN))))); % TODO:  improve s/n calculation
    fprintf(strcat('Crack start: ', num2str(Start),'.\t Total frames: ', num2str(crackTime), '.\t Signal to noise ratio: ', num2str(signalToNoiseRatio), '\r'));
    
    vid = vid(:,:,NORM_MARGIN:end);
    
    displacement = getDisplacement(vid, pixelsPerMicrons);
    velocity = getVelocity(displacement, framesPerMillisecond);
        
    disp(strcat('Saving results to: ', targetPath)); 
    
    if saveVideo == 1
        exportCrackColormap(normalize(vid,[]), targetPath);
    end
    
    if size(plotCoordinates,1) ~= 0
        plotLightInTime(vid, targetPath, plotCoordinates, framesPerMillisecond, pixelsPerMicrons);
    end
    
    if showVelocityPlot == 1
        plotDisplacement(displacement, targetPath, framesPerMillisecond);
        plotVelocity(velocity, targetPath, framesPerMillisecond);
    end
    
    if size(lightPeriodiogramRange,1) ~= 0
        showPeriodiogram(sourcePath, lightPeriodiogramRange, framesPerMillisecond);
    end
end

function [CrackStart, CrackEnd]=getCrackTimes(reader, rangeStart, rangeEnd)
    MAX_LENGTH = 1000;

    firstFrame = read(reader, rangeStart);
    lastFrame = read(reader, rangeEnd);

    firstAmplitude = getLightFromFrame(firstFrame);
    lastAmplitude = getLightFromFrame(lastFrame);
    
    lightRangeStart = 0.9;
    crackStartAmplitude = firstAmplitude * lightRangeStart + lastAmplitude * (1-lightRangeStart);

    CrackStart = findFirstAmplitude(crackStartAmplitude, reader, rangeStart, rangeEnd);
    
    if rangeEnd < CrackStart+MAX_LENGTH
        rangeEnd = CrackStart+MAX_LENGTH;
    end
    
    currentAmp = crackStartAmplitude;
    for i=CrackStart:5:rangeEnd
        prevAmp = currentAmp;
    	currentAmp = getLightFromFrame(read(reader, i));
        if prevAmp < currentAmp
            CrackEnd = i;
            return;
        end
    end
    
    CrackEnd = rangeEnd;
end

function Light=getLightFromFrame(vidFrame)
    Light = sum(sum(vidFrame(:,:,1),'double'),'double');
end

function CrackTime=getCrackTime(vid)
    vid = getBwVideo(vid);
    for i=1:size(vid,3)
        currentSize = sum(sum(vid(:,:,i),'double'),'double') / size(vid,1) / size(vid,2);
        if currentSize > 0.999
            CrackTime = i;
            return;
        end
    end

    CrackTime = size(normalized,3)-1;
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


function Normalized=normalize(vid, minSampleRange)

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
        
        if size(minSampleRange,1) > 0
            minValue = mean(vid(i,j,minSampleRange));
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

function Displacement=getDisplacement(vid, pixelsPerMicron)
    timeSize = size(vid,3);
    Displacement = zeros(timeSize,1);
    for i=1:timeSize;
        Displacement(i) = sum(sum(vid(:,:,i),'double'),'double') / size(vid, 1) * pixelsPerMicron;
    end
    
    
end

function Velocity=getVelocity(displacement, framesPerMillisecond)
    timeSize = size(displacement,1);
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

function BwVideo=getBwVideo(vid)
    vid = normalize(vid, []);

    BwVideo = zeros(size(vid));
    
    for i=1:size(vid,1)
        for j=1:size(vid,2)
            bwValue = 0;
            
            for k=1:size(vid,3)
                if vid(i,j,k) > 0.3
                    bwValue = 1;
                end
                
                BwVideo(i,j,k)=bwValue;
            end
        end
    end
end