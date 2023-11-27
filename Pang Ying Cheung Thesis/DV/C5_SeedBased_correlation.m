clear
close all
clc

mkdir('Seed Correlation');
mkdir('Mask Region');
mkdir('Mask Region/Trace');
mkdir('Mask Region/Binary');

DF_file = dir(['DFs/*.mat']);
DF_file = natsortfiles(DF_file);

mask_file = dir(['MaskROI/*.mat']);
mask_file = natsortfiles(mask_file);

avfile = dir('*_avAll.mat');
avfile = natsortfiles(avfile);

colour(1,:)= [0,0.4471,0.7412];
colour(2,:)= [0.6353,0.0784,0.1843];
colour(3,:)= [0.9294,0.6941,0.1255];
colour(4,:)= [0.4941,0.1843,0.5569];

scale2 = [1/600:1/600:3];

figure (1);
for iFile = 1:size(DF_file,1);
    name = DF_file(iFile).name; 
   % av_name = [name(1:end-4),'_avAll.mat'];
   % mask_name = [name(1:end-4),'_ROI.mat'];   
    
    mask_name = dir(['MaskROI/',name(1:end-4),'*_ROI.mat']);
    avfile = dir(['*',name(1:end-4),'*_avAll.mat']);
      
    load(['DFs/',name]);
    load(avfile(1).name);   
    load(['MaskROI/',mask_name(1).name]);
    
    % Downsize by 65% (35%)
    
    avAll = imresize(avAll,[359 429]);
    maskroi = imresize(maskroi,[359 429]);
    
    stack = imresize(stack,[359 429]);
    
%%%% Select pixel seed    
    im_max = max(max(avAll))+50;
    im_min = min(min(avAll))-50;
    
    figure(1);
    imshow(avAll,[im_min im_max]);

    cont = input('Can you see? 1 = yes, 0 = no: ');
    if cont == 1;
        ;
    else cont == 0;
        restart = input('Manually entry? 1 = yes, 0 = no: ');
        im_max
        im_min
        while restart == 1;
           im_max = input('maximum intensity: ');
           im_min = input('minimum intensity: ');
           
           figure(1)
           imshow(avAll,[im_min im_max]);
           
           restart = input('Try again? 1 = yes, 0 = no: ');
        end
        restart = 0;
    end
    % note down the min and max intensity
     
    j = imtool(avAll,[im_min im_max]); % To select pixel seeds;
      
    seed = [];
    a = 0;   
    last_seed = 0;
    
    fprintf('Put pixel values inbetween square brackets\n\n');
    
    while last_seed == 0;
        a = a+1;
        if a == 1;
           seed(a,:) = input('Auditory pixel info as:' ) 
           last_seed = 0;
        elseif a == 2; 
           seed(a,:) = input('Frontal pixel info as:' ) 
           last_seed = 0;
        elseif a == 3;
           seed(a,:) = input('Somatosensory pixel info as:' ) 
           last_seed = 0;
        else a == 4;
            seed(a,:) = input('Retrosplenial pixel info as:' ) 
           last_seed = 1;
        end
    end
      
    % 1 = Auditory = Caudo-lateral
    % 2 = Frontal = Near olfactory
    % 3 = Somatosensory = adjacent to bregma
    % 4 = Retrosplenial = caudo-medial
    
    seedling = [];
    for ii =1 : size(seed,1);
        seedpxl = stack((seed(ii,2)),(seed(ii,1)),:);
        seedpx = reshape(seedpxl, 1,size(stack,3));
        seedling(ii,:) = seedpx;
    end
    
%    maxlim = round(max(max(seedling)),0)+2;
%    minlim = round(min(min(seedling)),0)-2;
    
%    max_round = ceil(maxlim/10)*10;
%    min_round = ceil(-minlim/10)*-10;
        
%    figure (1)
%    set(gcf, 'color','w')
%    for pp = 1:size(seedling,1)
%        if pp < size(seedling,1);
%            subplot(4,1,pp);
%            plot(scale2, seedling(pp,1:1800),'Color',colour(pp,:));
%            ylim([min_round max_round])
%            ax = gca;
%            ax.TitleHorizontalAlignment = 'left';
%            set(gca,'xtick',[])
%            box off
%            axis off
          
