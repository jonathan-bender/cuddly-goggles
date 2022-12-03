function processFolder(sourcePath, targetPath, range, smoothing, trimming, lightUpperLimit, lightLowerLimit, lightBinning, framesPerMillisecond, pixelsPerMicrons, saveVideo, plotCoordinates, showVelocityPlot, lightPeriodiogramRange)

fileNames = cellstr(ls(sourcePath));
aviFiles = char(fileNames(cell2mat(cellfun(@(x) size(regexp(x, '(\.avi)$'),1) > 0, fileNames,'UniformOutput', false))));

fileNum = size(aviFiles);

disp(strcat('Processing files for: ', sourcePath));

for i=1:fileNum
   iStr = num2str(i);
   currentPath = char(aviFiles(cell2mat(cellfun(@(x) size(regexp(x, ['(\D' iStr '(\.avi)$']),1) > 0, aviFiles,'UniformOutput', false))));
   currentTargetPath = strcat(targetPath, '\', num2str(i));
   mkdir(currentTargetPath);
   processEvent(currentPath, currentTargetPath, range, smoothing, trimming, lightUpperLimit, lightLowerLimit, lightBinning, framesPerMillisecond, pixelsPerMicrons, saveVideo, plotCoordinates, showVelocityPlot, lightPeriodiogramRange);
end
end