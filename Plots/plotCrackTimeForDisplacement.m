function plotCrackTimeForDisplacement(crackTime,xAxis,fpms, targetPath)
    figure;
    plot(xAxis/1000,sum(crackTime,2)/fpms);
    
    title('Crack time');
    xlabel('x [millimeters]');
    ylabel('t [milliseconds]');
    
    if ~strcmp(targetPath,'')
        saveas(gcf,strcat(targetPath, '/crackTimeForDisplacement.png'));
        close;
    end
end