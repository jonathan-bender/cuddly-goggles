function plotLightInTime(lightVideo, targetPath, coordinates, framesPerMillisecond, pixelPerMicrons)

lightInTime = zeros(size(coordinates,1),size(lightVideo,2));

for i=1:size(coordinates,2)
    pixelCoordinates = round(coordinates(i) / pixelPerMicrons * 1000);
    lightInTime(i,:) = lightVideo(pixelCoordinates,:);
end

timeSize = size(lightVideo,2);
timeLine = linspace(0,timeSize/framesPerMillisecond,timeSize);

myColors = 'rgbcmykw';
figure;

% plot light in time
for i=1:size(lightInTime,1)
    plot(timeLine, lightInTime(i,:), myColors(i));
    
    hold on;
end

hold off;

legendItems = char.empty(0,size(coordinates,1));


for i=1:size(coordinates,2)
    result = strcat(num2str(round(coordinates(i))), 'mm from nucleation');
    for j=1:size(result,2)
        legendItems(i,j) = result(j);
    end
end
    
legend(legendItems, 'Location', 'NorthEast');

title('Light Over Time');
xlabel('time [milliseconds]');
ylabel('Light amplitude');

saveas(gcf,strcat(targetPath, '\lightInTime.jpg'));
close;

end