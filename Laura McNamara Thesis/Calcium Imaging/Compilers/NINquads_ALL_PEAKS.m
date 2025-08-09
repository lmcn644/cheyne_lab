clear; clc; close all;

%%
animals=dir;
animals(1:2,:)=[];
animals = natsortfiles(animals);
filter = {animals.name}; % Filters out any '.db' files in the animal folder
filter = ~(contains(filter,'.db'))';
animals = animals(filter,:);
nAnimals=size(animals,1);

AmpsTL = [];
MeanCellAmpsTL = [];
WidthTL = [];
MeanCellWidthTL = [];
FreqTL = [];

AmpsBL = [];
MeanCellAmpsBL = [];
WidthBL = [];
MeanCellWidthBL = [];
FreqBL = [];

AmpsTR = [];
MeanCellAmpsTR = [];
WidthTR = [];
MeanCellWidthTR = [];
FreqTR = [];

AmpsBR = [];
MeanCellAmpsBR = [];
WidthBR = [];
MeanCellWidthBR = [];
FreqBR = [];

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
    load quadrant_time

    %% TOP LEFT QUADRANT DATA

    indTL = final_peakdata(:,12) == 1;
    TL_peakdata = final_peakdata(indTL,:); %All peaks that fire in TL

    TL_stats = [];

    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=TL_peakdata(:,1)==iCell;
        TL_stats(row,1)=iCell;
        TL_stats(row,2)=sum(ind);
    end

    %% TL Peak Amplitudes
    AmpsTL = cat(1,AmpsTL,TL_peakdata(:,3));

    %% Mean amplitudes of peaks fired in TL quad by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=TL_peakdata(:,1)==iCell;
        amp = TL_peakdata(ind,3);
        TL_stats(row,5) = mean(amp);
        if isnan(TL_stats(row,5)) == 1
            TL_stats(row,5) = 0;
        end
    end

    toinsert = nonzeros(TL_stats(:,5));
    MeanCellAmpsTL = cat(1,MeanCellAmpsTL,toinsert);

    %% TL Peak Widths
    WidthTL = cat(1,WidthTL,TL_peakdata(:,4));

    %% Mean widths of peaks fired in TL quad by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=TL_peakdata(:,1)==iCell;
        wid = TL_peakdata(ind,4);
        TL_stats(row,4) = mean(wid);
        if isnan(TL_stats(row,4)) == 1
            TL_stats(row,4) = 0;
        end
    end

    toinsert = nonzeros(TL_stats(:,4));
    MeanCellWidthTL = cat(1,MeanCellWidthTL,toinsert);

    %% Frequency of each cell active in TL quadrant

    TL_stats(:,3)=TL_stats(:,2)/(t_q(1,1));
    toinsert = TL_stats(:,3);
    % toinsert = nonzeros(TL_stats(:,3));
    FreqTL = cat(1,FreqTL,toinsert);

    %%%%%%%%%%%%%%%%%%%%%%%%

    %% BOTTOM LEFT QUADRANT DATA

    indBL = final_peakdata(:,12) == 2;
    BL_peakdata = final_peakdata(indBL,:); %All peaks that fire in BL

    BL_stats = [];

    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=BL_peakdata(:,1)==iCell;
        BL_stats(row,1)=iCell;
        BL_stats(row,2)=sum(ind);
    end

    %% BL Peak Amplitudes
    AmpsBL = cat(1,AmpsBL,BL_peakdata(:,3));

    %% Mean amplitudes of peaks fired in BL quad by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=BL_peakdata(:,1)==iCell;
        amp = BL_peakdata(ind,3);
        BL_stats(row,5) = mean(amp);
        if isnan(BL_stats(row,5)) == 1
            BL_stats(row,5) = 0;
        end
    end

    toinsert = nonzeros(BL_stats(:,5));
    MeanCellAmpsBL = cat(1,MeanCellAmpsBL,toinsert);

    %% BL Peak Widths
    WidthBL = cat(1,WidthBL,BL_peakdata(:,4));

    %% Mean widths of peaks fired in BL quad by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=BL_peakdata(:,1)==iCell;
        wid = BL_peakdata(ind,4);
        BL_stats(row,4) = mean(wid);
        if isnan(BL_stats(row,4)) == 1
            BL_stats(row,4) = 0;
        end
    end

    toinsert = nonzeros(BL_stats(:,4));
    MeanCellWidthBL = cat(1,MeanCellWidthBL,toinsert);

    %% Frequency of each cell active in BL quadrant

    BL_stats(:,3)=BL_stats(:,2)/(t_q(2,1));
    toinsert = BL_stats(:,3);
    % toinsert = nonzeros(BL_stats(:,3));
    FreqBL = cat(1,FreqBL,toinsert);

    %%%%%%%%%%%%%%%%%%%%%%

    %% TOP RIGHT QUADRANT DATA

    indTR = final_peakdata(:,12) == 3;
    TR_peakdata = final_peakdata(indTR,:); %All peaks that fire in TR

    TR_stats = [];

    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=TR_peakdata(:,1)==iCell;
        TR_stats(row,1)=iCell;
        TR_stats(row,2)=sum(ind);
    end

    %% TR Peak Amplitudes
    AmpsTR = cat(1,AmpsTR,TR_peakdata(:,3));

    %% Mean amplitudes of peaks fired in TR quad by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=TR_peakdata(:,1)==iCell;
        amp = TR_peakdata(ind,3);
        TR_stats(row,5) = mean(amp);
        if isnan(TR_stats(row,5)) == 1
            TR_stats(row,5) = 0;
        end
    end

    toinsert = nonzeros(TR_stats(:,5));
    MeanCellAmpsTR = cat(1,MeanCellAmpsTR,toinsert);

    %% TR Peak Widths
    WidthTR = cat(1,WidthTR,TR_peakdata(:,4));

    %% Mean widths of peaks fired in TR quad by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=TR_peakdata(:,1)==iCell;
        wid = TR_peakdata(ind,4);
        TR_stats(row,4) = mean(wid);
        if isnan(TR_stats(row,4)) == 1
            TR_stats(row,4) = 0;
        end
    end

    toinsert = nonzeros(TR_stats(:,4));
    MeanCellWidthTR = cat(1,MeanCellWidthTR,toinsert);

    %% Frequency of each cell active in TR quadrant

    TR_stats(:,3)=TR_stats(:,2)/(t_q(3,1));
    toinsert = TR_stats(:,3);
    % toinsert = nonzeros(TR_stats(:,3));
    FreqTR = cat(1,FreqTR,toinsert);

    %%%%%%%%%%%

    %% BOTTOM RIGHT QUADRANT DATA

    indBR = final_peakdata(:,12) == 4;
    BR_peakdata = final_peakdata(indBR,:); %All peaks that fire in BR

    BR_stats = [];

    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=BR_peakdata(:,1)==iCell;
        BR_stats(row,1)=iCell;
        BR_stats(row,2)=sum(ind);
    end

    %% BR Peak Amplitudes
    AmpsBR = cat(1,AmpsBR,BR_peakdata(:,3));

    %% Mean amplitudes of peaks fired in BR quad by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=BR_peakdata(:,1)==iCell;
        amp = BR_peakdata(ind,3);
        BR_stats(row,5) = mean(amp);
        if isnan(BR_stats(row,5)) == 1
            BR_stats(row,5) = 0;
        end
    end

    toinsert = nonzeros(BR_stats(:,5));
    MeanCellAmpsBR = cat(1,MeanCellAmpsBR,toinsert);

    %% BR Peak Widths
    WidthBR = cat(1,WidthBR,BR_peakdata(:,4));

    %% Mean widths of peaks fired in BR quad by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=BR_peakdata(:,1)==iCell;
        wid = BR_peakdata(ind,4);
        BR_stats(row,4) = mean(wid);
        if isnan(BR_stats(row,4)) == 1
            BR_stats(row,4) = 0;
        end
    end

    toinsert = nonzeros(BR_stats(:,4));
    MeanCellWidthBR = cat(1,MeanCellWidthBR,toinsert);

    %% Frequency of each cell active in BR quadrant

    BR_stats(:,3)=BR_stats(:,2)/(t_q(4,1));
    toinsert = BR_stats(:,3);
    % toinsert = nonzeros(BR_stats(:,3));
    FreqBR = cat(1,FreqBR,toinsert);

    %%%%%%%%%%

    save quad_peakdata 'TL_peakdata' 'BL_peakdata' 'TR_peakdata' 'BR_peakdata'
    cd ..
