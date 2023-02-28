function plotDisplacement(displacement, targetPath, framesPerMillisecond, timeOffset)
    displacement = displacement / 1000;
    
    figure;
    
    timeSize = size(displacement,2);
    timeline = linspace(0,timeSize/framesPerMillisecond,timeSize)+timeOffset;
    plot(timeline, displacement);
    
    title('Displacement Over Time');
    xlabel('time [milliseconds]');
    ylabel('distacne [millimeters]');
    
    saveas(gcf,strcat(targetPath, '/displacement.jpg'));
    close;
end