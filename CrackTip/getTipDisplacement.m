function Displacement=getTipDisplacement(vid,xAxis,referenceFrames,threshold)

normalized = getNormalizedContactArea(vid,referenceFrames);

timeSize= size(vid,2);
Displacement=zeros(timeSize);
vidWidth=size(vid,1);

for t=1:timeSize
    x = 1;
    while x + 1 < vidWidth
        if ((normalized(x) > threshold && normalized(x+1) < threshold) ...
                || (normalized(x) < threshold && normalized(x+1) > threshold))
            break;
        end
        x=x+1;
    end

    Displacement(t)=xAxis(x);
end

end