clear; clc; close all;

%%
animals=dir;
animals(1:2,:)=[];
animals = natsortfiles(animals);
filter = {animals.name}; % Filters out any '.db' files in the animal folder
filter = ~(contains(filter,'.db'))';
animals = animals(filter,:);
nAnimals=size(animals,1);

AmpsInt = [];
MeanCellAmpsInt = [];
WidthInt = [];
MeanCellWidthInt = [];
FreqInt = [];

AmpsExt = [];
MeanCellAmpsExt = [];
WidthExt = [];
MeanCellWidthExt = [];
FreqExt = [];

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
    load OF_Interior_data

    %% INTERIOR DATA

    indInt = final_peakdata(:,13) == 1;
    Int_peakdata = final_peakdata(indInt,:); %All peaks that fire in interior

    Int_stats = [];

    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=Int_peakdata(:,1)==iCell;
        Int_stats(row,1)=iCell;
        Int_stats(row,2)=sum(ind);
    end

    %% Interior Peak Amplitudes
    AmpsInt = cat(1,AmpsInt,Int_peakdata(:,3));

    %% Mean amplitudes of peaks fired in interior by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=Int_peakdata(:,1)==iCell;
        amp = Int_peakdata(ind,3);
        Int_stats(row,5) = mean(amp);
        if isnan(Int_stats(row,5)) == 1
            Int_stats(row,5) = 0;
        end
    end

    toinsert = nonzeros(Int_stats(:,5));
    MeanCellAmpsInt = cat(1,MeanCellAmpsInt,toinsert);

    %% Interior Peak Widths
    WidthInt = cat(1,WidthInt,Int_peakdata(:,4));

    %% Mean widths of peaks fired in interior by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=Int_peakdata(:,1)==iCell;
        wid = Int_peakdata(ind,4);
        Int_stats(row,4) = mean(wid);
        if isnan(Int_stats(row,4)) == 1
            Int_stats(row,4) = 0;
        end
    end

    toinsert = nonzeros(Int_stats(:,4));
    MeanCellWidthInt = cat(1,MeanCellWidthInt,toinsert);

    %% Frequency of each cell active in interior

    Int_stats(:,3)=Int_stats(:,2)/(OF(1,2));
    toinsert = Int_stats(:,3);
    % toinsert = nonzeros(Int_stats(:,3));
    FreqInt = cat(1,FreqInt,toinsert);

%%%%%%%%%%%%%%%

    %% EXTERIOR DATA

    indExt = final_peakdata(:,13) == 2;
    Ext_peakdata = final_peakdata(indExt,:); %All peaks that fire in exterior

    Ext_stats = [];

    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=Ext_peakdata(:,1)==iCell;
        Ext_stats(row,1)=iCell;
        Ext_stats(row,2)=sum(ind);
    end

    %% Exterior Peak Amplitudes
    AmpsExt = cat(1,AmpsExt,Ext_peakdata(:,3));

    %% Mean amplitudes of peaks fired in exterior by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=Ext_peakdata(:,1)==iCell;
        amp = Ext_peakdata(ind,3);
        Ext_stats(row,5) = mean(amp);
        if isnan(Ext_stats(row,5)) == 1
            Ext_stats(row,5) = 0;
        end
    end

    toinsert = nonzeros(Ext_stats(:,5));
    MeanCellAmpsExt = cat(1,MeanCellAmpsExt,toinsert);

    %% Exterior Peak Widths
    WidthExt = cat(1,WidthExt,Ext_peakdata(:,4));

    %% Mean widths of peaks fired in exterior by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=Ext_peakdata(:,1)==iCell;
        wid = Ext_peakdata(ind,4);
        Ext_stats(row,4) = mean(wid);
        if isnan(Ext_stats(row,4)) == 1
            Ext_stats(row,4) = 0;
        end
    end

    toinsert = nonzeros(Ext_stats(:,4));
    MeanCellWidthExt = cat(1,MeanCellWidthExt,toinsert);

    %% Frequency of each cell active in exterior

    Ext_stats(:,3)=Ext_stats(:,2)/(OF(2,2));
    toinsert = Ext_stats(:,3);
    % toinsert = nonzeros(Ext_stats(:,3));
    FreqExt = cat(1,FreqExt,toinsert);

    %%%%%%%%%%%%%%%%%

    save Int_peakdata 'Int_peakdata' 'Ext_peakdata'
    cd ..
end

%% Save overall arrays
prompt = 'Input name to save arrays under:   ';
overallfilename=input(prompt,'s');
overallfilename = convertCharsToStrings(overallfilename);
%%%%%%

mkdir('Int_Peaks');
cd Int_Peaks\

OutputTable = array2table(AmpsInt,"VariableNames",{'Int Amps'});
Filename = sprintf(overallfilename+"_Int_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellAmpsInt,"VariableNames",{'Mean Cell Int Amps'});
Filename = sprintf(overallfilename+"_Mean_Cell_Int_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(WidthInt,"VariableNames",{'Int Widths'});
Filename = sprintf(overallfilename+"_Int_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellWidthInt,"VariableNames",{'Mean Cell Int Widths'});
Filename = sprintf(overallfilename+"_Mean_Cell_Int_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(FreqInt,"VariableNames",{'Int Cell Frequencies'});
Filename = sprintf(overallfilename+"_Int_Cell_Frequencies.xlsx");
writetable(OutputTable,Filename);

cd ..

mkdir('Ext_Peaks');
cd Ext_Peaks\

OutputTable = array2table(AmpsExt,"VariableNames",{'Ext Amps'});
Filename = sprintf(overallfilename+"_Ext_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellAmpsExt,"VariableNames",{'Mean Cell Ext Amps'});
Filename = sprintf(overallfilename+"_Mean_Cell_Ext_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(WidthExt,"VariableNames",{'Ext Widths'});
Filename = sprintf(overallfilename+"_Ext_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellWidthExt,"VariableNames",{'Mean Cell Ext Widths'});
Filename = sprintf(overallfilename+"_Mean_Cell_Ext_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(FreqExt,"VariableNames",{'Ext Cell Frequencies'});
Filename = sprintf(overallfilename+"_Ext_Cell_Frequencies.xlsx");
writetable(OutputTable,Filename);

cd ..

