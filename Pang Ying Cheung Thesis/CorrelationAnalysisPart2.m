
WT_corr = [];
KO_corr = [];
HET_corr = [];

WT_corr2 = [];
KO_corr2 = [];
HET_corr2 = [];

% WT_corr = cat(3,WT_corr,R);
% clearvars R
% WT_corr2 = cat(3,WT_corr2,R);
% clearvars R

% KO_corr = cat(3,KO_corr,R);
% clearvars R
% KO_corr2 = cat(3,KO_corr2,R);
% clearvars R

% HET_corr = cat(3,HET_corr,R);
% clearvars R
% HET_corr2 = cat(3,HET_corr2,R);
% clearvars R

clearvars -except keepVariables WT_corr WT_corr2 HET_corr HET_corr2 KO_corr KO_corr2 WT_trace WT_binary HET_trace HET_binary KO_trace KO_binary

num = dir(['Correlation Analysis/Trace/*_R_value.mat']);
num = natsortfiles(num);

for ii = 1:size(num,1);
    filename = num(ii).name;
    
    load(['Correlation Analysis/Trace/',filename]);
    
    % WT_corr = cat(3,WT_corr,R);
    % clearvars R
    
    % HET_corr = cat(3,HET_corr,R);
    % clearvars R
    
     KO_corr = cat(3,KO_corr,R);
     clearvars R
end

clearvars -except keepVariables WT_corr WT_corr2 HET_corr HET_corr2 KO_corr KO_corr2 WT_trace WT_binary HET_trace HET_binary KO_trace KO_binary

num = dir(['Correlation Analysis/Binary/*_R_value.mat']);
num = natsortfiles(num);

for ii = 1:size(num,1);
    filename = num(ii).name;
    
    load(['Correlation Analysis/Binary/',filename]);
    
    % WT_corr2 = cat(3,WT_corr2,R);
    % clearvars R
    
    % HET_corr2 = cat(3,HET_corr2,R);
    % clearvars R
    
     KO_corr2 = cat(3,KO_corr2,R);
     clearvars R
end

%%


% c=uisetcolor;

colour(1,:) = [0,0.45,0.74];
colour(2,:) = [0.63,0.078,0.18];
colour(3,:) = [0.93,0.69,0.12];
colour(4,:) = [0.49,0.18,0.56];



scale2 = [(1/600):(1/600):5];

maxlim = round(max(max(All_trace)),0)+2;
minlim = round(min(min(All_trace)),0)-2;


figure (1)
set(gcf, 'color','w')

for pp = 1:size(All_trace,2)
    if pp < size(All_trace,2);
        subplot(4,1,pp);
        plot(scale2, All_trace(1:end,pp),'Color',colour(pp,:));
        ylim([minlim maxlim])
        ax = gca;
        ax.TitleHorizontalAlignment = 'left';
        axis off
          set(gca,'xtick',[])
          box off
        
        if pp == 1;
            title('1. Auditory region','FontSize',15);
        elseif pp == 2;
            title('2. Frontal region','FontSize',15);
        else pp == 3;
            title('3. Somatosensory region','FontSize',15);      
        end
    else pp == size(All_trace,2);
        subplot(4,1,pp);
        plot(scale2, All_trace(1:end,pp),'Color',colour(pp,:));
        ylim([minlim maxlim])
        ax = gca;
        ax.TitleHorizontalAlignment = 'left';
        title('4. Retrosplenial region','FontSize',15);           
        ylabel ("ΔF/F")
        xlabel ("Time (min)")
        box off
    end
end

 export_fig WT_bin_in
    %%
    
   figure
   set(gcf, 'color','w')
   
   imshow(WT_binary, [0 1],'InitialMagnification','fit');
   colormap turbo 
   
 %  c = colorbar('eastoutside')
 %   c.Label.String = 'Correlation coefficient'
   
   
   axis on
   box off
   xticks([1 2 3 4])
    xticklabels({'A','F','S','R'})
%   xticklabels({'Auditory','Frontal','Somato-motor','Retrosplenial'})
   set(gca, 'XAxisLocation', 'top')
    yticks([1 2 3 4])
    yticklabels({'A','F','S','R'})
%   yticklabels({'Auditory','Frontal','Somato-motor','Retrosplenial'})
   
    

