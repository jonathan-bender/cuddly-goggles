function plotSgForDisplacement(sg,sgXAxis,plotTitle,fileTitle,sgPosition,targetPath)
    figure;
    
    plot(sgXAxis/1000, sg/1000000);
    
    title([plotTitle ' at ' num2str(sgPosition) 'mm']);
    xlabel('x-x_{tip} [millimeters]');
    ylabel(plotTitle);
    
    if ~strcmp(targetPath,'')
        saveas(gcf,strcat(targetPath, '/', fileTitle, num2str(sgPosition), '.jpg'));
        close;
    end
end