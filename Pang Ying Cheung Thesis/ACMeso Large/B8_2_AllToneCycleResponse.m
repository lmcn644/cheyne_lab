%% All tones 

clear
close all
clc

mkdir('DF output')
mkdir('DF Low-Mid-High')
mkdir('Normalised Output');

load(['Traces/keepfile.mat']);
load(['Traces/peakoffset.mat']);

recordings = dir(['AC ROI DF/','*.mat']);
recordings = natsortfiles(recordings);

stimfiles = dir('*stimuli.mat');
stimfiles = natsortfiles(stimfiles);

maskfiles = dir(['ACMask/*.mat']);
maskfiles = natsortfiles(maskfiles);

fps = 10; % frames per seconds
response = 1.5; % 2 seconds response window
baseline = 3; % baseline period in seconds
lastframe = 4;

for iFile = 1:size(recordings,1);
    
    if keepfile(iFile,1)==1;
        
        fprintf('iFile %d\n',iFile);
        fprintf('Inclusion criteria met\n');
        
        filename = recordings(iFile).name;
        load(['AC ROI DF/',filename]);
        
        name = filename(1:11);
        mkdir(['Normalised Output/',name])
        
        filename = maskfiles(iFile).name;
        load(['ACMask/',filename]);
        
        filename = stimfiles(iFile).name;
        load(filename);
        
        stimuli(:,1:2) = stimuli(:,1:2) - peakoffset(iFile,1);
        
        stimuli=round(stimuli);
        
        frequency = unique(stimuli(:,3));
        dB = unique(stimuli(:,4));
        
        loow = []; % 4-8
        miid = []; % 12-16
        hiigh =[]; % 20-24
        ultraa = []; % 28-32
        
        for iTone = 1 :size(frequency,1);
            
            base = [];
            res = [];
            
            t = find ((stimuli(:,3) == frequency(iTone,1)));
            
            f = frequency(iTone,1)/1000;
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
                                
                                row_loc = find(locs > 30 & locs < 45);
                                row_pk = pks(row_loc,:);
                                if size(row_loc,2) >= 1 & ~isempty(row_loc);
                                    pk_frame_find = find(px_trace(30:45,1)== max(row_pk));
                                    pk_frame = ((baseline*fps)-1)+ pk_frame_find;
                                    
                                    max_px(xx,yy) = mean((t_stack(xx,yy,pk_frame-2:pk_frame+2)),3,'omitnan');

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
            
            if  f == 4 | f == 8 ;
                loow = cat(3,loow, res);
            elseif f == 12 | f == 16;
                miid = cat(3,miid,res);
            elseif  f == 20| f == 24;
                hiigh = cat(3,hiigh,res);
            else f > 27;
                ultraa = cat(3,ultraa,res);
            end
            
            %%% Normalisation each tone per animal
            
            imax = max(max(avRes));
            imin = min(min(avRes));
            
                      
            norm_avRes1 = NaN(size(avRes,1,2));
            for xx = 1:size(avRes,1);
                for yy = 1:size(avRes,2);
                    if maskroi(xx,yy) == 0;
                        ;
                    else maskroi(xx,yy)== 1;
                        norr = (avRes(xx,yy)-imin)/(imax-imin);
                        norm_avRes1(xx,yy) = norr;
                    end
                end
            end
            
          norm_avRes = imcrop(norm_avRes1,[20 5 220 200] )
            
            save(['Normalised Output/',name,'/',combo,'.mat'],'norm_avRes');
            
            norm_avRes = single(norm_avRes);
            saveastiff(norm_avRes,['Normalised Output/',name,'/',combo,'.tif']);
            
        end
        
        %%% NOT NORMALISED!!! 
              
        mkdir(['DF Low-Mid-High/A1_Low']);
        
        avRes = mean(loow,3,'omitnan');
        
        thisname = [name,'.mat'];
        save(['DF Low-Mid-High/A1_Low/',thisname],'avRes');
        
        norm_avRes = single(avRes);
        thisname = [name,'.tif'];
        saveastiff(norm_avRes,['DF Low-Mid-High/A1_Low/',thisname])
        
        %%%%
        mkdir(['DF Low-Mid-High/A2_Mid']);
        
        avRes = mean(miid,3,'omitnan');
     
        thisname = [name,'.mat'];
        save(['DF Low-Mid-High/A2_Mid/',thisname],'avRes');
        
        norm_avRes = single(avRes);
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



%% Motion correct all frequencies

clear
close all
clc

load(['Traces/keepfile']);

avFile = dir('*avAll.mat');
avFile = natsortfiles(avFile);

for ii = 1:size(avFile,1);
    
    if keepfile(ii,1) == 1;
        filename = avFile(ii).name;
        load(filename);
        
        if ii == 1;
            avAll_fixed = avAll;
        elseif ii == 2;
            avAll_02 = avAll;
        elseif ii == 3;
            avAll_03 = avAll;
        else ii == 4; 
            avAll_04 = avAll;
        end
    else keepfile (ii,1) == 0;
        ;
    end
end

