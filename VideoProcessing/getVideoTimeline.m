function Timeline=getVideoTimeline(firstFrame, readLength, triggerDelay, framesPerMillisecond)

timeOffset=double(firstFrame)/framesPerMillisecond+triggerDelay;
Timeline= linspace(0,readLength/framesPerMillisecond,readLength)+timeOffset;

end