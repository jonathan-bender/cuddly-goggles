function plotLightInTime(vid, xAxis, timeline, xPoints,targetPath)

pixelIndices=zeros(size(xPoints));
for i=1:size(xPoints,2)
    [~,pixelIndices(i)]=min(abs(xAxis-xPoints(i)*1000));
end

lightInTime=vid(pixelIndices,:);


myColors = 'rgbcmykw';
figure;

for i=1:size(lightInTime,1)
    plot(timeline, lightInTime(i,:), myColors(i));

    hold on;
end

hold off;

legendItems = char.empty(0,size(xPoints,1));


for i=1:size(xPoints,2)
    result = strcat(num2str(round(xPoints(i))), 'mm');
    for j=1:size(result,2)
        legendItems(i,j) = result(j);
    end
end

legend(legendItems, 'Location', 'NorthEast');

title('Light in Time');
xlabel('time [milliseconds]');
ylabel('light intensity');

if ~strcmp(targetPath,'')
    saveas(gcf,strcat(targetPath, '\lightInTime.jpg'));
    close;
end
end