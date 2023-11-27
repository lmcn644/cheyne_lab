%% Inclusion criteria 


clear 
close all
clc

load(['Traces/peakoffset.mat']);

recordings = dir(['AC ROI DF/*AC_ROI.mat']);
recordings = natsortfiles(recordings);

stimfile = dir('*stimuli.mat');
stimfile = natsortfiles(stimfile);

fps = 10; %set recording frequency (frames per second)
baseline = 3;

response = 4;
reswind = 1.5;

xscatter = [30:35];
yscatter = zeros((size(xscatter,2)),1);

keepfile = [];



for iRec = 1:size(recordings);
    
    filename = stimfile(iRec).name;
    load(filename);
    stimuli(:,1:2) = stimuli(:,1:2)- peakoffset(iRec,:);
    stimuli = round(stimuli);
    
    filename = recordings(iRec).name;
    load(['AC ROI DF/',filename]);
    
     stackroi = [];
    for ff = 1:size(ROIstack,3)
        stackroi(ff,1) = mean(ROIstack (:,:,ff),'all','omitnan');
    end
        
    traces=[];
    alltraces = [];
    
    for ii = 1:size(stimuli,1);
        startframe = stimuli(ii,1)-((baseline*fps)-1);
        endframe = stimuli(ii,1)+((response*fps));
        
        traces(:,ii) = stackroi(startframe:endframe,1);
    end
    
    avTrace = mean(traces,2,'omitnan');
    
    AvShuffle = [];
    for ss = 1:5 % make an average of 5 shuffles
        rng = ('shuffle');
        StackOrder = randperm(size(ROIstack,3));
        
        shuffle = zeros(size(ROIstack));
        for ii = 1:size(ROIstack,3);
            shuffle (:,:,ii) = ROIstack(:,:,StackOrder(ii));
        end
        
        shuffleStack = zeros(size(shuffle,3),1);
        for oo = 1:size(shuffle,3)
            shuffleStack(oo,1)=mean(shuffle(:,:,oo),'all','omitnan'); % gives the mean of ALL elements in the matrix
        end
        
        tracesShuffle = [];
        for ii = 1:size(stimuli,1);
            startframe = stimuli(ii,1)-((baseline*fps)-1);
            endframe = stimuli(ii,1)+((response*fps));
            
            tracesShuffle(:,ii) = shuffleStack(startframe:endframe,1);
        end
        
        AvShuffle = cat(2,AvShuffle,tracesShuffle);
    end
    
    AvShuffleAll = mean(AvShuffle,2,'omitnan');
    
    difference = mean(avTrace((baseline*fps):((baseline*fps)+((reswind*fps)-1)))) - mean(AvShuffleAll((baseline*fps):((baseline*fps)+((reswind*fps)-1))));
    
    e = (std(traces,1,2,'omitnan'))/sqrt(size(traces,2)); % SEM Actual trace
    f = (std(AvShuffle,1,2,'omitnan'))/sqrt(size(AvShuffle,2)); % SEM randomised
    
    if difference < 0;
        final = 0;
    else difference > 0;
        if difference < (mean(e,'all','omitnan'))/2;
            final = 0;
        else difference > (mean(e,'all','omitnan'))/2;
            final = 1;
        end
    end
    
    figure
    set(gcf,'color','w')
    %      boundedline(1:1:size(avTrace,1),avTrace,e,1:1:size(AvShuffleAll),AvShuffleAll,f,'r')
    plot(avTrace);
    hold on
    plot(AvShuffleAll,'r');
    scatter(xscatter,yscatter,'*','k','HandleVisibility','off')
    xline(30,'HandleVisibility','off')
    xline(45,'HandleVisibility','off')
    legend('Average trace','Average 5 shuffles');
    legend box off   
    xticks([0 10 20 30 40 50 60 70]);
    xticklabels({'-3','-2','-1','0','1','2','3'})
    xlabel('Time (s)')
    ylabel('ΔF/F')
    if final == 1; % Inclusion criteria met
        text(0,0,'keep')
        keepfile = cat(1,keepfile,1);
    else final == 0; % Inclusion criteria NOT met
        text(0,0,'discard')
        keepfile = cat(1,keepfile,0);
    end
    box off
    
    filename = [filename(1:11),' compare to shuffle'];
    saveas(gcf,['Traces/',filename]);
      
    %%% 
    
    look(1,:) = avTrace;
    look(2,:) = AvShuffleAll;
    
    figure
    set(gcf,'color','w')
    imshow(look,[],'InitialMagnification','fit');
    colormap jet
    c = colorbar('southoutside')
    c.Label.String = 'ΔF/F'
    xline(30,'k','LineWidth',2)
    xline(45,'k','LineWidth',2)
    axis on
    box off
    yticks([1 2])
    yticklabels({'No Shuffle','Shuffle'})
    xticks([0 10 20 30 40 50 60 70]);
    xticklabels({'-3','-2','-1','0','1','2','3'})
    xlabel('Time (s)')
    
    filename = [filename(1:11),' compare to shuffle - visual'];
    saveas(gcf,['Traces/',filename]);
    
    close all
    
end

save(['Traces/','keepfile'],'keepfile');
    
    
    
    
    
    
    
    
    
    
    