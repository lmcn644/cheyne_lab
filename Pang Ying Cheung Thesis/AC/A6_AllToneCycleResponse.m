
clear
close all
clc

mkdir('DF output')
mkdir('DF Low-Mid-High')
mkdir('Normalised Output');

load(['Traces/keepfile.mat']);
load(['Traces/peakoffset.mat']);

recordings = dir(['DF roi/','*.mat']);
recordings = natsortfiles(recordings);

stimfiles = dir('*stimuli.mat');
stimfiles = natsortfiles(stimfiles);

maskfiles = dir(['Mask/*.mat']);
maskfiles = natsortfiles(maskfiles);

fps = 5; % frames per seconds
response = 2; % 2 seconds response window
baseline = 3; % baseline period in seconds
lastframe = 4;

for iFile = 1:size(recordings,1);
           
    if keepfile(iFile,1)==1;
              
        fprintf('iFile %d\n',iFile);
        fprintf('Inclusion criteria met\n');
      
        filename = recordings(iFile).name;
        load(['DF roi/',filename]);
       
        name = filename(1:8);        
        mkdir(['Normalised Output/',name])
        
        filename = maskfiles(iFile).name;
        load(['Mask/',filename]);
       
        filename = stimfiles(iFile).name;
        load(filename);
               
        stimuli(2:2:end,:) = [];
        stimuli(:,1:2) = stimuli(:,1:2) - peakoffset(iFile,1);
        
        stimuli=round(stimuli);
        
        frequency = unique(stimuli(:,3));            
        dB = unique(stimuli(:,4));
        
          %%%%
        loow = []; % 4-8
        miid = []; % 12-16
        hiigh =[]; % 20-24
        ultraa = []; % 28-32
        
        baseloow = [];
        basemiid = [];
        basehiigh =[];
        baseultraa = [];
        
        for iTone = 1 :size(frequency,1);
            
            base = [];
            res = [];
            
            t = find ((stimuli(:,3) == frequency(iTone,1)));
            
            f = frequency(iTone,1);
            combo = sprintf([num2str(f(1:end)), ' kHz'])
            
            mkdir(['DF output/',combo]);
            lunch = ['DF output/',combo,'/'];
            
            fprintf(['Finding maximum pixel in ', combo,'\n']);
            
            % For each pixel in the response period, find the frame with the brightest pixel
            for ii = 1:size(t,1);
                q = t(ii,1);
                startframe = stimuli(q,1)-((baseline*fps)-1);
                endframe = stimuli(q,1)+((lastframe*fps));
                
                if stimuli(q,1)<size(ROIstack,3)-50;
                    
                    t_stack = ROIstack(:,:,startframe:endframe);
                    
                    max_px = NaN(size(t_stack,1,2));
                    for xx = 1:size(t_stack,1);
                        for yy = 1:size(t_stack,2);
                            if maskroi(xx,yy) == 0;
                                ;
                            else maskroi(xx,yy) == 1;
                                px_trace = reshape(t_stack(xx,yy,:),[],1);
                                %    mph = prctile(px_trace,85);
                                mph = std(px_trace,1,'omitnan')/2;
                                [pks,locs] = findpeaks(px_trace,'MinPeakHeight',mph);
                                
                                row_loc = find(locs > 15 & locs < 25);
                                row_pk = pks(row_loc,:);
                                if size(row_loc,2) >= 1 & ~isempty(row_loc);
                                    pk_frame_find = find(px_trace(15:25,1)== max(row_pk));
                                    pk_frame = ((baseline*fps)-1)+ pk_frame_find;
                                    
                                    max_px(xx,yy) = mean((t_stack(xx,yy,pk_frame-2:pk_frame+2)),3,'omitnan');
                                    
                                    %   base01(xx,yy,:) = t_stack(xx,yy,1:baseline*fps-1);
                                    %   res01(xx,yy,:) = t_stack(xx,yy,baseline*fps+response*fps);
                                else  isempty(row_loc);
                                    ;
                                end
                            end
                        end
                    end
                    res = cat(3,res,max_px);
                    
                else stimuli(q,1)>size(ROIstack,3)-50;
                    ;
                end
            end
            
            
            avRes = mean(res,3,'omitnan');
            
            filename=[name,'.mat']
            save ([lunch,filename],'avRes')
            
            avRes = single(avRes);
            imname=[name,'.tif']
            saveastiff (avRes,[lunch,imname])
            
            if  f == 5 | f == 10;
                loow = cat(3,loow, res);
                baseloow = cat(3,baseloow,base);
            elseif f == 15 | f == 20;
                miid = cat(3,miid,res);
                basemiid = cat(3,basemiid,base);
            elseif  f == 25| f == 30;
                hiigh = cat(3,hiigh,res);
                basehiigh = cat(3,basehiigh,base);
            else f > 35;
                ultraa = cat(3,ultraa,res);
                baseultraa = cat(3,baseultraa,base);
            end
            
            %%% Normalisation each tone per animal
            
            imax = max(max(avRes));
            imin = min(min(avRes));
            
            norm_avRes = NaN(size(avRes,1,2));
            for xx = 1:size(avRes,1);
                for yy = 1:size(avRes,2);
                    if maskroi(xx,yy) == 0;
                        ;
                    else maskroi(xx,yy)== 1;
                        norr = (avRes(xx,yy)-imin)/(imax-imin);
                        norm_avRes(xx,yy) = norr;
                    end
                end
            end
            
            save(['Normalised Output/',name,'/',combo,'.mat'],'norm_avRes');
            
            norm_avRes = single(norm_avRes);
            saveastiff(norm_avRes,['Normalised Output/',name,'/',combo,'.tif']);
            
        end
        
        %%% NOT NORMALISED!!! 
              
        mkdir(['DF Low-Mid-High/A1_Low']);
        
        avRes = mean(loow,3,'omitnan');
        thisname = [name,'.mat'];
        save(['DF Low-Mid-High/A1_Low/',thisname],'avRes');
        
        avRes = single(avRes);
        thisname = [name,'.tif'];
        saveastiff(avRes,['DF Low-Mid-High/A1_Low/',thisname])
        
        %%%%
        mkdir(['DF Low-Mid-High/A2_Mid']);
        
        avRes = mean(miid,3,'omitnan');
        thisname = [name,'.mat'];
        save(['DF Low-Mid-High/A2_Mid/',thisname],'avRes');
        
        avRes = single(avRes);
        thisname = [name,'.tif'];
        saveastiff(avRes,['DF Low-Mid-High/A2_Mid/',thisname])
        
        %%%%
        mkdir(['DF Low-Mid-High/A3_High']);
        
        avRes = mean(hiigh,3,'omitnan');
        thisname = [name,'.mat'];
        save(['DF Low-Mid-High/A3_High/',thisname],'avRes');
        
        avRes = single(avRes);
        thisname = [name,'.tif'];
        saveastiff(avRes,['DF Low-Mid-High/A3_High/',thisname])
        
        %%%%
        mkdir(['DF Low-Mid-High/A4_Ultra']);
        
        avRes = mean(ultraa,3,'omitnan');
        thisname = [name,'.mat'];
        save(['DF Low-Mid-High/A4_Ultra/',thisname],'avRes');
        
        avRes = single(avRes);
        thisname = [name,'.tif'];
        saveastiff(avRes,['DF Low-Mid-High/A4_Ultra/',thisname])
        
    else keepfile(iFile,1) == 0;
        
        fprintf('iFile %d\n',iFile);       
        fprintf('Inclusion criteria not met\n');
       
    end
