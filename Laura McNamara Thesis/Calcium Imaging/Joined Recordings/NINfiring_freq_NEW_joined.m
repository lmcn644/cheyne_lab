%% Plot neuronal activity and get firing frequency
%% clear the workspace and select data
clear; clc; close all;

%%
animals=dir;
animals(1:2,:)=[];
animals = natsortfiles(animals);
filter = {animals.name}; % Filters out any '.db' files in the animal folder
filter = ~(contains(filter,'.db'))';
animals = animals(filter,:);
nAnimals=size(animals,1);

for iAnimal = 4:4:nAnimals; % 1:nAnimals for OF, 2:2:nAnimals for YM, 4:4:nAnimals for NO    %Will only work if cnmfe has been run
    iAnimal
    tic
    animal=animals(iAnimal).name;
    folder=animal;
    cd(folder)
    
    %%
    load final_peakdata
    load behave_joined
    load nFrames
    load nCells
    load NeuKeep
    load duration_joined

    behave = behave_joined;
    duration = duration_joined;

    %% Rasterplot
%     figure
%     scatter(final_peakdata(:,2),final_peakdata(:,1),'*')
    
    %% Neuronal firing frequency
    figure
    cell_stats=[];
    
    %framerate=nFrames/duration*1000
    framerate=max(behave(:,3))/duration*1000;
           
    % Loop creates table showing the number of peaks corresponding to each cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=final_peakdata(:,1)==iCell;
        cell_stats(row,1)=iCell;
        cell_stats(row,2)=sum(ind);
    end

%%%%%%%%%%%

    cell_stats(:,3)=cell_stats(:,2)/(nFrames/framerate); %Calculates peaks/second and places in c3 of cell_stats

    freqhist = histogram(cell_stats(:,3)); % Histogram of different firing rates across all cells
    hold on
    xlabel('Overall Firing Frequency (peaks per second)');
    ylabel('Number of cells');
    freqhist.NumBins = 30;
    hold off

    filename = sprintf(['Firing frequency histogram', '%d.png']);
    saveas(gcf,filename,'png'); %saves histogram
%%%%%%

%% No further analysis planned for width until a more reliable method of determining them is obtained

for iCell=NeuKeep
    row = find(NeuKeep == iCell);
    ind=final_peakdata(:,1)==iCell;
    width = final_peakdata(ind,4);
    width = width/framerate; %converts widths to seconds
    cell_stats(row,4) = mean(width);
    if isnan(cell_stats(row,4)) == 1
        cell_stats(row,4) = 0;
    end    
end

% figure;
% widhist = histogram(cell_stats(:,4))
% hold on
% xlabel('Mean Peak Width (seconds)');
% ylabel('Number of cells');
% widhist.NumBins = 30;
% hold off
% 
% figure;
% scatter(cell_stats(:,3),cell_stats(:,4))
% hold on
% xlabel('Overall Firing Frequency (peaks per second)');
% ylabel('Mean Peak Width (s)');
% hold off

    
    %% Sorted raster (least to most active)
    
    Scell_stats=sortrows(cell_stats,2); %sorts data by number of peaks (and thus frequency)
    
    %%

    figure
    hold on
    for i=1:nCells
        iCell=Scell_stats(i,1);
        ind=final_peakdata(:,1)==iCell;
        if sum(ind)>0
           % scatter(ALLPeakdata(ind,2),repmat(i,sum(ind),1),'*')
            scatter(final_peakdata(ind,2),repmat(i,sum(ind),1),1)   %Creates plot that indicates frame where each cell fires throughout recording, cells are sorted by level of activity.
        end
    end
    ylim([1 nCells])
    xlim([0 nFrames])
exportgraphics(gcf,'Sorted raster small3.eps','BackgroundColor','none','ContentType','vector')

     filename = sprintf(['Sorted raster small2','%d.eps']);
     saveas(gcf,filename,'epsc'); % save
    
    filename = sprintf(['Sorted raster small2','%d.svg']);
    saveas(gcf,'Sorted raster small','svg');
    
    filename = 'cell_stats';
    save (filename, 'cell_stats'); %saves information on cell firing frequencies; c1 = cell number, c2 = num of peaks, c3 = firing freq, c4 = mean peak width in seconds

    
    %% Number of action potentials in each bin over time
     tFreq=[];
     bin=150; % 150 frames = 5 seconds
     
     for iBin=1:nFrames/bin; %total number of bins
         ind=final_peakdata(:,2)>=bin*iBin+1-bin & final_peakdata(:,2)<bin*iBin+1; %ensures index only encompasses bin of interest for each iteration
         tFreq=cat(1,tFreq,sum(ind));
     end
     
     figure
     plot(tFreq)
     xlabel('Time (5-second bins)')
     ylabel('Number of action potentials per bin')
     title(['Action potential number over time - bin: ',int2str(bin),' frames'],'FontSize',14);
    
    %% Total firing rate of all cells
    
     peakbins=[];
     bin=150;
     

     %double loop that runs the peaks of every cell through every bin, organising peaks by both their cell of origin and which bin they fall into
     for iCell=NeuKeep
         count=0;
         temp=[];
         for iBin=1:nFrames/bin;
             count=count+1;
             ind=final_peakdata(:,1)== iCell & final_peakdata(:,2)>=bin*iBin+1-bin & final_peakdata(:,2)<bin*iBin+1;
             temp(count,1)=sum(ind);
         end
         peakbins=cat(2,peakbins,temp); %Creates an array that displays how many times each cell (columns) fired in each bin (rows)
     end
     
     figure
     tFreq=peakbins/bin*framerate; %bin is nFrames for this over time calculation, gets peaks per second for each bin
     plot(tFreq)
     hold on
     plot(mean(tFreq,2),'k','LineWidth',2) %plots the mean firing frequency in each bin
     xlabel('Time (5-second bins)')
     ylabel('Total firing frequency per bin')
     title(['Total firing frequency over time - bin: ',int2str(bin),' frames'],'FontSize',14);
    
    %% Mean firing rate of all cells
     figure
     plot(mean(tFreq,2))
     xlabel('Time (5-second bins)')
     ylabel('Mean firing frequency per bin')
     title(['Mean firing frequency over time - bin: ',int2str(bin),' frames'],'FontSize',14);
    
    %% Participation
     tPart=[];
     bin=150;
     for iBin=1:nFrames/bin;
         ind=final_peakdata(:,2)>=bin*iBin+1-bin & final_peakdata(:,2)<bin*iBin+1;  %Determines which bin we're working in
         temp=unique(final_peakdata(ind,1));  %Determines how many unique individual cells fired within the specified bin
         part=size(temp,1)/nCells*100; %Calculates percentage of all cells active during that bin
         tPart=cat(1,tPart,part);
     end
     figure
     plot(tPart)
     xlabel('Time (5-second bins)')
     ylabel('% of active cells per bin')
     title(['% of active cells over time - bin: ',int2str(bin),' frames'],'FontSize',14);
    %%

    filename='tFreq'; %Columns = every neuron, rows = firing frequency (peaks/s) for each 300-frame bin of the recording
    save (filename,'tFreq')
    
    filename='tPart'; %Percentage of total cell number that fire during each 300-frame bin of the recording
    save (filename,'tPart')    
    
    filename='framerate';  %Framerate of SCOPE recording
    save (filename,'framerate')
    
    save firing_freq  %Saves all variables in workspace
    
    clearvars -except animals iAnimal nAnimals
    close all
    
    cd ..
    
end