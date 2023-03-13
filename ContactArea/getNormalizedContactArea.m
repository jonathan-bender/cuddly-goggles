function Normalized=getNormalizedContactArea(vid,referenceFrames)

contactArea = squeeze(mean(vid));
referenceContactArea = squeeze(mean(contactArea(:,referenceFrames),2));

Normalized=zeros(size(contactArea));
for i=1:size(contactArea,1)
    for j=1:size(contactArea,2)
        Normalized(i,j)=contactArea(i,j)/referenceContactArea(i);
    end
end

end