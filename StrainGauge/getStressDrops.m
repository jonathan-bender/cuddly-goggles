function [DeltaOfUxx, DeltaOfSyy]=getStressDrops(sgData,sgIndices, timeline, displacement, dropRange)

DeltaOfUxx=zeros(size(sgIndices));
DeltaOfSyy=zeros(size(sgIndices));

for i=1:size(sgIndices,2)
    sgIndex=sgIndices(1,i);
    position=sgData.x_sg(1,sgIndex);
    
    [~,tipTimeIndex]=min(abs(displacement/1000-position));
    tipTime=timeline(tipTimeIndex);
    minTime=tipTime-dropRange/2;
    maxTime=tipTime+dropRange/2;
    tipTimeline=sgData.t>minTime&sgData.t<maxTime;
    
    Uxx=sgData.Uxx(tipTimeline, sgIndex);
    Syy=sgData.Syy(tipTimeline, sgIndex);
    
    DeltaOfUxx(i)=max(Uxx)-min(Uxx);
    DeltaOfSyy(i)=max(Syy)-min(Syy);
end

end