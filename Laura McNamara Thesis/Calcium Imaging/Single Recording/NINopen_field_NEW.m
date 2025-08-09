%% Neuronal firing analysis in open field

clear; clc; close all;

%%
animals=dir;
animals(1:2,:)=[];
animals = natsortfiles(animals);
nAnimals=size(animals,1);
for iAnimal = 1:nAnimals;
    iAnimal
    tic
    animals=dir;
    animals(1:2,:)=[];
    animals = natsortfiles(animals);
    animal=animals(iAnimal).name;
    folder=animal;
    cd(folder)
    load behave
    load scope
    load framerate
    load duration
    load nCells
    load NeuKeep
    load final_peakdata
    nLocs=size(behave,1); %Number of distinct locations (frames) the animal occupies in the recording.

     %% Loads in int vs ext data from DeepLabCut output
% 
%     filelist=dir('*ROIoutput.xlsx');
%     d1 = readtable(filelist(1).name, 'readvariablenames', false);
%     % get interior
%     num = d1(1:end,4);
%     num=num{:,:};
% 
%     if size(num,1)<nLocs;  %extends interior position logical array to fit with behave.mat.
%         num(end:nLocs,1)=0;
%     end
% 
%     behave(:,7)=num;  %c7 of behave.mat is now array for inner vs outer.

    filelist=dir('*resnet*.csv'); %Use DeepLabCut for coordinates
    d1 = readtable(filelist(1).name, 'readvariablenames', false);

    %%%%%%%%%%%

    folderlist=dir('*quads');  %% Ensure ROI outputs for quadrants are stored in a folder called /quads
    cd(folderlist(1).name)

    filelist=dir('*ROIoutput.xlsx');
    d2 = readtable(filelist(1).name, 'readvariablenames', false);

    cd ..

    d2 = table2array(d2);
    q = d2(:,4:7); %array compiling the quadrant locations

    %% Loads in int vs ext data from eztrack output

    %     filelist=dir('*LocationOutput.csv');
    %     d1 = readtable(filelist(1).name, 'readvariablenames', false);
    %     % get interior
    %     num=d1(2:nLocs,10);  %eztrack output determining whether it's true if the animal is in the interior or not.
    %     num=num{:,:};
    %
    %     %converts output to logical array
    %     num = strrep(num,'TRUE','1');
    %     num = strrep(num,'FALSE','0');
    %     num = str2double(num);
    %     num(isnan(num)) = [];
    %     num = logical(num);
    %
    %
    %     if size(num,1)<nLocs;
    %         num(end:nLocs,1)=0;  %extends interior position logical array to fit with behave.mat.
    %     end
    %     behave(:,7)=num;  %c7 of behave.mat is now array for inner vs outer.


    %% Frames in each quadrant for DLC

%     % Defining maximal and centre coordinates
%     x_left = min(behave(:,4));
%     x_right = max(behave(:,4));
%     y_top = min(behave(:,5));
%     y_bottom = max(behave(:,5));
%     x_centre = round((x_right+x_left)/2);
%     y_centre = round((y_bottom+y_top)/2);

    %% Verifies coordinates are in the correct positions%%%

    % TL = [x_left y_top];
    % BL = [x_left y_bottom];
    % TR = [x_right y_top];
    % BR = [x_right y_bottom];
    % Centre = [x_centre y_centre];
    % Key_coords = [TL; BL; TR; BR; Centre];

    % ncoords = size(Key_coords,1)
    % figure
    % cmap = [1 1 1;parula(ncoords)]
    % of=zeros(max(behave(:,4))+20,max(behave(:,5))+20);
    %
    % for i= 1:ncoords
    %         xcoords=Key_coords(i,1); %X coords
    %         ycoords=Key_coords(i,2); %y coords
    %         if ~isnan(xcoords) & ~isnan(ycoords)  %Provided these values ARE NOT NAN, colour inserted at that coordinate
    %             of(ycoords,xcoords)=i+1; %+1 so first pixel isn't white
    %         end
    %     end
    %
    %     trace = imshow(of(10:end,10:end),cmap);
    %
    %     hold on
    %     axis on
    %     cb = colorbar;
    %     cb.Label.String = 'Coordinates';
    %     cb.Label.FontSize = 12;
    %     title(['Key Coordinates'],'FontSize',14);

    %% way of generating quadrants if it wasn't done with behavioural data
