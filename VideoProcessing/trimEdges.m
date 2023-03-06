function Vid=trimEdges(vid, trimming)

if size(trimming,1) ~= 0
    Vid = vid(:,trimming(1):trimming(2),:);
end

end