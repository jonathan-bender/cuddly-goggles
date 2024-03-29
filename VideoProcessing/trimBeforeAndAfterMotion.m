function [CrackStart,CrackEnd,Vid]=trimBeforeAndAfterMotion(vid, maxSmoothing, readStart, readEnd)
    if maxSmoothing == 0
        CrackStart=readStart;
        CrackEnd=readEnd;
        Vid=vid;
        return;
    end
    
    midTime = round(size(vid,3)/2);
    
    CrackStart = readStart;
    CrackEnd = readEnd;
    
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

    Vid = vid(:,:,(CrackStart-readStart+1):(end-readEnd+CrackEnd));
end