function Vid=nullifyNoisyPixels(vid, minSignal, smoothing)
if minSignal==0
    Vid=vid;
    return;
end
for i=1:size(vid,1)
    for j=1:size(vid,2)
        if isNoisy(vid(i,j,:), minSignal, smoothing)
            vid(i,j,:) = 0;
        end
    end
end
Vid=vid;
end