function processFolder(sourcePath, targetPath)

fileNames = cellstr(ls(sourcePath));
aviFiles = fileNames(cell2mat(cellfun(@(x) size(regexp(x, '(\.avi)$'),1) > 0, fileNames,'UniformOutput', false)));

fileNum = size(aviFiles);

disp(strcat('Processing files for: ', sourcePath));

for i=1:fileNum
   iStr = num2str(i);
   currentSourceFilename = char(aviFiles(cell2mat(cellfun(@(x) size(regexp(x, ['\D' iStr '(\.avi)$']),1) > 0, aviFiles,'UniformOutput', false))));
   currentPath = strcat(sourcePath, '\', currentSourceFilename);
   currentTargetPath = strcat(targetPath, '\', iStr);
   mkdir(currentTargetPath);
   processEvent(currentPath, currentTargetPath);
end
end