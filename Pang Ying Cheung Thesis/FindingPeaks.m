%% ACMeso recordings

rec_length = 5;
fps = 10;

baseline = 3;
response = 1.5; 

trace = [];
for ii = 1:size(ROIstack,3);
    trace = cat(1,trace,(mean(ROIstack(:,:,ii),'all','omitnan')));
end


mph = std(trace,1,'omitnan')/2; % 1 SD of the trace
[pk,loc] = findpeaks(trace,'MinPeakHeight',mph);

    stimuli(:,1:2) = stimuli(:,1:2)- peakoffset(1,:);
    stimuli = round(stimuli);
    
base_location = [];
base_peaks = [];
res_location = [];
res_peaks = [];

figure (1)
clf
set(gcf,'color','w');

for tt = 1:size(stimuli,1);
    
    
    base_start = stimuli(tt,1)-((baseline*fps)-1);
    res_start = stimuli(tt,1);
    
    base_end = stimuli(tt,1)-1;
    res_end = stimuli(tt,1) + (response*fps);
    
    
    figure(1);
    hold on
    rectangle('Position', [base_start 2.5 baseline*fps 2.5], 'FaceColor', [0.8,0.8,0.8])
    rectangle('Position', [res_start 2.5 response*fps 2.5], 'FaceColor', [0.392,0.831,0.0745]);
    % xline(res_start,'color', [0.392,0.831,0.0745])
    % xline(res_end,'color', [0.392,0.831,0.0745])
    % xline(base_start,'color',[0.8,0.8,0.8]);
    % xline(base_end,'color',[0.8,0.8,0.8]);
    
    base_find = find(loc >= base_start & loc<=(stimuli(tt,1)-1));
    res_find = find (loc >=(stimuli(tt,1))& loc <=res_end);
    
    if isempty(base_find) == 1;
        ;
    else isempty(base_find)== 0;
        base_position = loc(base_find,1);
        base_pk_location = pk(base_find,1);
        
        base_location = cat(1,base_location,base_position);
        base_peaks = cat(1,base_peaks,base_pk_location);
    end
    
    if isempty(res_find) == 1;
        ;
    else isempty(res_find)== 0;
        res_position = loc(res_find,1);
        res_pk_location = pk(res_find,1);
        
        res_location = cat(1,res_location,res_position);
        res_peaks = cat(1,res_peaks,res_pk_location);
    end
    
    
    figure (1)
    hold on
    scatter(base_location,base_peaks,[],'r','filled');
    scatter(res_location,res_peaks,[],'g','filled');
    box off
    
    
end

xscale = [500:1:1500];

figure(1)
hold on
plot(xscale,trace(500:1500,1),'color',[0,0.4471,0.7412])
xlabel('Time (s)')
ylabel('ΔF/F')

xticks([500 600 700 800 900 1000 1100 1200 1300 1400 1500]);
xticklabels({'50','60','70','80','90','100','110','120','130','140','150'})

%% AC recordings
rec_length = 3;
fps =5;

baseline = 3;
response = 2;

trace = [];
for ii = 1:size(ROIstack,3);
    trace = cat(1,trace,(mean(ROIstack(:,:,ii),'all','omitnan')));
end


mph = std(trace,1,'omitnan')/2; % 1 SD of the trace
[pk,loc] = findpeaks(trace,'MinPeakHeight',mph);

stimuli(2:2:end,:) = [];
stimuli(:,1:2) = stimuli(:,1:2)- peakoffset(1,:);
stimuli = round(stimuli);

base_location = [];
base_peaks = [];
res_location = [];
res_peaks = [];

figure (1)
clf
set(gcf,'color','w');

for tt = 1:size(stimuli,1);
    
    
    base_start = stimuli(tt,1)-((baseline*fps)-1);
    res_start = stimuli(tt,1);
    
    base_end = stimuli(tt,1)-1;
    res_end = stimuli(tt,1) + (response*fps);
    
    
    figure(1);
    hold on
    rectangle('Position', [base_start -0.5 baseline*fps 0.5], 'FaceColor', [0.8,0.8,0.8])
    rectangle('Position', [res_start -0.5 response*fps 0.5], 'FaceColor', [0.392,0.831,0.0745]);
    % xline(res_start,'color', [0.392,0.831,0.0745])
    % xline(res_end,'color', [0.392,0.831,0.0745])
    % xline(base_start,'color',[0.8,0.8,0.8]);
    % xline(base_end,'color',[0.8,0.8,0.8]);
    
    base_find = find(loc >= base_start & loc<=(stimuli(tt,1)-1));
    res_find = find (loc >=(stimuli(tt,1))& loc <=res_end);
    
    if isempty(base_find) == 1;
        ;
    else isempty(base_find)== 0;
        base_position = loc(base_find,1);
        base_pk_location = pk(base_find,1);
        
        base_location = cat(1,base_location,base_position);
        base_peaks = cat(1,base_peaks,base_pk_location);
    end
    
    if isempty(res_find) == 1;
        ;
    else isempty(res_find)== 0;
        res_position = loc(res_find,1);
        res_pk_location = pk(res_find,1);
        
        res_location = cat(1,res_location,res_position);
        res_peaks = cat(1,res_peaks,res_pk_location);
    end
    
    
    figure (1)
    hold on
    scatter(base_location,base_peaks,[],'r','filled');
    scatter(res_location,res_peaks,[],'g','filled');
    box off
    
    
end

xscale = [1:1:900];

figure(1)
hold on
plot(xscale,trace(1:900,1),'color',[0,0.4471,0.7412])
xlabel('Time (s)')
ylabel('ΔF/F')

xticks([1 100 200 300 400 500 600 700 800 900]);
xticklabels({'1','20','40','60','80','100','120','140','160','180'})

%% DV recordings

fps = 10;

scale = [(1/(fps*60)):(1/(fps*60)):((size(stack,3)/10)/60)];

msk = imresize(msk,[359 429]);
stack = imresize(stack,[359 429]);

ROIstack = NaN(size(stack));
for xx = 1:size(stack,1);
    for yy = 1:size(stack,2);
        if msk(xx,yy,1)== 0;
            ;
        else msk(xx,yy,1) == 1;
            g_filt = imgaussfilt3(stack(xx,yy,:),2);
            ROIstack(xx,yy,:) = g_filt;
        end
    end
end

trace = [];
for ii = 1:size(ROIstack,3);
    trace(ii,1) = mean(ROIstack(:,:,ii),'all','omitnan');
end

mph = std(trace,1,'omitnan')/2; % 1 SD of the trace
[pk,loc,w] = findpeaks(trace,'MinPeakHeight',mph);

loc_scale = loc/(fps*60);


figure(1)
set(gcf,'color','w')
clf
plot(scale, trace);
hold on
scatter(loc_scale,pk,'*');
xlabel('Time (min)')
ylabel('ΔF/F')
box off




