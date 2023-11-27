
clearvars -except keepVariables peakoffset
close all
clc

mkdir('ACmask');
mkdir('AC ROI DF');

imageroi = dir(['DFs/*.mat']);
imageroi = natsortfiles(imageroi);

stimfile = dir('* stimuli.mat');
stimfile = natsortfiles(stimfile);

load(['Traces/peakoffset.mat']);

fps = 10; % frames per seconds
rec = round((12000/fps)/60);
ResWind = 1.5; % 2 seconds response window
BaseWind = 3; % 3s baseline
 
for iFile = 1:size(imageroi,1);
     
    % load stimulus file 
    filename = stimfile(iFile).name;
    
    load(filename);
    
    filename = imageroi(iFile).name;
    load(['DFs/',filename]);
        
    stimuli(:,1:2) = stimuli(:,1:2)- peakoffset(iFile,:);   
    stimuli = round(stimuli);
       
    StackRes = [];   
    StackBase = [];
    
    for ss = 1:size(stimuli,1)
        ResPeriod = stack(:,:,((stimuli(ss,1)):(stimuli(ss,1)+((ResWind*fps)-1))));
        BasePeriod = stack(:,:,((stimuli(ss,1)-(BaseWind)*fps):(stimuli(ss,1)-1)));
        StackRes = cat(3,StackRes,ResPeriod);
        StackBase = cat(3, StackBase,BasePeriod); 
    end
    
    resAll = mean(StackRes,3,'omitnan');
    baseAll = mean(StackBase,3,'omitnan');
    
    im_min = min(min(resAll));
    im_max = max(max(resAll));
    
    figure (1)
    clf
    set(gcf, 'color','w')
    subplot(1,2,1)
    imshow(baseAll,[0 im_max]);
    colormap turbo
    title ('Baseline period')
    subplot(1,2,2)
    imshow(resAll,[0 im_max]);
    title ('Response period')
    c=colorbar;
    c.Label.String = 'ΔF/F';
    colormap turbo
    
    saveas(figure(1), ['ACmask/',filename(1:end-4),'_BaseRes']);
        
%    close figure(1)
    
    figure(2)
    clf
    imshow(resAll, [],'InitialMagnification','fit');
    title ('Response');
    c=colorbar;
    c.Label.String = 'ΔF/F';
    colormap turbo
   
    saveas(figure(2), ['ACmask/',filename(1:end-4)]);
    
    
    roi = drawfreehand(gca);
    %roi = drawcircle(gca);
    cont = input ('Continue? 1 = yes, 0 = restart: ');
    if cont == 1
        ;
    else cont == 0
        restart = input('Re-draw ROI? (1 = yes, 0 = no): ');
        while restart == 1
            delete(roi)
            roi = drawfreehand(gca);
            restart = input('Re-draw ROI? (1 = yes, 0 = no): ');
        end
    end
    
    roimask = createMask(roi);
    maskroi = imdilate(roimask,strel('disk',3));
    
    save(['ACmask/',filename(1:end-4)],'maskroi');
 
    
    ROIstack = NaN(size(stack));
    for xx = 1:size(stack,1);
        for yy = 1:size(stack,2);
            if maskroi(xx,yy) == 0;
                ;
            else maskroi(xx,yy) == 1;
                g_filt = imgaussfilt3(stack(xx,yy,:),2);
                ROIstack(xx,yy,:) = g_filt;
            end
        end
    end
    
    name = [filename(1:end-4),'_AC_ROI.mat']
    save(['AC ROI DF/',name],'ROIstack','-v7.3')
       
    Ra = single(ROIstack);
    
    filename=[filename(1:end-4),'_AC_ROI.tif'];
    fTIF = Fast_Tiff_Write(['AC ROI DF/',filename]);
    for k = 1:size(Ra,3)
        fTIF.WriteIMG(Ra(:,:,k)');
    end
    fTIF.close;
    
end

    
    
    
    
    
    