%            if pp == 1;
%               title(strcat("1. Auditory seed pixel "," [",string(seed(pp,1)),",",string(seed(pp,2)),"]"),'FontSize',15);               
%            elseif pp == 2;
%               title(strcat("2. Frontal seed pixel "," [",string(seed(pp,1)),",",string(seed(pp,2)),"]"),'FontSize',15);
%            else pp == 3;
%                title(strcat("3. Somatosensory seed pixel "," [",string(seed(pp,1)),",",string(seed(pp,2)),"]"),'FontSize',15);
%            end
%        else pp = size(seedling,1);
%            subplot(4,1,pp);
%            plot(scale2, seedling(pp,1:1800),'Color',colour(pp,:));
%            ylim([min_round max_round])
%            ax = gca;
%            ax.TitleHorizontalAlignment = 'left';
%            title(strcat("4. Retrosplenial seed pixel "," [",string(seed(pp,1)),",",string(seed(pp,2)),"]"),'FontSize',15);               

%            ylabel ("ΔF/F")
%            xlabel ("Time (min)")
%            box off
%        end
%    end
    
%    saveas(gca,['Seed Correlation/Seed_trace_',name(1:end-4)]);
    
    %% Correlation Analysis on fluorescence signal
    stacknan= stack;
    stack(isnan(stack))=0;
    
    rDF1 = xcorr3 (stack,seedling(1,:));
    rDF2 = xcorr3 (stack,seedling(2,:));
    rDF3 = xcorr3 (stack,seedling(3,:));
    rDF4 = xcorr3 (stack,seedling(4,:));
    
    cor_min = 0;
    cor_max = 1;
    
    figure(1)
    set(gcf,'color','w');
    subplot(2,2,1)
    imshow(rDF1,[cor_min cor_max]);
  %  title(strcat("1. Auditory seed pixel "," [",string(seed(1,1)),",",string(seed(1,2)),"]"));               
    hold on
    colormap jet
    rectangle('position',[(seed(1,1)-0.5) (seed(1,2)-0.5) 1 1], 'FaceColor','w');
    axis off   
    subplot(2,2,2)
    imshow(rDF2,[cor_min cor_max]);
 %   title(strcat("2. Frontal seed pixel "," [",string(seed(2,1)),",",string(seed(1,2)),"]"));               
    colormap jet
    hold on
    rectangle('position',[(seed(2,1)-0.5) (seed(2,2)-0.5) 1 1], 'FaceColor','w');
    axis off  
    subplot(2,2,3)
   imshow(rDF3,[cor_min cor_max]);
 %   title(strcat("3. Somatosensory seed pixel "," [",string(seed(3,1)),",",string(seed(3,2)),"]"));               
    colormap jet
    hold on
    rectangle('position',[(seed(3,1)-0.5) (seed(3,2)-0.5) 1 1], 'FaceColor','w');
    % colorbar
    axis off   
    subplot(2,2,4)
    imshow(rDF4,[cor_min cor_max]);
   % title(strcat("4. Retrosplenial seed pixel "," [",string(seed(4,1)),",",string(seed(4,2)),"]"));               
    colormap jet
    hold on
    rectangle('position',[(seed(4,1)-0.5) (seed(4,2)-0.5) 1 1], 'FaceColor','w');
    c = colorbar
    c.Label.String = 'Correlaton coefficient'
    c.Ticks = [cor_min (cor_max/2) cor_max]
    axis off
    
    saveas(gcf,['Seed Correlation/Correlation_',name(1:end-4)]);
    
%%% Make Maskroi   
%    mkdir(['Mask Region/Trace/',name(1:end-4)]);
%    folder_path = ['Mask Region/Trace/',name(1:end-4),'/'];          
    
%%%%%%%%   
    figure(1)
    clf
    imshow(rDF1,[0 1]);
    colormap jet
    
    fprintf('Make Auditory ROI\n');
        
    roi = drawfreehand(gca);
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
    ACmask = imdilate(roimask,strel('disk',3));
      
%%%%%%%%%%
    figure(1)
    clf
    imshow(rDF2,[0 1]);
    colormap jet

    fprintf('Make Frontal ROI\n');
       
    roi = drawfreehand(gca);
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
    FCmask = imdilate(roimask,strel('disk',3));
    
