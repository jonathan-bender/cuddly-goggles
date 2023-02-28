
numOfpoints=size(sgData.Uxx,2);
maxPoints = zeros(1,numOfpoints);

for i=1:numOfpoints
    currentmin=min(sgData.Uxx(:,i));
    
    for j=1:size(sgData.Uxx(:,i))
        if sgData.Uxx(j,i) == currentmin
            maxPoints(i)=sgData.t(j);
        end
    end
end

figure;
plot(sgData.x_sg,maxPoints,'LineStyle', 'none', 'Marker', 'o');
