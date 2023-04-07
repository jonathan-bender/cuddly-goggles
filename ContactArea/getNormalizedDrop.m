function Normalized=getNormalizedDrop(vid)

minValue=min(vid,[],3);
maxValue=max(vid,[],3);

Normalized=zeros(size(vid));
for i=1:size(vid,1)
    for j=1:size(vid,2)
        for k=1:size(vid,3)
            Normalized(i,j,k)=(vid(i,j,k)-minValue(i,j))/(maxValue(i,j)-minValue(i,j));
        end
    end
end

end