end

%% Save overall arrays
prompt = 'Input name to save arrays under:   ';
overallfilename=input(prompt,'s');
overallfilename = convertCharsToStrings(overallfilename);
%%%%%%

mkdir('TL_Peaks');
cd TL_Peaks\

OutputTable = array2table(AmpsTL,"VariableNames",{'TL Amps'});
Filename = sprintf(overallfilename+"_TL_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellAmpsTL,"VariableNames",{'Mean Cell TL Amps'});
Filename = sprintf(overallfilename+"_Mean_Cell_TL_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(WidthTL,"VariableNames",{'TL Widths'});
Filename = sprintf(overallfilename+"_TL_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellWidthTL,"VariableNames",{'Mean Cell TL Widths'});
Filename = sprintf(overallfilename+"_Mean_Cell_TL_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(FreqTL,"VariableNames",{'TL Cell Frequencies'});
Filename = sprintf(overallfilename+"_TL_Cell_Frequencies.xlsx");
writetable(OutputTable,Filename);

cd ..

mkdir('BL_Peaks');
cd BL_Peaks\

OutputTable = array2table(AmpsBL,"VariableNames",{'BL Amps'});
Filename = sprintf(overallfilename+"_BL_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellAmpsBL,"VariableNames",{'Mean Cell BL Amps'});
Filename = sprintf(overallfilename+"_Mean_Cell_BL_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(WidthBL,"VariableNames",{'BL Widths'});
Filename = sprintf(overallfilename+"_BL_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellWidthBL,"VariableNames",{'Mean Cell BL Widths'});
Filename = sprintf(overallfilename+"_Mean_Cell_BL_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(FreqBL,"VariableNames",{'BL Cell Frequencies'});
Filename = sprintf(overallfilename+"_BL_Cell_Frequencies.xlsx");
writetable(OutputTable,Filename);

cd ..

mkdir('TR_Peaks');
cd TR_Peaks\

OutputTable = array2table(AmpsTR,"VariableNames",{'TR Amps'});
Filename = sprintf(overallfilename+"_TR_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellAmpsTR,"VariableNames",{'Mean Cell TR Amps'});
Filename = sprintf(overallfilename+"_Mean_Cell_TR_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(WidthTR,"VariableNames",{'TR Widths'});
Filename = sprintf(overallfilename+"_TR_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellWidthTR,"VariableNames",{'Mean Cell TR Widths'});
Filename = sprintf(overallfilename+"_Mean_Cell_TR_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(FreqTR,"VariableNames",{'TR Cell Frequencies'});
Filename = sprintf(overallfilename+"_TR_Cell_Frequencies.xlsx");
writetable(OutputTable,Filename);

cd .. 

mkdir('BR_Peaks');
cd BR_Peaks\

OutputTable = array2table(AmpsBR,"VariableNames",{'BR Amps'});
Filename = sprintf(overallfilename+"_BR_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellAmpsBR,"VariableNames",{'Mean Cell BR Amps'});
Filename = sprintf(overallfilename+"_Mean_Cell_BR_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(WidthBR,"VariableNames",{'BR Widths'});
Filename = sprintf(overallfilename+"_BR_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellWidthBR,"VariableNames",{'Mean Cell BR Widths'});
Filename = sprintf(overallfilename+"_Mean_Cell_BR_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(FreqBR,"VariableNames",{'BR Cell Frequencies'});
Filename = sprintf(overallfilename+"_BR_Cell_Frequencies.xlsx");
writetable(OutputTable,Filename);

cd ..
