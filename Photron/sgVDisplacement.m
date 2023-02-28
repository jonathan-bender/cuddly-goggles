

sgDisplacement=zeros(size(sgTimeline));

for i=1:size(sgTimeline,1)
    t=sgTimeline(i);
    if t<timeline(1)
        sgDisplacement(i)=displacement(1);
    else
        if t>timeline(end)
            sgDisplacement(i)=displacement(end);
        else
            for j=1:(size(timeline,2)-1)
                if (timeline(j)<=t && timeline(j+1)>=t)
                    diffT=(t-timeline(j))/(timeline(j+1)-timeline(j));
                    sgDisplacement(i)=displacement(j)*(1-diffT)+displacement(j+1)*(diffT);
                end
            end
        end
    end
end
