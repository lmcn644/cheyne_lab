clear
close all
clc

folders = dir('DV*');
folders = natsortfiles(folders);

mkdir('Other region - Raw')

for ifolder = 1:size(folders,1);
    animal = folders(ifolder).name;
    
    imFile = dir([animal,'/Corrected 2x/*.mat']);
    imFile = natsortfiles(imFile);
        
    FC_intensity = [];
    SC_intensity = [];
    RC_intensity = [];
    
    for ii = 1:size(imFile,1);    
       
        filename = imFile(ii).name;
        
        load([animal,'/Mask Region/Trace/',filename]);
        load([animal,'/Corrected 2x/',filename]);
        
        Mr = imresize(Mr,[359 429]);
        msk = imresize(msk,[359 429]);
        
        Mr(:,:,3001:end) = [];
        
        %%% Frontal Region
        
        ROI = NaN(size(Mr));
        for xx = 1:size(Mr,1);
            for yy = 1:size(Mr,2);
                if msk(xx,yy,2)== 0;
                    ;
                else msk(xx,yy,2) == 1;
                    g_filt = Mr(xx,yy,:);
                    ROI(xx,yy,:) = g_filt;
                end
            end
        end
        
        avIntensity = mean(mean(ROI,3,'omitnan'),'all','omitnan');
        FC_intensity = cat(2,FC_intensity,avIntensity);
        
        %%% Somatosensory Region
        
        ROI = NaN(size(Mr));
        for xx = 1:size(Mr,1);
            for yy = 1:size(Mr,2);
                if msk(xx,yy,3)== 0;
                    ;
                else msk(xx,yy,3) == 1;
                    g_filt = Mr(xx,yy,:);
                    ROI(xx,yy,:) = g_filt;
                end
            end
        end
        
        avIntensity = mean(mean(ROI,3,'omitnan'),'all','omitnan');
        SC_intensity = cat(2,SC_intensity,avIntensity);
        
        %%% Retrosplenial Region
        
        ROI = NaN(size(Mr));
        for xx = 1:size(Mr,1);
            for yy = 1:size(Mr,2);
                if msk(xx,yy,4)== 0;
                    ;
                else msk(xx,yy,4) == 1;
                    g_filt = Mr(xx,yy,:);
                    ROI(xx,yy,:) = g_filt;
                end
            end
        end
        
        avIntensity = mean(mean(ROI,3,'omitnan'),'all','omitnan');
        RC_intensity = cat(2,RC_intensity,avIntensity);
             
    end
    
    save(['Other region - Raw/',animal,'.mat'],'FC_intensity','SC_intensity','RC_intensity');
end

%%

clearvars -except keepVariables folders

FC_raw = [];
FC_amplitude = [];

SC_raw = [];
SC_amplitude = [];

RC_raw = [];
RC_amplitude = [];

for ii = 1:size(folders);
    foldername = folders(ii).name;
    
    load(['Other Regions/',foldername]);
    load(['Other region - Raw/',foldername]);
    
    FC_raw = cat(1,FC_raw, (transpose(FC_intensity)));
    FC_amplitude = cat(1,FC_amplitude,(transpose(Frontal_amp)));
    
    SC_raw =  cat(1,SC_raw, (transpose(SC_intensity)))
    SC_amplitude =  cat(1,SC_amplitude,(transpose(Somato_amp)));
    
    RC_raw = cat(1,RC_raw, (transpose(RC_intensity)))
    RC_amplitude =  cat(1,RC_amplitude,(transpose(Retro_amp)));
    
    clearvars -except keepVariables folders ii FC_raw FC_amplitude SC_raw SC_amplitude RC_raw RC_amplitude     
end








    