end

%%%%%%

honey = dir(['DF output']);
honey(1:2,:) = [];
honey = natsortfiles(honey);

for iFolder = 1:size(honey,1);
    bee = honey(iFolder).name;
    
    bee_file = dir(['DF output/',bee,'/','*.mat']);
      
    crrt = [];
    for iFile = 1:size(bee_file,1);
        imfile = bee_file(iFile).name;
        
        load(['DF output/',bee,'/',imfile]);
      
        crrt = cat(3,crrt,avRes);        
    end
        
    av_crrt = mean(crrt,3,'omitnan'); 
    
    %%%% Normalisation
    
    imax = max(max(av_crrt));
    imin = min(min(av_crrt));
    
    norm_avRes = NaN(size(av_crrt,1,2));
    for xx = 1:size(av_crrt,1);
        for yy = 1:size(av_crrt,2);
            if isnan(av_crrt (xx,yy))== 1;
                ;
            else isnan(av_crrt (xx,yy))== 0;
                norr = (av_crrt(xx,yy)-imin)/(imax-imin);
                norm_avRes(xx,yy) = norr;
            end
        end
    end
     
    save(['Normalised Output/',bee],'norm_avRes');
    norm_avRes = single(norm_avRes);
    saveastiff(norm_avRes,['Normalised Output/',bee,'.tif']);
end
      






%%% CODE COPIED FROM ACMESO.. NOT OPTIMISED


% clear
% close all
% clc

% load brightfield for image registration


% registrationEstimator

% save('movingReg02','movingReg02');
% save('movingReg03','movingReg03');

% fixed02 = imref2d(movingReg02.SpatialRefObj.ImageSize);
% fixed03 = imref2d(movingReg03.SpatialRefObj.ImageSize);

% honey = dir(['DF output']);
% honey(1:2,:) = [];
% honey = natsortfiles(honey);


% for iFolder = 1:size(honey,1);
%    bee = honey(iFolder).name;
    
%    bee_file = dir(['DF output/',bee,'/','*.mat']);
    
%    crrt = [];
%    for iFile = 1:size(bee_file,1);
%        imfile = bee_file(iFile).name;
        
%        load(['DF output/',bee,'/',imfile]);
        
%        if iFile == 1;
%            crrt = cat(3,crrt,avRes);
            
%        elseif iFile == 2;
%            correct = imwarp(avRes,movingReg02.Transformation,'OutputView',fixed02);
%            crrt = cat(3,crrt,correct);
            
%        elseif iFile == 3;
%            correct = imwarp(avRes,movingReg03.Transformation,'OutputView',fixed03);
%            crrt = cat(3,crrt,correct);
%        else iFile == 4;
%            correct = imwarp(avRes,movingReg04.Transformation,'OutputView',fixed04);
%            crrt = cat(3,crrt,correct);
%        end
%    end
        
%    av_crrt = mean(crrt,3,'omitnan');   
%    save(['DF output/',bee,'.mat'],'av_crrt');
   
%    av_crrt = single(av_crrt);
%    saveastiff(av_crrt,['DF output/',bee,'.tif']);  
% end

% close all

        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        