%% Finding frequency of calcium transients in the whole recording

clear
close all
clc



fps = 5;
base_time = 3;
res_time = 2;

num_file = dir(['DF roi/*.mat']);
num_file = natsortfiles(num_file);

stim_file = dir('* stimuli.mat');
stim_file = natsortfiles(stim_file);

freq_events = []; % in seconds

base_freq = []; % in seconds
res_freq = [];

res_location = [];
res_peaks = [];
base_location = [];
base_peaks =[];

load(['Traces/keepfile.mat']);
load(['Traces/peakoffset.mat']);

% mph = 0.5; % Calcium transients higher than 0.5 

scale = [0:(1/fps):8*60];
scale(:,end) = [];

figure(1);

for iFile = 1:size(num_file,1);
    filename = num_file(iFile).name;
    name = filename(1:8);
    
    load(['DF roi/',filename]);
    
    %%%% Make the fluorescence trace over time
    
    trace = [];
    for ff = 1:size(ROIstack,3);
        trace(ff,1)= mean (ROIstack(:,:,ff),'all','omitnan');
    end
    
    mph = std(trace,1,'omitnan')/2; % 1 SD of the trace

    [pk loc] = findpeaks(trace,'MinPeakHeight',mph);
    
    loc_scale = loc/fps;
    
    figure(1)
    clf
    set(gcf,'color','w');
    plot(scale,trace(1:2400,1))
    hold on
    scatter(loc_scale, pk)
    yline(0, 'HandleVisibility','off')
    box off
    xlabel('Time (s)')
    ylabel('ΔF/F')
    
    saveas(gcf, ['Area and Frequency/',name]);
    
    num_events = (size(pk,1)/size(ROIstack,3))*fps; % number of events per frame
    freq_events = cat(2,freq_events, num_events);
       
    if keepfile(iFile) == 1;
        filename = stim_file(iFile).name;
        load(filename);
        
        stimuli(2:2:end,:) = [];
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
                base_position = loc(base_find,1)
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
        
        base_loc_scale = round(base_location/fps);
        res_loc_scale = round(res_location/fps);
             
        figure (1)
        clf
        set(gcf,'color','w');
        plot(trace)
        hold on
        scatter(base_location,base_peaks,[],'r');
        scatter(res_location,res_peaks,[],'g');
        box off
        xlabel('Time (frame number)')
        ylabel('ΔF/F')
        
        saveas(gcf, ['Area and Frequency/',name,'_base_res']);
          
    else keepfile(iFile,1) == 0;
        ;
    end
end

save(['Area and Frequency/FreqEvents.mat'],'freq_events');

if isempty(base_freq)==0;
    save(['Area and Frequency/Baseline_FreqEvents.mat'],'base_freq');
end

if isempty(res_freq)==0;
    save(['Area and Frequency/Response_FreqEvents.mat'],'res_freq');
end

close all

%% 

clear
close all
clc

load(['Traces/keepfile.mat']);

fps = 5;

ex_peak_amp = [];
in_peak_amp = [];

ex_prom = [];
in_prom = [];

ex_width = [];
in_width = [];


imfile = dir(['DF roi/*.mat']);
imfile = natsortfiles(imfile);

for ii = 1:size(keepfile,1);
    filename = imfile(ii).name;
    load(['DF roi/',filename]);
   
    trace = [];
    for ff = 1:size(ROIstack,3);
        trace(ff,1)= mean (ROIstack(:,:,ff),'all','omitnan');
    end
    
     mph = std(trace,1,'omitnan')/2; % 1 SD of the trace
     [pk,loc,w, prom] = findpeaks(trace,'MinPeakHeight',mph);
        % pk = peak
        % loc = location
        % w = width (half prominence)
        % prom = prominence
     
        av_pk = mean(pk);
        av_width = (mean(w)/fps); % in seconds
        av_prom = mean(prom);
            
    if keepfile(ii,1) == 0; % Excluded file 
        ex_peak_amp = cat(2,ex_peak_amp,av_pk);
        ex_prom = cat(2,ex_prom,av_prom);
        ex_width = cat(2,ex_width,av_width);
        
    else keepfile(ii,1)==1;
        in_peak_amp = cat(2,in_peak_amp,av_pk);
        in_prom = cat(2, in_prom,av_prom);
        in_width = cat(2, in_width,av_width);
    end
end

if isempty (ex_peak_amp)== 0;
    save(['Area and Frequency/ex_peak_amp.mat'],'ex_peak_amp');
end

if isempty (ex_prom)== 0;
    save(['Area and Frequency/ex_prom.mat'],'ex_prom');
end

if isempty (ex_width)== 0;
    save(['Area and Frequency/ex_width.mat'],'ex_width');
end

if isempty (in_peak_amp)== 0;
    save(['Area and Frequency/in_peak_amp.mat'],'in_peak_amp');
end

if isempty (in_prom)== 0;
    save(['Area and Frequency/in_prom.mat'],'in_prom');
end

if isempty (in_width)== 0;
    save(['Area and Frequency/in_width.mat'],'in_width');
end

