AC = [];
FC = [];
SC = [];
RC = [];

AC2 = [];
FC2 = [];
SC2 = [];
RC2 = [];


for ii = 1:4;
    if ii == 1;
        AC = cat(2,AC,All_trace(:,ii));
    elseif ii == 2;
        FC = cat(2,FC,All_trace(:,ii));
    elseif ii == 3; 
        SC = cat(2,SC,All_trace(:,ii));
    else ii == 4;
        RC = cat(2,RC,All_trace(:,ii));
    end
end

clearvars All_trace

save(['Correlation/AC.mat'],'AC');
save(['Correlation/FC.mat'],'FC');
save(['Correlation/SC.mat'],'SC');
save(['Correlation/RC.mat'],'RC');



for ii = 1:4;
    if ii == 1;
        AC2 = cat(2,AC2,All_trace(:,ii));
    elseif ii == 2;
        FC2 = cat(2,FC2,All_trace(:,ii));
    elseif ii == 3; 
        SC2 = cat(2,SC2,All_trace(:,ii));
    else ii == 4;
        RC2 = cat(2,RC2,All_trace(:,ii));
    end
end

clearvars All_trace

save(['Correlation/AC2.mat'],'AC2');
save(['Correlation/FC2.mat'],'FC2');
save(['Correlation/SC2.mat'],'SC2');
save(['Correlation/RC2.mat'],'RC2');

%%

WT_AC_in = [];
WT_AC_ex = [];
KO_AC_in = [];
KO_AC_ex = [];
HET_AC_in = [];
HET_AC_ex = [];

WT_FC_in = [];
WT_FC_ex = [];
KO_FC_in = [];
KO_FC_ex = [];
HET_FC_in = [];
HET_FC_ex = [];

WT_SC_in = [];
WT_SC_ex = [];
KO_SC_in = [];
KO_SC_ex = [];
HET_SC_in = [];
HET_SC_ex = [];

WT_RC_in = [];
WT_RC_ex = [];
KO_RC_in = [];
KO_RC_ex = [];
HET_RC_in = [];
HET_RC_ex = [];



WT_AC_in = cat(2,WT_AC_in,AC);

WT_FC_in = cat(2,WT_FC_in,FC);

WT_SC_in = cat(2,WT_SC_in,AC);

WT_RC_in = cat(2,WT_RC_in,RC);

%%%%%
WT_AC_ex = cat(2,WT_AC_ex,AC2);

WT_FC_ex = cat(2,WT_FC_ex,FC2);

WT_SC_ex = cat(2,WT_SC_ex,AC2);

WT_RC_ex = cat(2,WT_RC_ex,RC2);


clearvars AC FC SC RC AC2 FC2 SC2 RC2

save(['Correlation/WT_AC_in.mat'],'WT_AC_in');
save(['Correlation/WT_FC_in.mat'],'WT_FC_in');
save(['Correlation/WT_SC_in.mat'],'WT_SC_in');
save(['Correlation/WT_RC_in.mat'],'WT_RC_in');

save(['Correlation/WT_AC_ex.mat'],'WT_AC_ex');
save(['Correlation/WT_FC_ex.mat'],'WT_FC_ex');
save(['Correlation/WT_SC_ex.mat'],'WT_SC_ex');
save(['Correlation/WT_RC_ex.mat'],'WT_RC_ex');

%%%%

KO_AC_in = cat(2,KO_AC_in,AC);

KO_FC_in = cat(2,KO_FC_in,FC);

KO_SC_in = cat(2,KO_SC_in,AC);

KO_RC_in = cat(2,KO_RC_in,RC);

%%%%%
KO_AC_ex = cat(2,KO_AC_ex,AC2);

KO_FC_ex = cat(2,KO_FC_ex,FC2);

KO_SC_ex = cat(2,KO_SC_ex,AC2);

KO_RC_ex = cat(2,KO_RC_ex,RC2);


clearvars AC FC SC RC AC2 FC2 SC2 RC2


save(['Correlation/KO_AC_in.mat'],'KO_AC_in');
save(['Correlation/KO_FC_in.mat'],'KO_FC_in');
save(['Correlation/KO_SC_in.mat'],'KO_SC_in');
save(['Correlation/KO_RC_in.mat'],'KO_RC_in');