% 
%     ind = behave(:,4)>=x_left & behave(:,4)<x_centre & behave(:,5)>=y_top & behave(:,5)<y_centre;
%     Q_TL = [];
%     Q_TL = ind;
%     ind = behave(:,4)>=x_left & behave(:,4)<x_centre & behave(:,5)>=y_centre & behave(:,5)<=y_bottom;
%     Q_BL = [];
%     Q_BL = ind;
%     ind = behave(:,4)>=x_centre & behave(:,4)<=x_right & behave(:,5)>=y_top & behave(:,5)<y_centre;
%     Q_TR = [];
%     Q_TR = ind;
%     ind = behave(:,4)>=x_centre & behave(:,4)<=x_right & behave(:,5)>=y_centre & behave(:,5)<=y_bottom;
%     Q_BR = [];
%     Q_BR = ind;
% 
%     q = [Q_TL Q_BL Q_TR Q_BR]; %array compiling the quadrant locations

    %% Confirming quadrants %%
    nLocs=size(behave,1);
    figure
    cmap = [1 1 1;jet(4)];
    of=zeros(max(behave(:,4))+20,max(behave(:,5))+20);
%     verify = Q_TL + Q_BL + Q_TR + Q_BR;
%     if size(find(verify==1),1) == size(1:nLocs,2); %checks to ensure animal is only ever occupying a single quadrant at a time.
        for i = 1:nLocs %used to generate a figure that verifies the quadrants
            x_coords = behave(i,4);
            y_coords = behave(i,5);
            if q(i,1) == 1 & q(i,2) == 0 & q(i,3) == 0 & q(i,4) == 0
                of(y_coords,x_coords) = 2;
            elseif q(i,1) == 0 & q(i,2) == 1 & q(i,3) == 0 & q(i,4) == 0
                of(y_coords,x_coords) = 3;
            elseif q(i,1) == 0 & q(i,2) == 0 & q(i,3) == 1 & q(i,4) == 0
                of(y_coords,x_coords) = 4;
            elseif q(i,1) == 0 & q(i,2) == 0 & q(i,3) == 0 & q(i,4) == 1
                of(y_coords,x_coords) = 5;
            else
            end
        end
%     else
%         disp("Verify boundary coordinates, animal occupies more than one quadrant at a time.");
%         return
%     end
    postrace = imshow(of(10:end,10:end),cmap);
    pause
    close all

    %% Calculate the total time in each quadrant

    framerate_bh = max(behave(:,1))/(max(behave(:,2))/1000);

    t_q=sum(q,1)/framerate_bh;

    t_q_percent = t_q/(duration/1000)*100; %Gives time in each quadrant in percent


%%%%%%%%%
    
    %% Compare firing freqency between quadrants
    % add quadrant to final_peakdata

    quadrant = q;

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

                temp=quadrant(b_frame,:); %Determines which arm the animal was occupying during current behavioural frame
                [r c]=find(temp==1); %Gives row and column number for which arm the mouse is in
                if isempty(c) | size(c,2)>1
                    final_peakdata(iPeak,12)=0; %If somehow frame is not found, 0 is default
                end
                if ~isempty(c)& size(c,2)==1
                    final_peakdata(iPeak,12)=c;% column 12 = what quadrant they are in during that spike: c1 = TL, c2 = BL, c3 = TR, c4 = BR
                end

            else
                [M,I] = min(abs(behave(:,1)-min(temp)));
                b_frame = behave(I,1);
                temp=quadrant(b_frame,:); %Determines which arm the animal was occupying during current behavioural frame
                [r c]=find(temp==1); %Gives row and column number for which quadrant the mouse is in
                if isempty(c) | size(c,2)>1
                    final_peakdata(iPeak,12)=0; %If somehow frame is not found, 0 is default
                end
                if ~isempty(c)& size(c,2)==1
                    final_peakdata(iPeak,12)=c;% column 12 = what quadrant they are in during that spike: c1 = TL, c2 = BL, c3 = TR, c4 = BR
                end
            end
        end
    end

%%%%%%%%%

    %% Compare firing freqency between quadrants
