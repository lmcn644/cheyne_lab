
clear 
close all
clc


fps = 10;
base_time = 3;
res_time = 1.5;

mkdir('Shuffle Freq');

num_file = dir(['AC ROI DF/*.mat']);
num_file = natsortfiles(num_file);

stim_file = dir('* stimuli.mat');
stim_file = natsortfiles(stim_file);

freq_events = []; % in seconds

base_freq = []; % in seconds
res_freq = [];

load(['Traces/keepfile.mat']);
load(['Traces/peakoffset.mat']);


% mph = 0.5; % Calcium transients higher than 0.5 

scale = [0:(1/(fps*60)):20];
scale(:,12001:end) = [];

figure(1);

for iFile = 1:size(num_file,1);
    
    if keepfile(iFile,1) == 1;
        ;
    else keepfile(iFile,1)== 0;
        
        filename = num_file(iFile).name;
        name = filename(1:11);
        
        load(['AC ROI DF/',filename]);
        
        %%%% Make the fluorescence trace over time
        
        trace = [];
        for ff = 1:12000;
            trace(ff,1)= mean (ROIstack(:,:,ff),'all','omitnan');
        end
        
        mph = std(trace,1,'omitnan')/2; % 1 SD of the trace
        
        [pk,loc,w] = findpeaks(trace,'MinPeakHeight',mph);
        % pk = peak
        % loc = location
        % w = width (half prominence)
        
        
        loc_scale = loc/(fps*60);
        
        %   saveas(gcf, ['Area and Frequency/',name]);
        
        num_events = (size(pk,1)/size(ROIstack,3))*fps; % number of events per second
        freq_events = cat(2,freq_events, num_events);
        
        
        filename = stim_file(iFile).name;
        load(filename);
        
        
        rng = ('shuffle');
        random = randperm(10,5);
        
        
        
        stimuli(:,1:2) = round(stimuli(:,1:2) - peakoffset(iFile));
        og_stim = stimuli;
                      
        shuffled_base= [];
        shuffled_res = [];
        
        for ii = 1:5;
            stimuli = og_stim;
            
            stimuli(:,1:2) = round(stimuli(:,1:2) - random(1,ii));
            
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
                    base_position = loc(base_find,1)
                    base_pk_location = pk(base_find,1);
                    %        base_width_location = w(base_find,1);
                    
                    base_location = cat(1,base_location,base_position);
                    base_peaks = cat(1,base_peaks,base_pk_location);
                    %        base_width = cat(1,base_width,base_width_location);
                end
                
                if isempty(res_find) == 1;
                    ;
                else isempty(res_find)== 0;
                    res_position = loc(res_find,1);
                    res_pk_location = pk(res_find,1);
                    %         res_width_location = w(res_find,1);
                    
                    res_location = cat(1,res_location,res_position);
                    res_peaks = cat(1,res_peaks,res_pk_location);
                    %         res_width = cat(1,res_width,res_width_location);
                end
            end
            
            
            
            total_baseline_length = base_time*fps*size(stimuli,1);
            num_base_freq = (size(base_location,1)/total_baseline_length)*fps;
            shuffled_base = cat(2,shuffled_base,num_base_freq);
            
            total_res_length = res_time*fps*size(stimuli,1);
            num_res_freq = (size(res_location,1)/total_res_length)*fps;
            shuffled_res = cat(2,shuffled_res,num_res_freq);
            
            base_loc_scale = round(base_location/fps);
            res_loc_scale = round(res_location/fps);
        end
        
        av_base = mean(shuffled_base);
        av_res = mean(shuffled_res);
        
        
        base_freq = cat(1,base_freq,av_base);
        res_freq = cat(1,res_freq,av_res);
        
        
    end
end

if isempty (res_width_all)== 0;
    save(['Area and Frequency/res_width_all.mat'],'res_width_all');
end

if isempty (base_width_all)== 0;
    save(['Area and Frequency/base_width_all.mat'],'base_width_all');
end

if isempty (res_pk_all)== 0;
    save(['Area and Frequency/res_pk_all.mat'],'res_pk_all');
end

if isempty (base_pk_all)== 0;
    save(['Area and Frequency/base_pk_all.mat'],'base_pk_all');
end

save(['Area and Frequency/FreqEvents.mat'],'freq_events');

if isempty(base_freq)==0;
    save(['Area and Frequency/Baseline_FreqEvents.mat'],'base_freq');
end

if isempty(res_freq)==0;
    save(['Area and Frequency/Response_FreqEvents.mat'],'res_freq');
end

if isempty (ex_peak_amp)== 0;
    save(['Area and Frequency/ex_peak_amp.mat'],'ex_peak_amp');
end

if isempty (ex_width)== 0;
    save(['Area and Frequency/ex_width.mat'],'ex_width');
end

if isempty (in_peak_amp)== 0;
    save(['Area and Frequency/in_peak_amp.mat'],'in_peak_amp');
end

if isempty (in_width)== 0;
    save(['Area and Frequency/in_width.mat'],'in_width');
end


close all

