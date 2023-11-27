
clear
close all
clc 

mkdir('Frequency');

DF_file = dir(['DFs/*.mat']);
DF_file = natsortfiles(DF_file);

msk_roi = dir(['Mask Region/Trace/*.mat']);
msk_roi = natsortfiles(msk_roi);

fps = 10;

figure(1)
freq_evt_s = [];
freq_evt = [];
amp = [];
duration = [];

% load('Tilt_number.mat');

for iFile = 1:size(DF_file,1);
   %  if tilt_number(iFile,1) > 0;
        
        filename = DF_file(iFile).name;
        
        load(['DFs/',filename]);
        
        load(['Mask Region/Trace/',filename(1:end-4)]);
        % 1 = AC; 2 = FC; 3 = SC; 4 = RC
        
        msk = imresize(msk,[359 429]);
        
        stack = imresize(stack,[359 429]);
        
        
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
        [pk,loc,w] = findpeaks(trace,'MinPeakHeight',mph);
        
        avW = mean(w)/fps;
        
        figure(1)
        clf
        plot(trace);
        hold on
        scatter(loc,pk,'*');
                
        saveas(figure(1),['Frequency/',filename(1:end-4)]);
        
        num_event = (size(pk,1)/size(ROIstack,3))*fps;
        
        freq_evt = cat(2,freq_evt,size(pk,1));
        freq_evt_s = cat(2,freq_evt_s,num_event);
        amp = cat(2,amp,(mean(pk)));
        duration = cat(2, duration,avW);
  %  else tilt_number == 0;
  %      ;
  %  end   
end

save(['Frequency/',filename(1:end-6),'Frequency_s'],'freq_evt_s');
save(['Frequency/',filename(1:end-6),'Frequency'],'freq_evt');
save(['Frequency/',filename(1:end-6),'avAmplitude'],'amp');
save(['Frequency/',filename(1:end-6),'duration'],'duration');












