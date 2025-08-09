%% Location specific firing cells
%genotype=[]; %WT=1 %KO=2

%load genotype
%% clear the workspace and select data
clear; clc; close all;

%%
animals=dir;
animals(1:2,:)=[];
animals = natsortfiles(animals);
nAnimals=size(animals,1);

for iAnimal = 1:2:nAnimals;
    iAnimal
    tic
    animal=animals(iAnimal).name;
    folder=animal;
    cd(folder)

    load behave
    YM1behave = behave;
    load scope
    YM1scope = scope;

    filelist=dir('*ROIoutput.xlsx');
    d1 = readtable(filelist(1).name, 'readvariablenames', false);
    num=d1(1:end,4:6);
    num=num{:,:};

    if size(num,1)<max(YM1scope(:,4))   %Expands YM arm location array to match scope array
        num(end+1: max(YM1scope(:,4)),:)=0;
    end
    quadrantYM1=num(1:max(YM1scope(:,4)),:);

    cd ..
    iAnimal = iAnimal + 1;
    animal=animals(iAnimal).name;
    folder=animal;
    cd(folder)

    load behave
    load behave_joined
    load scope
    load scope_joined
    load final_peakdata
    load duration_joined
%     load framerate
    load nFrames
    load nCells
    load NeuKeep
    
    %% Loop through options  
    
    filelist=dir('*ROIoutput.xlsx');
    d1 = readtable(filelist(1).name, 'readvariablenames', false);
    num=d1(1:end,4:6);
    num=num{:,:};
%     if sum(sum(num))==0
%         num=d1(2:end,10:12);
%         num=num{:,:};
%         num = strcmp(num,'True');
%     end
    if size(num,1)<max(scope(:,4))   %Expands YM arm location array to match scope array 
        num(end+1: max(scope(:,4)),:)=0;
    end
    quadrantYM2=num(1:max(scope(:,4)),:);

    quadrant = [quadrantYM1; quadrantYM2];

    %% Behavioural Framerate across both recordings together

    framerate_bh = max(behave_joined(:,1))/(max(behave_joined(:,2))/1000); %Framerate of behavioural recording

    t_q=sum(quadrant,1)/framerate_bh;

    t_q(1,4) = (size(behave_joined,1) - sum(sum(quadrant,1)))/framerate_bh;  %puts time spent in centre in c4 of t_q
    t_q_percent = t_q/(duration_joined/1000)*100; %Gives time in each quadrant in percent

    %% Compare firing freqency between quadrants

    nPeaks=size(final_peakdata,1); %All peaks

    for iPeak=1:nPeaks
        frame=final_peakdata(iPeak,10); %indexing corrected scope frame for peak
        if  ismember(frame, scope_joined(:,1)) == 0
            frame = frame+1; %Contingency in case scope frames don't begin at '1'
        end
        %if frame<size(scope(:,1),1)
        temp=scope_joined(frame-1:frame+1,6); %Takes small range to index for equivalent behavioural frame where peak is fired
        if nansum(temp)==0
            temp=scope_joined(frame-2:frame+2,6);
        end
        b_frame=min(temp); %minimum value utilised as equivalent behavioural frame
        b_frame = find(behave_joined(:,1) == b_frame,1); %adjusts behavioural frame selected due to deletions from raw DLC output


        if ~isempty(b_frame)

            temp=quadrant(b_frame,:); %Determines which arm the animal was occupying during current behavioural frame
            [r c]=find(temp==1); %Gives row and column number for which arm the mouse is in
            if isempty(c) | size(c,2)>1
                final_peakdata(iPeak,12)=0; %If somehow frame is not found or mouse is occupying multiple arms, 0 is default
            end
            if ~isempty(c)& size(c,2)==1
                final_peakdata(iPeak,12)=c;% column 12 = what quadrant they are in during that spike: Left [c = 1], Right [c = 2], Novel [c = 3], Middle [c = 0]
            end
        else
            [M,I] = min(abs(behave_joined(:,1)-min(temp)));
            b_frame = behave_joined(I,1);
            temp=quadrant(b_frame,:); %Determines which arm the animal was occupying during current behavioural frame

            [r c]=find(temp==1); %Gives row and column number for which arm the mouse is in
            if isempty(c) | size(c,2)>1
                final_peakdata(iPeak,12)=0; %If somehow frame is not found, 0 is default
            end
            if ~isempty(c)& size(c,2)==1
                final_peakdata(iPeak,12)=c;% column 12 = what quadrant they are in during that spike: Left [c = 1], Right [c = 2], Novel [c = 3], Middle [c = 0]
            end
        end

        %end
    end

