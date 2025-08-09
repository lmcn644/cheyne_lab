
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
    animal=animals(iAnimal).name;
    folder=animal;
    cd(folder)
    load behave
    load scope
    scope(scope == 0) = NaN;
    load final_peakdata
    load framerate
    load framerate_bh
    load nFrames
    load nCells
    load NeuKeep
%     load quad_stats
    load arm_time
    load arm_frames
    nLocs=size(behave,1); %Number of distinct locations (frames) the animal occupies in the recording.

    TotalTime = size(behave,1)/framerate_bh; %Total time in seconds
    t_q(2,:) = t_q(1,:)/TotalTime; %Row 2 of t_q = Occupancy probability

    %% Adds column for when animal is in the centre of the maze
    q = quadrant;
    for i = 1:size(quadrant,1)
        if sum(quadrant(i,:)) == 1
            q(i,4) = 0;
        else
            q(i,4) = 1;
        end
    end

    %%

    cell_stats=[];

    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        if isempty(row) == 0
        cell_stats(row,1)=iCell; %Cell number
        ind=final_peakdata(:,1)==iCell; %Creates an index finding all peaks corresponding to that cell
        cell_stats(row,2)=sum(ind); % Number of times current cell fires
        cell_stats(row,3)=cell_stats(row,2)/TotalTime; %Overall firing rate of current cell

        ind=final_peakdata(:,1)==iCell & final_peakdata(:,12)==1; %Index for peaks that fire in the L arm
        cell_stats(row,4)=sum(ind); %Number of times current cell fires in L arm
        cell_stats(row,5) = cell_stats(row,4)/t_q(1,1); %Frequency cell fires at (peaks/s) within L arm

        ind=final_peakdata(:,1)==iCell & final_peakdata(:,12)==2; %Index for peaks that fire in the R arm
        cell_stats(row,6)=sum(ind);  %Number of times current cell fires in R arm
        cell_stats(row,7) = cell_stats(row,6)/t_q(1,2); %Frequency cell fires at (peaks/s) within R arm

        ind=final_peakdata(:,1)==iCell & final_peakdata(:,12)==3; %Index for peaks that fire in the N arm
        cell_stats(row,8)=sum(ind);  %Number of times current cell fires in N arm
        cell_stats(row,9) = cell_stats(row,8)/t_q(1,3); %Frequency cell fires at (peaks/s) within N arm

        ind=final_peakdata(:,1)==iCell & final_peakdata(:,12)==0; %Index for peaks that fire in the centre
        cell_stats(row,10)=sum(ind);  %Number of times current cell fires in centre
        cell_stats(row,11) = cell_stats(row,10)/t_q(1,4); %Frequency cell fires at (peaks/s) within centre
        else
        end
    end

    ind = cell_stats(:,3) < 0.02;  % Only cells with an overall firing rate above 0.02 Hz can be considered as place cells
    cell_stats(ind,:) = [];

    PotPlc = cell_stats(:,1)'; %Cell numbers of potential place cells

    if ~isempty(PotPlc)

    %% matrices for each bin
    OverallData = cell_stats(:,1:3);
    LData = [cell_stats(:,1),cell_stats(:,4:5)];
    RData = [cell_stats(:,1),cell_stats(:,6:7)];
    NData = [cell_stats(:,1),cell_stats(:,8:9)];
    CData = [cell_stats(:,1),cell_stats(:,10:11)];

    %% L BIN

    for iCell=PotPlc
        row = find(PotPlc == iCell);
        LData(row,4) = t_q(2,1)*(LData(row,3)/OverallData(row,3))*log2((LData(row,3)/OverallData(row,3))); %Spatial information (bits/spike)
%         TLData(row,5) = (t_q(2,1)*(TLData(row,3)^2))/(OverallData(row,3)^2); % Sparsity (relative proportion of maze the cell has fired on)
    end

    %% R BIN

    for iCell=PotPlc
        row = find(PotPlc == iCell);
        RData(row,4) = t_q(2,2)*(RData(row,3)/OverallData(row,3))*log2((RData(row,3)/OverallData(row,3))); %Spatial information (bits/spike)