registrationEstimator

save('movingReg02','movingReg02');
fixed02 = imref2d(movingReg02.SpatialRefObj.ImageSize);

 save('movingReg03','movingReg03');
 fixed03 = imref2d(movingReg03.SpatialRefObj.ImageSize);

% save('movingReg04','movingReg04')
% fixed04 = imref2d(movingReg04.SpatialRefObj.ImageSize);

mskfile = dir(['ACmask/*.mat']);
mskfile = natsortfiles(mskfile);

% The ROI of AC is not the same for each recording 
% need to find the smallest  mask ROI

final_mask = zeros([201 221]);
for ii = 1:size(mskfile,1);
    if keepfile(ii,1)== 1;
        filename = mskfile(ii).name;
        load(['ACmask/',filename]);
        
        maskro = imcrop(maskroi,[20 5 220 200] )
       
        maskroi = maskro;
        
        for xx = 1:size(maskroi,1);
            for yy = 1:size(maskroi,2);
                if isnan(final_mask(xx,yy)) == 0; % free, not used
                    if maskroi(xx,yy) == 0;
                        final_mask(xx,yy) = NaN;
                    else maskroi(xx,yy) == 1;
                        final_mask(xx,yy) = 1;
                    end
                else isnan(final_mask(xx,yy))==1;
                    ;
                end
            end
        end
        
    else keepfile(ii,1) == 0;
        ;
    end
    
end

save('final_mask.mat','final_mask');

clearvars -except keepfile movingReg02 movingReg03 movingReg04 fixed02 fixed03 fixed04 final_mask;
clc

maskroi = final_mask;
maskroi(isnan(maskroi)==1) = 0;

honey = dir(['DF Output/']);
honey(1:2,:) = [];
honey = natsortfiles(honey);



for iFolder = 1:size(honey,1);
    bee = honey(iFolder).name;
    
    bee_file = dir(['DF output/',bee,'/','*.mat']);
    
    crrt = [];
    for iFile = 1:size(bee_file,1);
        imfile = bee_file(iFile).name;
        
        load(['DF output/',bee,'/',imfile]);
        
         I = imcrop(avRes,[20 5 220 200] );
         avRes = I;
                              
        if iFile == 1;
            avRes_msk = zeros(size(avRes));
            for xx = 1:size(avRes,1);
                for yy = 1:size(avRes,2);
                    if maskroi(xx,yy) == 0; % element in matrix is NaN;
                        ;
                    else maskroi(xx,yy)== 1; % Within the mask
                        avRes_msk(xx,yy) = avRes(xx,yy);
                    end
                end
            end
                        
            crrt = cat(3,crrt,avRes_msk);   
            
        elseif iFile == 2;
            correct = imwarp(avRes,movingReg02.Transformation,'OutputView',fixed02);
           
            avRes_msk = zeros([201 221]);
            for xx = 1:size(avRes,1);
                for yy = 1:size(avRes,2);
                    if maskroi(xx,yy) == 0; % element in matrix is NaN;
                        ;
                    else maskroi(xx,yy)== 1; % Within the mask
                        avRes_msk(xx,yy) = avRes(xx,yy);
                    end
                end
            end
                       
            crrt = cat(3,crrt,avRes_msk);
            
        elseif iFile == 3;
            correct = imwarp(avRes,movingReg03.Transformation,'OutputView',fixed03);
            
            avRes_msk = zeros([201 221]);
            for xx = 1:size(avRes,1);
                for yy = 1:size(avRes,2);
                    if maskroi(xx,yy) == 0; % element in matrix is NaN;
                        ;
                    else maskroi(xx,yy)== 1; % Within the mask
                        avRes_msk(xx,yy) = avRes(xx,yy);
                    end
                end
            end
                        
            crrt = cat(3,crrt,avRes_msk);
            
        else iFile == 4;
            correct = imwarp(avRes_msk,movingReg04.Transformation,'OutputView',fixed04);
            
            avRes_msk = zeros([201 221]);
            for xx = 1:size(avRes,1);
                for yy = 1:size(avRes,2);
                    if maskroi(xx,yy) == 0; % element in matrix is NaN;
                        ;
                    else maskroi(xx,yy)== 1; % Within the mask
                        avRes_msk(xx,yy) = avRes(xx,yy);
                    end
                end
            end
                      
            crrt = cat(3,crrt,avRes_msk);
        end
    end
        
    av_crrt = mean(crrt,3,'omitnan');   
    save(['DF output/',bee,'.mat'],'av_crrt');
   
    av_crrt = single(av_crrt);
    saveastiff(av_crrt,['DF output/',bee,'.tif']);  
end

clearvars -except movingReg02 movingReg03 movingReg04 fixed02 fixed03 fixed04 maskroi
clc

freqIm = dir(['DF output/*.mat']);
freqIm = natsortfiles (freqIm);

