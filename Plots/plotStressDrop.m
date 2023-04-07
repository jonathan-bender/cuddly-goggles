function plotStressDrop(deltaUxx,deltaSyy, targetPath)
    figure;
    
    
    plot(deltaUxx/10e6,deltaSyy/10e6,'o');
    
    
    xlabel('\delta(U_{xx})');
    ylabel('\delta(\sigma_{yy})');
    
    if ~strcmp(targetPath,'')
        saveas(gcf,strcat(targetPath, '/stressDrop.jpg'));
        close;
    end

end