%         BLData(row,5) = (t_q(2,2)*(BLData(row,3)^2))/(OverallData(row,3)^2); % Sparsity (relative proportion of maze the cell has fired on)
    end


    %% N BIN

    for iCell=PotPlc
        row = find(PotPlc == iCell);
        NData(row,4) = t_q(2,3)*(NData(row,3)/OverallData(row,3))*log2((NData(row,3)/OverallData(row,3))); %Spatial information (bits/spike)
%         TRData(row,5) = (t_q(2,3)*(TRData(row,3)^2))/(OverallData(row,3)^2); % Sparsity (relative proportion of maze the cell has fired on)
    end

    %% C BIN

    for iCell=PotPlc
        row = find(PotPlc == iCell);
        CData(row,4) = t_q(2,4)*(CData(row,3)/OverallData(row,3))*log2((CData(row,3)/OverallData(row,3))); %Spatial information (bits/spike)
%         BRData(row,5) = (t_q(2,4)*(BRData(row,3)^2))/(OverallData(row,3)^2); % Sparsity (relative proportion of maze the cell has fired on)
    end

%%%%%%%%%%%%%%%%%%%%%%%%

    %% Peak Shuffling to validate place cells

    rng('shuffle'); %set randomisation mode to shuffle
    bFrames = max(behave(:,1)); % total number of behavioural frames

    for iCell=PotPlc

        row = find(PotPlc == iCell);
        ind = final_peakdata(:,1) == iCell;
        realpeaks = final_peakdata(ind,11); %gets behavioural frames of real peaks from current cell

        totalrandpeaks = [];
        while size(totalrandpeaks,2) < 5000  %adjust shuffling size here
            randpeaks = sort(randperm(bFrames,size(realpeaks,1)))'; % Shifts all peaks to random frames
            totalrandpeaks = cat(2,totalrandpeaks,randpeaks); % Shuffling is repeated 5000 times, each column = one group of shuffled peaks
        end

        randquad = [];
        for i = 1:size(totalrandpeaks,2)
            for iPeak=1:size(realpeaks,1)
                loc=totalrandpeaks(iPeak,i); %behavioural frame for current shuffled peak
                [rowloc,c] = find(behave(:,1) == loc); %compensates for frame drops during recordings
                if isempty(rowloc)
                    [M,I] = min(abs(behave(:,1)-loc)); %If behavioural frame was deleted from original DLC output, just take closest frame
                    rowloc = behave(I,1);
                    quad=q(rowloc,:);
                    [r c]=find(quad==1);
                    randquad(iPeak,i)=c;
                else
                    quad=q(rowloc,:); %determines which quadrant animal is in during current shuffled peak
                    [r c]=find(quad==1);
                    if isempty(c)  %Slight frame adjustment to account for rare instances of poor tracking
                        quad = q(rowloc-1,:);
                        [r c]=find(quad==1);
                    end
                    randquad(iPeak,i)=c;  %what quadrant they are in during shuffled spike
                end
            end %% L = 1, R = 2, N = 3, C = 4 %%
        end

        randquad_stats=[];
        for i = 1:size(totalrandpeaks,2)
            for iQuad=1:4
                ind=randquad(:,i)==iQuad; %creates index indicating number of times there is a shuffled peak for a particular quadrant
                randquad_stats(iQuad,i)=sum(ind);% count event number for each quadrant,  %% L = r1, R = r2, N = r3, C = r4
            end
        end

        for i = 1:4
            randquad_stats(i,:) = randquad_stats(i,:)/t_q(1,i); %Converts to peaks/sec for each quadrant
        end

        randquad_SI = [];
        SIcutoff = [];
%         randquad_spars = [];
%         sparscutoff = [];

        for j = 1:4
            for i = 1:size(totalrandpeaks,2)
                randquad_SI(j,i) = t_q(2,j)*(randquad_stats(j,i)/OverallData(row,3))*log2((randquad_stats(j,i)/OverallData(row,3))); %Spatial information (bits/spike) for all shuffled data