%     nPeaks=size(final_peakdata,1);
%     for iPeak=1:nPeaks
%         Cframe=final_peakdata(iPeak,10); %corrected scope frame for current peak
%         loc=final_peakdata(iPeak,11); %behavioural frame for current peak
%         quad=q(loc,:); %determines which quadrant animal is in during current peak
%         [r c]=find(quad==1);
%         final_peakdata(iPeak,12)=c;  % c12 = what quadrant they are in during that spike
%     end %% TL = 1, BL = 2, TR = 3, BR = 4 %%

    %% quad_stats indicates the number of peaks that occur in each quadrant
    quad_stats=[];
    for iQuad=1:4
        ind=final_peakdata(:,12)==iQuad; %creates index indicating number of times there is a peak for a particular quadrant
        quad_stats(iQuad,1)=iQuad; % each quadrant
        quad_stats(iQuad,2)=sum(ind);% count event number for each quadrant
    end

    %         figure
    %         bar(quad_stats(:,2)) % number of events in each quadrant

    %% Normalise to the amount of time spent in that quadrant

    t_q=t_q';
    quad_stats(:,3)=quad_stats(:,2)./t_q; %Gives peaks/sec for that quadrant

    %%%%%%%%%%%%%%%%%%%%%%%%%

    QUADS=[];

    TL = 1;
    BL = 2;
    TR = 3;
    BR = 4;

    indTL = final_peakdata(:,12)==TL; %Index for peaks that occur in the top left
    indBL = final_peakdata(:,12)==BL; %Index for peaks that occur in the bottom left
    indTR = final_peakdata(:,12)==TR; %Index for peaks that occur in the top right
    indBR = final_peakdata(:,12)==BR; %Index for peaks that occur in the bottom right

    QUADS(1,1)=sum(sum(quadrant(:,TL))); %1	number of frames spent in top left
    QUADS(2,1)=sum(sum(quadrant(:,BL))); %1	number of frames spent in bottom left
    QUADS(3,1)=sum(sum(quadrant(:,TR)));   % 1	number of frames spent in top right
    QUADS(4,1)=sum(quadrant(:,BR));   % 1	number of frames spent in the bottom right

    %% top left spiking outputs
    QUADS(1,2)=QUADS(1,1)./framerate_bh;    % 2 seconds spent in top left
    QUADS(1,3)=sum(indTL); % 	3	total number of peaks that occur in top left
    QUADS(1,4)=nanmean(final_peakdata(indTL,3)); % 	4	mean amplitude of peaks that occur in top left
    QUADS(1,5)=nanstd(final_peakdata(indTL,3));% 	5	amplitude STD
    QUADS(1,6)=nanmean(final_peakdata(indTL,4)); % 	6	mean peak width for peaks that occur in top left
    QUADS(1,7)=nanstd(final_peakdata(indTL,4));% 	7	Width STD
    temp=unique(final_peakdata(indTL,1));
    QUADS(1,8)=size(temp,1); % 	8	Number of unique cells that fire in top left
    QUADS(1,9)=QUADS(1,8)/nCells*100;  % 	9	Percentage of all cells that fire in top left (participation)
    QUADS(1,10)=QUADS(1,3)./QUADS(1,2);% 	10	Overall firing Freq (spike/sec)

    %% bottom left spiking outputs
    QUADS(2,2)=QUADS(2,1)./framerate_bh; % 2 seconds spent in bottom left
    QUADS(2,3)=sum(indBL); % 	3	total number of peaks that occur in bottom left
    QUADS(2,4)=nanmean(final_peakdata(indBL,3)); % 	4	mean amplitude of peaks that occur in bottom left
    QUADS(2,5)=nanstd(final_peakdata(indBL,3));% 	5	amplitude STD
    QUADS(2,6)=nanmean(final_peakdata(indBL,4)); % 	6	mean peak width for peaks that occur in bottom left
    QUADS(2,7)=nanstd(final_peakdata(indBL,4));% 	7	Width STD
    temp=unique(final_peakdata(indBL,1));
    QUADS(2,8)=size(temp,1); % 	8	Number of unique cells that fire in bottom left
    QUADS(2,9)=QUADS(2,8)/nCells*100;  % 	9	Percentage of all cells that fire in bottom left (participation)
    QUADS(2,10)=QUADS(2,3)./QUADS(2,2);% 	10	Overall firing Freq (spike/sec)

    %% top right spiking outputs
    QUADS(3,2)=QUADS(3,1)./framerate_bh; % 2 seconds spent in the top right
    QUADS(3,3)=sum(indTR); % 	3	total number of peaks that occur in the top right
    QUADS(3,4)=nanmean(final_peakdata(indTR,3)); % 	4	mean amplitude of peaks that occur in the top right
    QUADS(3,5)=nanstd(final_peakdata(indTR,3));% 	5	amplitude STD
    QUADS(3,6)=nanmean(final_peakdata(indTR,4)); % 	6	mean peak width for peaks that occur in the top right
    QUADS(3,7)=nanstd(final_peakdata(indTR,4));% 	7	Width STD
    temp=unique(final_peakdata(indTR,1));
    QUADS(3,8)=size(temp,1); % 	8	Number of unique cells that fire in the top right
    QUADS(3,9)=QUADS(3,8)/nCells*100;  % 	9	Percentage of all cells that fire in the top right (participation)
    QUADS(3,10)=QUADS(3,3)./QUADS(3,2);% 	10	Overall firing Freq (spike/sec)

    %% bottom right spiking outputs
    QUADS(4,2)=QUADS(4,1)./framerate_bh; % 2 seconds spent in the bottom right
    QUADS(4,3)=sum(indBR); % 	3	total number of peaks that occur in the bottom right
    QUADS(4,4)=nanmean(final_peakdata(indBR,3)); % 	4	mean amplitude of peaks that occur in the bottom right
    QUADS(4,5)=nanstd(final_peakdata(indBR,3));% 	5	amplitude STD
    QUADS(4,6)=nanmean(final_peakdata(indBR,4)); % 	6	mean peak width for peaks that occur in the bottom right
    QUADS(4,7)=nanstd(final_peakdata(indBR,4));% 	7	Width STD
    temp=unique(final_peakdata(indBR,1));
    QUADS(4,8)=size(temp,1); % 	8	Number of unique cells that fire in the bottom right
    QUADS(4,9)=QUADS(4,8)/nCells*100;  % 	9	Percentage of all cells that fire in the bottom right (participation)
    QUADS(4,10)=QUADS(4,3)./QUADS(4,2);% 	10	Overall firing Freq (spike/sec)

    %         figure
    %         bar(quad_stats(:,3))
    %         ylabel('Firing rate (peaks/second)')

    %% Cell activity per quadrant

    cell_stats=[];
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        if isempty(row) == 0
            cell_stats(row,1)=iCell; %Cell number
            ind=final_peakdata(:,1)==iCell; %Creates an index finding all peaks corresponding to that cell
            cell_stats(row,2)=sum(ind); % Number of times current cell fires
            ind=final_peakdata(:,1)==iCell & final_peakdata(:,12)==1; %Index for peaks that fire in the TL quad
            cell_stats(row,4)=sum(ind); %Number of times current cell fires in TL quad
            ind=final_peakdata(:,1)==iCell & final_peakdata(:,12)==2; %Index for peaks that fire in the BL quad
            cell_stats(row,5)=sum(ind);  %Number of times current cell fires in BL quad
            ind=final_peakdata(:,1)==iCell & final_peakdata(:,12)==3; %Index for peaks that fire in the TR quad
            cell_stats(row,6)=sum(ind);  %Number of times current cell fires in TR quad
            ind=final_peakdata(:,1)==iCell & final_peakdata(:,12)==4; %Index for peaks that fire in the BR quad
            cell_stats(row,7)=sum(ind);  %Number of times current cell fires in BR quad
        else
        end
    end

    %% Note: c3 of cell_stats is empty

