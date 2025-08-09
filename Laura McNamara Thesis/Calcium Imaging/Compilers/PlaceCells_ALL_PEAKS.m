
clear; clc; close all;

%%
animals=dir;
animals(1:2,:)=[];
animals = natsortfiles(animals);
filter = {animals.name}; % Filters out any '.db' files in the animal folder
filter = ~(contains(filter,'.db'))';
animals = animals(filter,:);
nAnimals=size(animals,1);

AmpsPC = [];
MeanCellAmpsPC = [];
WidthPC = [];
MeanCellWidthPC = [];
FreqPC = [];
QuadFreqPC = [];
SIAll = [];

for iAnimal = 1:nAnimals;
    iAnimal
    animal=animals(iAnimal).name;
    folder=animal;
    cd(folder)
    PCCheck = exist("PlaceCells.mat");

    if PCCheck == 2
        load PlaceCells
        ind = PlaceCells(:,4)>= 0.3;  % Ensures place cells all provide at least 0.3 bits/spike of spatial information
        PlaceCells = PlaceCells(ind,:);
        PCCheck = ~isempty(PlaceCells);

        if PCCheck == 1
            load scope
            load behave
            load NeuKeep
            load framerate
            load nFrames
            load nCells
            load final_peakdata
            
            %% Place Cell index
            PCind = [];

            for i = PlaceCells(:,1)'
                [r,c] = find(final_peakdata(:,1) == i);
                PCind = cat(1,PCind,r);
            end

            PC_peakdata = final_peakdata(PCind,:);

            %% All Place Cell Peak Amplitudes
            AmpsPC = cat(1,AmpsPC,PC_peakdata(:,3));

            %% Mean peak amplitudes of each Place Cell

            PCstats = [];

            for iCell=PlaceCells(:,1)'
                row = find(PlaceCells(:,1)' == iCell);
                ind=final_peakdata(:,1)==iCell;
                amp = final_peakdata(ind,3);
                PCstats(row,5) = mean(amp);
                if isnan(PCstats(row,5)) == 1
                    PCstats(row,5) = 0;
                end
            end

            MeanCellAmpsPC = cat(1,MeanCellAmpsPC,PCstats(:,5));

            %% All Place Cell Peak Widths
            WidthPC = cat(1,WidthPC,PC_peakdata(:,4));

            %% Mean peak widths of each place cell
            for iCell=PlaceCells(:,1)'
                row = find(PlaceCells(:,1)' == iCell);
                ind=final_peakdata(:,1)==iCell;
                wid = final_peakdata(ind,4);
                PCstats(row,4) = mean(wid);
                if isnan(PCstats(row,4)) == 1
                    PCstats(row,4) = 0;
                end
            end

            MeanCellWidthPC = cat(1,MeanCellWidthPC,PCstats(:,4));

            %% Overall firing rate of each place cell

            for iCell=PlaceCells(:,1)'
                row = find(PlaceCells(:,1)' == iCell);
                ind=final_peakdata(:,1)==iCell;
                PCstats(row,1)=iCell;
                PCstats(row,2)=sum(ind);
            end

            PCstats(:,3)=PCstats(:,2)/(nFrames/framerate);

            FreqPC = cat(1,FreqPC,PCstats(:,3));

            %% Firing rate of each place cell in their specific quadrant

            QuadFreqPC = cat(1,QuadFreqPC,PlaceCells(:,3));

            %% Spatial information provided by each place cell

            SIAll = cat(1,SIAll,PlaceCells(:,4));

        else
        end

    else
    end
    clearvars -except iAnimal animals nAnimals AmpsPC MeanCellAmpsPC WidthPC MeanCellWidthPC FreqPC QuadFreqPC SIAll
    cd ..
end

%%%%%
%% Save overall arrays
prompt = 'Input name to save arrays under:   ';
overallfilename=input(prompt,'s');
overallfilename = convertCharsToStrings(overallfilename);

mkdir('Place_Cell_Peaks');
cd Place_Cell_Peaks\;

OutputTable = array2table(AmpsPC,"VariableNames",{'Place Cell Amps'});
Filename = sprintf(overallfilename+"_PC_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellAmpsPC,"VariableNames",{'Mean Place Cell Amps'});
Filename = sprintf(overallfilename+"_Mean_PC_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(WidthPC,"VariableNames",{'Place Cell Widths'});
Filename = sprintf(overallfilename+"_PC_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellWidthPC,"VariableNames",{'Mean Place Cell Widths'});
Filename = sprintf(overallfilename+"_Mean_PC_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(FreqPC,"VariableNames",{'Place Cell Frequencies'});
Filename = sprintf(overallfilename+"_PC_Frequencies.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(QuadFreqPC,"VariableNames",{'Quadrant Place Cell Frequencies'});
Filename = sprintf(overallfilename+"_Quad_PC_Frequencies.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(SIAll,"VariableNames",{'Spatial Information'});
Filename = sprintf(overallfilename+"_PC_Spatial_Information.xlsx");
writetable(OutputTable,Filename);

cd ..