%                 randquad_spars(j,i) = (t_q(2,j)*(randquad_stats(j,i)^2))/(OverallData(row,3)^2); % Sparsity for all shuffled data (relative proportion of maze the cell has fired on)
            end
            randquad_SI(isnan(randquad_SI)) = 0; %turn NaNs to 0s
            SIcutoff(j,1) = prctile(randquad_SI(j,:),99); %Gives cutoff for the 99th percentile of SI, based on data shuffled 5000x
            %             sparscutoff(j,1) = prctile(randquad_spars(j,:),25); %Gives cutoff for the 25th percentile of sparsity, based on data shuffled 5000x
        end

        LData(row,6) = SIcutoff(1,1); % c6 =  99th percentile of shuffled SIs for a cell in left arm
        RData(row,6) = SIcutoff(2,1); % c6 =  99th percentile of shuffled SIs for a cell in right arm
        NData(row,6) = SIcutoff(3,1); % c6 =  99th percentile of shuffled SIs for a cell in novel
        CData(row,6) = SIcutoff(4,1); % c6 =  99th percentile of shuffled SIs for a cell in centre

    end

    LData(:,7) = LData(:,4)>=LData(:,6); %If cell's real SI is at or above the 99th percentile for L
    RData(:,7) = RData(:,4)>=RData(:,6); %If cell's real SI is at or above the 99th percentile for R
    NData(:,7) = NData(:,4)>=NData(:,6); %If cell's real SI is at or above the 99th percentile for N
    CData(:,7) = CData(:,4)>=CData(:,6); %If cell's real SI is at or above the 99th percentile for centre

    ind = LData(:,7) == 1;
    LPlc = LData(ind,:);

    ind = RData(:,7) == 1;
    RPlc = RData(ind,:);
    RPlc(:,7) = 2; 

    ind = NData(:,7) == 1;
    NPlc = NData(ind,:);
    NPlc(:,7) = 3;

    ind = CData(:,7) == 1;
    CPlc = CData(ind,:);
    CPlc(:,7) = 4;

    PlaceCells = sortrows([LPlc; RPlc; NPlc; CPlc]); %c7 now indicates which quadrant the cell is specific to: %% L = r1, R = r2, C = r3, N = r4

    %% Checks if any cells are specific to more than one quadrant and removes them

    [C,ia,ic] = unique(PlaceCells(:,1));
    a_counts = accumarray(ic,1);
    value_counts = [C, a_counts];  %counts how many times each unique cell is classified as a place cell, if it's a real place cell, it should only be specific to 1 quadrant

    check = find(value_counts(:,2) > 1); %checks if cell is specific to more than 1 quadrant
    dup = isempty(check); % If there are no repeats, this will == 1

    if dup == 0

        remove = value_counts(check,1);  %removes duplicate cells from PlaceCell array
        ind = ismember(PlaceCells(:,1),remove);
        PlaceCells(ind,:) = [];

    else
    end

    %%%%%%%%%%%%%%%%%%%%%%

    %% plot most location specific place cells

        SPlaceCells=sortrows(PlaceCells,4,'descend'); %sorts cells by spatial information

        if size(SPlaceCells,1) < 10   %Restricts the loop to the number of place cells there actually are, if the number is less than 10
            loop = 1:size(SPlaceCells,1);
        else
            loop = 1:10;
        end

        %% plot 10 most location specific cells
        cmap = jet(10);
        close all;

        for ii = loop  %for the 10 most location-specific cells
            iCell=SPlaceCells(ii,1); %Ensures top 10 cells are selected  

                figure
                of=zeros(max(behave(:,4))+20,max(behave(:,5))+20);
                for i=1:nLocs      % add animal path
                    x=behave(i,4);
                    y=behave(i,5);
                    if ~isnan(x) & ~isnan(y)
                        of(y,x)=5; %Creates plots for animal locomotion
                    end
                end
                [r2 c2]=find(final_peakdata(:,1)==iCell); %Finds all peaks corresponding to the cell of interest
                for i=1:size(r2,1); % add cell firing
                    j=r2(i,1); %rows corresponding to the peaks fired by the cell
                    frame=final_peakdata(j,10); %Identifies corrected scope frames corresponding to peak for this cell
                    loc=final_peakdata(j,11); %Identifies behavioural frames corresponding to peak for this cell
                    loc = find(behave(:,1) == loc,1);
                    if ~isempty(loc)
                        [M,I] = min(abs(behave(:,1)-min(final_peakdata(j,11))));
                        loc = behave(I,1);
                    end
                    loccheck = size(behave,1)-loc;
                    if loccheck<=0
                        loc = size(behave,1);
                    end
                    of(behave(loc,5),behave(loc,4))=50; %Following lines create a large point around behavioural coordinate where the peak is fired for the cell
                    of(behave(loc,5)-1,behave(loc,4))=50;
                    of(behave(loc,5)-1,behave(loc,4)-1)=50;
                    of(behave(loc,5),behave(loc,4)-1)=50;
                    of(behave(loc,5)+1,behave(loc,4))=50;
                    of(behave(loc,5)+1,behave(loc,4)+1)=50;
                    of(behave(loc,5),behave(loc,4)+1)=50;
                    of(behave(loc,5)-1,behave(loc,4)+1)=50;
                    of(behave(loc,5)+1,behave(loc,4)-1)=50;

                end

                row = find(cell_stats(:,1) == iCell); %row in cell_stats corresponding to current cell
                imshow(of,cmap)
                title({['Cell: ',int2str(iCell),'   Number of Peaks: ',int2str(cell_stats(row,2))] ...
                    ['   SI: ',num2str(SPlaceCells(ii,4))]},'FontSize',14);
                %filename = sprintf(['10 most location specific','%d.eps']);
                %saveas(gcf,filename,'epsc'); % save
            %pause
            % close all
        end

        %Saves 10 most location-specific cells in tiled figure

        nfig = findobj('type','figure');
        nfig = size(nfig,1);

        figlist = get(groot,'Children');
        figlist = flip(figlist,1);
        newfig = figure;
        tcl=tiledlayout(newfig,'flow');
        for i = 1:nfig
            figure(figlist(i));
            ax=gca;
            ax.Parent=tcl;
            ax.Layout.Tile=i;
        end

        tcl.TileSpacing = 'tight';
        tcl.Padding = 'compact';
        graphtitle = title(tcl,'Cells Exhibiting Highest Location-Specific Firing', newline);
        graphtitle.FontSize =20;

        close(1:nfig);
        fig = figure(nfig+1);
        fig.WindowState = 'maximized';
        filename = sprintf(['10 most location specific','%d.png']);
        saveas(gcf,filename,'png'); % save

        close all

        %% overlay the 10 most location specific cells
