
stack = stack_og;



save(['PCA-ICA/DV12_04 comboRemove.mat'],'stack','-v7.3');



trace_og = [];
for ff = 1:size(stack_og,3);
    frame = mean(stack_og(:,:,ff),'all','omitnan');
    trace_og = cat(1,trace_og,frame);
end


trace= [];
for ff = 1:size(stack,3);
    frame = mean(stack(:,:,ff),'all','omitnan');
    trace = cat(1,trace,frame);
end

figure
plot(trace_og);
hold on
plot(trace);


roi = drawfreehand(gca);
%%% if need to add a way point, right click > aff way point

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

save(['PCA-ICA/DV12_04 ROI_combo'],'maskroi');



ROIstack_og = NaN(size(stack_og));
for xx = 1:size(stack_og,1);
    for yy = 1:size(stack_og,2);
        if maskroi(xx,yy,1)== 0;
            ;
        else maskroi(xx,yy,1) == 1;
            ROIstack_og(xx,yy,:) = stack_og(xx,yy,:);
            
        end
    end
end



ROIstack = NaN(size(stack));
for xx = 1:size(stack,1);
    for yy = 1:size(stack,2);
        if maskroi(xx,yy,1)== 0;
            ;
        else maskroi(xx,yy,1) == 1;
            ROIstack(xx,yy,:) = stack(xx,yy,:);
            
        end
    end
end



trace_og_roi = [];
for ff = 1:size(ROIstack_og,3);
    frame = mean(ROIstack_og(:,:,ff),'all','omitnan');
    trace_og_roi = cat(1,trace_og_roi,frame);
end


trace_roi= [];
for ff = 1:size(ROIstack,3);
    frame = mean(ROIstack(:,:,ff),'all','omitnan');
    trace_roi = cat(1,trace_roi,frame);
end



figure
plot(trace_og_roi);
hold on
plot(trace_roi);

%%%%     
name2 = ['DV12_04 raw.tif'];

a = single(stack_og);
fTIF = Fast_Tiff_Write(['PCA-ICA/',name2]);
for k = 1:size(a,3)
    fTIF.WriteIMG(a(:,:,k)');
end
fTIF.close;
    
%%%%

name2 = ['DV12_04 noCombo.tif'];

a = single(stack);
fTIF = Fast_Tiff_Write(['PCA-ICA/',name2]);
for k = 1:size(a,3)
    fTIF.WriteIMG(a(:,:,k)');
end
fTIF.close;    

%%%

name2 = ['DV12_04 no34.tif'];

a = single(stack);
fTIF = Fast_Tiff_Write(['PCA-ICA/',name2]);
for k = 1:size(a,3)
    fTIF.WriteIMG(a(:,:,k)');
end
fTIF.close;    


%%% 

name2 = ['DV12_04 no31_27.tif'];

a = single(stack);
fTIF = Fast_Tiff_Write(['PCA-ICA/',name2]);
for k = 1:size(a,3)
    fTIF.WriteIMG(a(:,:,k)');
end
fTIF.close;    

%%    
    
fps = 10; 
scale = [(1/(fps*60)):(1/(fps*60)):5];

figure (1)
set(gcf, 'color','w')

subplot(3,1,1);
plot(scale, trace_og,'Color',[0,0.4471,0.7412]);
ylim([-5 5])
ax = gca;
ax.TitleHorizontalAlignment = 'left';
%   axis off
set(gca,'xtick',[])
set(gca,'ytick',[])
box off
title('1. Trace from raw images','FontSize',15);

subplot(3,1,2);
plot(scale, trace,'Color', [1.0000,0.4118,0.1608]);
ylim([-5 5])
ax = gca;
ax.TitleHorizontalAlignment = 'left';
%   axis off
set(gca,'xtick',[])
set(gca,'ytick',[])
box off
title('2. Trace from recontructed images','FontSize',15);

subplot(3,1,3);
plot(scale, trace_og);
hold on 
plot(scale, trace);
ylim([-5 5])
ax = gca;
ax.TitleHorizontalAlignment = 'left';
%   axis off
title('3. Overlap','FontSize',15);
ylabel ("ΔF/F")
xlabel ("Time (min)")
legend ('Raw trace','Reconstructed trace');
box off
legend box off

%% Region traces

fps = 10; 
scale = [(1/(fps*60)):(1/(fps*60)):5];

figure
set(gcf, 'color','w')

subplot(3,1,1);
plot(scale, trace_og_roi,'Color',[0,0.4471,0.7412]);
ylim([-40 60])
ax = gca;
ax.TitleHorizontalAlignment = 'left';
%   axis off
set(gca,'xtick',[])
set(gca,'ytick',[])
box off
title('1. Trace from raw images','FontSize',15);

subplot(3,1,2);
plot(scale, trace_roi,'Color', [1.0000,0.4118,0.1608]);
ylim([-40 60])
ax = gca;
ax.TitleHorizontalAlignment = 'left';
%   axis off
set(gca,'xtick',[])
set(gca,'ytick',[])
box off
title('2. Trace from recontructed images','FontSize',15);

subplot(3,1,3);
plot(scale, trace_og_roi,'Color',[0,0.4471,0.7412]);
hold on 
plot(scale, trace_roi,'Color', [1.0000,0.4118,0.1608]);
ylim([-40 60])
ax = gca;
ax.TitleHorizontalAlignment = 'left';
%   axis off
title('3. Overlap','FontSize',15);
ylabel ("ΔF/F")
xlabel ("Time (min)")
legend ('Raw trace','Reconstructed trace');
box off
legend box off


    
    
    

    
    
    










    
    
    
    
    