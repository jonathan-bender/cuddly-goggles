function plotLightXT(lightXT,xAxis,timeline, targetPath)
    figure;
    imagesc(xAxis/1000,timeline,lightXT');
    
    set(gca,'YDir','normal')
    title('Light Intensity');
    xlabel('x [millimeters]');
    ylabel('t [milliseconds]');
    
    if ~strcmp(targetPath,'')
        saveas(gcf,strcat(targetPath, '/lightXT.png'));
        close;
    end
end