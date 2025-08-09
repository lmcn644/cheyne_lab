clear; clc; close all;

%%
animals=dir;
animals(1:2,:)=[];
animals = natsortfiles(animals);
filter = {animals.name}; % Filters out any '.db' files in the animal folder
filter = ~(contains(filter,'.db'))';
animals = animals(filter,:);
nAnimals=size(animals,1);

AmpsMotion = [];
MeanCellAmpsMotion = [];
WidthMotion = [];
MeanCellWidthMotion = [];
FreqMotion = [];

AmpsFreeze = [];
MeanCellAmpsFreeze = [];
WidthFreeze = [];
MeanCellWidthFreeze = [];
FreqFreeze = [];

for iAnimal = 1:nAnimals;
    iAnimal
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
    load OF_Freezing_data

    %% MOTION PEAK DATA

    indMotion = final_peakdata(:,14) == 2;
    Motion_peakdata = final_peakdata(indMotion,:); %All peaks that fire while animal is in motion

    Motion_stats = [];

    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=Motion_peakdata(:,1)==iCell;
        Motion_stats(row,1)=iCell;
        Motion_stats(row,2)=sum(ind);
    end

    %% Peak amplitudes while in motion
    AmpsMotion = cat(1,AmpsMotion,Motion_peakdata(:,3));

    %% Mean amplitudes of peaks fired while in motion by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=Motion_peakdata(:,1)==iCell;
        amp = Motion_peakdata(ind,3);
        Motion_stats(row,5) = mean(amp);
        if isnan(Motion_stats(row,5)) == 1
            Motion_stats(row,5) = 0;
        end
    end

    toinsert = nonzeros(Motion_stats(:,5));
    MeanCellAmpsMotion = cat(1,MeanCellAmpsMotion,toinsert);

    %% Peak Widths while in motion
    WidthMotion = cat(1,WidthMotion,Motion_peakdata(:,4));

    %% Mean widths of peaks fired while in motion by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=Motion_peakdata(:,1)==iCell;
        wid = Motion_peakdata(ind,4);
        Motion_stats(row,4) = mean(wid);
        if isnan(Motion_stats(row,4)) == 1
            Motion_stats(row,4) = 0;
        end
    end

    toinsert = nonzeros(Motion_stats(:,4));
    MeanCellWidthMotion = cat(1,MeanCellWidthMotion,toinsert);

    %% Frequency of each cell active while in motion

    Motion_stats(:,3)=Motion_stats(:,2)/(OF(1,2));
    toinsert = Motion_stats(:,3);
    % toinsert = nonzeros(Motion_stats(:,3));
    FreqMotion = cat(1,FreqMotion,toinsert);

    %%%%%%%%%%%%%%%%%%%%%%%%

    %% FREEZING PEAK DATA

    indFreeze = final_peakdata(:,14) == 1;
    Freeze_peakdata = final_peakdata(indFreeze,:); %All peaks that fire while animal is freezing

    Freeze_stats = [];

    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=Freeze_peakdata(:,1)==iCell;
        Freeze_stats(row,1)=iCell;
        Freeze_stats(row,2)=sum(ind);
    end

    %% Freezing Peak Amplitudes
    AmpsFreeze = cat(1,AmpsFreeze,Freeze_peakdata(:,3));

    %% Mean amplitudes of peaks fired while freezing by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=Freeze_peakdata(:,1)==iCell;
        amp = Freeze_peakdata(ind,3);
        Freeze_stats(row,5) = mean(amp);
        if isnan(Freeze_stats(row,5)) == 1
            Freeze_stats(row,5) = 0;
        end
    end

    toinsert = nonzeros(Freeze_stats(:,5));
    MeanCellAmpsFreeze = cat(1,MeanCellAmpsFreeze,toinsert);

    %% Freezing Peak Widths
    WidthFreeze = cat(1,WidthFreeze,Freeze_peakdata(:,4));

    %% Mean widths of peaks fired while freezing by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=Freeze_peakdata(:,1)==iCell;
        wid = Freeze_peakdata(ind,4);
        Freeze_stats(row,4) = mean(wid);
        if isnan(Freeze_stats(row,4)) == 1
            Freeze_stats(row,4) = 0;
        end
    end

    toinsert = nonzeros(Freeze_stats(:,4));
    MeanCellWidthFreeze = cat(1,MeanCellWidthFreeze,toinsert);

    %% Frequency of each cell active while freezing

    Freeze_stats(:,3)=Freeze_stats(:,2)/(OF(2,2));
    toinsert = Freeze_stats(:,3);
    % toinsert = nonzeros(Freeze_stats(:,3));
    FreqFreeze = cat(1,FreqFreeze,toinsert);

    %%%%%%%%%%%

    save Freeze_peakdata 'Motion_peakdata' 'Freeze_peakdata'
    cd ..

end

%% Save overall arrays
prompt = 'Input name to save arrays under:   ';
overallfilename=input(prompt,'s');
overallfilename = convertCharsToStrings(overallfilename);
%%%%%%

mkdir('Motion_Peaks');
cd Motion_Peaks\

OutputTable = array2table(AmpsMotion,"VariableNames",{'Motion Amps'});
Filename = sprintf(overallfilename+"_Motion_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellAmpsMotion,"VariableNames",{'Mean Cell Motion Amps'});
Filename = sprintf(overallfilename+"_Mean_Cell_Motion_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(WidthMotion,"VariableNames",{'Motion Widths'});
Filename = sprintf(overallfilename+"_Motion_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellWidthMotion,"VariableNames",{'Mean Cell Motion Widths'});
Filename = sprintf(overallfilename+"_Mean_Cell_Motion_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(FreqMotion,"VariableNames",{'Motion Cell Frequencies'});
Filename = sprintf(overallfilename+"_Motion_Cell_Frequencies.xlsx");
writetable(OutputTable,Filename);

cd ..

mkdir('Freeze_Peaks');
cd Freeze_Peaks\

OutputTable = array2table(AmpsFreeze,"VariableNames",{'Freeze Amps'});
Filename = sprintf(overallfilename+"_Freeze_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellAmpsFreeze,"VariableNames",{'Mean Cell Freeze Amps'});
Filename = sprintf(overallfilename+"_Mean_Cell_Freeze_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(WidthFreeze,"VariableNames",{'Freeze Widths'});
Filename = sprintf(overallfilename+"_Freeze_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellWidthFreeze,"VariableNames",{'Mean Cell Freeze Widths'});
Filename = sprintf(overallfilename+"_Mean_Cell_Freeze_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(FreqFreeze,"VariableNames",{'Freeze Cell Frequencies'});
Filename = sprintf(overallfilename+"_Freeze_Cell_Frequencies.xlsx");
writetable(OutputTable,Filename);

cd ..
