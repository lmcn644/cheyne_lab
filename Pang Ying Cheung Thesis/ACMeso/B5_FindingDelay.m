

close all
clear
clc

mkdir ('Traces');

%%  Finding delay Pt 1

fps = 10; %set recording frequency (frames per second)
baseline = 3;
ExpectedPeak = (baseline*fps)+(fps); % Expected peak at 1 s
response = 4;
reswind = 1.5;

xscatter = [30:35];
yscatter = zeros((size(xscatter,2)),1);

recordings = dir(['DFs/','*.mat']); %use folder of pre-processed trials as z-stacks
recordings = natsortfiles(recordings);

stimfiles = dir('*stimuli.mat');
stimfiles = natsortfiles(stimfiles);

avim = dir('*avAll.mat');
avim = natsortfiles(avim);

peakoffset = [];

for iRec = 1   :size(recordings,1); % Find shift for each recording
   
    file = recordings(iRec).name;
    load(['DFs/',file]);
    
    stimfile = [stimfiles(iRec).name]; %adjust to suit folder structure
    disp(['Stimfile: ',stimfile]);
    load(stimfile)
        
    stimuli = round(stimuli);
    
    avimfile = avim(iRec).name;
    load(avimfile);
    
    avAll = imresize(avAll,0.5);
   
    av_min = prctile(avAll,10,'all');
    av_max = prctile(avAll,90,'all');
    
    figure
    imshow(avAll,[av_min,av_max]);
    
    % make a rough ROI over the caudo-lateral region
    
    roi = drawfreehand(gca);
    cont = input ('Continue? 1 = yes, 0 = restart: ');
    if cont == 1
        ;
    else cont == 0
        restart = input('Re-draw ROI? (1 = yes, 0 = no): ');
        while restart == 1
            delete(roi)
            roi = drawfreehand(gca);
            restart = input('Re-draw ROI? (1 = yes, 0 = no): ');
        end
    end
    
    roimask = createMask(roi);
    maskroi = imdilate(roimask,strel('disk',3));
        
    ROIstack = NaN(size(stack));
    for xx = 1:size(stack,1);
        for yy = 1:size(stack,2);
            if maskroi(xx,yy) == 0;
                ;
            else maskroi(xx,yy) == 1;
                ROIstack(xx,yy,:) = stack(xx,yy,:);
            end
        end
    end
       
    %%
    
    traces=[];
    alltraces = [];
    
    stackroi = [];
    for ff = 1:size(ROIstack,3)
        stackroi(ff,1) = mean(ROIstack (:,:,ff),'all','omitnan');
    end
    
    for ii = 1:size(stimuli,1);
        startframe = stimuli(ii,1)-((baseline*fps)-1);
        endframe = stimuli(ii,1)+((response*fps));
        
         traces(:,ii) = stackroi(startframe:endframe,1);
    end
    
    avTrace = mean(traces,2,'omitnan');
        
    %% Determining if there is a peak
    
    [pk,loc] = findpeaks(avTrace);
    peaklocation = loc((find(max(pk)== pk)),1);
    
    PkDiff = ExpectedPeak - peaklocation; %
    
    figure
    set(gcf,'color','w')
    hold on
    plot(avTrace)
    scatter(peaklocation,max(pk));
    scatter(xscatter,yscatter,'*','k','HandleVisibility','off')
    if  ~isempty(PkDiff);
        if PkDiff < 2*fps;
            text(0,0,'Continue to correction - Peak difference within 2s')
        else PkDiff > 2*fps;
            text(0,0,'No correction - Peak difference outside 2s')
        end
    else isempty(PkDiff);
        text(0,0,'No correction - No peak detected')
    end
    xlabel('Frame')
    ylabel('ΔF/F')
    title('No offset correction - findpeak');
        
    filename = [file(1:end-4),' Find Peak']
    saveas(gcf,['Traces/',filename]);
    
    %% Correcting for delay
        
    if ~isempty(PkDiff); % There IS a difference
        peakoffset(iRec,:) = PkDiff(1,1);
        
        if abs(PkDiff(1,1)) <= (2*fps); % criteria: accepts shifts less than 2s
            stimuli(:,1:2) = stimuli(:,1:2)- peakoffset(iRec,:);
            
            traces=[];
            alltraces = [];
           
            for ii = 1:size(stimuli,1);
                startframe = stimuli(ii,1)-((baseline*fps)-1);
                endframe = stimuli(ii,1)+((response*fps));
                
                traces(:,ii) = stackroi(startframe:endframe,1);
            end
            
            avTrace = mean(traces,2,'omitnan');
            
            figure
            set(gcf,'color','w')
            hold on
            plot(avTrace)       
            scatter(xscatter,yscatter,'*','k','HandleVisibility','off')            
            xlabel('Frame')
            ylabel('ΔF/F')
            title('No offset correction - findpeak');
                     
        end
        
        close all
    else isempty(PkDiff)== 1; % no differene
         peakoffset(iRec,:) = PkDiff(1,1);
    end
end
            
save(['Traces/peakoffset.mat'],'peakoffset');
            
 xticks([0 10 20 30 40 50 60 70]);
    xticklabels({'-3','-2','-1','0','1','2','3','4'})
 xlabel('Time (s)');
 ylim([-3 6]);
 xline(20)
 xline(60)
           