%%%%%%%%
    figure(1)
    clf
    imshow(rDF3,[0 1]);
    colormap jet
    
    fprintf('Make Somatosensory ROI\n');
    
    roi = drawfreehand(gca);
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
    SCmask = imdilate(roimask,strel('disk',3));
  
%%%%%%%%%%%%
    figure(1)
    clf
    imshow(rDF4,[0 1]);
    colormap jet
    
    fprintf('Make Retrosplenial ROI\n');
    
    roi = drawfreehand(gca);
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
    RCmask = imdilate(roimask,strel('disk',3));
  
%%%% Region of ROI using fluorescence 
   msk(:,:,1) = ACmask;
   msk(:,:,2) = FCmask;
   msk(:,:,3) = SCmask;
   msk(:,:,4) = RCmask;
   av_m = mean(msk,3);
   
   save(['Mask Region/Trace/',name(1:end-4)],'msk');
      
   k = imfuse(avAll, av_m, 'blend');
   
   figure(1);
   clf
   set(gcf,'color','w')
   imshow(k,[]);
   
   saveas(gcf,['Seed Correlation/',name(1:end-4),'_trace_regions']);
     
    %% Correlation Analysis on binary signal
    
    %%% Binary seed
    binary_seed = [];
    for bb = 1:size(seedling,1);
        px2 = seedling(bb,:);
        
        threshold = std(px2)/2;
        
        binar = [];
        for jj = 1:size(px2,2);
            if px2(1,jj) < threshold;
                binar(1,jj) = 0;
            else px2(1,jj)>= threshold;
                binar(1,jj) = 1;
            end
        end
        
        binary_seed(bb,:)= binar;
    end
    
    clearvars -except keepVariables av_file avAll binary_seed colour DF_file iFile im_min im_max maskroi name rDF1 rDF2 rDF3 rDF4 scale2 seed seedling stack stacknan
    
    binarr = zeros(size(stacknan));
    for xx = 1:size(stacknan,1);
        for yy = 1:size(stacknan,2);
            
            px = stacknan(xx,yy,:);
            
            if maskroi(xx,yy) == 0;
                ;
            else maskroi(xx,yy) == 1;
                
                %     pxx = reshape(px,[],size(stack,3));
                threshold = std(px)/2;
                
                zeros_ones = zeros(size(px));
                for iCol = 1:size(px,3);
                    if px(1,1,iCol)<threshold;
                        zeros_ones(1,1,iCol) = 0;
                    else px(1,1,iCol)>threshold;
                        zeros_ones(1,1,iCol) = 1;
                    end
                end
                
                binarr(xx,yy,:) = zeros_ones;
            end
        end
    end
    
    r1 = xcorr3(binarr,binary_seed(1,:));
    r2 = xcorr3(binarr,binary_seed(2,:));
    r3 = xcorr3(binarr,binary_seed(3,:));
    r4 = xcorr3(binarr,binary_seed(4,:));
    
    cor_min = 0;
    cor_max = 1;
    
    figure(1)
    set(gcf,'color','w');
    subplot(2,2,1)
    imshow(r1,[cor_min cor_max]);
    title(strcat("1. Auditory seed pixel "," [",string(seed(1,1)),",",string(seed(1,2)),"]"));
    hold on
    colormap jet
    rectangle('position',[(seed(1,1)-0.5) (seed(1,2)-0.5) 1 1], 'FaceColor','w');
    axis off
    subplot(2,2,2)
    imshow(r2,[cor_min cor_max]);
    title(strcat("2. Frontal seed pixel "," [",string(seed(2,1)),",",string(seed(2,2)),"]"));
    colormap jet
    hold on
    rectangle('position',[(seed(2,1)-0.5) (seed(2,2)-0.5) 1 1], 'FaceColor','w');
    axis off
    subplot(2,2,3)
    imshow(r3,[cor_min cor_max]);
    title(strcat("3. Somatosensory seed pixel "," [",string(seed(3,1)),",",string(seed(3,2)),"]"));
    colormap jet
    hold on
    rectangle('position',[(seed(3,1)-0.5) (seed(3,2)-0.5) 1 1], 'FaceColor','w');
    % colorbar
    axis off
    subplot(2,2,4)
    imshow(r4,[cor_min cor_max]);
    title(strcat("1. Auditory seed pixel "," [",string(seed(4,1)),",",string(seed(4,2)),"]"));
    colormap jet
    hold on
    rectangle('position',[(seed(4,1)-0.5) (seed(4,2)-0.5) 1 1], 'FaceColor','w');
    c = colorbar
    c.Label.String = 'Correlaton coefficient'
    c.Ticks = [cor_min (cor_max/2) cor_max]
    axis off
    
    saveas(gca,['Seed Correlation/Binary_',name(1:end-4)]);