for iTone = 1:size(freqIm,1);
    filename = freqIm(iTone).name;
    load(['DF output/',filename]);
       
    imax = max(max(av_crrt));
    imin = min(min(av_crrt));
    
    norm_avRes = NaN(size(av_crrt,1,2));
    for xx = 1:size(av_crrt,1);
        for yy = 1:size(av_crrt,2);
            if maskroi(xx,yy) == 0;
                ;
            else maskroi(xx,yy)== 1;
                norr = (av_crrt(xx,yy)-imin)/(imax-imin);
                norm_avRes(xx,yy) = norr;
            end
        end
    end
    
    save(['Normalised Output/',filename],'norm_avRes');
    
    norm_avRes = single(norm_avRes);
    saveastiff(norm_avRes,['Normalised Output/',filename(1:end-4),'.tif']);
end
    

%% High-Mid-Low 
        
clearvars -except movingReg02 movingReg03 movingReg04 fixed02 fixed03 fixed04 maskroi
clc

mkdir('Normalised HML');

paddock = dir(['DF Low-Mid-High']);
paddock(1:2,:)=[];

paddock = natsortfiles(paddock);

for iFolder = 1:size(paddock,1);
    cow = paddock(iFolder).name;
    
    cow_file = dir(['DF Low-Mid-High/',cow,'/*.mat']);
    cow_file = natsortfiles(cow_file);
    
    crrt = [];
    for iFile = 1:size(cow_file,1);
        imfile = cow_file(iFile).name;
        
        load(['DF Low-Mid-High/',cow,'/',imfile]);
        
        
        if iFile == 1;
            
            avRes_msk = zeros(size(avRes));
            for xx = 1:size(avRes,1);
                for yy = 1:size(avRes,2);
                    if maskroi(xx,yy) == 0; % element in matrix is NaN;
                        ;
                    else maskroi(xx,yy)== 1; % Within the mask
                        avRes_msk(xx,yy) = avRes(xx,yy);
                    end
                end
            end
            
            crrt = cat(3,crrt,avRes_msk);
        elseif iFile == 2;
            correct = imwarp(avRes,movingReg02.Transformation,'OutputView',fixed02);
            
            avRes_msk = zeros(size(correct));
            for xx = 1:size(avRes,1);
                for yy = 1:size(avRes,2);
                    if maskroi(xx,yy) == 0; % element in matrix is NaN;
                        ;
                    else maskroi(xx,yy)== 1; % Within the mask
                        avRes_msk(xx,yy) = avRes(xx,yy);
                    end
                end
            end
            
            crrt = cat(3,crrt,avRes_msk);
            
        elseif iFile == 3;
            correct = imwarp(avRes,movingReg03.Transformation,'OutputView',fixed03);
            
            avRes_msk = zeros(size(correct));
            for xx = 1:size(avRes,1);
                for yy = 1:size(avRes,2);
                    if maskroi(xx,yy) == 0; % element in matrix is NaN;
                        ;
                    else maskroi(xx,yy)== 1; % Within the mask
                        avRes_msk(xx,yy) = avRes(xx,yy);
                    end
                end
            end
            
            crrt = cat(3,crrt,avRes_msk);
            
        else iFile == 4;
            correct = imwarp(avRes,movingReg04.Transformation,'OutputView',fixed04);
            
            avRes_msk = zeros(size(correct));
            for xx = 1:size(avRes,1);
                for yy = 1:size(avRes,2);
                    if maskroi(xx,yy) == 0; % element in matrix is NaN;
                        ;
                    else maskroi(xx,yy)== 1; % Within the mask
                        avRes_msk(xx,yy) = avRes(xx,yy);
                    end
                end
            end
            
            crrt = cat(3,crrt,avRes_msk);
            
        end
    end
    
    av_crrt = mean(crrt,3,'omitnan');
    save(['DF Low-Mid-High/',cow],'av_crrt');
    
    av_crrt = single(av_crrt);
    saveastiff(av_crrt,['DF Low-Mid-High/',cow,'.tif']);
    
end

clearvars -except movingReg02 movingReg03 movingReg04 fixed02 fixed03 fixed04 maskroi
clc

freqIm = dir(['DF Low-Mid-High/*.mat']);
freqIm = natsortfiles (freqIm);

mskfile = dir(['ACmask/*.mat']);
mskfile = natsortfiles(mskfile);
msk = mskfile(1).name;

load(['ACmask/',msk]);

for iTone = 1:size(freqIm,1);
    filename = freqIm(iTone).name;
    load(['DF Low-Mid-High/',filename]);
    
    imax = max(max(av_crrt));
    imin = min(min(av_crrt));
    
    norm_avRes = NaN(size(av_crrt,1,2));
    for xx = 1:size(av_crrt,1);
        for yy = 1:size(av_crrt,2);
            if maskroi(xx,yy) == 0;
                ;
            else maskroi(xx,yy)== 1;
                norr = (av_crrt(xx,yy)-imin)/(imax-imin);
                norm_avRes(xx,yy) = norr;
            end
        end
    end
    
    save(['Normalised HML/',filename],'norm_avRes');
    
    norm_avRes = single(norm_avRes);
    saveastiff(norm_avRes,['Normalised HML/',filename(1:end-4),'.tif']);
end


