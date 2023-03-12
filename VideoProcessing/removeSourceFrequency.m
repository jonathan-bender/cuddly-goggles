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

function Hd = filterDesign(from,to, framesPerMillisecond)
Fs = framesPerMillisecond;  % Sampling Frequency

N   = 4;      % Order
Fc1 = from;  % First Cutoff Frequency
Fc2 = to;  % Second Cutoff Frequency

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.bandstop('N,F3dB1,F3dB2', N, Fc1, Fc2, Fs);
Hd = design(h, 'butter');
end
