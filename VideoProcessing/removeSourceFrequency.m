function Vid=removeSourceFrequency(vid, sourceFrequency, sourceFrequencyWidth,fps)
vid = permute(vid, [3 1 2]);
if size(vid, 1) < 5
    Vid = permute(vid, [2 3 1]);
    return;
end

Hd = filterDesign(sourceFrequency-sourceFrequencyWidth,sourceFrequency+sourceFrequencyWidth, fps);
vid= filtfilt(Hd.sosMatrix,Hd.ScaleValues,vid);
Vid = permute(vid, [2 3 1]);

end