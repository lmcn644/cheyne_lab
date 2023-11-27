%%

clear
close all
clc

folders = dir('DV*');
folders = natsortfiles(folders);

for ifolder = 1:size(folders,1);
    animal = folders(ifolder).name;
    
    imFile = dir([animal,'/Corrected 2x/*.mat']);
    imFile = natsortfiles(imFile);
    
    intensity = [];   
    for ii = 1:size(imFile,1);
        filename = imFile(ii).name;
        
        load([animal,'/Mask Region/Trace/',filename]);
        load([animal,'/Corrected 2x/',filename]);
        
        Mr = imresize(Mr,[359 429]);
        msk = imresize(msk,[359 429]);
        
        Mr(:,:,3001:end) = [];
        
        ROI = NaN(size(Mr));
        for xx = 1:size(Mr,1);
            for yy = 1:size(Mr,2);
                if msk(xx,yy,1)== 0;
                    ;
                else msk(xx,yy,1) == 1;
                    g_filt = Mr(xx,yy,:);
                    ROI(xx,yy,:) = g_filt;
                end
            end
        end
        
        avIntensity = mean(mean(ROI,3,'omitnan'),'all','omitnan');
        intensity = cat(2,intensity,avIntensity);
    end
    save([animal,'/Amplitude/Intensity.mat'],'intensity');
       
end

%%%%%
raw = [];
amplitude = [];

% folders = dir('DV*');
% folders = natsortfiles(folders);

for ii = 1:size(folders);
    foldername = folders(ii).name;

    load([foldername,'/Amplitude/Intensity.mat']);
    load([foldername,'/Frequency/',foldername,'_avAmplitude.mat']);
    
    raw = cat(1,raw,(transpose(intensity)));
    amplitude = cat(1,amplitude,(transpose(amp)));
   
    clear intensity amp

end

save('All_amplitude.mat','amplitude');
save('All_raw_intensity.mat','raw');

mdl = fitlm(raw,amplitude);

R_squared = mdl.Rsquared.Ordinary;
R_value = sqrt(mdl.Rsquared.Ordinary);

save('Linear_regression_Raw_amplitude.mat','mdl');

save('R_value_Raw_vs_Amplitude.mat','R_value');

figure
set(gcf,'color','w');
scatter(raw,amplitude);
xlabel('Mean grey intensity')
ylabel('Average amplitude (ΔF/F0)');


%%


clear
close all
clc

folders = dir('AC*');
folders = natsortfiles(folders);

for iFolder = 1:size(folders,1);
    animal = folders(iFolder).name;
    mkdir([animal,'/Amplitude']);
    
    imFile = dir([animal,'/Corrected 2x/*.mat']);
    imFile = natsortfiles(imFile);
    
    mskFile = dir([animal,'/ACmask/*.mat']);
    mskFile = natsortfiles(mskFile);
    
    DF_file = dir([animal,'/AC ROI DF/*.mat']);
    DF_file = natsortfiles(DF_file);
    
    intensity = [];
    amp = [];
    
    for iFile = 1:size(imFile,1);
       
        filename_raw = imFile(iFile).name;
        filename_DF = DF_file(iFile).name;
        filename_mas = mskFile(iFile).name;
        
        load([animal,'/Corrected 2x/', filename_raw]);
        load([animal,'/AC ROI DF/',filename_DF]);        
        load([animal,'/ACmask/', filename_mas]);
      
        All(:,:,12001:end)=[];
        ROIstack(:,:,12001:end)= [];
        
        All = imresize(All, [256 306]);
        ROIstack = imresize(ROIstack,[256 306]);
            
        %%% Mean grey value RAW       
        ROI = NaN(size(All));
        for xx = 1:size(All,1);
            for yy = 1:size(All,2);
                if maskroi(xx,yy)== 0;
                    ;
                else maskroi(xx,yy) == 1;
                    g_filt = All(xx,yy,:);
                    ROI(xx,yy,:) = g_filt;
                end
            end
        end
        
        avIntensity = mean(mean(ROI,3,'omitnan'),'all','omitnan');
        intensity = cat(2,intensity,avIntensity);
        
        %%% find amplitude for whole recording?
        trace = [];
        for ff = 1:size(ROIstack,3);
            frame = mean(ROIstack(:,:,ff),'all','omitnan');
            trace = cat(1,trace,frame);
        end
        
        mph = std(trace,1,'omitnan')/2; % 1 SD of the trace
        [pk,loc] = findpeaks(trace,'MinPeakHeight',mph);
        
        av_amp = mean(pk);
        amp = cat(2, amp,av_amp);
        
    end
    
    save([animal,'/Amplitude/Intensity.mat'],'intensity');
    save([animal,'/Amplitude/Amplitude.mat'],'amp')
    
end

%%%%% 
raw = [];
amplitude = [];

folders = dir('AC*');
folders = natsortfiles(folders);

for ii = 1:size(folders);
    foldername = folders(ii).name;

    load([foldername,'/Amplitude/Intensity.mat']);
    load([foldername,'/Amplitude/Amplitude.mat']);
    
    raw = cat(1,raw,(transpose(intensity)));
    amplitude = cat(1,amplitude,(transpose(amp)));
   
    clear intensity amp

end


save('All_amplitude.mat','amplitude');
save('All_raw_intensity.mat','raw');

mdl = fitlm(raw,amplitude);

R_squared = mdl.Rsquared.Ordinary;
R_value = sqrt(mdl.Rsquared.Ordinary);

save('Linear_regression_Raw_amplitude.mat','mdl');

save('R_value_Raw_vs_Amplitude.mat','R_value');

figure
set(gcf,'color','w');
scatter(raw,amplitude);
xlabel('Mean grey intensity')
ylabel('Average amplitude (ΔF/F0)');


%% 

raw = [];

for ii = 1:size(folders);
    foldername = folders(ii).name;

    load([foldername,'/Amplitude Histogram/All_Peaks.mat']);   
    raw = cat(1,raw,all_peaks);  
   

end







