% 1. find the magnitude

% Determining the direction of tonotopy
clearvars -except keepVariables avAll compete coordinates final tones colour

close all
clc

openfig(['Maps/_BF.fig']);
openfig(['Maps/_BF zoom.fig']);

X = zeros(size(final));
Y = zeros(size(final));
U = zeros(size(final));
V = zeros(size(final)); %use unit vectors


% Averaged BF vectors
X1 = [];
Y1 = [];
Uxx = [];
Vyy = [];

RaoTest = [];

avAng = [];
all_Ang = [];
all_Ang_tone = [];

figure(3)
set (gcf,'color','w');
tiledlayout(2,5,'TileSpacing','Compact')

figure(4)
set (gcf,'color','w');
tiledlayout(2,5,'TileSpacing','Compact')

for tt = 1:size(tones,2);
    
    X_each = zeros(size(final));
    Y_each = zeros(size(final));
    U_each = zeros(size(final));
    V_each = zeros(size(final)); %use unit vectors
    
    each_Ang = [];
    
    % Find all pixels associated to BF (tt)
    row1 = [];
    row1 = find(coordinates(:,3)==tt);
    
    if isempty(row1)==0;
        
        y_list=[];
        x_list=[];
        for gg = 1:size(row1,1);
            x_list(gg,1) = coordinates(row1(gg,1),1);
            y_list(gg,1) = coordinates(row1(gg,1),2);
        end
        
        % Find the average for the BF position
        x_BF = ((sum(x_list))/(size(x_list,1)));
        y_BF = ((sum(y_list))/(size(y_list,1)));
        
        a_av = [x_BF y_BF];
        
        % list of all the averaged location of each tone
        X1 = cat(1,X1,x_BF);
        Y1 = cat(1,Y1,y_BF);
        
        if tt == size(tones,2); % last tone have no next tone; no vector
            RaoTest = cat(1,RaoTest,NaN);
            
            Uxx = cat(1,Uxx,NaN);
            Vyy = cat(1,Vyy,NaN);
            
            figure(3)
            nexttile
            scatter(y_list,x_list,15,'filled','MarkerFaceColor',colour(tt,:)); % All BF identified
            hold on
            %    scatter(y_avVector,x_avVector,25,'*','m') % average next BF location
            %    quiver(Y_each,X_each,V_each,U_each,2,'w') % direction of each BF
            %    quiver(y_BF,x_BF,compy,compx,50,'r','LineWidth',2) % resultant direction
            set(gca,'color','k');
            set(gca,'Ydir','reverse')
            set(gca,'Ytick',[]);
            set(gca,'Xtick',[]);
            ylim([0 size(final,2)]);
            xlim([0 size(final,1)]);
            title ([num2str(tt*5), ' kHz'],'FontSize',24,'FontWeight','Bold');
            
            each_Ang = NaN;
            
            figure(4)
            nexttile
            circ_plot_direction(each_Ang,'pretty','bo',false,'linewidth',2,'color','r'),
            title ([num2str(tt*5), ' kHz'],'FontSize',24,'FontWeight','Bold');
            %      text(1.2, 0, 'Rostral'); text(-.05, 1.2, 'Ventral/Lateral');  text(-1.35, 0, 'Caudal');  text(-.075, -1.2, 'Dorsal/Lateral');
            axis off
            axis square;
            set(gca,'box','off')
            set(gca,'xtick',[])
            set(gca,'ytick',[])
            axis off
            
            
        else tt < size(tones,2);
            
            row2 = [];
            % Find all pixels associated to the next BF increment (tt+1)
            row2 = find(coordinates(:,3) == tt+1);
            
            if isempty(row2)==0; % There is BF of next tone
                
                % list of all next tone's BF location
                x2_list = [];
                y2_list = [];
                for gg2 = 1:size(row2,1);
                    x2_list(gg2,1) = coordinates(row2(gg2,1),1);
                    y2_list(gg2,1) = coordinates(row2(gg2,1),2);
                end
                
                % Find the average for the next tone position
                x_avVector = ((sum(x2_list))/(size(x2_list,1)));
                y_avVector = ((sum(y2_list))/(size(y2_list,1)));
                
                b = [x_avVector y_avVector];
                
                % the vector of each BF pixel to the averaged next BF location
                for rr = 1:size(row1,1);
                    x1 = x_list(rr,1);
                    y1 = y_list(rr,1);
                    X(x1,y1) = x1;
                    Y(x1,y1) = y1;
                    
                    X_each(x1,y1) = x1;
                    Y_each(x1,y1) = y1;
                    
                    a = [x1 y1];
                    
                    % find the magnitude and angles to horizontal
                    magnitude = norm(b-a);
                    ang = atan2((b(1,2)-a(1,2)),(b(1,1)-a(1,1))); %
                    %     ang = ang1+2*pi % find the co-terminal (all positive angles)
                    
                    all_Ang = cat(1,all_Ang,ang);
                    all_Ang_tone = cat(1,all_Ang_tone,tt);
                    each_Ang = cat(1,each_Ang,ang);
                    
                    Ux = (magnitude*cos(ang))/magnitude; % unit vector
                    Vy = (magnitude*sin(ang))/magnitude; % unit vector
                    
                    U(x1,y1) = Ux;
                    V(x1,y1) = Vy;
                    
                    U_each(x1,y1) = Ux;
                    V_each(x1,y1) = Vy;
                    
                end
                
                avBF_v = norm(b-a_av); % the magnitude of the averaged BF and next average BF
                %  avBF_ang1 = atan((b(1,2)-a_av(1,2))/(b(1,1)-a_av(1,1)));
                %  avBF_ang = avBF_ang1+2*pi; % Find the coterminal angle
                avBF_ang = atan2((b(1,2)-a_av(1,2)),(b(1,1)-a_av(1,1)));
                
                avAng = cat(1,avAng,avBF_ang);
                compx = (avBF_v*cos(avBF_ang))/avBF_v;
                compy = (avBF_v*sin(avBF_ang))/avBF_v;
                
                Uxx = cat(1,Uxx,compx);
                Vyy = cat(1,Vyy,compy);
                
                figure(3)
                nexttile
                scatter(y_list,x_list,25,'filled','MarkerFaceColor',colour(tt,:)); % All BF identified
                hold on
                scatter(y_avVector,x_avVector,25,'*','m') % average next BF location
                quiver(Y_each,X_each,V_each,U_each,5,'w','LineWidth',1,'MaxHeadSize',50) % direction of each BF
                quiver(y_BF,x_BF,compy,compx,50,'r','LineWidth',2,'MaxHeadSize',2) % resultant direction
                set(gca,'color','k');
              %  set(gca,'color','w')
                set(gca,'Ydir','reverse')
                set(gca,'Ytick',[]);
                set(gca,'Xtick',[]);
                ylim([0 size(final,2)]);
                xlim([0 size(final,1)]);
                title ([num2str(tt*5), ' kHz'],'FontSize',24,'FontWeight','Bold');
                
                %%%% Calculating the next direction
                alpha_bar = circ_mean(each_Ang);
                
                p_alpha = circ_raotest(each_Ang); % Rao's spacing test
                
                RaoTest = cat(1,RaoTest,p_alpha);
                
                figure(4)
                nexttile
                if p_alpha < 0.05 % no uniformity therefore directionality
                    circ_plot_direction(each_Ang,'pretty','bo',true,'linewidth',2,'color','#77AC30');
                    title ([num2str(tt*5), ' kHz'],'FontSize',24,'FontWeight','Bold');
                    
                    axis square;
                    set(gca,'box','off')
                    set(gca,'xtick',[])
                    set(gca,'ytick',[])
                    %   text(1.2, 0, 'Rostral'); text(-.05, 1.2, 'Ventral/Lateral');  text(-1.35, 0, 'Caudal');  text(-.075, -1.2, 'Dorsal/Lateral');
                    axis off
                    
                else p_alpha > 0.05 % uniformity therefore no directionality
                    circ_plot_direction(each_Ang,'pretty','bo',true,'linewidth',2,'color','r'),
                    title ([num2str(tt*5), ' kHz'],'FontSize',24,'FontWeight','Bold');
                    axis square;
                    set(gca,'box','off')
                    set(gca,'xtick',[])
                    set(gca,'ytick',[])
                    %  text(1.2, 0, 'Rostral'); text(-.05, 1.2, 'Ventral/Lateral');  text(-1.35, 0, 'Caudal');  text(-.075, -1.2, 'Dorsal/Lateral');
                    axis off
                end
                
            else isempty(row2) == 1; % no next BF labled
                RaoTest = cat(1,RaoTest,NaN);
                
                Uxx = cat(1,Uxx,NaN);
                Vyy = cat(1,Vyy,NaN);
                
                each_Ang = NaN;
                
                figure(3)
                nexttile
                scatter(y_list,x_list,15,'filled','MarkerFaceColor',colour(tt,:)); % All BF identified
                hold on
                %    quiver(Y_each,X_each,V_each,U_each,2,'w') % direction of each BF
                set(gca,'color','k');
                set(gca,'Ydir','reverse')
                set(gca,'Ytick',[]);
                set(gca,'Xtick',[]);
                ylim([0 size(final,2)]);
                xlim([0 size(final,1)]);
                title ([num2str(tt*5), ' kHz'],'FontSize',24,'FontWeight','Bold');
                
                figure(4)
                nexttile
                circ_plot_direction(each_Ang,'pretty','bo',false,'linewidth',2,'color','r'),
                title ([num2str(tt*5), ' kHz'],'FontSize',24,'FontWeight','Bold');
                axis square;
                set(gca,'box','off')
                set(gca,'xtick',[])
                set(gca,'ytick',[])
                %           text(1.2, 0, 'Rostral'); text(-.05, 1.2, 'Ventral/Lateral');  text(-1.35, 0, 'Caudal');  text(-.075, -1.2, 'Dorsal/Lateral');
                axis off
            end
        end
        
    else isempty(row1)== 1;
        % Find all pixels associated to the next BF increment (tt+1)
        each_Ang = NaN;
        
        RaoTest = cat(1,RaoTest,NaN);
        
        figure(3)
        nexttile
        hold on
        scatter(1,1,'k');
        set(gca,'color','k');
        set(gca,'Ydir','reverse')
        set(gca,'Ytick',[]);
        set(gca,'Xtick',[]);
        ylim([0 size(final,2)]);
        xlim([0 size(final,1)]);
        title ([num2str(tt*5), ' kHz'],'FontSize',24,'FontWeight','Bold');
        
        figure(4)
        nexttile
        circ_plot_direction(each_Ang,'pretty','bo',false,'linewidth',2,'color','r'),
        title ([num2str(tt*5), ' kHz'],'FontSize',24,'FontWeight','Bold');
        if tt == (size(tones,2)-1)
            axis square;
            set(gca,'box','off')
            set(gca,'xtick',[])
            set(gca,'ytick',[])
            text(1.2, 0, 'Rostral'); text(-.05, 1.2, 'Ventral/Lateral');  text(-1.35, 0, 'Caudal');  text(-.075, -1.2, 'Dorsal/Lateral');
            axis off
        else tt < (size(tones,2)-1)
            axis square;
            set(gca,'box','off')
            set(gca,'xtick',[])
            set(gca,'ytick',[])
            axis off
        end
    end
