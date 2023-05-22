function Displacement=getTipDisplacement(vid,xAxis,referenceFrames,threshold)

normalized = getNormalizedContactArea(vid,referenceFrames);

timeSize= size(vid,3);
Displacement=NaN(timeSize,1);
vidWidth=size(vid,2);
timeForDisplacement=zeros(vidWidth,1);

for x=1:vidWidth
    for t=1:timeSize-1
        if (normalized(x,t) >= threshold && normalized(x,t+1) < threshold) ...
                || (normalized(x,t) < threshold && normalized(x,t+1) >= threshold)
            timeForDisplacement(x)=t;
            break;
        end
    end
end

for t=1:timeSize
    for x=2:vidWidth-10
        if (timeForDisplacement(x) >= t && timeForDisplacement(x-1) < t) ...
                || (timeForDisplacement(x) < t && timeForDisplacement(x-1) >= t)
            Displacement(t)=xAxis(x);
            break;
        end
    end
end

end