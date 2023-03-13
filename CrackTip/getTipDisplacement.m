function Displacement=getTipDisplacement(vid,xAxis,referenceFrames,threshold,minDrop,spread)

normalized = getNormalizedContactArea(vid,referenceFrames);

timeSize= size(vid,3);
Displacement=NaN(timeSize,1);
vidWidth=size(vid,2);

for t=1:timeSize
    x = 1;
    while x + 1 < vidWidth
        if (~isNoisyPixel(normalized(x,:),minDrop,spread) && ((normalized(x,t) >= threshold && normalized(x+1,t) < threshold) ...
                || (normalized(x,t) < threshold && normalized(x+1,t) >= threshold)))
            Displacement(t)=xAxis(x);
            break;
        end
        x=x+1;
    end    
end

end

function IsNoisy=isNoisyPixel(arr,minRatio,spread)
arr=arr(:);
drop = mean(arr(1:spread)) - mean(arr(end-spread:end));
arrMean = mean(arr);

IsNoisy = double(drop) / arrMean < minRatio;

end