end

figure  (1)
% quiver (Y,X,V,U,2,'color','#C7C6C1','LineWidth',1); % Hexadecimal Color Code
 quiver (Y,X,V,U,5,'color','k','LineWidth',1,'MaxHeadSize',100); % Hexadecimal Color Code
set(gca,'Ydir','reverse');
set(gca,'color','k');

figure(2)
quiver (Y,X,V,U,2,'color','#C7C6C1','LineWidth',1); % Hexadecimal Color Code
set(gca,'Ydir','reverse');
set(gca,'color','k');

saveas(figure(1),['Maps/BF quiver.fig']);
saveas(figure(2),['Maps/BF_zoomquiver.fig']);
saveas(figure(3),['Maps/Each BF quiver.fig']);
saveas(figure(4),['Maps/Each BF circ stat.fig']);

%% Find all significant averaged BF direction gives a significan overall direction    
% Rayleigh'z test but this test has 2 assumptions:
% 1. Data is normal
% 2. Vectors are NOT bidirectionmal
% Therefore this script uses Rao's Test
% Berens (2009) CircStat: A MATLAB toolbox for circular statistics


% Use all angles detected
final_ang = [];
for ii = 1:size(RaoTest,1);
    if isnan(RaoTest(ii,1))==0;
        %if RaoTest(ii,1) < 0.05; % no unifromity detected;
            riolu = find(all_Ang_tone==ii);
            revali = all_Ang(riolu,1);
            final_ang = cat(1,final_ang,revali);
        %else RaoTest(ii,1)> 0.05;
        %    ;
        %end
    else isnan(RaoTest(ii,1))==0;
        ;       
    end
