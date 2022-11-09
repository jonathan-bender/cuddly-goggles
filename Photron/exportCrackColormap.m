function exportCrackColormap(vid, targetPath)
    vidPath = strcat(targetPath, '/crackVideo.avi');
    vw = VideoWriter(vidPath);
    
    open(vw);
    
    currentColormap = jet(256);
    
    for i=1:size(vid,3)       
        result = zeros(size(vid,1), size(vid,2));
        
        for j=1:size(vid,1)
            for k=1:size(vid,2)
                current = vid(j,k,i);
                currentColormapped = floor((current * 0.999)  * 256) + 1;
                
                result(j,k,1) = currentColormap(currentColormapped,1);
                result(j,k,2) = currentColormap(currentColormapped,2);
                result(j,k,3) = currentColormap(currentColormapped,3);
            end
        end
        
        writeVideo(vw,result);
    end
    
    close(vw);
end
