function Vid=trimNoisyEdges(vid, trimNoisyEdges, minSignal, smoothing)
if trimNoisyEdges
currentColumn = 1;
while currentColumn < size(vid,2)
    if ~isNoisyColumn(vid(:,currentColumn,:),minSignal, smoothing)
        break;
    end

    currentColumn=currentColumn+1;
end

vid = vid(:,currentColumn+1:end,:);

currentColumn = size(vid,2);
while currentColumn > 0
    if ~isNoisyColumn(vid(:,currentColumn,:), minSignal, smoothing)
        break;
    end

    currentColumn=currentColumn-1;
end

Vid = vid(:,1:currentColumn-1,:);

end
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