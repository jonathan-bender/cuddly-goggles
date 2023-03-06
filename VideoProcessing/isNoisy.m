function IsNoisy=isNoisy(arr,minRatio,spread)
drop = mean(arr(1:spread)) - mean(arr(end-spread:end));
arrMean = mean(arr);

IsNoisy = double(drop) / arrMean < minRatio;
end