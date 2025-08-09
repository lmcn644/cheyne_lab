
clear; clc; close all;

%%
animals=dir;
animals(1:2,:)=[];
animals = natsortfiles(animals);
filter = {animals.name}; % Filters out any '.db' files in the animal folder
filter = ~(contains(filter,'.db'))';
animals = animals(filter,:);
nAnimals=size(animals,1);

AmpsAll = [];
MeanCellAmpsAll = [];
WidthAll = [];
MeanCellWidthAll = [];
FreqAll = [];
% AllbinFreq = [];
% AlltDist = [];

for iAnimal = 1:nAnimals;
    iAnimal
    animal=animals(iAnimal).name;
    folder=animal;
    cd(folder)

    load scope
    load behave
    load NeuKeep
    load framerate
    load nFrames
    load nCells
    load final_peakdata
    load cell_stats

    %% All Peak Amplitudes
    AmpsAll = cat(1,AmpsAll,final_peakdata(:,3));

    %% Mean peak amplitudes of each cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=final_peakdata(:,1)==iCell;
        amp = final_peakdata(ind,3);
        cell_stats(row,5) = mean(amp);
        if isnan(cell_stats(row,5)) == 1
            cell_stats(row,5) = 0;
        end
    end

    MeanCellAmpsAll = cat(1,MeanCellAmpsAll,cell_stats(:,5));

    %% All Peak Widths
    WidthAll = cat(1,WidthAll,final_peakdata(:,4));

    %% Mean peak widths of each cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=final_peakdata(:,1)==iCell;
        wid = final_peakdata(ind,4);
        cell_stats(row,4) = mean(wid);
        if isnan(cell_stats(row,4)) == 1
            cell_stats(row,4) = 0;
        end
    end

    MeanCellWidthAll = cat(1,MeanCellWidthAll,cell_stats(:,4));

    %% All Cell Frequencies

    FreqAll = cat(1,FreqAll,cell_stats(:,3));

%     if nCells >= 30
%         %% Number of action potentials in each bin over time
% 
%         Freq=[];
%         tDist=[];
%         bin=300; %300 frames/10 seconds
% 
%         for iBin=1:nFrames/bin
%             ind=final_peakdata(:,2)>=bin*iBin+1-bin & final_peakdata(:,2)<bin*iBin+1; %Index indicating which cells fired in a particular bin
%             Freq=cat(1,Freq,sum(ind)); %Number of peaks in that bin
%             ind=behave(:,3)>=bin*iBin+1-bin & behave(:,3)<bin*iBin+1; %Index that filters for locomotion occuring within that specific bin
%             tDist=cat(1,tDist,sum(behave(ind,6))); %Total distance travelled within a particular bin
%         end
% 
%         if ~isempty(AllbinFreq)
%             if size(Freq(:,1),1) < size(AllbinFreq(:,1),1)
%                 diff = size(AllbinFreq,1) - size(Freq,1);
%                 Freq = [Freq; zeros(diff,1)];
%                 tDist = [tDist; zeros(diff,1)];
%             end
% 
%             if size(Freq(:,1),1) > size(AllbinFreq(:,1),1)
%                 Freq = Freq(1:size(AllbinFreq,1),:);
%                 tDist = tDist(1:size(AlltDist,1),:);
%             end
%         else
%         end
% 
%         Freq = Freq/nCells;  %Normalises number of peaks to number of cells
%         AllbinFreq = cat(2,AllbinFreq,Freq);
%         AlltDist = cat(2,AlltDist,tDist);
% 
%     end

    cd ..

end

%% Save overall arrays
prompt = 'Input name to save arrays under:   ';
overallfilename=input(prompt,'s');
overallfilename = convertCharsToStrings(overallfilename);
%%%%%%

OutputTable = array2table(AmpsAll,"VariableNames",{'All Amps'});
Filename = sprintf(overallfilename+"_All_Amps.xlsx");
writetable(OutputTable,Filename);

figure;
AmpsAllHist = histogram(AmpsAll);
hold on
title('Amplitude Distribution of All Calcium Peaks');
xlabel('\DeltaF/F0');
ylabel('Number of Peaks');
AmpsAllHist.NumBins = 30;
hold off

