function CrackTime=getCrackTime(vid,referenceFrames, dropThreshold, medFilt)

lightXT = getNormalizedContactArea(vid,referenceFrames);
CrackTime=abs(diff(lightXT,1,2)) > dropThreshold;
CrackTime=medfilt2(CrackTime,medFilt,'symmetric');

end