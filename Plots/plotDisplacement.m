function plotDisplacement(displacement,timeline, targetPath)
    figure;
    
    plot(timeline, displacement/1000);
    
    title('Tip Position');
    xlabel('time [milliseconds]');
    ylabel('position [millimeters]');
    
    saveas(gcf,strcat(targetPath, '/displacement.jpg'));
    close;

end