%%%%%%%%%%%%%

    
    %%
    
    YM=[];
    middle=0;
    left=1;
    right=2;
    known=1:2;
    novel=3;

    indL = final_peakdata(:,12)==left; %Index for peaks that occur in the left arm
    indR = final_peakdata(:,12)==right; %Index for peaks that occur in the right arm
    indF = final_peakdata(:,12)==left | final_peakdata(:,12)==right; %Index for peaks that occur in familiar arms
    indN = final_peakdata(:,12)==novel; %Index for peaks that occur in the novel arm
    indM = final_peakdata(:,12)==middle; %Index for peaks that occur in the middle

    YM(1,1)=sum(sum(quadrant(:,left))); %1	number of frames spent in left arm
    YM(2,1)=sum(sum(quadrant(:,right))); %1	number of frames spent in right arm
    YM(3,1)=sum(sum(quadrant(:,known)));   % 1	number of frames spent in familiar arms
    YM(4,1)=sum(quadrant(:,novel));   % 1	number of frames spent in the novel arm
    YM(5,1)=max(behave(:,1))-YM(3,1)-YM(4,1); % 1	number of frames spent in the middle

    %% Left arm spiking outputs
    YM(1,2)=YM(1,1)./framerate_bh;    % 2 seconds spent in left arm
    YM(1,3)=sum(indL); % 	3	total number of peaks that occur in left arm
    YM(1,4)=nanmean(final_peakdata(indL,3)); % 	4	mean amplitude of peaks that occur in left arm
    YM(1,5)=nanstd(final_peakdata(indL,3));% 	5	amplitude STD
    YM(1,6)=nanmean(final_peakdata(indL,4)); % 	6	mean peak width for peaks that occur in left arm
    YM(1,7)=nanstd(final_peakdata(indL,4));% 	7	Width STD
    temp=unique(final_peakdata(indL,1));
    YM(1,8)=size(temp,1); % 	8	Number of unique cells that fire in left arm
    YM(1,9)=YM(1,8)/nCells*100;  % 	9	Percentage of all cells that fire in left arm (participation)
    YM(1,10)=YM(1,3)./YM(1,2);% 	10	Overall firing Freq (spike/sec)

    %% Right arm spiking outputs
    YM(2,2)=YM(2,1)./framerate_bh; % 2 seconds spent in the right arm
    YM(2,3)=sum(indR); % 	3	total number of peaks that occur in the right arm
    YM(2,4)=nanmean(final_peakdata(indR,3)); % 	4	mean amplitude of peaks that occur in the right arm
    YM(2,5)=nanstd(final_peakdata(indR,3));% 	5	amplitude STD
    YM(2,6)=nanmean(final_peakdata(indR,4)); % 	6	mean peak width for peaks that occur in the right arm
    YM(2,7)=nanstd(final_peakdata(indR,4));% 	7	Width STD
    temp=unique(final_peakdata(indR,1));
    YM(2,8)=size(temp,1); % 	8	Number of unique cells that fire in the right arm
    YM(2,9)=YM(2,8)/nCells*100;  % 	9	Percentage of all cells that fire in the right arm (participation)
    YM(2,10)=YM(2,3)./YM(2,2);% 	10	Overall firing Freq (spike/sec)

     %% Familiar arms spiking outputs
    YM(3,2)=YM(3,1)./framerate_bh; % 2 seconds spent in the familiar arms
    YM(3,3)=sum(indF); % 	3	total number of peaks that occur in the familiar arms
    YM(3,4)=nanmean(final_peakdata(indF,3)); % 	4	mean amplitude of peaks that occur in the familiar arms
    YM(3,5)=nanstd(final_peakdata(indF,3));% 	5	amplitude STD
    YM(3,6)=nanmean(final_peakdata(indF,4)); % 	6	mean peak width for peaks that occur in the familiar arms
    YM(3,7)=nanstd(final_peakdata(indF,4));% 	7	Width STD
    temp=unique(final_peakdata(indF,1));
    YM(3,8)=size(temp,1); % 	8	Number of unique cells that fire in the familiar arms
    YM(3,9)=YM(3,8)/nCells*100;  % 	9	Percentage of all cells that fire in the familiar arms (participation)
    YM(3,10)=YM(3,3)./YM(3,2);% 	10	Overall firing Freq (spike/sec)

    %% Novel arm spiking outputs
    YM(4,2)=YM(4,1)./framerate_bh; % 2 seconds spent in the novel arm
    YM(4,3)=sum(indN); % 	3	total number of peaks that occur in the novel arm
    YM(4,4)=nanmean(final_peakdata(indN,3)); % 	4	mean amplitude of peaks that occur in the novel arm
    YM(4,5)=nanstd(final_peakdata(indN,3));% 	5	amplitude STD
    YM(4,6)=nanmean(final_peakdata(indN,4)); % 	6	mean peak width for peaks that occur in the novel arm
    YM(4,7)=nanstd(final_peakdata(indN,4));% 	7	Width STD
    temp=unique(final_peakdata(indN,1));
    YM(4,8)=size(temp,1); % 	8	Number of unique cells that fire in the novel arm
    YM(4,9)=YM(4,8)/nCells*100;  % 	9	Percentage of all cells that fire in the novel arm (participation)
    YM(4,10)=YM(4,3)./YM(4,2);% 	10	Overall firing Freq (spike/sec)

     %% Middle spiking outputs
    YM(5,2)=YM(5,1)./framerate_bh; % 2 seconds spent in the middle
    YM(5,3)=sum(indM); % 	3	total number of peaks that occur in the middle
    YM(5,4)=nanmean(final_peakdata(indM,3)); % 	4	mean amplitude of peaks that occur in the middle
    YM(5,5)=nanstd(final_peakdata(indM,3));% 	5	amplitude STD
    YM(5,6)=nanmean(final_peakdata(indM,4)); % 	6	mean peak width for peaks that occur in the middle
    YM(5,7)=nanstd(final_peakdata(indM,4));% 	7	Width STD
    temp=unique(final_peakdata(indM,1));
    YM(5,8)=size(temp,1); % 	8	Number of unique cells that fire in the middle
    YM(5,9)=YM(5,8)/nCells*100;  % 	9	Percentage of all cells that fire in the middle (participation)
    YM(5,10)=YM(5,3)./YM(5,2);% 	10	Overall firing Freq (spike/sec)

    %%   
    
