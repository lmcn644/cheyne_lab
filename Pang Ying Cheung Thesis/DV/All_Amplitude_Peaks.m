
clear
close all
clc

folders = dir('DV*');
folders = natsortfiles(folders);

fps = 10;

for ii = 1:size(folders,1);
    foldername = folders(ii).name;
    
    DF_file = dir([foldername,'/DFs/*.mat']);
    DF_file = natsortfiles(DF_file);
    
    
    for iFile = 1:size(DF_file,1);
        filename = DF_file(iFile).name;
        
        All_trace = [];
        
        load([foldername,'/DFs/',filename]);
        load([foldername,'/Mask Region/Trace/',filename(1:end-4)]);
        
        msk = imresize(msk,[359 429]);
        stack = imresize(stack,[359 429]);
        
        %%%
        ROIstack = NaN(size(stack));
        for xx = 1:size(stack,1);
            for yy = 1:size(stack,2);
                if msk(xx,yy,1)== 0;
                    ;
                else msk(xx,yy,1) == 1;
                    g_filt = imgaussfilt3(stack(xx,yy,:),2);
                    ROIstack(xx,yy,:) = g_filt;
                end
            end
        end
        
        trace = [];
        for ii = 1:size(ROIstack,3);
            trace(ii,1) = mean(ROIstack(:,:,ii),'all','omitnan');
        end
        
        mph = std(trace,1,'omitnan')/2; % 1 SD of the trace
        [pk,loc] = findpeaks(trace,'MinPeakHeight',mph);
        
        
        save([foldername,'/Amplitude/',filename(1:end-4),'_pk.mat'],'pk');
        save([foldername,'/Amplitude/',filename(1:end-4),'_loc.mat'],'loc');
        
        All_trace = cat(2,All_trace,trace);
        
        %%% Frontal trace
        
        ROIstack = NaN(size(stack));
        for xx = 1:size(stack,1);
            for yy = 1:size(stack,2);
                if msk(xx,yy,2)== 0;
                    ;
                else msk(xx,yy,2) == 1;
                    g_filt = imgaussfilt3(stack(xx,yy,:),2);
                    ROIstack(xx,yy,:) = g_filt;
                end
            end
        end
        
        
        trace = [];
        for ii = 1:size(ROIstack,3);
            trace(ii,1) = mean(ROIstack(:,:,ii),'all','omitnan');
        end
        
        All_trace = cat(2,All_trace,trace);
        
        
        %%% Somatosensory trace
        ROIstack = NaN(size(stack));
        for xx = 1:size(stack,1);
            for yy = 1:size(stack,2);
                if msk(xx,yy,3)== 0;
                    ;
                else msk(xx,yy,3) == 1;
                    g_filt = imgaussfilt3(stack(xx,yy,:),2);
                    ROIstack(xx,yy,:) = g_filt;
                end
            end
        end
        
        trace = [];
        for ii = 1:size(ROIstack,3);
            trace(ii,1) = mean(ROIstack(:,:,ii),'all','omitnan');
        end
        
        All_trace = cat(2,All_trace,trace);
        
        %%% Retrosplenial trace
        ROIstack = NaN(size(stack));
        for xx = 1:size(stack,1);
            for yy = 1:size(stack,2);
                if msk(xx,yy,4)== 0;
                    ;
                else msk(xx,yy,4) == 1;
                    g_filt = imgaussfilt3(stack(xx,yy,:),2);
                    ROIstack(xx,yy,:) = g_filt;
                end
            end
        end
        
        trace = [];
        for ii = 1:size(ROIstack,3);
            trace(ii,1) = mean(ROIstack(:,:,ii),'all','omitnan');
        end
        
        All_trace = cat(2,All_trace,trace);
        
        save([foldername,'/Amplitude/',filename(1:end-4),'_All_trace.mat'],'All_trace');
    end
end


%%

clear
close all
clc

folders = dir('DV*');
folders = natsortfiles(folders);

