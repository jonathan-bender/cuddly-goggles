function Timeline=getVideoTimeline(firstFrame, lastFrame, zeroFrame, triggerDelay, framesPerMillisecond)

timeOffset=(zeroFrame-firstFrame)/framesPerMillisecond-triggerDelay;
timeSize = lastFrame-firstFrame;
Timeline= linspace(0,timeSize/framesPerMillisecond,timeSize)+timeOffset;

end