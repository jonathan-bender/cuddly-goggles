function plotVelocity(velocity,timeline, targetPath)
    figure;
    
    plot(timeline, velocity/1000);
    
    title('Tip Velocity');
    xlabel('time [milliseconds]');
    ylabel('velocity [meter / sec]');
    
    if ~strcmp(targetPath,'')
        saveas(gcf,strcat(targetPath, '\velocity.jpg'));
        close;
    end
end