
clear
close all
clc


mkdir('Frequency');

folders = dir('ACMeso*');
folders = natsortfiles(folders);

fps = 10;
base_time = 3;
res_time = 3;

scale = [0:(1/(fps*60)):20];
scale(:,12001:end) = [];

for ii = 8:size(folders,1);
    animal = folders(ii).name;
    
    num_file = dir([animal,'/AC ROI DF/*.mat']);
    num_file = natsortfiles(num_file);
    
    stim_file = dir([animal,'/* stimuli.mat']);
    stim_file = natsortfiles(stim_file);
    
    load([animal,'/Traces/keepfile.mat']);
    load([animal,'/Traces/peakoffset.mat']);
 
   
    base_freq = []; % in seconds
    res_freq = [];
    
    res_location = [];
    res_peaks = [];
    base_location = [];
    base_peaks =[];
    
    sp_res_location = [];
    sp_res_peaks = [];
    sp_base_location = [];
    sp_base_peaks =[];
    
    for iFile = 1:size(num_file,1);
        filename = num_file(iFile).name;
        
        load([animal,'/AC ROI DF/',filename]);
        
        %%%% Make the fluorescence trace over time
        trace = [];
        for ff = 1:size(ROIstack,3);
            trace(ff,1)= mean (ROIstack(:,:,ff),'all','omitnan');
        end
       
        
        mph = std(trace,1,'omitnan')/2; % 1 SD of the trace
        
        [pk,loc] = findpeaks(trace,'MinPeakHeight',mph);
        
        
        filename = stim_file(iFile).name;
        load([animal,'/',filename]);
        
        stimuli(:,1:2) = round(stimuli(:,1:2) - peakoffset(iFile,1));
         total_baseline_length = base_time*fps*size(stimuli,1);
         total_res_length = res_time*fps*size(stimuli,1);
        
        clearvars base_location base_peaks res_location res_peaks
        base_location = [];
        base_peaks = [];
        
        res_location = [];
        res_peaks = [];
        
    %    figure
    %    plot(trace);
    %    xlim([0 12000]);        
    %    hold on
    %    scatter(loc,pk);
        
        
        for tt = 1:size(stimuli,1);
              clearvars base_start res_end base_find res_find
            
            base_start = stimuli(tt,1)-((base_time*fps)-1);
            res_end = stimuli(tt,1)+(res_time*fps);
            
            base_find = find(loc >= base_start & loc<=(stimuli(tt,1)-1));
            res_find = find (loc >=(stimuli(tt,1))& loc <=res_end);
            
      %      xline(base_start,'r')
      %      xline(res_end,'b');
      %      xline(stimuli(tt,1));
            
            
            if isempty(base_find) == 1;
                ;
            else isempty(base_find)== 0;
                base_position = loc(base_find);
                base_pk_location = pk(base_find);
                                             
      %         hold on
      %          scatter(base_position,base_pk_location,'*','r');
                               
                base_location = cat(1,base_location,base_position);
                base_peaks = cat(1,base_peaks,base_pk_location);
            end
            
            if isempty(res_find) == 1;
                ;
            else isempty(res_find)== 0;
                res_position = loc(res_find);
                res_pk_location = pk(res_find);
                
       %         hold on
       %         scatter(res_position,res_pk_location,'*','g');
                
                res_location = cat(1,res_location,res_position);
                res_peaks = cat(1,res_peaks,res_pk_location);
            end
            
        end
              
        num_base_freq = (size(base_location,1)/total_baseline_length)*fps;   %0.0434 per frame           
        base_freq = cat(2,base_freq,num_base_freq);
               
        num_res_freq = (size(res_location,1)/total_res_length)*fps;
        res_freq = cat(2,res_freq,num_res_freq);
    end
    save(['Frequency/',animal,'_base3.mat'],'base_freq');
    save(['Frequency/',animal,'_res3.mat'],'res_freq');
end
    
%% 

clear
close all
clc

mkdir('Frequency 1.5');

folders = dir('ACMeso*');
folders = natsortfiles(folders);

fps = 10;
base_time = 1.5;
res_time = 1.5;

scale = [0:(1/(fps*60)):20];
scale(:,12001:end) = [];

for ii = 1:size(folders,1);
    animal = folders(ii).name;
    
    num_file = dir([animal,'/AC ROI DF/*.mat']);
    num_file = natsortfiles(num_file);
    
    stim_file = dir([animal,'/* stimuli.mat']);
    stim_file = natsortfiles(stim_file);
    
    load([animal,'/Traces/keepfile.mat']);
    load([animal,'/Traces/peakoffset.mat']);
 
   
    base_freq = []; % in seconds
    res_freq = [];
    
    res_location = [];
    res_peaks = [];
    base_location = [];
    base_peaks =[];
    
    sp_res_location = [];
    sp_res_peaks = [];
    sp_base_location = [];
    sp_base_peaks =[];
    
    for iFile = 1:size(num_file,1);
        filename = num_file(iFile).name;
        
        load([animal,'/AC ROI DF/',filename]);
        
        %%%% Make the fluorescence trace over time
        trace = [];
        for ff = 1:size(ROIstack,3);
            trace(ff,1)= mean (ROIstack(:,:,ff),'all','omitnan');
        end
        
        mph = std(trace,1,'omitnan')/2; % 1 SD of the trace
        
        [pk,loc] = findpeaks(trace,'MinPeakHeight',mph);
        
        filename = stim_file(iFile).name;
        load([animal,'/',filename]);
        
        stimuli(:,1:2) = round(stimuli(:,1:2) - peakoffset(iFile,1));
        
        
        clearvars base_location base_peaks res_location res_peaks
        base_location = [];
        base_peaks = [];
        
        res_location = [];
        res_peaks = [];
        
        for tt = 1:size(stimuli,1);
            base_start = stimuli(tt,1)-((base_time*fps)-1);
            res_end = stimuli(tt,1)+(res_time*fps);
            
            base_find = find(loc >= base_start & loc<=(stimuli(tt,1)-1));
            res_find = find (loc >=(stimuli(tt,1))& loc <=res_end);
            
            if isempty(base_find) == 1;
                ;
            else isempty(base_find)== 0;
                base_position = loc(base_find,1);
                base_pk_location = pk(base_find,1);
                
                base_location = cat(1,base_location,base_position);
                base_peaks = cat(1,base_peaks,base_pk_location);
            end
            
            if isempty(res_find) == 1;
                ;
            else isempty(res_find)== 0;
                res_position = loc(res_find,1);
                res_pk_location = pk(res_find,1);
                
                res_location = cat(1,res_location,res_position);
                res_peaks = cat(1,res_peaks,res_pk_location);
            end
        end
        
        total_baseline_length = base_time*fps*size(stimuli,1);
        num_base_freq = (size(base_location,1)/total_baseline_length)*fps;
        base_freq = cat(2,base_freq,num_base_freq);
        
        total_res_length = res_time*fps*size(stimuli,1);
        num_res_freq = (size(res_location,1)/total_res_length)*fps;
        res_freq = cat(2,res_freq,num_res_freq);
    end
    save(['Frequency 1.5/',animal,'_base1_5.mat'],'base_freq');
    save(['Frequency 1.5/',animal,'_res1_5.mat'],'res_freq');
end