%     ALL_YM2=cat(1,ALL_YM2,YM);  %Concatenates YM fam/nov data for all animals into a single array, odd rows = familiar arms, even rows = novel arm
%     
%     %% Cell activity per category
%     
%     cell_stats=[];
%     for iCell=NeuKeep
%         row = find(NeuKeep == iCell);
%         cell_stats(row,1)=iCell; %Number of selected cell in c1
%         ind=final_peakdata(:,1)==iCell; %Finds all peaks corresponding to current cell
%         cell_stats(row,2)=sum(ind); %Number of peaks corresponding to the cell in c2 of cell_stats
%         ind=final_peakdata(:,1)==iCell & final_peakdata(:,12)==left; %Finds peaks the current cell fires while in left arm
%         cell_stats(row,4)=sum(ind); %Number of peaks the current cell fires while in left arm in c4 of cell_stats
%         ind=final_peakdata(:,1)==iCell & final_peakdata(:,12)==right; %Finds peaks the current cell fires while in right arm
%         cell_stats(row,5)=sum(ind); %Number of peaks the current cell fires while in right arm in c5 of cell_stats
%         ind=final_peakdata(:,1)==iCell & [final_peakdata(:,12)==left | final_peakdata(:,12)==right]; %Finds peaks the current cell fires while in familiar arms
%         cell_stats(row,6)=sum(ind); %Number of peaks the current cell fires while in familiar arms in c6 of cell_stats
%         ind=final_peakdata(:,1)==iCell & final_peakdata(:,12)==novel; %Finds peaks the current cell fires while in the novel arm
%         cell_stats(row,7)=sum(ind); %Number of peaks the current cell fires while in novel arm in c7 of cell_stats
%         ind=final_peakdata(:,1)==iCell & final_peakdata(:,12)==middle; %Finds peaks the current cell fires while in the middle
%         cell_stats(row,8)=sum(ind); %Number of peaks the current cell fires while in novel arm in c8 of cell_stats
%     end
%     
%     %% % spikes in each zone
%     
%     cell_stats(:,10)=cell_stats(:,4)./cell_stats(:,2)*100; %c10 = Percentage of peaks fired by each cell which occur in the left arm
%     cell_stats(:,11)=cell_stats(:,5)./cell_stats(:,2)*100; %c11 = Percentage of peaks fired by each cell which occur in the right arm
%     cell_stats(:,12)=cell_stats(:,6)./cell_stats(:,2)*100; %c12 = Percentage of peaks fired by each cell which occur in the familiar arms
%     cell_stats(:,13)=cell_stats(:,7)./cell_stats(:,2)*100; %c13 = Percentage of peaks fired by each cell which occur in the novel arm
%     cell_stats(:,14)=cell_stats(:,8)./cell_stats(:,2)*100; %c14 = Percentage of peaks fired by each cell which occur in the middle
% 
% 
%     Scell_stats=sortrows(cell_stats,10,'descend'); %Sorts cells by percentage of spiking that occur in left arm
%     ind =Scell_stats(:,2)<10; %Only cells that fire more than 10 times are considered.
%     Scell_stats(ind,:)=[];
%     ind = Scell_stats(:,10)<=50; %Only cells that fire more than 50% of the time while the animal is in the left arm are considered.
%     Scell_stats(ind,:)=[];
% 
%     filename='Scell_statsLeft'; %c1: Cell number, c2: peaks corresponding to the cell, c4: peaks cell fires while in left arm, c5: peaks cell fires while in right arm, c6: peaks cell fires while in fam arms, c7: peaks cell fires while in nov arm, c8: peaks cell fires while in middle,
%     %c10: percentage of peaks in left arm, c11:percentage of peaks in right arm, c12: percentage of peaks in familiar arms, 13: percentage of peaks in nov arm, c14: percentage of peaks in middle
%     save (filename,'Scell_stats')
% 
%     Scell_stats=sortrows(cell_stats,11,'descend'); %Sorts cells by percentage of spiking that occur in right arm
%     ind =Scell_stats(:,2)<10; %Only cells that fire more than 10 times are considered.
%     Scell_stats(ind,:)=[];
%     ind = Scell_stats(:,11)<=50; %Only cells that fire more than 50% of the time while the animal is in the right arm are considered.
%     Scell_stats(ind,:)=[];
% 
%     filename='Scell_statsRight'; %c1: Cell number, c2: peaks corresponding to the cell, c4: peaks cell fires while in left arm, c5: peaks cell fires while in right arm, c6: peaks cell fires while in fam arms, c7: peaks cell fires while in nov arm, c8: peaks cell fires while in middle,
%     %c10: percentage of peaks in left arm, c11:percentage of peaks in right arm, c12: percentage of peaks in familiar arms, 13: percentage of peaks in nov arm, c14: percentage of peaks in middle
%     save (filename,'Scell_stats')
% 
%     Scell_stats=sortrows(cell_stats,12,'descend'); %Sorts cells by percentage of spiking that occur in familiar arms
%     ind =Scell_stats(:,2)<10; %Only cells that fire more than 10 times are considered.
%     Scell_stats(ind,:)=[];
%     ind = Scell_stats(:,12)<=50; %Only cells that fire more than 50% of the time while the animal is in the familiar arms are considered.
%     Scell_stats(ind,:)=[];
% 
%     filename='Scell_statsFamiliar'; %c1: Cell number, c2: peaks corresponding to the cell, c4: peaks cell fires while in left arm, c5: peaks cell fires while in right arm, c6: peaks cell fires while in fam arms, c7: peaks cell fires while in nov arm, c8: peaks cell fires while in middle,
%     %c10: percentage of peaks in left arm, c11:percentage of peaks in right arm, c12: percentage of peaks in familiar arms, 13: percentage of peaks in nov arm, c14: percentage of peaks in middle
%     save (filename,'Scell_stats')
% 
%     Scell_stats=sortrows(cell_stats,13,'descend'); %Sorts cells by percentage of spiking that occur in novel arm
%     ind =Scell_stats(:,2)<10; %Only cells that fire more than 10 times are considered.
%     Scell_stats(ind,:)=[];
%     ind = Scell_stats(:,13)<=50; %Only cells that fire more than 50% of the time while the animal is in the novel arm are considered.
%     Scell_stats(ind,:)=[];
% 
%     filename='Scell_statsNovel'; %c1: Cell number, c2: peaks corresponding to the cell, c4: peaks cell fires while in left arm, c5: peaks cell fires while in right arm, c6: peaks cell fires while in fam arms, c7: peaks cell fires while in nov arm, c8: peaks cell fires while in middle,
%     %c10: percentage of peaks in left arm, c11:percentage of peaks in right arm, c12: percentage of peaks in familiar arms, 13: percentage of peaks in nov arm, c14: percentage of peaks in middle
%     save (filename,'Scell_stats')
% 
%     Scell_stats=sortrows(cell_stats,14,'descend'); %Sorts cells by percentage of spiking that occur in middle
%     ind =Scell_stats(:,2)<10; %Only cells that fire more than 10 times are considered.
%     Scell_stats(ind,:)=[];
%     ind = Scell_stats(:,14)<=50; %Only cells that fire more than 50% of the time while the animal is in the middle are considered.
%     Scell_stats(ind,:)=[];
% 
%     filename='Scell_statsMiddle'; %c1: Cell number, c2: peaks corresponding to the cell, c4: peaks cell fires while in left arm, c5: peaks cell fires while in right arm, c6: peaks cell fires while in fam arms, c7: peaks cell fires while in nov arm, c8: peaks cell fires while in middle,
%     %c10: percentage of peaks in left arm, c11:percentage of peaks in right arm, c12: percentage of peaks in familiar arms, 13: percentage of peaks in nov arm, c14: percentage of peaks in middle
%     save (filename,'Scell_stats')

    %%%%%%%%%%%%%%%%%%%%%%%

    save final_peakdata 'final_peakdata'  % Adds column 12 = Indicates which arm animal was in was when peak fired, Left [c = 1], Right [c = 2], Novel [c = 3], Middle [c = 0]
    save arm_frames 'quadrant' %array compiling the arm locations for each behavioural frame. c1 = L, c2 = R, c3 = N
    save arm_time 't_q' %c1 = Time in L, c2= Time in R, c3= Time in N, c4=Time in centre
    save framerate_bh 'framerate_bh' %Save framerate specific to behavioural recording
    filename = 'YM_Firing_data';  %See line 88 for column info, row 1 = familiar arms, row 2 = novel arm
    save (filename, 'YM');
    
    cd ..
end

%%


