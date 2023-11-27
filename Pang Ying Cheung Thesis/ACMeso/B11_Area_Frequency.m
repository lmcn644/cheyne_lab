%% Finding the area of all tone responsive 
clear
close all
clc

mkdir('Area and Frequency')
load('BF_coordinates.mat');
load(['Traces/','keepfile']);


sum_pixel = size(coordinates,1);
% Area = (0.02008^2)*size(coordinates,1); % unit is mm


Area = (0.040321^2)*size(coordinates,1)

% look for the total pixel allocated with a BF
% the length on side of a pixel is 01/.04913 mm


A_dir = dir(['ACmask/*.mat']),
for iFile = 1:size(A_dir,1);
    if keepfile(iFile,1) == 1;
        filename = A_dir(iFile).name;
        
        load (['ACmask/',filename]);
        
        A = sum(maskroi,'all');
        
        Ay(iFile,1) = (0.02008^2)*A;
        
    else keepfile(iFile,1)==0;
        ;
    end
end

Ayy = mean(Ay,'all');
Area(1,2) = (0.02008^2)*A;

save(['Area and Frequency/Area.mat'],'Area');

%%

clearvars -except keepVariables Area
close all
clc

fps = 10;
base_time = 3;
res_time = 1.5;

num_file = dir(['AC ROI DF/*.mat']);
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

ex_peak_amp = [];
in_peak_amp = [];

ex_width = [];
in_width = [];

res_width_all = [];
base_width_all = [];

res_pk_all = [];
base_pk_all = [];

load(['Traces/keepfile.mat']);
load(['Traces/peakoffset.mat']);


% mph = 0.5; % Calcium transients higher than 0.5 

scale = [0:(1/(fps*60)):20];
scale(:,12001:end) = [];

figure(1);

for iFile = 1:size(num_file,1);
    filename = num_file(iFile).name;
    name = filename(1:11);
    
    load(['AC ROI DF/',filename]);
    
    %%%% Make the fluorescence trace over time
    
    trace = [];
    for ff = 1:size(ROIstack,3);
        trace(ff,1)= mean (ROIstack(:,:,ff),'all','omitnan');
    end
    
    mph = std(trace,1,'omitnan')/2; % 1 SD of the trace
    
    [pk,loc,w] = findpeaks(trace,'MinPeakHeight',mph);
    % pk = peak
    % loc = location
    % w = width (half prominence)
    
    av_pk = mean(pk);
    av_width = (mean(w)/fps); % in seconds
    
    loc_scale = loc/(fps*60);
    
    figure(1)
    clf
    set(gcf,'color','w');
    plot(scale,trace(1:12000,1))
    hold on
    scatter(loc_scale, pk)
    yline(0, 'HandleVisibility','off')
    xlim([0 20])
    box off
    xlabel('Time (min)')
    ylabel('ΔF/F')
    
    saveas(gcf, ['Area and Frequency/',name]);
    
    num_events = (size(pk,1)/size(ROIstack,3))*fps; % number of events per second
    freq_events = cat(2,freq_events, num_events);
       
    if keepfile(iFile) == 1;
        filename = stim_file(iFile).name;
        load(filename);
        
        in_peak_amp = cat(2,in_peak_amp,av_pk);
        in_width = cat(2, in_width,av_width);      
        stimuli(:,1:2) = round(stimuli(:,1:2) - peakoffset(iFile,1));
        
        clearvars base_location base_peaks res_location res_peaks
        base_location = [];
        base_peaks = [];
        res_location = [];
        res_peaks = [];
        
        res_width = [];
        base_width = []; 
     
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
                base_width_location = w(base_find,1);
                               
                base_location = cat(1,base_location,base_position);
                base_peaks = cat(1,base_peaks,base_pk_location);
                base_width = cat(1,base_width,base_width_location);                                             
            end
                            
            if isempty(res_find) == 1;
                ;
            else isempty(res_find)== 0;            
                res_position = loc(res_find,1);
                res_pk_location = pk(res_find,1);
                res_width_location = w(res_find,1);
                
                res_location = cat(1,res_location,res_position);
                res_peaks = cat(1,res_peaks,res_pk_location);
                res_width = cat(1,res_width,res_width_location);
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
             
        res_av_width = (mean(res_width,'all'))/fps;
        res_width_all = cat(2,res_width_all,res_av_width);
        
        base_av_width = (mean(base_width,'all'))/fps;
        base_width_all = cat(2,base_width_all,base_av_width);
        
        base_pk_av = mean(base_peaks,'all');
        base_pk_all = cat(2,base_pk_all,base_pk_av);
        
        res_pk_av = mean(res_peaks,'all');
        res_pk_all = cat(2,res_pk_all,res_pk_av);
                
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
        ex_peak_amp = cat(2,ex_peak_amp,av_pk);
        ex_width = cat(2,ex_width,av_width);       
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

