function processFolder(sourcePath, targetPath, range, smoothing, trimming, framesPerMillisecond, pixelsPerMicrons, saveVideo, plotCoordinates, showVelocityPlot, lightPeriodiogramRange)

fileNames = cellstr(ls(sourcePath));
aviFiles = char(fileNames(cell2mat(cellfun(@(x) size(regexp(x, '(\.avi)$'),1) > 0, fileNames,'UniformOutput', false))));

fileNum = size(aviFiles);

disp(strcat('Processing files for: ', sourcePath));

for i=1:fileNum
   currentPath = strcat(sourcePath, '\', aviFiles(i,:));
   currentTargetPath = strcat(targetPath, '\', num2str(i));
   mkdir(currentTargetPath);
   processEvent(currentPath, currentTargetPath, range, smoothing, trimming, framesPerMillisecond, pixelsPerMicrons, saveVideo, plotCoordinates, showVelocityPlot, lightPeriodiogramRange);
end


end