%%%%

    figure(1)
    clf
    imshow(r1,[0 1]);
    colormap jet
    
    fprintf('Make Auditory ROI\n');
        
    roi = drawfreehand(gca);
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
    ACmask = imdilate(roimask,strel('disk',3));
      
%%%%%%%%%%
    figure(1)
    clf
    imshow(r2,[0 1]);
    colormap jet

    fprintf('Make Frontal ROI\n');
       
    roi = drawfreehand(gca);
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
    FCmask = imdilate(roimask,strel('disk',3));
    
%%%%%%%%
    figure(1)
    clf
    imshow(r3,[0 1]);
    colormap jet
    
    fprintf('Make Somatosensory ROI\n');
    
    roi = drawfreehand(gca);
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
    SCmask = imdilate(roimask,strel('disk',3));
  
%%%%%%%%%%%%
    figure(1)
    clf
    imshow(r4,[0 1]);
    colormap jet
    
    fprintf('Make Retrosplenial ROI\n');
    
    roi = drawfreehand(gca);
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
    RCmask = imdilate(roimask,strel('disk',3));
  
%%%% Region of ROI using fluorescence 
   msk(:,:,1) = ACmask;
   msk(:,:,2) = FCmask;
   msk(:,:,3) = SCmask;
   msk(:,:,4) = RCmask;
   av_m = mean(msk,3);
   
   save(['Mask Region/Binary/',name(1:end-4)],'msk');
      
   k = imfuse(avAll, av_m, 'blend');
   
   figure(1);
   clf
   set(gcf,'color','w')
   imshow(k,[]);
   
   saveas(gcf,['Seed Correlation/',name(1:end-4),'_binary_regions']);
   
   
%%%%   
   imax = (max(avAll,[],'all'))+2;
   imin = (min(avAll,[],'all'))-1;  
   
   figure (1)
   set(gcf, 'color','w')
   imshow(avAll,[im_min im_max])
   hold on
   
   rectangle('position',[(seed(1,1)-0.5) (seed(1,2)-0.5) 1 1], 'FaceColor','w');
   a = seed(1,1);
   b = seed(1,2);
   c = ['1. [',num2str(a(1:end)),',',num2str(b(1:end)),']'];
   text((seed(1,1)-5),(seed(1,2)-5),sprintf([c]),'color','green','FontSize',15);
   
   rectangle('position',[(seed(2,1)-0.5) (seed(2,2)-0.5) 1 1], 'FaceColor','g');
   a = seed(2,1);
   b = seed(2,2);
   c = ['2. [',num2str(a(1:end)),',',num2str(b(1:end)),']'];
   text((seed(2,1)-5),(seed(2,2)-5),sprintf([c]),'color','green','FontSize',15);
   
   rectangle('position',[(seed(3,1)-0.5) (seed(3,2)-0.5) 1 1], 'FaceColor','y');
   a = seed(3,1);
   b = seed(3,2);
   c = ['3. [',num2str(a(1:end)),',',num2str(b(1:end)),']'];
   text((seed(3,1)-5),(seed(3,2)-5),sprintf([c]),'color','green','FontSize',15);
   
   rectangle('position',[(seed(4,1)-0.5) (seed(4,2)-0.5) 1 1], 'FaceColor','y');
   a = seed(4,1);
   b = seed(4,2);
   c = ['4. [',num2str(a(1:end)),',',num2str(b(1:end)),']'];
   text((seed(4,1)-5),(seed(4,2)-5),sprintf([c]),'color','green','FontSize',15);

      
   saveas(gcf,['Seed Correlation/',name(1:end-4),'_Seed location']);

   save(['Seed Correlation/',name(1:end-4)],'binarr','binary_seed','msk','r1','r2','r3','r4','rDF1','rDF2','rDF3','rDF4','scale2','seed','seedling','name','-v7.3');


end

   
   
%% To load a variable within a saved file   
%%%% load(['Seed Correlation/DV01_01.mat'],'r1'),
   
       
    
    