%     %% cells with quadrant specific activity
%     for iCell=1:nCells
%         if cell_stats(iCell,2) >= 10  %Must fire enough times to ascertain place specificity
%             loc_spc=max(cell_stats(iCell,4:7))/cell_stats(iCell,2)*100; % quadrant with max number of spikes/number of spikes for that cell
% 
%             FireQuad = max(cell_stats(iCell,4:7));
%             [r,c] = find(cell_stats(iCell,4:7) == FireQuad);
%             QuadTime = t_q_percent(:,c); % Percent of total time spent in the quad with apparent place specificity
% 
%             if loc_spc>=50 && QuadTime<=50; % if more than 50% of spikes are in 1 quadrant AND The animal spends less than 50% of their total time in that quadrant
%                 cell_stats(iCell,8)=loc_spc; %NOTE: only specificity above 50%  will appear in c8, otherwise they will appear as 0
%             end
%         end
%     end

%     if size(cell_stats,2) == 8
% 
%         loc_spc = cell_stats(:,8);
%         loc_spc = loc_spc(loc_spc>=50);
% 
%         %% Creates histogram indicating distribution of quadrant specificities
%         %     loc_hist = histogram(loc_spc,30); % Histogram of different location specificity levels.
%         %     hold on
%         %     xlabel('Specificity to a single quadrant(%)');
%         %     ylabel('Number of cells');
%         %     title('Quadrant Firing Specificity for All Cells', FontSize=14);
%         %     hold off
% 
%     else
%     end

    %% Plot cellular activity and animal location
    %all cells
    figure
    of=zeros(max(behave(:,4))+20,max(behave(:,5))+20);
    for i=1:nLocs % for each frame
        [r n]=find(final_peakdata(:,11)==i);  % searches for spikes that occur during this particular behavioural frame.
        if sum(n)>0 % if there are spikes, many frames won't have any
            x=behave(i,4); % x coord for that frame
            y=behave(i,5); % y coord for that frame
            of(y,x)=[sum(n)+1]; % colour that location based on spike number
        end
        behave(i,8)=sum(n); %c8 of behave indicates how many peaks were fired during that particular frame.
    end

    %     cmap = [[1 1 1]; turbo(max(behave(:,8)))];
    %     imshow(of,cmap);  % Produces figure indicating positions where spikes occur, and how many occur at each position.
    %     hold on
    %     cb = colorbar('TickLabels',{0:max(behave(:,8))});
    %     hold off

    %% Will plot traces indicating the position of the animal in the arena for every peak fired by a given cell
    cmap = jet(13);
    mkdir('Peak_Locations');
    folder='Peak_Locations\';

    for iCell = NeuKeep
        row = find(NeuKeep == iCell);
        figure
        of=zeros(max(behave(:,4))+20,max(behave(:,5))+20);
        for i=1:nLocs     % add animal path
            x=behave(i,4);
            y=behave(i,5);
            if ~isnan(x) & ~isnan(y)
                of(y,x)=5;
            end
        end

        [r c]=find(final_peakdata(:,1)==iCell); %Defines the peaks corresponding to the cell in question
        for i=1:size(r,1); % add cell firing, iterations correspond to the number of peaks the cell has
            j=r(i,1); %creates index for the rows containing the peaks for this cell in final_peakdata
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
        imshow(of ,cmap) %Creates image indicating spatial positions where each peak was fired for a given cell

        title(['Cell: ',int2str(iCell),'   Number of Peaks: ',int2str(cell_stats(row,2)),],'FontSize',14);
        filename = sprintf(['Peak Locations ',int2str(iCell),'%d.png']);
        fullfilename=[folder,filename];
        saveas(gcf,fullfilename,'png');
        %pause
        close all
        % end
    end

    %     %% blur cell activity to show firing map
    %         cmap = jet(5);
    %         for iCell=NeuKeep %For all cells
    %             row = find(NeuKeep == iCell);
    %             figure
    %             of=zeros(max(behave(:,4))+20,max(behave(:,5))+20);
    %             [r2 c2]=find(final_peakdata(:,1)==iCell); %Identifies peaks for cell in question
    %             for i=1:size(r2,1); %For all peaks from current cell
    %                 j=r2(i,1);
    %                 frame=final_peakdata(j,10); %Identifies corrected scope frame corresponding to peak for this cell
    %                 loc=final_peakdata(j,11); %Identifies behavioural frame corresponding to peak for this cell
    %                 of(behave(loc,5),behave(loc,4))=50; %Marks coordinate on 'of' where peak is fired
    %             end
    %             B = imgaussfilt(of,2); %Applies gaussian blur to peak locations in 'of'
    %             imshow(B ,cmap) %Applies colourmap
    %
    %                 title(['Cell: ',int2str(iCell),'   Number of Peaks: ',int2str(cell_stats(row,2)),],'FontSize',14);
    %
    %             pause
    %             close all
    %         end


    %% Border vs internal   A bit redundant because all these parameters are obtained in NIN_OFinterior

    %
    %         % Check inner vs outer boundaries
    %         cmap = jet(5);
    %         of=zeros(max(behave(:,4))+20,max(behave(:,5))+20);
    %         for i=1:nLocs
    %             if behave(i,7)==1; %1 for inner
    %                 x= behave(i,4);
    %                 y= behave(i,5);
    %                 if ~isnan(x) & ~isnan(y)
    %                     of(y,x)=2;
    %                 end
    %             elseif behave(i,7)==0; %0 for outer
    %                  x= behave(i,4);
    %                 y= behave(i,5);
    %                 if ~isnan(x) & ~isnan(y)
    %                     of(y,x)=5;
    %                 end
    %             end
    %         end
    %         imshow(of,cmap)
    %         pause
    %         close all
    %
    %     %% Add inner/outer to all peak data
    %
    %     nPeaks=size(final_peakdata,1);
    %     for iPeak=1:nPeaks
    %         frame=final_peakdata(iPeak,10); %Identifies corrected scope frame corresponding to peak
    %         loc=final_peakdata(iPeak,11); %Identifies behavioural frame corresponding to peak
    %         final_peakdata(iPeak,13)=behave(loc,7);  % c13 of final_peakdata now corresponds whether peak was fired in the interior or exterior, 0 for outer, 1 for inner
    %     end
    %
    %     %% cell activity for inner/outer
    %     for iCell=NeuKeep %for each cell
    %         row = find(NeuKeep == iCell);
    %         ind=final_peakdata(:,1)==iCell & final_peakdata(:,13)==0; %index for when cell fires in ext
    %         cell_stats(row,9)=sum(ind); %c9 of cell_stats = number of times cells fires in ext
    %         ind=final_peakdata(:,1)==iCell & final_peakdata(:,13)==1; %index for when cell fires in int
    %         cell_stats(row,10)=sum(ind); %c10 of cell_stats = number of times cells fires in int
    %     end
    %
    %     %% Compare firing freqency between inner/outer
    %     IvO_stats=[];
    %     for iIvO=1:2
    %         ind=final_peakdata(:,13)==iIvO-1;  %Creates index for either all int or ext peaks
    %         IvO_stats(iIvO,1)=iIvO;
    %         IvO_stats(iIvO,2)=sum(ind);
    %     end  %IvO_stats r1 = number of peaks in exterior, r2 = number of peaks in interior
    %
    %     %% Normalise to the amount of time spent in either zone
    %
    %     IvO_stats(1,3)=nLocs-sum(behave(:,7)); % frames in outer
    %     IvO_stats(2,3)=sum(behave(:,7)); %frames in inner
    %
    %     IvO_stats(:,4)=IvO_stats(:,3)/framerate_bh; %Time spent in inner/outer in seconds
    %     IvO_stats(:,5)=IvO_stats(:,2)./IvO_stats(:,4); %Gives firing frequencies in peaks/second for inner and outer regions

    %         bar(IvO_stats(:,5))

    save final_peakdata 'final_peakdata'  %Adds c12= which quadrant animal was in during peak, [c13= whether animal was in interior or exterior when peak was fired]
    save QUADS_Firing_data 'QUADS'  %See line 250 for column info, row 1 = TL, row 2 = BL, row 3 = TR, row 4 = BR
    save behave 'behave'  %[Adds c7 = whether animal was in int or ext for behavioural frame], c8 = number of peaks fired for a particular behavioural frame
    save framerate_bh 'framerate_bh' %Save framerate specific to behavioural recording
%     save cell_stats_OF 'cell_stats' %c1 = cell num, c2 = number of peaks, c4-7 = Number of times fired in specific quadrant, c8 = location specificity (%), c9 = number of peaks in ext, c10 = number of peaks in int
    % save IvO_stats 'IvO_stats' %c1 = ext or int, c2 = total peaks in each region, c3 = behavioural frames in each region, c4 = seconds in each region, c5 = peaks/s in each region
%     save quad_stats 'quad_stats' %c1 = each quadrant, c2 = total peaks in each quadrant, c3 = peaks/sec for each quadrant
    save quadrant_time 't_q' %c1 = Time in TL, c2= Time in BL, c3= Time in TR, c4=Time in BR
    save quad_frames 'q' %array compiling the quadrant locations for each behavioural frame. c1 = TL, c2 = BL, c3 = TR, c4 = BR

    close all
    cd ..
end

%%


