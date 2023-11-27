%% Correlation analysis

clear 
close all
clc

mkdir('Correlation')

imfile = dir(['DFs/*.mat']);
imfile = natsortfiles(imfile);

ACmask = dir(['ACmask/*.mat']);
ACmask = natsortfiles(ACmask);

AC_roi = dir(['AC ROI DF/*.mat']);
AC_roi = natsortfiles(AC_roi);

av_im = dir('*_avAll.mat');
av_im = natsortfiles(av_im);

stim_file = dir('* stimuli.mat');
stim_file = natsortfiles(stim_file);

fps = 10;
baseline = 3;
response = 4;

load(['Traces/peakoffset.mat']);

figure(1);


for iFile = 1:size(imfile,1);
    
    a = sprintf(num2str(iFile(1:end)));
    fprintf(['File number: ',a,'\n'])
    
   % Load AC roi DF
   load(['ACmask/',ACmask(iFile).name]);
   load(['AC ROI DF/',AC_roi(iFile).name]);
   
   ROIstack(:,:,12001:end) = [];
   
   AC_trace = [];
   for ii = 1:size(ROIstack,3);
       AC_trace = cat(1, AC_trace,(mean(ROIstack(:,:,ii),'all','omitnan')));
   end
   
   filename = imfile(iFile).name;
   load(['DFs/',filename]);
   stack(:,:,12001:end) = [];
   
   load(av_im(iFile).name);
   avAll = imresize(avAll,0.5);
   
   figure(1)
   clf
   imshow(avAll,[]);

   %   
   fprintf('Make Pre-frontal ROI\n');
  
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
   PFmask = imdilate(roimask,strel('disk',3));
  
  % save(['Correlation/',filename(1:end-4),'_PF'],'PFmask');
   
   ROIstack = NaN(size(stack));
   for xx = 1:size(stack,1);
       for yy = 1:size(stack,2);
           if PFmask(xx,yy) == 0;
               ;
           else PFmask(xx,yy) == 1;
               g_filt = imgaussfilt3(stack(xx,yy,:),2);
               ROIstack(xx,yy,:) = g_filt;
           end
       end
   end
   
   PF_trace = [];
   for ii = 1:size(ROIstack,3);
       PF_trace = cat(1, PF_trace,(mean(ROIstack(:,:,ii),'all','omitnan')));
   end
   
% 
   fprintf('Make Somato-motor ROI\n');
   
   delete(roi);
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
   SMmask = imdilate(roimask,strel('disk',3));
   
