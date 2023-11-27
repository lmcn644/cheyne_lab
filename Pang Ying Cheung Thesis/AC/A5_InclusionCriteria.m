close all
clear
clc

mkdir ('Traces');

%%  Finding delay Pt 1

fps = 5; %set recording frequency (frames per second)
baseline = 3;
ExpectedPeak = (baseline*fps)+(fps); % Expected peak at 1 s
response = 4;
reswind = 2;

xscatter = [15:17];
yscatter = zeros((size(xscatter,2)),1);

%%
recordings = dir(['DF roi/','*.mat']); %use folder of pre-processed trials as z-stacks
stimfiles = dir('*stimuli.mat');

peakoffset = [];
keepfile = [];

TraceAll = [];
ShuffleAll = [];


for iRec = 1:size(recordings,1); % Find shift for each recording
    file = recordings(iRec).name;
    load(['DF roi/',file]);
    
    stimfile = [stimfiles(iRec).name]; %adjust to suit folder structure
    disp(['Stimfile: ',stimfile]);
    load(stimfile)
    
    stimuli(2:2:end,:)=[];
    
    stimuli = round(stimuli);
    
    %% Getting the trace for each tone cycle
    
    traces=[];
    alltraces = [];
    
    stackroi = [];
    for ff = 1:size(ROIstack,3)
        stackroi(ff,1) = mean(ROIstack (:,:,ff),'all','omitnan');
    end
    
    for ii = 1:size(stimuli,1);
        startframe = stimuli(ii,1)-((baseline*fps)-1);
        endframe = stimuli(ii,1)+((response*fps));
        
        temp = []; % final
        clearvars front behind
        
        % Overall averaged trace
        if startframe == 0; % if the start of frame is 0
            front = NaN((baseline*fps),1);
            behind = stackroi(1:endframe,1);
            temp = cat(1,front,behind);
            
            traces(:,ii) = temp;
        elseif startframe < 1; % if the start of frame starts in negatives
            front = zeros((abs(startframe)-0),1);
            behind = stackroi(1:endframe-1,1);
            temp = cat(1,front,behind);
            traces(:,ii) = temp;
            
        elseif endframe>size(stackroi,1);
            front = stackroi(startframe:end,1);
            behind = NaN((endframe-size(stackroi,1)),1);
            temp = cat(1,front,behind);
            traces(:,ii) = temp;
        else
            traces(:,ii) = stackroi(startframe:endframe,1);
        end
    end
    
    avTrace = mean(traces,2,'omitnan');
    
    figure
    hold on
    plot(avTrace)
    xline(15)
    xlabel('Frame')
    ylabel('ΔF/F')
    title('No time correction');
    
    
    %% Correcting delay
    
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
    
    
    %% Finding delay pt 2
    
    
    if ~isempty(PkDiff); % There IS a difference
        peakoffset(iRec,:) = PkDiff(1,1);
        
        if abs(PkDiff(1,1)) <= (2*fps); % criteria: accepts shifts less than 2s
            stimuli(:,1:2) = stimuli(:,1:2)- peakoffset(iRec,:);
            
            traces = [];
            
            % Overall averaged CORRECTED trace
            for ii = 1:size(stimuli,1);
                startframe = stimuli(ii,1)-((baseline*fps)-1);
                endframe = stimuli(ii,1)+((response*fps));
                
                temp = []; % final
                clearvars front behind
                
                if startframe == 0; % if the start of frame is 0
                    front = NaN((baseline*fps),1);
                    behind = stackroi(1:endframe,1);
                    temp = cat(1,front,behind);
                    
                    traces(:,ii) = temp;
                elseif startframe < 1; % if the start of frame starts in negatives
                    front = zeros((abs(startframe)-0),1);
                    behind = stackroi(1:endframe-1,1);
                    temp = cat(1,front,behind);
                    traces(:,ii) = temp;
                    
                elseif endframe>size(stackroi,1);
                    front = stackroi(startframe:end,1);
                    behind = NaN((endframe-size(stackroi,1)),1);
                    temp = cat(1,front,behind);
                    traces(:,ii) = temp;
                else
                    traces(:,ii) = stackroi(startframe:endframe,1);
                end
            end
            
            avTrace = mean(traces,2,'omitnan');
            
            %%% Make randomise trace
            
            AvShuffle = [];
            for ss = 1:20 % make an average of 20 shuffles
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
                for ii = 1:size(stimuli,1); % 60 tones delivered
                    
                    startframe = stimuli(ii,1)-((baseline*fps)-1);
                    endframe = stimuli(ii,1)+((response*fps));
                    
                    temp = []; % final
                    clearvars front behind
                    
                    if startframe == 0; % if the start of frame is 0
                        front = NaN((baseline*fps),1);
                        behind = shuffleStack(1:endframe,1);
                        temp = cat(1,front,behind);
                        
                        tracesShuffle(:,ii) = temp;
                        
                    elseif startframe < 1; % if the start of frame starts in negatives
                        front = zeros((abs(startframe)-0),1);
                        behind = shuffleStack(1:endframe-1);
                        temp = cat(1,front,behind);
                        
                        tracesShuffle(:,ii) = temp;
                        
                    elseif endframe>size(stackroi,1);
                        front = shuffleStack(startframe:end,1);
                        behind = NaN((endframe-size(stackroi,1)),1);
                        temp = cat(1,front,behind);
                        tracesShuffle(:,ii) = temp;
                    else
                        tracesShuffle(:,ii) = shuffleStack(startframe:endframe,1);
                    end
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
            xline(15,'HandleVisibility','off')
            xline(25,'HandleVisibility','off')
            legend('Average trace','Average 20 shuffles');
            legend box off
            xticks([0 5 10 15 20 25 30 35]);
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
            
            filename = [file(1:end-4),' compare to shuffle'];
            saveas(gcf,['Traces/',filename]);
            
        %    save(['Traces/',file(1:end-4),'_avTrace.mat'],'avTrace');
                       
            look(1,:) = avTrace;
            look(2,:) = AvShuffleAll;
            
            figure
            set(gcf,'color','w')
            imshow(look,[],'InitialMagnification','fit');
            colormap jet
            c = colorbar('southoutside')
            c.Label.String = 'ΔF/F'
            xline(15,'k','LineWidth',2)
            xline(25,'k','LineWidth',2)
            axis on
            box off
            yticks([1 2])
            yticklabels({'No Shuffle','Shuffle'})
            xticks([0 5 10 15 20 25 30 35]);
            xticklabels({'-3','-2','-1','0','1','2','3'})
            xlabel('Time (s)')
            
            filename = [file(1:end-4),' compare to shuffle - visual'];
            saveas(gcf,['Traces/',filename]);
                       
        else  abs(PkDiff(1,1)) > 2*fps; % Criteria not met: outside 2s for shift
            keepfile(iRec,:) = 0;
            
            %%% Make randomise trace
            AvShuffle = [];
            for ss = 1:20 % make an average of 20 shuffles
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
                for ii = 1:size(stimuli,1); % 60 tones delivered
                    
                    startframe = stimuli(ii,1)-((baseline*fps)-1);
                    endframe = stimuli(ii,1)+((response*fps));
                    
                    temp = []; % final
                    clearvars front behind
                    
                    if startframe == 0; % if the start of frame is 0
                        front = NaN((baseline*fps),1);
                        behind = shuffleStack(1:endframe,1);
                        temp = cat(1,front,behind);
                        
                        tracesShuffle(:,ii) = temp;
                        
                    elseif startframe < 1; % if the start of frame starts in negatives
                        front = zeros((abs(startframe)-0),1);
                        behind = shuffleStack(1:endframe-1);
                        temp = cat(1,front,behind);
                        
                        tracesShuffle(:,ii) = temp;
                        
                    elseif endframe>size(stackroi,1);
                        front = shuffleStack(startframe:end,1);
                        behind = NaN((endframe-size(stackroi,1)),1);
                        temp = cat(1,front,behind);
                        tracesShuffle(:,ii) = temp;
                    else
                        tracesShuffle(:,ii) = shuffleStack(startframe:endframe,1);
                    end
                end
                AvShuffle = cat(2,AvShuffle,tracesShuffle);
            end
            
            AvShuffleAll = mean(AvShuffle,2,'omitnan');
            
            difference = mean(avTrace((baseline*fps):((baseline*fps)+((reswind*fps)-1)))) - mean(AvShuffleAll((baseline*fps):((baseline*fps)+((reswind*fps)-1))));
            
            figure
            set(gcf,'color','w')
            %      boundedline(1:1:size(avTrace,1),avTrace,e,1:1:size(AvShuffleAll),AvShuffleAll,f,'r')
            plot(avTrace);
            hold on
            plot(AvShuffleAll,'r');
            scatter(xscatter,yscatter,'*','k','HandleVisibility','off')
            xline(15,'HandleVisibility','off')
            xline(25,'HandleVisibility','off')
            legend('Average trace','Average 20 shuffles');
            legend box off
            xticks([0 5 10 15 20 25 30 35]);
            xticklabels({'-3','-2','-1','0','1','2','3'})
            xlabel('Time (s)')
            ylabel('ΔF/F')
            text(0,0,'discard - Peak outside 2s')
            box off
            
            filename = [file(1:end-4),' compare to shuffle'];
            saveas(gcf,['Traces/',filename]);
            
            look(1,:) = avTrace;
            look(2,:) = AvShuffleAll;
            
            figure
            set(gcf,'color','w')
            imshow(look,[],'InitialMagnification','fit');
            colormap jet
            c = colorbar('southoutside')
            c.Label.String = 'ΔF/F'
            xline(15,'k','LineWidth',2)
            xline(25,'k','LineWidth',2)
            axis on
            box off
            yticks([1 2])
            yticklabels({'No Shuffle','Shuffle'})
            xticks([0 5 10 15 20 25 30 35]);
            xticklabels({'-3','-2','-1','0','1','2','3'})
            xlabel('Time (s)')
            
            filename = [file(1:end-4),' compare to shuffle - visual'];
            saveas(gcf,['Traces/',filename]);
        end
               
    else isempty (PkDiff);
        keepfile(iRec,:) = 0;
        Peakoffset(iRec,:) = 0;
        
        %%% Make randomise trace
        AvShuffle = [];
        
        for ss = 1:20 % make an average of 20 shuffles
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
            for ii = 1:size(stimuli,1); % 60 tones delivered
                
                startframe = stimuli(ii,1)-((baseline*fps)-1);
                endframe = stimuli(ii,1)+((response*fps));
                
                temp = []; % final
                clearvars front behind
                
                if startframe == 0; % if the start of frame is 0
                    front = NaN((baseline*fps),1);
                    behind = shuffleStack(1:endframe,1);
                    temp = cat(1,front,behind);
                    
                    tracesShuffle(:,ii) = temp;
                    
                elseif startframe < 1; % if the start of frame starts in negatives
                    front = zeros((abs(startframe)-0),1);
                    behind = shuffleStack(1:endframe-1);
                    temp = cat(1,front,behind);
                    
                    tracesShuffle(:,ii) = temp;
                    
                elseif endframe>size(stackroi,1);
                    front = shuffleStack(startframe:end,1);
                    behind = NaN((endframe-size(stackroi,1)),1);
                    temp = cat(1,front,behind);
                    tracesShuffle(:,ii) = temp;
                else
                    tracesShuffle(:,ii) = shuffleStack(startframe:endframe,1);
                end
            end
            AvShuffle = cat(2,AvShuffle,tracesShuffle);
        end
        
        AvShuffleAll = mean(AvShuffle,2,'omitnan');
        
        difference = mean(avTrace((baseline*fps):((baseline*fps)+((reswind*fps)-1)))) - mean(AvShuffleAll((baseline*fps):((baseline*fps)+((reswind*fps)-1))));
        
        figure
        set(gcf,'color','w')
        %      boundedline(1:1:size(avTrace,1),avTrace,e,1:1:size(AvShuffleAll),AvShuffleAll,f,'r')
        plot(avTrace);
        hold on
        plot(AvShuffleAll,'r');
        scatter(xscatter,yscatter,'*','k','HandleVisibility','off')
        xline(15,'HandleVisibility','off')
        xline(25,'HandleVisibility','off')
        legend('Average trace','Average 20 shuffles');
        legend box off
        xticks([0 5 10 15 20 25 30 35]);
        xticklabels({'-3','-2','-1','0','1','2','3'})
        xlabel('Time (s)')
        ylabel('ΔF/F')
        text(0,0,'Discard - No peaks detected')
        box off
        
        filename = [file(1:end-4),' compare to shuffle'];
        saveas(gcf,['Traces/',filename]);
        
        save(['Traces/',file(1:end-4),'_avTrace.mat'],'avTrace');
        
        
        look(1,:) = avTrace;
        look(2,:) = AvShuffleAll;
        
        figure
        set(gcf,'color','w')
        imshow(look,[],'InitialMagnification','fit');
        colormap jet
        c = colorbar('southoutside')
        c.Label.String = 'ΔF/F'
        xline(15,'k','LineWidth',2)
        xline(25,'k','LineWidth',2)
        axis on
        box off
        yticks([1 2])
        yticklabels({'No Shuffle','Shuffle'})
        xticks([0 5 10 15 20 25 30 35]);
        xticklabels({'-3','-2','-1','0','1','2','3'})
        xlabel('Time (s)')
        
        filename = [file(1:end-4),' compare to shuffle - visual'];
        saveas(gcf,['Traces/',filename]);
    end
    close all
end
       
save(['Traces/','peakoffset'],'peakoffset');
save(['Traces/','keepfile'],'keepfile');



    
    
    
    
    