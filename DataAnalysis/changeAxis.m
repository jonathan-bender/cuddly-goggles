function NewY=changeAxis(originalX,newX,originalY)

NewY=zeros(size(newX));

for i=1:size(newX,1)
    x=newX(i);
    
    if x<originalX(1) || x>=originalX(end)
        NewY(i)=NaN;
    else
        ind=find(originalX>x,1,'first')-1;
        xDiffRatio=(x-originalX(ind))/(originalX(ind+1)-originalX(ind));
        NewY(i)=originalY(ind)*(1-xDiffRatio)+originalY(ind+1)*xDiffRatio;
    end
end

end