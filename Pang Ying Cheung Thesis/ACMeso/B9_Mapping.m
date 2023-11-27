

clear
close all
clc

mkdir('Maps/');

rec_file = dir(['Normalised Output/*.mat']);
rec_file = natsortfiles(rec_file);

avIm = dir(['*avAll.mat']);
avIm = natsortfiles(avIm);

%% crop image

clearvars colour
colour(1,:) = [0.0941176470588235,0.0941176470588235,0.439215686274510]; % dark blue - 4 kHz
colour(2,:) = [0, 0.3, 1];
colour(3,:) = [0, 0.7, 1.0000];
colour(4,:) = [0.0549, 0.9020, 0.3922];
colour(5,:) = [0.7, 1, 0.3];
colour(6,:) = [1, 1, 0];
colour(7,:) = [1.0000, 0.7, 0];
colour(8,:) = [1, 0, 0]; % red - 32 kHz

load((avIm(1).name));
avAll = imresize(avAll,0.5);

tonestack = [];
for iFile = 1:size(rec_file,1);
    filename = rec_file(iFile).name;
    load(['Normalised Output/',filename]);
    
    tonestack = cat(3, tonestack,norm_avRes);
end

tones = [1:size(tonestack,3)];

figure(1)
clf
set(figure(1),'color','w')
imshow(avAll,[]);
hold on

figure(2)
clf
set(figure(2),'color','w')
hold on

compete = [];
v = 75;

