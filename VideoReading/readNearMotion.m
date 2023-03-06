function [ReadStart,ReadEnd,Vid]=readNearMotion(sourcePath, range, maxRead)
reader = VideoReader(sourcePath);

totalFrames = int64(reader.NumberOfFrames);

if size(range,1)==0
    range = [1 totalFrames];
end

firstFrame = read(reader, range(1));
lastFrame = read(reader, range(2));

firstAmplitude = getLightFromFrame(firstFrame);
lastAmplitude = getLightFromFrame(lastFrame);

midAmplitude = (firstAmplitude+lastAmplitude)/2;

midTime = findFirstAmplitude(reader, midAmplitude, range(1), range(2));

ReadStart = midTime - maxRead/2;
ReadEnd = midTime + maxRead/2;

if ReadStart < range(1)
    ReadStart = range(1);
    ReadEnd = range(1) + maxRead;
end

if ReadEnd > range(2)
    ReadStart = range(2) - maxRead;
    if ReadStart < 1 % could be replaced by comparing the length of the video to the max length
        ReadStart = 1;
    end
    ReadEnd = range(2);
end

vid = read(reader, [ReadStart,ReadEnd]);

Vid = squeeze(vid(:,:,1,:));

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
