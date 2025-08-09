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
    
    %% Freezing
    filelist=dir('*Freezing_output.xlsx');
    
    d1 = readtable(filelist(1).name, 'readvariablenames', false);
    
    num=d1(1:end,4);
    num=num{:,:};
    
    if size(num,1)<size(behave(:,1),1)
        num(end+1: size(behave(:,1),1),:)=0;
    end
    if size(num,1)>size(behave(:,1),1)
        num(size(behave(:,1),1)+1:end,:)=[];
    end

    ind=num(:,:)==100; %Index for when animal is freezing
    quadrant=[];
    quadrant(:,1)=ind; % c1 = animal is freezing
    quadrant(:,2)=~ind; % c2 = animal is in motion
    
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
            b_frame=min(temp); %indexing the behavioural frame from the scope matrix for higher accuracy, MINIMAL possible behavioural frame is taken as the 'peak frame', hence why is differs slightly to indexing from ALLPeakdata(:,6)
            b_frame = find(behave(:,1) == b_frame,1); %adjusts behavioural frame selected due to deletions from raw DLC output

            if ~isempty(b_frame)
                temp=quadrant(b_frame,2);  %Determines if animal was freezing(0) or in motion(1) for that frame
                if temp==0;  %Freezing
                    final_peakdata(iPeak,14)=1;
                end
                if temp==1;  %In motion
                    final_peakdata(iPeak,14)=2;
                end
            else
                [M,I] = min(abs(behave(:,1)-min(temp)));
                b_frame = behave(I,1);
                temp=quadrant(b_frame,2);  %Determines if animal was freezing(0) or in motion(1) for that frame
                if temp==0;  %Freezing
                    final_peakdata(iPeak,14)=1;
                end
                if temp==1;  %In motion
                    final_peakdata(iPeak,14)=2;
                end
            end
        end
    end
    %%

    b_framerate = max(behave(:,1))/(max(behave(:,2))/1000); %Behavioural video frame rate

    OF=[];
    
    move=2;
    freeze=1;
    ind=final_peakdata(:,14)==move;   %Indexes peaks from final_peakdata for when animal is in motion
    ind2=final_peakdata(:,14)==freeze;   %Indexes peaks from final_peakdata for when animal is freezing
    
    OF(1,1)=sum(quadrant(:,move));   % 1	frames spent in motion
    OF(1,2)=OF(1,1)./b_framerate;    % 2 seconds spent in motion
    OF(1,3)=sum(ind); % 	3	number of peaks that occur while animal is in motion
    OF(1,4)=nanmean(final_peakdata(ind,3)); % 	4	mean peak amplitude while animal is in motion
    OF(1,5)=nanstd(final_peakdata(ind,3));% 	5	amplitude STD
    OF(1,6)=nanmean(final_peakdata(ind,4)); % 	6	mean peak width while animal is in motion
    OF(1,7)=nanstd(final_peakdata(ind,4));% 	7	Width STD
    temp=unique(final_peakdata(ind,1));
    OF(1,8)=size(temp,1); % 	8	Number of unique cells that fire while animal is in motion
    OF(1,9)=OF(1,8)/nCells*100;  % 	9	Participation - percentage of cells that fire while animal is in motion
    OF(1,10)=OF(1,3)./OF(1,2);% 	10	Overall Firing Freq (spike/sec) while animal is in motion
    
    OF(2,1)=sum(quadrant(:,freeze));   % 1	frames spent freezing
    OF(2,2)=OF(2,1)./b_framerate; % seconds spent freezing
    OF(2,3)=sum(ind2); % 	3	number of peaks that occur while animal is freezing
    OF(2,4)=nanmean(final_peakdata(ind2,3)); % 	4	mean peak amplitude while animal is freezing
    OF(2,5)=nanstd(final_peakdata(ind2,3));% 	5	amplitude STD
    OF(2,6)=nanmean(final_peakdata(ind2,4)); % 	6	mean peak width while animal is freezing
    OF(2,7)=nanstd(final_peakdata(ind2,4));% 	7	Width STD
    temp=unique(final_peakdata(ind2,1));
    OF(2,8)=size(temp,1); % 	8	Number of unique cells
    OF(2,9)=OF(2,8)/nCells*100;  % 	9	Participation - percentage of cells that fire while animal is freezing
    OF(2,10)=OF(2,3)./OF(2,2);% 	10	Overall Firing Freq (spike/sec) while animal is freezing
    
%         %% Cell activity per category
%     
%     cell_stats=[];
%     for iCell=NeuKeep
%         row = find(NeuKeep == iCell);
%         cell_stats(row,1)=iCell;  %Cell number in c1 of cell_stats
%         ind=final_peakdata(:,1)==iCell;  %Finds all peaks corresponding to current cell
%         cell_stats(row,2)=sum(ind); %Number of peaks corresponding to the cell in c2 of cell_stats
%         ind=final_peakdata(:,1)==iCell & final_peakdata(:,14)==1; %Finds peaks the current cell fires while freezing
%         cell_stats(row,4)=sum(ind);  %Number of peaks the current cell fires while freezing in c4 of cell_stats
%         ind=final_peakdata(:,1)==iCell & final_peakdata(:,14)==2; %Finds peaks the current cell fires while in motion
%         cell_stats(row,5)=sum(ind); %Number of peaks the current cell fires while in motion in c5 of cell_stats
%     end
%     
%     %% % spikes in each zone    
%     
%     cell_stats(:,8)=cell_stats(:,4)./cell_stats(:,2)*100; %c8 = Percentage of peaks fired by each cell which occur while freezing
%     cell_stats(:,9)=cell_stats(:,5)./cell_stats(:,2)*100; %c9 = Percentage of peaks fired by each cell which occur while in motion
%           
%     Scell_stats=sortrows(cell_stats,8,'descend'); %Sorts cells by percentage of spiking that occurs while freezing.
%     ind =Scell_stats(:,2)<10; %Only cells that fire more than 10 times are considered.
%     Scell_stats(ind,:)=[];
%     ind = Scell_stats(:,8)<=50; %Only cells that fires more than 50% of the time while the animal is freezing are considered.
%     Scell_stats(ind,:)=[];
    
    save final_peakdata 'final_peakdata'  % Adds c14= whether animal was in freezing (1) or in motion (2) when peak was fired
    
%     filename='Scell_statsFreeze';  %c1: Cell number, c2: peaks corresponding to the cell, c4: peaks cell fires while freezing, c5: peaks cell fires while in motion, c8: percentage of peaks while freezing, c9: percentage of peaks while moving
%     save (filename,'Scell_stats')  

    filename = 'OF_Freezing_data';  %See line 88 for column info, row 1 = in motion, row 2 = freezing
    save (filename, 'OF');
    
    %%
        
    cd ..
end