for tt = 1:size(tonestack,3);
    t = tonestack(:,:,tt);
    tone = tones(1,tt);
    
    o = [];
    if tt == 1;
   %    criteria = (mean(t,'all','omitnan')+((mean(t,'all','omitnan')*0.250)));
   %    thresholt = t >= criteria == 1;
        
        criteria = prctile(t,v,'all');
        thresholt = t >= criteria == 1;
        
        [find_x, find_y] = find(thresholt==1);
        B = NaN(size(thresholt,1,2));
        
        B(thresholt) = t(thresholt);
        compete(:,:,tt) = B;
        
        o = repmat (tt,size(find_y,1),1);
        
        n = [num2str((tone(1:end)*4)),' kHz'];
        
        figure(1)
        scatter(find_y,find_x,[],'filled', 'MarkerFaceColor',colour(tt,:),'DisplayName',n);
        
        figure(2)
        scatter(find_y,o,[],'filled', 'MarkerFaceColor',colour(tt,:),'DisplayName',n);
        
    elseif tt == 2;
     %   criteria = (mean(t,'all','omitnan')+((mean(t,'all','omitnan')*0.250)));
     %   thresholt = t >= criteria == 1;
        
         criteria = prctile(t,v,'all');
         thresholt = t >= criteria == 1;
        
        [find_x, find_y] = find(thresholt==1);
        B = NaN(size(thresholt,1,2));
        
        B(thresholt) = t(thresholt);
        compete(:,:,tt) = B;
        
        o = repmat (tt,size(find_y,1),1);
        
        n = [num2str((tone(1:end)*4)),' kHz'];
        
        figure(1)
        scatter(find_y,find_x,[],'filled', 'MarkerFaceColor',colour(tt,:),...
            'MarkerFaceAlpha',.8,'MarkerEdgeAlpha',.8, 'DisplayName',n);
        
        figure(2)
        scatter(find_y,o,[],'filled', 'MarkerFaceColor',colour(tt,:),'DisplayName',n);
        
    elseif tt == 3;
       %  criteria = (mean(t,'all','omitnan')+((mean(t,'all','omitnan')*0.250)));
       %  thresholt = t >= criteria == 1;
        
         criteria = prctile(t,v,'all');
         thresholt = t >= criteria == 1;
        
        [find_x, find_y] = find(thresholt==1);
        B = NaN(size(thresholt,1,2));
        
        B(thresholt) = t(thresholt);
        compete(:,:,tt) = B;
        
        o = repmat (tt,size(find_y,1),1);
        
        n = [num2str((tone(1:end)*4)),' kHz'];
        
        figure(1)
        scatter(find_y,find_x,[],'filled', 'MarkerFaceColor',colour(tt,:),...
            'MarkerFaceAlpha',.6,'MarkerEdgeAlpha',.6, 'DisplayName',n);
        
        figure(2)
        scatter(find_y,o,[],'filled', 'MarkerFaceColor',colour(tt,:),'DisplayName',n);
        
    elseif tt == 4;
     %   criteria = (mean(t,'all','omitnan')+((mean(t,'all','omitnan')*0.250)));
     %   thresholt = t >= criteria == 1;
        
         criteria = prctile(t,v,'all');
         thresholt = t >= criteria == 1;
        
        [find_x, find_y] = find(thresholt==1);
        B = NaN(size(thresholt,1,2));
        
        B(thresholt) = t(thresholt);
        compete(:,:,tt) = B;
        
        o = repmat (tt,size(find_y,1),1);
        
        n = [num2str((tone(1:end)*4)),' kHz'];
        
        figure(1)
        scatter(find_y,find_x,[],'filled', 'MarkerFaceColor',colour(tt,:),...
            'MarkerFaceAlpha',.4,'MarkerEdgeAlpha',.4, 'DisplayName',n);
        
        figure(2)
        scatter(find_y,o,[],'filled', 'MarkerFaceColor',colour(tt,:),'DisplayName',n);
        
    elseif tt == 5;
     %    criteria = (mean(t,'all','omitnan')+((mean(t,'all','omitnan')*0.250)));
     %   thresholt = t >= criteria == 1;
        
         criteria = prctile(t,v,'all');
         thresholt = t >= criteria == 1;
        
        [find_x, find_y] = find(thresholt==1);
        B = NaN(size(thresholt,1,2));
        
        B(thresholt) = t(thresholt);
        compete(:,:,tt) = B;
        
        o = repmat (tt,size(find_y,1),1);
        
        n = [num2str((tone(1:end)*4)),' kHz'];
        
        figure(1)
        scatter(find_y,find_x,[],'filled', 'MarkerFaceColor',colour(tt,:),...
            'MarkerFaceAlpha',.4,'MarkerEdgeAlpha',.4, 'DisplayName',n);
        
        figure(2)
        scatter(find_y,o,[],'filled', 'MarkerFaceColor',colour(tt,:),'DisplayName',n);
        
    elseif tt == 6;
     %    criteria = (mean(t,'all','omitnan')+((mean(t,'all','omitnan')*0.250)));
     %   thresholt = t >= criteria == 1;
        
         criteria = prctile(t,v,'all');
         thresholt = t >= criteria == 1;
        
        [find_x, find_y] = find(thresholt==1);
        B = NaN(size(thresholt,1,2));
        
        B(thresholt) = t(thresholt);
        compete(:,:,tt) = B;
        
        o = repmat (tt,size(find_y,1),1);
        
        n = [num2str((tone(1:end)*4)),' kHz'];
        
        figure(1)
        scatter(find_y,find_x,[],'filled', 'MarkerFaceColor',colour(tt,:),...
            'MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2, 'DisplayName',n);
        
        figure(2)
        scatter(find_y,o,[],'filled', 'MarkerFaceColor',colour(tt,:),'DisplayName',n);
        
    elseif tt == 7;
     %   criteria = (mean(t,'all','omitnan')+((mean(t,'all','omitnan')*0.250)));
     %   thresholt = t >= criteria == 1;
        
        criteria = prctile(t,v,'all');
        thresholt = t >= criteria == 1;
        
        [find_x, find_y] = find(thresholt==1);
        B = NaN(size(thresholt,1,2));
        
        B(thresholt) = t(thresholt);
        compete(:,:,tt) = B;
        
        o = repmat (tt,size(find_y,1),1);
        
        n = [num2str((tone(1:end)*4)),' kHz'];
        figure(1)
        scatter(find_y,find_x,[],'filled', 'MarkerFaceColor',colour(tt,:),...
            'MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2, 'DisplayName',n);
        
        figure(2)
        scatter(find_y,o,[],'filled', 'MarkerFaceColor',colour(tt,:),'DisplayName',n);
        
    else tt == 8;
      %  criteria = (mean(t,'all','omitnan')+((mean(t,'all','omitnan')*0.250)));
      %  thresholt = t >= criteria == 1;
        
        criteria = prctile(t,v,'all');
        thresholt = t >= criteria == 1;
        
        [find_x, find_y] = find(thresholt==1);
        B = NaN(size(thresholt,1,2));
        
        B(thresholt) = t(thresholt);
        compete(:,:,tt) = B;
        
        o = repmat (tt,size(find_y,1),1);
        
        
        n = [num2str((tone(1:end)*4)),' kHz'];
        figure(1)
        scatter(find_y,find_x,[],'filled', 'MarkerFaceColor',colour(tt,:),...
            'MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2, 'DisplayName',n);
        
        figure(2)
        scatter(find_y,o,[],'filled', 'MarkerFaceColor',colour(tt,:),'DisplayName',n);
        
    end
end

figure(1)
xlabel ('Rostro-caudal')
ylabel ('medio-lateral/dorso-ventral')

axis on
xticks([1 size(avAll,1)])
xticklabels({'Rostral','Caudal'})
yticks([1 size(avAll,2)])
yticklabels({'Lateral/ventral','dorsal/medial'})

lgd = legend('Location','southoutside')
lgd.NumColumns = 4;
legend box off

figure(2)
ylabel ('Frequency (kHz)')
yticks([1:1:size(tones,2)])
yticklabels({'4','8','12','16','20','24','28','32'})
xlabel ('Rostral-caudal')
xticks([1 size(avAll,2)])
xticklabels({'rostral','caudal'})

saveas(figure(1),['Maps/BF overlapped'])
saveas(figure(2),['Maps/_overlapped index'])

%%

final = NaN(size(compete,1,2));
for xx = 1:size(compete,1);
    for yy = 1:size(compete,2);
        
        max_px = compete(xx,yy,:);
        
        m = max(max_px);
        mNaN = isnan(m);
        
        if mNaN == 1;
            ;
        else mNaN == 0;
            
            find_z = find(compete(xx,yy,:)== m);
            
            if size(find_z,1)>1;
                find_z = min(find_z);
            end
            
            if find_z == 1;
                final(xx,yy) = find_z;
                [find_x, find_y] = find(final==1);
                
            elseif find_z == 2;
                final(xx,yy) = find_z;
            elseif find_z == 3;
                final(xx,yy) = find_z;
            elseif find_z == 4;
                final(xx,yy) = find_z;
            elseif find_z == 5;
                final(xx,yy) = find_z;
            elseif find_z == 6;
                final(xx,yy) = find_z;
            elseif find_z == 7;
                final(xx,yy) = find_z;
            else find_z == 8;
                final(xx,yy) = find_z;
            end
        end
    end
end


figure(3)
clf
set(gcf,'color','w');
% imshow(backgd,'InitialMagnification','fit')
ax1 = axes;
imshow(avAll,[],'InitialMagnification','fit');
hold on
ax2 = axes;

for tt = 1:size(tones,2) % ignore the 0, indicating no frequency
    
    mask = final == tt; % only get pixel of that frequency
    if tt == 1;   % 4 kHz
        tint = cat(3, 0.0941176470588235*ones(size(mask)) ,0.0941176470588235*ones(size(mask)), 0.439215686274510*ones(size(mask)));
        h = imshow(tint);
        set(h,'AlphaData',mask);
        hold on
    elseif tt == 2; % 8 kHz
        tint = cat(3, zeros(size(mask)), 0.3*ones(size(mask)), ones(size(mask)));
        h = imshow(tint);
        set(h,'AlphaData',mask);
        hold on
    elseif tt == 3; % 12 kHz
        tint = cat(3, zeros(size(mask)), 0.7*ones(size(mask)), ones(size(mask)));
        h = imshow(tint);
        set(h,'AlphaData',mask);
        hold on
    elseif tt == 4; % 16 kHz
        tint = cat(3, 0.0549*ones(size(mask)), 0.9020*ones(size(mask)),0.3922 *ones(size(mask) ));
        h = imshow(tint);
        set(h,'AlphaData',mask);
        hold on
    elseif tt == 5; % 20 kHz
        tint = cat(3,0.7*ones(size(mask)), ones(size(mask)), 0.3*ones(size(mask) ));
        h = imshow(tint);
        set(h,'AlphaData',mask);
        hold on
    elseif tt == 6; % 24 kHz
        tint = cat(3, ones(size(mask)), ones(size(mask)), zeros(size(mask)));
        h = imshow(tint);
        set(h,'AlphaData',mask);
        hold on
    elseif tt == 7; % 28 kHz
        tint = cat(3, ones(size(mask)), 0.7*ones(size(mask)), zeros(size(mask)));
        h = imshow(tint);
        set(h,'AlphaData',mask);
        hold on
    else tt == 8; % 32 kHz
        tint = cat(3, ones(size(mask)), zeros(size(mask)), zeros(size(mask)));
        h = imshow(tint);
        set(h,'AlphaData',mask);
        hold on
    end
end

colormap(ax2,colour);
cb2 = colorbar(ax2,'southoutside');
cb2.Label.String = 'Frequency (kHz)';
caxis ([1 8]);
cb2.TickLabels = {'4','8','12','16','20','24','28','32'};
cb2.TickLength = 0;

saveas(gcf,['Maps/_BF'])

%% Work with "compete" because it's BF across all frequencies

x_list = [];
y_list = [];
tonenum = [];

figure
set(gca,'Ydir','reverse')
set(gca,'color','w')
% imshow(avAll,[]);
hold on

for xx = 1:size(final,1);
    for yy = 1:size(final,2);
        
        if isnan(final(xx,yy))== 1; 
            ;            
        else isnan(final(xx,yy))== 0; % not a NaN
            if final(xx,yy) == 1;
                x_list = cat(1,x_list,xx);
                y_list = cat(1,y_list,yy);
                tonenum = cat(1,tonenum, 1);
                
                n = [num2str(1*4),' kHz'];
                scatter(yy,xx,5,'filled', 'MarkerFaceColor',colour(1,:), 'DisplayName',n);
                
            elseif final(xx,yy) == 2;
                x_list = cat(1,x_list,xx);
                y_list = cat(1,y_list,yy);
                tonenum = cat(1,tonenum, 2);
                
                n = [num2str(2*4),' kHz'];
                scatter(yy,xx,5,'filled', 'MarkerFaceColor',colour(2,:), 'DisplayName',n);
                
            elseif final(xx,yy) == 3;
                x_list = cat(1,x_list,xx);
                y_list = cat(1,y_list,yy);
                tonenum = cat(1,tonenum, 3);
                
                n = [num2str(3*4),' kHz'];
                scatter(yy,xx,5,'filled', 'MarkerFaceColor',colour(3,:), 'DisplayName',n);
                
            elseif final(xx,yy) == 4;
                x_list = cat(1,x_list,xx);
                y_list = cat(1,y_list,yy);
                tonenum = cat(1,tonenum, 4);
                
                n = [num2str(4*4),' kHz'];
                scatter(yy,xx,5,'filled', 'MarkerFaceColor',colour(4,:), 'DisplayName',n);
                
            elseif final(xx,yy) == 5;
                x_list = cat(1,x_list,xx);
                y_list = cat(1,y_list,yy);
                tonenum = cat(1,tonenum, 5);
                
                n = [num2str(5*4),' kHz'];
                scatter(yy,xx,5,'filled', 'MarkerFaceColor',colour(5,:), 'DisplayName',n);
                
            elseif final(xx,yy) == 6;
                x_list = cat(1,x_list,xx);
                y_list = cat(1,y_list,yy);
                tonenum = cat(1,tonenum, 6);
                
                n = [num2str(6*4),' kHz'];
                scatter(yy,xx,5,'filled', 'MarkerFaceColor',colour(6,:), 'DisplayName',n);
                
            elseif final(xx,yy) == 7;
                x_list = cat(1,x_list,xx);
                y_list = cat(1,y_list,yy);
                tonenum = cat(1,tonenum, 7);
                
                n = [num2str(7*4),' kHz'];
                scatter(yy,xx,5,'filled', 'MarkerFaceColor',colour(7,:), 'DisplayName',n);
                
            else final(xx,yy) == 8;
                x_list = cat(1,x_list,xx);
                y_list = cat(1,y_list,yy);
                tonenum = cat(1,tonenum, 8);
                
                n = [num2str(8*4),' kHz'];
                scatter(yy,xx,5,'filled', 'MarkerFaceColor',colour(8,:), 'DisplayName',n);
                
            end
        end
    end
end

xlabel ('Rostro-caudal')

axis on
xticks([1 size(avAll,1)])
xticklabels({'Rostral','Caudal'})
yticks([1 size(avAll,2)])
yticklabels({'Medial/dordal','Lateral/Ventral'})

saveas(gcf,['Maps/_BF zoom'])

coordinates = [];
coordinates(:,1) = x_list;
coordinates(:,2) = y_list;
coordinates(:,3) = tonenum;

save('BF_coordinates.mat','coordinates');
save('Final.mat','final');


%%%%%

figure (5)
clf
set(gca,'color','w');
hold on

for bb = 1:size(tonenum,1);
    scatter(y_list(bb,1),tonenum(bb,1), [],'filled', 'MarkerFaceColor',colour((tonenum(bb,1)),:))
end

ylim([1 8])
yticks([1 2 3 4 5 6 7 8]);
yticklabels({'4','8','12','16','20','24','28','32'})
ylabel('Frequency (kHz)');

xlabel ('Rostral-caudal')
xticks([1 size(avAll,2)])
xticklabels({'caudal','rostral'})

saveas(gcf,['Maps/_BF index'])

%% cropping

figure
imshow(final, []);

[I rect] = imcrop;

save('crop_position.mat','rect');
save('Crop_final.mat','I');


%%
x_list = [];
y_list = [];
tonenum = [];

crop_avAll = imcrop(avAll, rect);

figure (1)
clf
set(gca,'Ydir','reverse')
set(gca,'color','w')
imshow(crop_avAll,[]);
hold on

for xx = 1:size(I,1);
    for yy = 1:size(I,2);
        
        if isnan(I(xx,yy))== 0;
            if I(xx,yy) == 1;
                x_list = cat(1,x_list,xx);
                y_list = cat(1,y_list,yy);
                tonenum = cat(1,tonenum, 1);
                
                n = [num2str(1*4),' kHz'];
                scatter(yy,xx,5,'filled', 'MarkerFaceColor',colour(1,:), 'DisplayName',n);
                
            elseif I(xx,yy) == 2;
                x_list = cat(1,x_list,xx);
                y_list = cat(1,y_list,yy);
                tonenum = cat(1,tonenum, 2);
                
                n = [num2str(2*4),' kHz'];
                scatter(yy,xx,5,'filled', 'MarkerFaceColor',colour(2,:), 'DisplayName',n);
                
            elseif I(xx,yy) == 3;
                x_list = cat(1,x_list,xx);
                y_list = cat(1,y_list,yy);
                tonenum = cat(1,tonenum, 3);
                
                n = [num2str(3*4),' kHz'];
                scatter(yy,xx,5,'filled', 'MarkerFaceColor',colour(3,:), 'DisplayName',n);
                
            elseif I(xx,yy) == 4;
                x_list = cat(1,x_list,xx);
                y_list = cat(1,y_list,yy);
                tonenum = cat(1,tonenum, 4);
                
                n = [num2str(4*4),' kHz'];
                scatter(yy,xx,5,'filled', 'MarkerFaceColor',colour(4,:), 'DisplayName',n);
                
            elseif I(xx,yy) == 5;
                x_list = cat(1,x_list,xx);
                y_list = cat(1,y_list,yy);
                tonenum = cat(1,tonenum, 5);
                
                n = [num2str(5*4),' kHz'];
                scatter(yy,xx,5,'filled', 'MarkerFaceColor',colour(5,:), 'DisplayName',n);
                
            elseif I(xx,yy) == 6;
                x_list = cat(1,x_list,xx);
                y_list = cat(1,y_list,yy);
                tonenum = cat(1,tonenum, 6);
                
                n = [num2str(6*4),' kHz'];
                scatter(yy,xx,5,'filled', 'MarkerFaceColor',colour(6,:), 'DisplayName',n);
                
            elseif I(xx,yy) == 7;
                x_list = cat(1,x_list,xx);
                y_list = cat(1,y_list,yy);
                tonenum = cat(1,tonenum, 7);
                
                n = [num2str(7*4),' kHz'];
                scatter(yy,xx,5,'filled', 'MarkerFaceColor',colour(7,:), 'DisplayName',n);
                
            else I(xx,yy) == 8;
                x_list = cat(1,x_list,xx);
                y_list = cat(1,y_list,yy);
                tonenum = cat(1,tonenum, 8);
                
                n = [num2str(8*4),' kHz'];
                scatter(yy,xx,5,'filled', 'MarkerFaceColor',colour(8,:), 'DisplayName',n);
                
            end
        end
    end
end

saveas(gcf,['Maps/cropped_BF'])


coordinates = [];
coordinates(:,1) = x_list;
coordinates(:,2) = y_list;
coordinates(:,3) = tonenum;

save('cropped_BF_coordinates.mat','coordinates');

















