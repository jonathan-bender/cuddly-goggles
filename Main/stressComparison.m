

%% constants

% read video
VID_SOURCE_PATH='';
VID_EVENT_NUMS=[5 6 7 8];
RANGE = [];
MAX_READ = 400;

% video data
FRAMES_PER_MILLISECOND = 581.196;
PIXELS_PER_MICRON = 0.006315;
TOTAL_LENGTH=200000;
TRIGGER_FRAME=5500;
TRIGGER_DELAY=7.262;

% video processing
EDGE_DROP_RANGE=9;
REFERENCE_FRAMES=1:30;
MOTION_STEP=10;
SOURCE_FREQUENCY=115;
SOURCE_FREQUENCY_WIDTH=1;
TRIM_EDGES=[];

% crack tip
CRACK_TIP_THRESHOLD=0.97;
MIN_DROP=0.0005;
MIN_DROP_RANGE=10;

% strain gauge
SG_SOURCE_PATH='D:\Experiments\2023-1-23\20-52-14';
SG_EVENT_SHIFT=1;
SG_INDICES=[1 2 4 5 7 13 15 16 17 18];

% stress drop points
TIP_RANGE=50;

% target path
TARGET_PATH='C:\Users\owner\Documents\Jonathan\Experiments\Analysis\Photron2\Mar23\10';


%%  vid folder details
fileNames = cellstr(ls(VID_SOURCE_PATH));
aviFiles = fileNames(cell2mat(cellfun(@(x) size(regexp(x, '(\.avi)$'),1) > 0, fileNames,'UniformOutput', false)));

for i=1:size(VID_EVENT_NUMS,2)
    %% set paths
    vidEventNum=VID_EVENT_NUMS(i);
    vidEventNumStr = num2str(vidEventNum);
    currentSourceFilename = char(aviFiles(cell2mat(cellfun(@(x) size(regexp(x, ['\D' vidEventNumStr '(\.avi)$']),1) > 0, aviFiles,'UniformOutput', false))));
    currentVidPath= strcat(VID_SOURCE_PATH, '\', currentSourceFilename);
    
    currentTargetPath = strcat(TARGET_PATH, '\', vidEventNumStr);
    
    sgEventNum=vidEventNum+SG_EVENT_SHIFT;
    
    mkdir(currentTargetPath);
    
    %% read video
    [motionStart,motionEnd, motionVid] = readNearMotion(currentPath, RANGE, MAX_READ);

    %% process video
    vid=removeSourceFrequency(motionVid, SOURCE_FREQUENCY, SOURCE_FREQUENCY_WIDTH, FRAMES_PER_MILLISECOND);

    vid=trimEdges(vid,TRIM_EDGES);
    
    [readStart,readEnd,vid]=trimBeforeAndAfterMotion(vid,MOTION_STEP,motionStart,motionEnd);

    timeline=getVideoTimeline(readStart,readEnd,TRIGGER_FRAME,TRIGGER_DELAY,FRAMES_PER_MILLISECOND);

    [xAxis, vid]=getXAxisFromDarkEdges(vid, PIXELS_PER_MICRON, TOTAL_LENGTH, REFERENCE_FRAMES, EDGE_DROP_RANGE);
    
    %% tip displacement
    displacement = getTipDisplacement(vid,xAxis,REFERENCE_FRAMES,CRACK_TIP_THRESHOLD,MIN_DROP,MIN_DROP_RANGE);
    
    %% load strain gauge
    sgData=GetSgData(SG_SOURCE_PATH,SG_EVENT_NUM,'shift','fix','');
    
    %% compare stresses
    for j=1:size(SG_INDICES,2)
        %% compare stresses
        currentIndex=SG_INDICES(j);
        [currentXAxis sgX h]=getSgXAxis(sgData,currentIndex,timeline,displacement);
        tipVelocityForDisplacement=getTipVelocityForDisplacement(currentXAxis ,currentTimeline);
        Uxx=sgData.Uxx(:,currentIndex);

        [minUxx minUxxIndex]=min(sgData.Uxx(:,currentIndex));
        [minU,minUtime]=min(Uxx);
        [maxU,maxUtime]=max(Uxx);

        Syy=Syy(myRange);
        [minS,minStime]=min(Syy);
        [maxS,maxStime]=max(Syy);
        x=currentXAxis(minUxxIndex)-sgX;
        v=tipVelocityForDisplacement(minUxxIndex);
        theta=atan(h/x);
        r=(h.^2+x.^2).^0.5;
        
       
        thinOnThin=something;
        
        %% plot stresses
        plotExtrimumStresses(sgData.Uxx(:,currentIndex),sgXAxis,'U_{xx}','Uxx',sgPosition,TARGET_PATH);
        plotExtrimumStresses(KFactor,sgXAxis,'K_{II}(x)','Kii',sgPosition,TARGET_PATH);
    end

    
        sgData=GetSgData(SG_PATH,EVENT_NUMS(i),'shift','fix','');
        for j=1:size(SG_INDICES,2)
            sgIndex=SG_INDICES(1,j);
            myRange=1000:4000;
            Uxx=sgData.Uxx(myRange, sgIndex);
            Syy=sgData.Syy(myRange, sgIndex);
            [~,crackTime]=min(Uxx);
            myRange=(crackTime-TIP_RANGE):(crackTime+TIP_RANGE);

            DeltaOfUxx=max(Uxx(myRange))-min(Uxx(myRange));
            DeltaOfSyy=max(Syy(myRange))-min(Syy(myRange));
            
            currentIndex=size(thinOnThin,1)+1;
            thinOnThin(currentIndex,:)=[DeltaOfUxx,DeltaOfSyy];            
        end
end

%% plot stress in time

TIP_RANGE=50;

SG_PATH='D:\Experiments\2023-3-23\14-3-28';
EVENT_NUMS=17;
sgIndices=[1 2 4 5 7 13 15 16 17 18];


for i=1:size(EVENT_NUMS,2)
        %sgData=GetSgData(sgPath,eventnumbers(i),'shift','fix','');
        for j=1:size(sgIndices,2)
            sgIndex=sgIndices(1,j);
            myRange=1000:4000;
            Uxx=sgData.Uxx(myRange, sgIndex);
            Syy=sgData.Syy(myRange, sgIndex);
            [~,crackTime]=min(Uxx);
            myRange=(crackTime-TIP_RANGE):(crackTime+TIP_RANGE);
            Uxx=Uxx(myRange);
            [minU,minUtime]=min(Uxx);
            [maxU,maxUtime]=max(Uxx);
            
            Syy=Syy(myRange);
            [minS,minStime]=min(Syy);
            [maxS,maxStime]=max(Syy);

            figure;
            plot(Uxx);
            hold on;
            plot(minUtime,minU,'or');
            plot(maxUtime,maxU,'or');
            hold off;
            figure;
            plot(Syy);
            hold on;
            plot(minStime,minS,'or');
            plot(maxStime,maxS,'or');
            hold off;

        end
end