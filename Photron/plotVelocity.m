function plotVelocity(velocity, targetPath, framesPerMillisecond)
    velocity(1:5) = zeros(1,5);
    
    figure;
        
    timeSize = size(velocity,1);
    timeline = linspace(0,timeSize/framesPerMillisecond,timeSize);
    plot(timeline, velocity);
    
    title('Velocity Over Time');
    xlabel('time [milliseconds]');
    ylabel('velocity [meters per second]');
    
    saveas(gcf,strcat(targetPath, '/velocity.jpg'));
    close;
end