end

%%%% descriptive stats 
alpha_bar = circ_mean(final_ang) % mean angle

% alpha_hat = circ_median(final_Ang); 
% R_alpha = circ_r(final_Ang); % The length
% S_alpha = circ_var(final_Ang); % variance
% [s_alpha s0_alpha] = circ_std(final_Ang); % Standard deviation
% b_alpha = circ_skewness(final_Ang); % Skewness
% k_alpha = circ_kurtosis(final_Ang); % Kurtosis

p_alpha_final = circ_raotest(final_ang) % Rao's spacing test

figure (5)
clf
if p_alpha_final <0.05;
    circ_plot_direction(all_Ang,'pretty','bo',true,'linewidth',2,'color','#77AC30');
    n = ['p = ', num2str(p_alpha_final(1:end)),' - Directionality detected']
    text(-.05, 1.2, n);
    axis square;
    set(gcf,'color','w')
    set(gca,'box','off')
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    axis off
else p_alpha_final > 0.05;
    circ_plot_direction(all_Ang,'pretty','bo',true,'linewidth',2,'color','r');
    n = ['p = ', num2str(p_alpha_final(1:end)),' - No Directionality detected']
    text(-.05, 1.2, n);
    axis square;
    set(gcf,'color','w')
    set(gca,'box','off')
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    axis off
end

saveas(gcf,['Maps/Resultant Direction'])
save('Overall direction.mat','alpha_bar');
save('All_BF_Angle.mat','final_ang');