save(['Correlation/KO_AC_ex.mat'],'KO_AC_ex');
save(['Correlation/KO_FC_ex.mat'],'KO_FC_ex');
save(['Correlation/KO_SC_ex.mat'],'KO_SC_ex');
save(['Correlation/KO_RC_ex.mat'],'KO_RC_ex');

%%%%

HET_AC_in = cat(2,HET_AC_in,AC);

HET_FC_in = cat(2,HET_FC_in,FC);

HET_SC_in = cat(2,HET_SC_in,AC);

HET_RC_in = cat(2,HET_RC_in,RC);

%%%%%
HET_AC_ex = cat(2,HET_AC_ex,AC2);

HET_FC_ex = cat(2,HET_FC_ex,FC2);

HET_SC_ex = cat(2,HET_SC_ex,AC2);

HET_RC_ex = cat(2,HET_RC_ex,RC2);


clearvars AC FC SC RC AC2 FC2 SC2 RC2

save(['Correlation/HET_AC_in.mat'],'HET_AC_in');
save(['Correlation/HET_FC_in.mat'],'HET_FC_in');
save(['Correlation/HET_SC_in.mat'],'HET_SC_in');
save(['Correlation/HET_RC_in.mat'],'HET_RC_in');

save(['Correlation/HET_AC_ex.mat'],'HET_AC_ex');
save(['Correlation/HET_FC_ex.mat'],'HET_FC_ex');
save(['Correlation/HET_SC_ex.mat'],'HET_SC_ex');
save(['Correlation/HET_RC_ex.mat'],'HET_RC_ex');

%%%%

a2 = mean(HET_AC_ex,2);
a = mean(HET_AC_in,2);

b = mean(HET_FC_in,2);
b2 = mean(HET_FC_ex,2);

c = mean(HET_SC_in,2);
c2 = mean(HET_SC_ex,2);

d = mean(HET_RC_in,2);
d2 = mean(HET_RC_ex,2);

HET_in_trace(1,:) = a; %AC
HET_in_trace(2,:) = b; %FC
HET_in_trace(3,:) = c; %SC
HET_in_trace(4,:) = d; %RC

HET_ex_trace(1,:) = a2;
HET_ex_trace(2,:) = b2;
HET_ex_trace(3,:) = c2;
HET_ex_trace(4,:) = d2;

save('HET_ex_trace.mat','HET_ex_trace');
save('HET_in_trace.mat','HET_in_trace');


[R_WT_in PV_WT_in]= corrcoef(transpose(WT_in_trace)); % R value and p value
[R_WT_ex PV_WT_ex]= corrcoef(transpose(WT_ex_trace));
   
[R_KO_in PV_KO_in]= corrcoef(transpose(KO_in_trace));  
[R_KO_ex PV_KO_ex]= corrcoef(transpose(KO_ex_trace));
    
[R_HET_in PV_HET_in]= corrcoef(transpose(HET_in_trace));
[R_HET_ex PV_HET_ex]= corrcoef(transpose(HET_ex_trace));
    
    
%%%


scale = [1/600:1/600:5];



threshold = std(p)/2;

[pk loc] = findpeaks(p,'MinPeakHeight',threshold);

xloc = loc/600; % 10 fps * 60 s

binn = [];
for jj = 1:size(p,1);
    if p(jj,:) < threshold;
        binn(jj,1) = 0;
    else p(jj,1) > threshold;
        binn(jj,1) = 1;
    end
end

g(:,1) = binn;
g(:,2) = scale;

avAC = p;

figure
set(gcf, 'color','w');
subplot(2,1,1);
plot(scale, avAC,'LineWidth',1.5);
hold on
% scatter(xloc, pk)
yline(threshold,'--','LineWidth',1.5);
ylabel('ΔF/F0')
set(gca,'xtick',[])
box off
h = gca; 
h.XAxis.Visible = 'off';

subplot(2,1,2);
for hh = 1:size(g,1);
    if g(hh,1) == 1;
        xline(g(hh,2));
    end
end
box off
ylim([0 1]);
set(gca,'YTick',[0 1]);
xlabel('Time (min)')
h2 = gca; 
h2.YAxis.Visible = 'off';


plot(scale, binn(1:1800),'LineWidth',1.5);
    
    
    
    
    
    
    
    
    

