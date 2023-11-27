%% Finding frequency in baseline vs response in spontaneous activity recording

clear 
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
        
        %   av_pk = mean(pk);
        %   av_width = (mean(w)/fps); % in seconds
        
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
        
        filename = stim_file(iFile).name;
        load(filename);
        
        %        rng = ('shuffle');
        %        random = randi(10)*10;
        
           
        stimuli(:,1:2) = round(stimuli(:,1:2) - peakoffset(iFile));
        
        
        clearvars base_location base_peaks res_location res_peaks
        base_location = [];
        base_peaks = [];
        res_location = [];
        res_peaks = [];
        
        %   res_width = [];
        %   base_width = [];
        
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
        base_freq = cat(2,base_freq,num_base_freq);
        
        total_res_length = res_time*fps*size(stimuli,1);
        num_res_freq = (size(res_location,1)/total_res_length)*fps;
        res_freq = cat(2,res_freq,num_res_freq);
        
        base_loc_scale = round(base_location/fps);
        res_loc_scale = round(res_location/fps);
        
        %   res_av_width = (mean(res_width,'all'))/fps;
        %   res_width_all = cat(2,res_width_all,res_av_width);
        
        %  base_av_width = (mean(base_width,'all'))/fps;
        %   base_width_all = cat(2,base_width_all,base_av_width);
        
        %   base_pk_av = mean(base_peaks,'all');
        %   base_pk_all = cat(2,base_pk_all,base_pk_av);
        
        %   res_pk_av = mean(res_peaks,'all');
        %   res_pk_all = cat(2,res_pk_all,res_pk_av);
        
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
        
        %   saveas(gcf, ['Area and Frequency/',name,'_base_res']);
    end
end

% if isempty(base_freq)==0;
%    save(['Area and Frequency/Baseline_FreqEvents.mat'],'base_freq');
% end

% if isempty(res_freq)==0;
%    save(['Area and Frequency/Response_FreqEvents.mat'],'res_freq');
%end

close all

