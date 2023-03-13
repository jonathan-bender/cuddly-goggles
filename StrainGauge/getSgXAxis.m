function [SgXAxis,SgPosition]=getSgXAxis(sgData,sgNum,timeline,tipDisplacement)
sgTimeline=sgData.t;
SgPosition=sgData.x_sg(sgNum);

tipDisplacementIndices=find(~isnan(tipDisplacement));
tipDisplacement=tipDisplacement(tipDisplacementIndices);
timeline=timeline(tipDisplacementIndices);

SgXAxis=zeros(size(sgTimeline));

for i=1:size(sgTimeline,1)
    t=sgTimeline(i);
    if t<timeline(1)
        SgXAxis(i)=tipDisplacement(1);
    else
        if t>timeline(end)
            SgXAxis(i)=tipDisplacement(end);
        else
            for j=1:(size(timeline,2)-1)
                if (timeline(j)<=t && timeline(j+1)>=t)
                    diffT=(t-timeline(j))/(timeline(j+1)-timeline(j));
                    SgXAxis(i)=tipDisplacement(j)*(1-diffT)+tipDisplacement(j+1)*(diffT);
                end
            end
        end
    end
end

SgXAxis=SgXAxis-SgPosition*1000;
end