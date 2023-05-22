function [Vid TriggerFrame]=readBinVideo(path,eventNum, readStart,readLength)
vidMetadata=phantomReadMeta(path);
triggerFrame=vidMetadata.NumIms-vidMetadata.PostIms;
fromFrame=triggerFrame+readStart;
toFrame=triggerFrame+readStart+readLength-1;

Vid=phantomReadImsNew(path,eventNum,fromFrame,1,toFrame,1,'all');
TriggerFrame=triggerFrame;
end