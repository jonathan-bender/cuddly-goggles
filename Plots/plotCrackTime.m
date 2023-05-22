function plotCrackTime(crackTime,xAxis,timeline, targetPath)
    figure;
    imagesc(xAxis/1000,timeline,crackTime');
    
    set(gca,'YDir','normal')
    title('Crack time');
    xlabel('x [millimeters]');
    ylabel('t [milliseconds]');
    
    if ~strcmp(targetPath,'')
        saveas(gcf,strcat(targetPath, '/crackTime.png'));
        close;
    end
end