%             figure
%             cmap = jet(120);
%             of=zeros(max(behave(:,4))+20,max(behave(:,5))+20);
%         
%             for i=1:nLocs     % add animal path
%                 x=behave(i,4);
%                 y=behave(i,5);
%                 if ~isnan(x) & ~isnan(y)
%                     of(y,x)=10;
%                 end
%             end
%         
%             for ii=loop;
%                 iCell=SPlaceCells(ii,1);
%            
%                 [r2 c2]=find(final_peakdata(:,1)==iCell);
%                 for i=1:size(r2,1); % add cell firing
%                     j=r2(i,1);
%                     frame=final_peakdata(j,10);
%                     loc=final_peakdata(j,11);
%                     loc = find(behave(:,1) == loc,1);
%                     if ~isempty(loc)
%                         [M,I] = min(abs(behave(:,1)-min(final_peakdata(j,11))));
%                         loc = behave(I,1);
%                     end
%                     loccheck = size(behave,1)-loc;
%                     if loccheck<=0
%                         loc = size(behave,1);
%                     end
%                     of(behave(loc,5),behave(loc,4))=10*ii+20;  %lines are multiplied by iteration number to create a distinct colour for each cell.
%                     of(behave(loc,5)-1,behave(loc,4))=10*ii+20;
%                     of(behave(loc,5)-1,behave(loc,4)-1)=10*ii+20;
%                     of(behave(loc,5),behave(loc,4)-1)=10*ii+20;
%                     of(behave(loc,5)+1,behave(loc,4))=10*ii+20;
%                     of(behave(loc,5)+1,behave(loc,4)+1)=10*ii+20;
%                     of(behave(loc,5),behave(loc,4)+1)=10*ii+20;
%                     of(behave(loc,5)-1,behave(loc,4)+1)=10*ii+20;
%                     of(behave(loc,5)+1,behave(loc,4)-1)=10*ii+20;
%         
%                 end
%                 imshow(of ,cmap)
%            
%             end

        %% plot ROIs

        %% Open needed.mat
        folderlist=dir('*extraction');
        cd(folderlist(1).name)
        folderlist=dir('frames*');
        cd(folderlist(1).name)
        folderlist=dir('LOGS*');
        cd(folderlist(1).name)
        needfile = dir('needed.mat'); %generate this using cnmfe_outputs.m
        needfile = needfile(1,:);
        needfile = needfile.name;
        load ([needfile]);

        cd ..
        cd ..
        cd ..
        %%%

        plotControl.Cn=Cn;
        plotControl.thr=0.95;
        plotControl.option=1;
        d1=size(Cn,1);
        d2=size(Cn,2);
        %cd ..

        %%

        if size(SPlaceCells,1) < 10   %Restricts to the number of place cells there actually are, if the number is less than 10
            selected=SPlaceCells(1:size(SPlaceCells,1),1);
        else
            selected=SPlaceCells(1:10,1); %Gives numbers of the top 10 most location-specific neurons
        end

        cells=size(C,1);  %All neuronal signals identified in CNMF_E
        %         %load A
        row = find(NeuKeep == iCell);

        %Loop creates index for final_peakdata to select only the top 10 most location-specific neurons
        ind=[];
        for iCell=1:cells; %for all cells
            if ismember(iCell,selected); %If current iteration is for a cell in the top 10
                ind(iCell,1)=1;
            else
                ind(iCell,1)=0;
            end
        end
        ind= logical( ind );
        B=A(:,ind); %Creates variable for spatial neuronal data only for the top 10 most location-specific neurons

        [coor, contourInfo] = plotROIContour( B, d1, d2, plotControl ); %%third-party function that plots contours for top 10 most location-specific neurons
        filename = sprintf(['Location specific neuron contours','%d.png']);
        saveas(gcf,filename,'png'); % save
        close all
