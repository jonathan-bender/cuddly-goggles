function plotSgForDisplacement(sg,sgXAxis,plotTitle,sgPosition,targetPath)
    figure;
    
    plot(sgXAxis, sg);
    
    title([plotTitle ' at ' num2str(sgPosition)]);
    xlabel('x-xTip [millimeters]');
    ylabel(plotTitle);
    
    saveas(gcf,strcat(targetPath, '/', plotTitle, sgPosition, '.jpg'));
    close;
end