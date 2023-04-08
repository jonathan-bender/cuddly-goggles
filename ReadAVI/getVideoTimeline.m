function Timeline=getVideoTimeline(firstFrame, lastFrame, zeroFrame, triggerDelay, framesPerMillisecond)

timeOffset=double(zeroFrame-firstFrame+1)/framesPerMillisecond-triggerDelay;
timeSize = double(lastFrame-firstFrame+1);
Timeline= linspace(0,timeSize/framesPerMillisecond,timeSize)+timeOffset;

end