for ii = 1:size(folders,1);
       foldername = folders(ii).name;
       
       mkdir([foldername,'/Amplitude Histogram']);
       
       pk_file = dir([foldername,'/Amplitude/*_pk.mat']);
       pk_file = natsortfiles(pk_file);
       
       all_peaks = [];
       for jj = 1:size(pk_file,1);
           filename = pk_file(jj).name;
           Bin_Limits = [];
           Bin_Values = [];
           BinInfo = [];
           
           load([foldername,'/Amplitude/',filename]);
           
           all_peaks = cat(1,all_peaks,pk);
           
           figure(1)
           clf
           h = histogram(pk,'BinWidth',2);
           hold on
           
           Bin_Values = h.Values;
           Bin_Limits = h.BinEdges;
           
           Bin_Y = cat(2,0,Bin_Values);
           
           BinInfo (:,1) = Bin_Limits;
           BinInfo (:,2) = Bin_Y;
           
           
           save([foldername,'/Amplitude Histogram/',filename(1:7),'_BinInfo.mat'],'BinInfo');
           
       end
       save([foldername,'/Amplitude Histogram/All_Peaks.mat'],'all_peaks');
end

clearvars -except keepVariables folders 

for ii = 1:size(folders,1);
    foldername = folders(ii).name;
    
    pk_file = dir([foldername,'/Amplitude Histogram/*_BinInfo.mat']);
    pk_file = natsortfiles(pk_file);
    
    load([foldername,'/Amplitude Histogram/All_Peaks.mat']);
    
    figure(1)
    clf
    set(gcf,'color','w');
    yyaxis right
    h = histogram(all_peaks,'BinWidth',2,'FaceAlpha',0.5);
    ylabel('Count per animal')
    box off
    
    for jj = 1:size(pk_file,1);
        filename = pk_file(jj).name;
        load([foldername,'/Amplitude Histogram/',filename]);
        
        % Removing rows with zeros counts
        gone=find(BinInfo(:,2)==0);
        BinInfo(gone,:) = [];
        
        figure (1)
        yyaxis left
        hold on        
        scatter(BinInfo(:,1),BinInfo(:,2),50,'filled');
        
    end
    ylabel('Count per recording')
    
    saveas(gcf,[foldername,'/Amplitude Histogram/Amplitude counts']);
              
end
   
%% 

% WT


total_pk = [];

figure(1)
clf
set(gcf,'color','w');
subplot(2,1,1)
hold on
% set(gca,'xtick',[])
box off
ylabel('Count (per recording)')
xlim ([0 50]);
ylim([0 35])
    
for ii = 1:size(folders,1);
    foldername = folders(ii).name;
    
    pk_file = dir([foldername,'/Amplitude Histogram/*_BinInfo.mat']);
    pk_file = natsortfiles(pk_file);
    
    load([foldername,'/Amplitude Histogram/All_Peaks.mat']);
    
    total_pk = cat(1,total_pk,all_peaks);
       
    for jj = 1:size(pk_file,1);
        filename = pk_file(jj).name;
        load([foldername,'/Amplitude Histogram/',filename]);
        
        % Removing rows with zeros counts
        gone=find(BinInfo(:,2)==0);
        BinInfo(gone,:) = [];
        
        figure (1)
    %    yyaxis left
        hold on        
        scatter(BinInfo(:,1),BinInfo(:,2),25,'filled');
              
    end    
              
end

subplot(2,1,2)
h = histogram(total_pk,'BinWidth',2,'FaceAlpha',0.5)
box off
ylabel('Count (all recording per genotype)')
xlabel('Amplitude (ΔF/F0)');
xlim ([0 50]);
ylim([0 300])



%%



total_KO = [];

    
for ii = 1:size(folders,1);
    foldername = folders(ii).name;
    
    pk_file = dir([foldername,'/Amplitude Histogram/*_BinInfo.mat']);
    pk_file = natsortfiles(pk_file);
    
    load([foldername,'/Amplitude Histogram/All_Peaks.mat']);
    
        
%    total_WT = cat(1,total_WT,all_peaks);    
%    total_HET = cat(1,total_HET,all_peaks);
    total_KO = cat(1,total_KO,all_peaks);
                   
end


figure
clf
set(gcf,'color','w')
box off
hold on
histogram(total_WT,'BinWidth',2)
histogram(total_HET,'BinWidth',2,'FaceAlpha',0.5)
histogram(total_KO,'BinWidth',2,'FaceAlpha',0.25)
xlim([0 50]);
ylim([0 300]);

ylabel('Count (all recording per genotype)')
xlabel('Amplitude (ΔF/F0)');

legend ('WT','HET','KO')
legend box on

















       
        
        
        
       
        
    
    

           

    
    
    
    



        