%   save(['Correlation/',filename(1:end-4),'_SM'],'SMmask');

   ROIstack = NaN(size(stack));
   for xx = 1:size(stack,1);
       for yy = 1:size(stack,2);
           if SMmask(xx,yy) == 0;
               ;
           else SMmask(xx,yy) == 1;
               g_filt = imgaussfilt3(stack(xx,yy,:),2);
               ROIstack(xx,yy,:) = g_filt;
           end
       end
   end
      
   SM_trace = [];
   for ii = 1:size(ROIstack,3);
       SM_trace = cat(1, SM_trace,(mean(ROIstack(:,:,ii),'all','omitnan')));
   end

   % 
   fprintf('Make Retrosplenial-Visual ROI\n');
   % Retrosplenial cortex
  
   delete(roi);
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
   RVmask = imdilate(roimask,strel('disk',3));
      
   ROIstack = NaN(size(stack));
   for xx = 1:size(stack,1);
       for yy = 1:size(stack,2);
           if RVmask(xx,yy) == 0;
               ;
           else RVmask(xx,yy) == 1;
               g_filt = imgaussfilt3(stack(xx,yy,:),2);
               ROIstack(xx,yy,:) = g_filt;
           end
       end
   end
      
   RV_trace = [];
   for ii = 1:size(ROIstack,3);
       RV_trace = cat(1, RV_trace,(mean(ROIstack(:,:,ii),'all','omitnan')));
   end
   
   msk(:,:,1) = maskroi;
   msk(:,:,2) = PFmask;
   msk(:,:,3) = SMmask;
   msk(:,:,4) = RVmask;
   av_m = mean(msk,3);
   
   k = imfuse(avAll, av_m, 'blend');
   
   figure(1);
   clf
   set(gcf,'color','w')
   imshow(k,[]);
   
   saveas(gcf,['Correlation/',filename(1:end-4),'_regions']);
   
   %
   All_trace(:,1) = AC_trace;
   All_trace(:,2) = PF_trace;
   All_trace(:,3) = SM_trace;
   All_trace(:,4) = RV_trace;
   
   save(['Correlation/',filename(1:end-4),'_region_trace'],'All_trace');
   
   [R p]= corrcoef(All_trace);
   save(['Correlation/',filename(1:end-4),'_R_value'],'R');
   
   
   figure(1)
   clf
   set(gcf,'color','w')
   imshow(R,[0 1], 'InitialMagnification','fit')
   colormap turbo
   c = colorbar('eastoutside')
   c.Label.String = 'Correlation coefficient'
   axis on
   box off
   xticks([1 2 3 4])
   xticklabels({'Auditory','Frontal','Somato-motor','Retrosplenial'})
   set(gca, 'XAxisLocation', 'top')
   yticks([1 2 3 4])
   yticklabels({'Auditory','Frontal','Somato-motor','Retrosplenial'})
   
   saveas(gcf,['Correlation/',filename(1:end-4),'_R']);
   
   %
   clearvars -except keepVariables AC_roi All_trace av_im filename iFile imfile peakoffset R stack stim_file fps baseline response ACmask
   
   load(stim_file(iFile).name);
   stimuli(:,1:2) = stimuli(:,1:2)- peakoffset(iFile,:);
   stimuli = round(stimuli);
   
   AC_traces = [];
   PF_traces = [];
   SM_traces = [];
   RV_traces = [];
   
   for ii = 1:size(stimuli,1);
       startframe = stimuli(ii,1)-((baseline*fps)-1);
       endframe = stimuli(ii,1)+((response*fps));
       
       AC_traces(:,ii) = All_trace(startframe:endframe,1);
       PF_traces(:,ii) = All_trace(startframe:endframe,2);
       SM_traces(:,ii) = All_trace(startframe:endframe,3);
       RV_traces(:,ii) = All_trace(startframe:endframe,4);
   end
   
   AC = mean(AC_traces,2);
   PF = mean(PF_traces,2);
   SM = mean(SM_traces,2);
   RV = mean(RV_traces,2);
   
   figure(1)
   clf
   set(gcf,'color','w');
   hold on
   p1 = plot(AC);
   p2 = plot(PF);
   p3 = plot(SM);
   p4 = plot(RV);
   xticks([0 10 20 30 40 50 60 70]);
   xticklabels({'-3','-2','-1','0','1','2','3'})
   xlabel('Time (s)')
   ylabel('ΔF/F')
   xline(30)
   xline(45)
   legend([p1 p2 p3 p4],'Auditory','Frontal','Somato-motor','Retrosplenial');
   legend box off
   
   saveas(gcf,['Correlation/',filename(1:end-4),'_trace']);
   
   clearvars -except keepVariables AC_roi av_im iFile imfile peakoffset stim_file fps baseline response ACmask
   
end

clear
close all
clc

mkdir('Binarised Correlation');
filess = dir(['Correlation/*_region_trace.mat']);
filess = natsortfiles(filess);

for iFile = 1:size(filess,1);
    filename = filess(iFile).name;
    
    load(['Correlation/',filename]);
    
    
    binarr = [];
    for pp = 1:size(All_trace,2);
        p = All_trace(:,pp);
        
        threshold = std(p)/2;
        
        binn = [];
        for jj = 1:size(p,1);
            if p(jj,:) < threshold;
                binn(jj,1) = 0;
            else p(jj,1) > threshold;
                binn(jj,1) = 1;
            end
        end
        binarr = cat(2,binarr,binn);
    end
    
    R = corrcoef(binarr);
    save(['Binarised Correlation/',filename(1:end-4),'_R_value'],'R');
    
    figure(1)
    clf
    set(gcf,'color','w')
    imshow(R,[0 1], 'InitialMagnification','fit')
    colormap turbo
    c = colorbar('eastoutside')
    c.Label.String = 'Correlation coefficient'
    axis on
    box off
    xticks([1 2 3 4])
    xticklabels({'Auditory','Frontal','Somato-motor','Retrosplenial'})
    set(gca, 'XAxisLocation', 'top')
    yticks([1 2 3 4])
    yticklabels({'Auditory','Frontal','Somato-motor','Retrosplenial'})
    
    saveas(gcf,['Binarised Correlation/',filename(1:end-4),'_R']);
    
end

    
    
    
    
    
    
    
