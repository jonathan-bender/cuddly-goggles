function getPicturesFromVideo(vid, fromT,toT,tSteps)

vr = VideoReader(vid);
j=1;
for i=fromT:tSteps:toT

current = read(vr, i);

jStr = num2str(j);
if(length(jStr) == 1)
    jStr = strcat('0',jStr);
end

imwrite(current,strcat('C:\Users\owner\Documents\Jonathan\ImagesForJay\',jStr,'.png'));
j=j+1;

end

end