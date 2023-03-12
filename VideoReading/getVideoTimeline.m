function Timeline=getVideoTimeline(firstFrame, lastFrame, zeroFrame, triggerDelay, framesPerMillisecond)

timeOffset=double(zeroFrame-firstFrame)/framesPerMillisecond-triggerDelay;
timeSize = double(lastFrame-firstFrame);
Timeline= linspace(0,timeSize/framesPerMillisecond,timeSize)+timeOffset;

end