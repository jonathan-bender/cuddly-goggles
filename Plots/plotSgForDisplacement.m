function plotSgForDisplacement(sg,plotPoints,sgXAxis,plotTitle,fileTitle,sgPosition,targetPath)
    figure;
    
    plot(sgXAxis/1000, sg/1000000);
    
    title([plotTitle ' at ' num2str(sgPosition) 'mm']);
    xlabel('x-x_{tip} [millimeters]');
    ylabel(plotTitle);
    
            
    hold on;
    for i=1:size(plotPoints,2)
        ind=plotPoints(i);
        plot(sgXAxis(ind)/1000, sg(ind)/1000000,'or');
    end
    hold off;

    
    if ~strcmp(targetPath,'')
        saveas(gcf,strcat(targetPath, '/', fileTitle, num2str(sgPosition), '.jpg'));
        close;
    end
end