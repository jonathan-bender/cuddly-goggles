function XAxis=getXAxisFromDarkEdges(vid, resolution, totalLength, referenceFrames, minLight)

contactArea=sum(sum(vid(:,:,referenceFrames),2),3);

vidWidth=size(vid,1);

leftEdge = 0;

if contactArea(1)< minLight
    while leftEdge < vidWidth && contactArea(leftEdge) < minLight
        leftEdge=leftEdge+1;
    end
else
    rightEdge = vidWidth;
    
    while rightEdge > 0 && contactArea(rightEdge) < minLight
        rightEdge=rightEdge-1;
    end
    
    leftEdge=rightEdge-totalLength*resolution;
end


XAxis=linspace(-leftEdge/resolution,totalLength-leftEdge/resolution, vidWidth);

end