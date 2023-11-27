clear
close all
clc

folders = dir('DV*');
folders = natsortfiles(folders);

fps = 10;

mkdir('Other Regions');

for ii = 1:size(folders,1);
      foldername = folders(ii).name;
      
      amp_file = dir([foldername,'/Amplitude/*All_trace.mat']);
      amp_file = natsortfiles(amp_file);
      
      Frontal_freq_evt_s = [];
      Frontal_amp = [];
      Frontal_duration = [];
      
      Somato_freq_evt_s = [];
      Somato_amp = [];
      Somato_duration = [];
      
      Retro_freq_evt_s = [];
      Retro_amp = [];
      Retro_duration = [];
      
      DF_file = dir([foldername,'/DFs/*.mat']);
      DF_file = natsortfiles(DF_file);
      
      for iFile = 1:size(amp_file,1);
        filename = amp_file(iFile).name;
        
        load([foldername,'/Amplitude/',filename]);
        
        DF_name = DF_file(iFile).name;
        matObj = matfile([foldername,'/DFs/',DF_name]);
        [~,~, nframe] = size(matObj,'stack');    
                
        %%% Frontal
        
        trace = All_trace(:,2);
        
        mph = std(trace,1,'omitnan')/2; % 1 SD of the trace
        [pk,loc,w] = findpeaks(trace,'MinPeakHeight',mph);
        
        avW = mean(w)/fps;
        
        num_event = (size(pk,1)/nframe)*fps;
        
        Frontal_freq_evt_s = cat(2,Frontal_freq_evt_s,num_event);
        Frontal_amp = cat(2,Frontal_amp,(mean(pk)));
        Frontal_duration = cat(2, Frontal_duration,avW);
        
        %%% Somato
        
        trace = All_trace(:,3);
        
        mph = std(trace,1,'omitnan')/2; % 1 SD of the trace
        [pk,loc,w] = findpeaks(trace,'MinPeakHeight',mph);
        
        avW = mean(w)/fps;
        
        num_event = (size(pk,1)/nframe)*fps;
        
        Somato_freq_evt_s = cat(2,Somato_freq_evt_s,num_event);
        Somato_amp = cat(2,Somato_amp,(mean(pk)));
        Somato_duration = cat(2, Somato_duration,avW);
        
        %%% Retro
        
        trace = All_trace(:,4);
        
        mph = std(trace,1,'omitnan')/2; % 1 SD of the trace
        [pk,loc,w] = findpeaks(trace,'MinPeakHeight',mph);
        
        avW = mean(w)/fps;
        
        num_event = (size(pk,1)/nframe)*fps;
        
        Retro_freq_evt_s = cat(2,Retro_freq_evt_s,num_event);
        Retro_amp = cat(2,Retro_amp,(mean(pk)));
        Retro_duration = cat(2, Retro_duration,avW);
      end
      
      save(['Other Regions/',foldername,'.mat'],'Frontal_amp','Frontal_duration','Frontal_freq_evt_s',...
          'Somato_amp','Somato_duration','Somato_freq_evt_s','Retro_amp','Retro_duration','Retro_freq_evt_s');



end



         
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    