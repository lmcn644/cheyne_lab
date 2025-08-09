%% Location specific firing cells
%genotype=[]; %WT=1 %KO=2

%load genotype
%% clear the workspace and select data
clear; clc; close all;

%%
animals=dir;
animals(1:2,:)=[];
animals = natsortfiles(animals);
filter = {animals.name}; % Filters out any '.mat' files in the animal folder
filter = ~(contains(filter,'.mat'))';
animals = animals(filter,:);
nAnimals=size(animals,1);

for iAnimal = 1:nAnimals;
    iAnimal
    tic
    animal=animals(iAnimal).name;
    folder=animal;
    cd(folder)
    load behave
    load scope
    scope(scope == 0) = NaN;
    load final_peakdata
    load framerate
    load nFrames
    load nCells
    load NeuKeep
%     load cell_stats_OF

    nLocs=size(behave,1); %Number of distinct locations (frames) the animal occupies in the recording.
    
    %% Interior    
    filelist=dir('*ROIoutput.xlsx');
    d1 = readtable(filelist(1).name, 'readvariablenames', false);
    % get interior
    num = d1(1:end,4);
    num=num{:,:};

  %couple of loops that ensure interior position array matches the max number of behavioural frames
%     if size(num,1)<max(scope(:,4))
%         num(end+1: max(scope(:,4)),:)=0;
%     end
%     if size(num,1)>max(scope(:,4))
%         num(max(scope(:,4))+1:end,:)=[];
%     end

    behave(:,7) = num;

    ind=behave(:,7)==1;
    quadrant=[];
    quadrant(:,1)=ind; %c1 = animal is in interior
    quadrant(:,2)=~ind; %c2 = animal is in exterior
    
    %% Compare firing freqency between quadrants
    % add quadrant to final_peakdata

    nPeaks=size(final_peakdata,1);
    for iPeak=1:nPeaks
        frame=final_peakdata(iPeak,10); %corrected scope frame for peak
        if frame<size(scope(:,1),1)
            temp=scope(frame-1:frame+1,6); %Gets a range of behavioural frames that could correspond to corrected scope frame
            if nansum(temp)==0
                temp=scope(frame-2:frame+2,6); %Take wider bracket if there's no non-NaN options (should be resolved by indexing from column 6 instead of 4).
            end
            b_frame=min(temp);  %indexing the behavioural frame from the scope matrix for higher accuracy, MINIMAL possible behavioural frame is taken as the 'peak frame', hence why is differs slightly to indexing from ALLPeakdata(:,11)
            b_frame = find(behave(:,1) == b_frame,1); %adjusts behavioural frame selected due to deletions from raw DLC output
            
            
            if ~isempty(b_frame)
                temp=quadrant(b_frame,2); %Determines if animal was in int(1) or ext(2) for that frame

                if temp==0;  %in int
                    final_peakdata(iPeak,13)=1;
                end
                if temp==1;  %in ext
                    final_peakdata(iPeak,13)=2;
                end
            else
                [M,I] = min(abs(behave(:,1)-min(temp)));
                b_frame = behave(I,1);
                temp=quadrant(b_frame,2);  %Determines if animal was in int(1) or ext(2) for that frame
                if temp==0;  %in int
                    final_peakdata(iPeak,13)=1;
                end
                if temp==1;   %in ext
                    final_peakdata(iPeak,13)=2;
                end
            end
        end
    end
    
    %%
    
    % Check inner vs outer boundaries

    cmap = jet(5);
    of=zeros(max(behave(:,4))+20,max(behave(:,5))+20);
    for i=1:nLocs
        if behave(i,7)==1; %1 for inner
            x= behave(i,4);
            y= behave(i,5);
            if ~isnan(x) & ~isnan(y)
                of(y,x)=2;
            end
        elseif behave(i,7)==0; %0 for outer
            x= behave(i,4);
            y= behave(i,5);
            if ~isnan(x) & ~isnan(y)
                of(y,x)=5;
            end
        end
    end
    imshow(of,cmap)
    pause
    close all

    %% cell activity for inner/outer added to cell_stats.mat

