function [XAxis, Vid]=getXAxisFromDarkEdges(vid, resolution, totalLength, referenceFrames, edgeDrop)

contactArea=squeeze(mean(mean(vid(:,:,referenceFrames),3)));

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
    disp(['Found right edge at pixel: ' num2str(rightEdge)]);
    leftEdge=rightEdge-totalLength*resolution;
else
    disp(['Found left edge at pixel: ' num2str(leftEdge)]);
end

XAxis=linspace(-leftEdge/resolution,(vidWidth-leftEdge)/resolution, vidWidth);
Vid=vid;

if rightEdge < vidWidth
   XAxis=XAxis(1:rightEdge-1);
   Vid=Vid(:,1:rightEdge-1,:);
end

if leftEdge > 1
    XAxis=XAxis(leftEdge+1:end);
    Vid=Vid(:,leftEdge+1:end,:);
end

end