function [CrackStart,CrackEnd,vid]=trimBeforeAndAfterMotion(vid, maxSmoothing, readStart, readEnd)
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

    vid = vid(:,:,(crackStart-readStart+1):(end-readEnd+crackEnd));
end