%     for iCell=NeuKeep %for each cell
%         row = find(NeuKeep == iCell);
%         ind=final_peakdata(:,1)==iCell & final_peakdata(:,13)==2; %index for when cell fires in ext
%         cell_stats(row,9)=sum(ind); %c9 of cell_stats = number of times cells fires in ext
%         ind=final_peakdata(:,1)==iCell & final_peakdata(:,13)==1; %index for when cell fires in int
%         cell_stats(row,10)=sum(ind); %c10 of cell_stats = number of times cells fires in int
%     end

    b_framerate = max(behave(:,1))/(max(behave(:,2))/1000); %Behavioural video frame rate

    OF=[];
    
    interior=1;
    exterior=2;
    ind=final_peakdata(:,13)==interior;  %Indexes peaks from final_peakdata for when animal is in the interior 
    ind2=final_peakdata(:,13)==exterior; %Indexes peaks from final_peakdata for when animal is in the exterior
    
    OF(1,1)=sum(quadrant(:,interior));   % 1	frames spent in interior
    OF(1,2)=OF(1,1)./b_framerate;    % 2 seconds spent in interior
    OF(1,3)=sum(ind); % 	3	number of peaks that occur while animal is in interior
    OF(1,4)=nanmean(final_peakdata(ind,3)); % 	4	mean peak amplitude while animal is in interior
    OF(1,5)=nanstd(final_peakdata(ind,3));% 	5	amplitude STD
    OF(1,6)=nanmean(final_peakdata(ind,4)); % 	6	mean peak width while animal is in interior
    OF(1,7)=nanstd(final_peakdata(ind,4));% 	7	Width STD
    temp=unique(final_peakdata(ind,1));
    OF(1,8)=size(temp,1); % 	8	Number of unique cells that fire while animal is in interior
    OF(1,9)=OF(1,8)/nCells*100;  % 	9	Participation - percentage of cells that fire in the interior
    OF(1,10)=OF(1,3)./OF(1,2);% 	10	Overall Firing Freq (spike/sec) while animal is in interior
    
    OF(2,1)=sum(quadrant(:,exterior));   % 1	frames spent in exterior
    OF(2,2)=OF(2,1)./b_framerate; % 2 seconds spent in exterior
    OF(2,3)=sum(ind2); % 	3	number of peaks that occur while animal is in exterior
    OF(2,4)=nanmean(final_peakdata(ind2,3)); % 	4	mean peak amplitude while animal is in exterior
    OF(2,5)=nanstd(final_peakdata(ind2,3));% 	5	amplitude STD
    OF(2,6)=nanmean(final_peakdata(ind2,4)); % 	6	mean peak width while animal is in exterior
    OF(2,7)=nanstd(final_peakdata(ind2,4));% 	7	Width STD
    temp=unique(final_peakdata(ind2,1));
    OF(2,8)=size(temp,1); % 	8	Number of unique cells that fire while animal is in exterior
    OF(2,9)=OF(2,8)/nCells*100;  % 	9	Participation - percentage of cells that fire in the exterior
    OF(2,10)=OF(2,3)./OF(2,2);% 	10	Overall Firing Freq (spike/sec) while animal is in exterior
    
    %% Cell activity per category
    
%     cell_stats=[];
%     for iCell=NeuKeep
%         row = find(NeuKeep == iCell);
%         cell_stats(row,1)=iCell; %Cell number in c1 of cell_stats
%         ind=final_peakdata(:,1)==iCell; %Finds all peaks corresponding to current cell
%         cell_stats(row,2)=sum(ind); %Number of peaks corresponding to the cell in c2 of cell_stats
%         ind=final_peakdata(:,1)==iCell & final_peakdata(:,13)==1; %Finds peaks the current cell fires while in the interior
%         cell_stats(row,4)=sum(ind); %Number of peaks the current cell fires while in the interior in c4 of cell_stats
%         ind=final_peakdata(:,1)==iCell & final_peakdata(:,13)==2; %Finds peaks the current cell fires while in the exterior
%         cell_stats(row,5)=sum(ind); %Number of peaks the current cell fires while in the exterior in c5 of cell_stats
%     end
%     
%     %% % spikes in each zone    
%     
%     cell_stats(:,8)=cell_stats(:,4)./cell_stats(:,2)*100; %c8 = Percentage of peaks fired by each cell which occur in the interior
%     cell_stats(:,9)=cell_stats(:,5)./cell_stats(:,2)*100; %c9 = Percentage of peaks fired by each cell which occur in the exterior
%           
%     Scell_stats=sortrows(cell_stats,8,'descend'); %Sorts cells by percentage of spiking that occurs in the interior.
%     ind =Scell_stats(:,2)<10; %Only cells that fire more than 10 times are considered.
%     Scell_stats(ind,:)=[];
%     ind = Scell_stats(:,8)<=50; %Only cells that fires more than 50% of the time in the interior are considered.
%     Scell_stats(ind,:)=[];
%     
    save final_peakdata 'final_peakdata'  % Adds c13= whether animal was in interior (1) or exterior (2) when peak was fired
    save behave 'behave' %Adds c7 = whether animal was in int or ext for behavioural frame
    
%     filename='Scell_statsInterior';  %c1: Cell number, c2: peaks corresponding to the cell, c4: peaks cell fires while in interior, c5: peaks cell fires while in exterior, c8: percentage of peaks in int, c9: percentage of peaks in ext
%     save (filename,'Scell_stats')

    filename = 'OF_Interior_data';  %See line 88 for column info, row 1 = int, row 2 = ext
    save (filename, 'OF');
    
    %%
        
    cd ..
end





