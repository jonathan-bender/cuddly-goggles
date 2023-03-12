function plotLightXT(lightXT,xAxis,timeline, targetPath)
    figure;
    imagesc(xAxis,timeline,lightXT);
    
    set(gca,'YDir','normal')
    title('Light Intensity');
    xlabel('x [millimeters]');
    ylabel('t [milliseconds]');
    
    saveas(gcf,strcat(targetPath, '/lightXT.png'));
    close;
end