filename = sprintf(['All Amps Histogram', '%d.png']);
saveas(gcf,filename,'png'); %saves histogram
close all
%%%%

OutputTable = array2table(MeanCellAmpsAll,"VariableNames",{'Mean Cell Amps'});
Filename = sprintf(overallfilename+"_Mean_Cell_Amps.xlsx");
writetable(OutputTable,Filename);

figure;
CellAmpsAllHist = histogram(MeanCellAmpsAll);
hold on
title('Mean Amplitude Distribution of All Cells');
xlabel('Mean \DeltaF/F0');
ylabel('Number of Cells');
CellAmpsAllHist.NumBins = 30;
hold off

filename = sprintf(['Mean Cell Amps Histogram', '%d.png']);
saveas(gcf,filename,'png'); %saves histogram
close all
%%%%

OutputTable = array2table(WidthAll,"VariableNames",{'All Widths'});
Filename = sprintf(overallfilename+"_All_Widths.xlsx");
writetable(OutputTable,Filename);

figure;
WidthAllHist = histogram(WidthAll);
hold on
title('Width Distribution of All Calcium Peaks');
xlabel('Peak Width (Frames)');
ylabel('Number of Peaks');
WidthAllHist.NumBins = 30;
hold off

filename = sprintf(['All Widths Histogram', '%d.png']);
saveas(gcf,filename,'png'); %saves histogram
close all
%%%%%

OutputTable = array2table(MeanCellWidthAll,"VariableNames",{'Mean Cell Widths'});
Filename = sprintf(overallfilename+"_Mean_Cell_Widths.xlsx");
writetable(OutputTable,Filename);

figure;
CellWidthAllHist = histogram(MeanCellWidthAll);
hold on
title('Mean Peak Width Distribution of All Cells');
xlabel('Mean Peak Width (Frames)');
ylabel('Number of Cells');
CellWidthAllHist.NumBins = 30;
hold off

filename = sprintf(['Mean Cell Widths Histogram', '%d.png']);
saveas(gcf,filename,'png'); %saves histogram
close all
%%%%

OutputTable = array2table(FreqAll,"VariableNames",{'All Cell Frequencies'});
Filename = sprintf(overallfilename+"_All_Cell_Frequencies.xlsx");
writetable(OutputTable,Filename);

figure;
FreqAllHist = histogram(FreqAll);
hold on
title('Frequency Distribution of All Cells');
xlabel('Firing Frequency (Peak/s)');
ylabel('Number of Cells');
FreqAllHist.NumBins = 30;
hold off

filename = sprintf(['All Cell Frequencies Histogram', '%d.png']);
saveas(gcf,filename,'png'); %saves histogram
close all
%%%%%

% OutputTable = array2table(AllbinFreq);
% Filename = sprintf(overallfilename+"_All_Normalised_Binned_Firing_Frequencies.xlsx");
% writetable(OutputTable,Filename);
% 
% OutputTable = array2table(AlltDist);
% Filename = sprintf(overallfilename+"_All_Binned_Distances.xlsx");
% writetable(OutputTable,Filename);
% 
% figure
% scatter(AlltDist,AllbinFreq,'fill');
% hold on;
% % linear regression
% x=AlltDist;
% y=AllbinFreq;
% %     [P] = polyfit(x,y,1); %First degree polynomial means the line will be linear (y = mx + c), the outputs of 'P' will be the gradient P(1) and the y-axis intercept P(2)
% %     yfit = P(1)*x+P(2); % Gives approximated y-values for a line of best fit, based on the polynomial coefficients from 'P'.
% %     plot(x,yfit,'r-.');
% %     Rsqu = "R^2 = " + string([corr(x,y)]^2);
% %     dim = [.2 .6 .1 .1];
% %     annotation('textbox',dim,'String',Rsqu);
% xlabel('Distance (cm)'); %Distance travelled in that bin
% ylabel('Number of action potentials per 10-second bin per cell');
% title('Relationship Between Ambulation and Firing Frequency');
% hold off;
% 
% filename = sprintf(['Relationship Between Ambulation and Firing Frequency', '%d.png']);
% saveas(gcf,filename,'png'); %saves histogram
% close all
