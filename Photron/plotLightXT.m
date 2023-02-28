function plotLightXT(vid, targetPath, framesPerMillisecond, pixelsPerMicron, timeOffset)
    figure;
    
    xSize = size(vid,1);
    vidX = linspace(0,xSize*pixelsPerMicron/1000,xSize);
    
    tSize = size(vid,2);
    vidT = linspace(0,tSize/framesPerMillisecond,tSize);
    
    vidT = vidT+timeOffset;
    imagesc(vidX,vidT,-vid');
    
    set(gca,'YDir','normal')
    title('Light amplitude');
    xlabel('x [millimeters]');
    ylabel('t [milliseconds]');
    
    saveas(gcf,strcat(targetPath, '/lightXT.png'));
    close;
end