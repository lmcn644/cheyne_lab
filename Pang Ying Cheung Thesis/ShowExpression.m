clear 
close all
clc

% load DF image
% s = stack;

stack = s;

stack (:,:,3001:end) = [];

rec_length  = 5; % recording length 
fps = 10;
scalea = [0:(1/fps):rec_length*60];
scale = scalea/60; % convert to min

trace = [];
for ii = 1:size(stack,3);
    f = mean(stack(:,:,ii),'all','omitnan');
    trace= cat(1,trace,f);
end

figure
set(gcf, 'color','w');
plot(scale,trace);
xlabel('Time (min)')
ylabel('ΔF/F0')
box off

saveas(gcf,['TemporalTrace.png']); % Save the image as png first
saveas(gcf,'TemporalTrace');

%% 

figure
set(gcf, 'color','w')
tiledlayout(2,10,'TileSpacing','Compact')      
clims = [0 15];

for ii = 1:20
    % Plot
    nexttile
    imshow(stack(:,:,ii+601),[clims],'InitialMagnification','fit')
    colormap turbo;
   % colormap (gca, lightzero);
   timescale = scalea(ii+1);
    title ([num2str(timescale(1:end)),' s'],'fontsize',15);
end
c = colorbar
c.Label.String = 'ΔF/F'
set(gca,'YTick',[clims]);

saveas(gcf,['Time Frame.png']); % Save the image as png first
saveas(gcf,'Time Frame ');
