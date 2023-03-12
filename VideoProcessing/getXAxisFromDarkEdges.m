function XAxis=getXAxisFromDarkEdges(vid, resolution, totalLength, referenceFrames, edgeDrop)

contactAreaSize=double(size(referenceFrames,2)/size(vid,1));
referenceVid=double(squeeze(mean(mean(double(vid(:,:,referenceFrames)),3))));
contactArea=referenceVid/contactAreaSize;

vidWidth=size(contactArea,2);

leftEdge = 1;

while leftEdge+1 < vidWidth && (contactArea(leftEdge+1)-contactArea(leftEdge)<edgeDrop)
    leftEdge=leftEdge+1;
end

rightEdge=vidWidth;
while rightEdge > 2 && (contactArea(rightEdge-1)-contactArea(rightEdge)<edgeDrop)
    rightEdge=rightEdge-1;
end
    
if vidWidth-rightEdge < leftEdge
    leftEdge=rightEdge-totalLength/resolution;
end

XAxis=linspace(-leftEdge*resolution,totalLength-leftEdge*resolution, vidWidth);

end