
clear
close all
clc 

mkdir('Correlation Analysis');
mkdir(['Correlation Analysis/Trace']);
mkdir(['Correlation Analysis/Binary']);

DF_file = dir(['DFs/*.mat']);
DF_file = natsortfiles(DF_file);

msk_roi = dir(['Mask Region/Trace/*.mat']);
msk_roi = natsortfiles(msk_roi);

fps = 10;

AC_FC = [];
AC_SC = [];
AC_RC = [];
FC_SC = [];
FC_RC = [];
SC_RC = [];

%load('Tilt_number.mat');

for iFile = 1:size(DF_file,1);
    
    %   if tilt_number == 0;
    %       ;
    %   else tilt_number > 0;
    filename = DF_file(iFile).name;
    %     av_name = [filename(1:end-4),'_avAll.mat'];
    avfile = dir(['*',filename(1:end-4),'*_avAll.mat']);
    
    load(['DFs/',filename]);
    
    load(['Mask Region/Trace/',filename(1:end-4)]);
    
    load(avfile(1).name);
    
    
    msk = imresize(msk,[359 429]);
    
    stack = imresize(stack,[359 429]);
    
    avAll = imresize(avAll,[359 429]);
    %%%
    fprintf('Auditory Trace\n');
    
    ROIstack = NaN(size(stack));
    for xx = 1:size(stack,1);
        for yy = 1:size(stack,2);
            if msk(xx,yy,1)== 0;
                ;
            else msk(xx,yy,1) == 1;
            %    g_filt = imgaussfilt3(stack(xx,yy,:),2);
                g_filt = stack(xx,yy,:);
                ROIstack(xx,yy,:) = g_filt;
            end
        end
    end
    
    AC_trace = [];
    for ii = 1:size(ROIstack,3);
        AC_trace(ii,1) = mean(ROIstack(:,:,ii),'all','omitnan');
    end
    
    %%%
    fprintf('Frontal Trace\n');
    
    ROIstack = NaN(size(stack));
    for xx = 1:size(stack,1);
        for yy = 1:size(stack,2);
            if msk(xx,yy,2)== 0;
                ;
            else msk(xx,yy,2) == 1;
            %    g_filt = imgaussfilt3(stack(xx,yy,:),2);
                 g_filt = stack(xx,yy,:);
                ROIstack(xx,yy,:) = g_filt;
            end
        end
    end
    
    FC_trace = [];
    for ii = 1:size(ROIstack,3);
        FC_trace(ii,1) = mean(ROIstack(:,:,ii),'all','omitnan');
    end
    
    %%%
    fprintf('Somatosensory Trace\n');
    
    ROIstack = NaN(size(stack));
    for xx = 1:size(stack,1);
        for yy = 1:size(stack,2);
            if msk(xx,yy,3)== 0;
                ;
            else msk(xx,yy,3) == 1;
           %     g_filt = imgaussfilt3(stack(xx,yy,:),2);
              g_filt = stack(xx,yy,:);
                ROIstack(xx,yy,:) = g_filt;
            end
        end
    end
    
    SC_trace = [];
    for ii = 1:size(ROIstack,3);
        SC_trace(ii,1) = mean(ROIstack(:,:,ii),'all','omitnan');
    end
    
    %%%
    fprintf('Retrosplenial Trace\n');
    
    ROIstack = NaN(size(stack));
    for xx = 1:size(stack,1);
        for yy = 1:size(stack,2);
            if msk(xx,yy,4)== 0;
                ;
            else msk(xx,yy,4) == 1;
           %     g_filt = imgaussfilt3(stack(xx,yy,:),2);
              g_filt = stack(xx,yy,:);
                ROIstack(xx,yy,:) = g_filt;
            end
        end
    end
    
    RC_trace = [];
    for ii = 1:size(ROIstack,3);
        RC_trace(ii,1) = mean(ROIstack(:,:,ii),'all','omitnan');
    end
    
    %%%
    av_msk = mean(msk,3);
    
    k = imfuse(avAll, av_msk, 'blend');
    
    figure(1);
    clf
    set(gcf,'color','w')
    imshow(k,[]);
    
    saveas(gcf,['Correlation Analysis/',filename(1:end-4),'_regions']);
    
    %%
    All_trace(:,1) = AC_trace;
    All_trace(:,2) = FC_trace;
    All_trace(:,3) = SC_trace;
    All_trace(:,4) = RC_trace;
    
    save(['Correlation Analysis/Trace/',filename(1:end-4),'_region_trace'],'All_trace');
    
    R = corrcoef(All_trace);
    save(['Correlation Analysis/Trace/',filename(1:end-4),'_R_value'],'R');
    
    AC_FC = cat(2,AC_FC,R(1,2));
    AC_SC = cat(2,AC_SC,R(1,3));
    AC_RC = cat(2,AC_RC,R(1,4));
    FC_SC = cat(2,FC_SC,R(2,3));
    FC_RC = cat(2,FC_RC,R(2,4));
    SC_RC = cat(2,SC_RC,R(3,4));
    
    clearvars -except keepVariables DF_file fps iFile msk_roi AC_FC AC_SC AC_RC FC_SC FC_RC SC_RC
    %  end
end

save(['Correlation Analysis/Trace/All_AC_FC.mat'],'AC_FC');
save(['Correlation Analysis/Trace/All_AC_SC.mat'],'AC_SC');
save(['Correlation Analysis/Trace/All_AC_RC.mat'],'AC_RC');
save(['Correlation Analysis/Trace/All_FC_SC.mat'],'FC_SC');
save(['Correlation Analysis/Trace/All_FC_RC.mat'],'FC_RC');
save(['Correlation Analysis/Trace/All_SC_RC.mat'],'SC_RC');

%% Binary

clearvars -except keepVariables DF_file fps msk_roi
close all
clc

filess = dir(['Correlation Analysis/Trace/*_region_trace.mat']);
filess = natsortfiles(filess);

AC_FC = [];
AC_SC = [];
AC_RC = [];
FC_SC = [];
FC_RC = [];
SC_RC = [];

for iFile = 1:size(filess,1);
  %  if tilt_number == 0;
  %      ;
  %  else tilt_number > 0;
        filename = filess(iFile).name;
        
        load(['Correlation Analysis/Trace/',filename]);
        
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
        save(['Correlation Analysis/Binary/',filename(1:end-4),'_R_value'],'R');
        
        AC_FC = cat(2,AC_FC,R(1,2));
        AC_SC = cat(2,AC_SC,R(1,3));
        AC_RC = cat(2,AC_RC,R(1,4));
        FC_SC = cat(2,FC_SC,R(2,3));
        FC_RC = cat(2,FC_RC,R(2,4));
        SC_RC = cat(2,SC_RC,R(3,4));
        
        clearvars -except keepVariables DF_file fps iFile msk_roi filess AC_FC AC_SC AC_RC FC_SC FC_RC SC_RC
%    end
end

save(['Correlation Analysis/Binary/All_AC_FC.mat'],'AC_FC');
save(['Correlation Analysis/Binary/All_AC_SC.mat'],'AC_SC');
save(['Correlation Analysis/Binary/All_AC_RC.mat'],'AC_RC');
save(['Correlation Analysis/Binary/All_FC_SC.mat'],'FC_SC');
save(['Correlation Analysis/Binary/All_FC_RC.mat'],'FC_RC');
save(['Correlation Analysis/Binary/All_SC_RC.mat'],'SC_RC');

clear
clc