% 
%             % Sorted raster (least to most location specific)
%         
%             figure
%             hold on
%             for i=SPlaceCells(:,1)'
%                 ind=final_peakdata(:,1)==i;
% 
%                 row = find(SPlaceCells(:,1) == i);
% 
%                 if sum(ind)>0
%                     scatter(final_peakdata(ind,2),repmat(row,sum(ind),1),'*')  %%Creates scatterplot of all cells, organised by location-specificity (most location specific at the bottom)
%                 end
%             end

    save PlaceCells 'PlaceCells' % c1 = cell number, c2 = number of peaks in specific arm, c3 = firing frequency in specific arm, c4 = spatial info in specific arm, c6 = spatial info cutoff for 99th percentile of shuffled data, c7 = arm the cell is specific to
    save arm_cell_stats 'cell_stats' % c1 = cell number, c2 = number of times cell fires, c3 = Overall firing rate, c4 = peaks in L arm, c5 = firing rate in L arm, c6 = peaks in R arm, c7 = firing rate in R arm, c8 = peaks in N arm, c9 = firing rate in N arm, c10 = peaks in centre, c11 = firing rate in centre
    save arm_firing_specificity 'LData' 'RData' 'NData' 'CData' % c1 = cell number, c2 = number of peaks in specific arm, c3 = firing frequency in specific arm, c4 = spatial info in specific arm, c6 = spatial info cutoff for 99th percentile of shuffled data, c7 = Logical index for whether cell qualifies as place cell
    
    else 
        NoPlaceCells = [];
        save NoPlaceCells 'NoPlaceCells'
    end
    
    cd ..

end