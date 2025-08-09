clear; clc; close all;

%%
animals=dir;
animals(1:2,:)=[];
animals = natsortfiles(animals);
filter = {animals.name}; % Filters out any '.db' files in the animal folder
filter = ~(contains(filter,'.db'))';
animals = animals(filter,:);
nAnimals=size(animals,1);

AmpsL = [];
MeanCellAmpsL = [];
WidthL = [];
MeanCellWidthL = [];
FreqL = [];

AmpsR = [];
MeanCellAmpsR = [];
WidthR = [];
MeanCellWidthR = [];
FreqR = [];

AmpsF = [];
MeanCellAmpsF = [];
WidthF = [];
MeanCellWidthF = [];
FreqF = [];

AmpsN = [];
MeanCellAmpsN = [];
WidthN = [];
MeanCellWidthN = [];
FreqN = [];

AmpsC = [];
MeanCellAmpsC = [];
WidthC = [];
MeanCellWidthC = [];
FreqC = [];

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
    load YM_Firing_data

    %% LEFT ARM DATA

    indL = final_peakdata(:,12) == 1;
    L_peakdata = final_peakdata(indL,:); %All peaks that fire in left arm

    L_stats = [];

    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=L_peakdata(:,1)==iCell;
        L_stats(row,1)=iCell;
        L_stats(row,2)=sum(ind);
    end

    %% Left Arm Peak Amplitudes
    AmpsL = cat(1,AmpsL,L_peakdata(:,3));

    %% Mean amplitudes of peaks fired in left arm by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=L_peakdata(:,1)==iCell;
        amp = L_peakdata(ind,3);
        L_stats(row,5) = mean(amp);
        if isnan(L_stats(row,5)) == 1
            L_stats(row,5) = 0;
        end
    end

    toinsert = nonzeros(L_stats(:,5));
    MeanCellAmpsL = cat(1,MeanCellAmpsL,toinsert);

    %% Left Arm Peak Widths
    WidthL = cat(1,WidthL,L_peakdata(:,4));

    %% Mean widths of peaks fired in left arm by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=L_peakdata(:,1)==iCell;
        wid = L_peakdata(ind,4);
        L_stats(row,4) = mean(wid);
        if isnan(L_stats(row,4)) == 1
            L_stats(row,4) = 0;
        end
    end

    toinsert = nonzeros(L_stats(:,4));
    MeanCellWidthL = cat(1,MeanCellWidthL,toinsert);

    %% Frequency of each cell active in left arm

    L_stats(:,3)=L_stats(:,2)/(YM(1,2));
    toinsert = L_stats(:,3);
    % toinsert = nonzeros(L_stats(:,3));
    FreqL = cat(1,FreqL,toinsert);

    %%%%%%%%%%

    %% RIGHT ARM DATA

    indR = final_peakdata(:,12) == 2;
    R_peakdata = final_peakdata(indR,:); %All peaks that fire in right arm

    R_stats = [];

    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=R_peakdata(:,1)==iCell;
        R_stats(row,1)=iCell;
        R_stats(row,2)=sum(ind);
    end

    %% Right Arm Peak Amplitudes
    AmpsR = cat(1,AmpsR,R_peakdata(:,3));

    %% Mean amplitudes of peaks fired in right arm by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=R_peakdata(:,1)==iCell;
        amp = R_peakdata(ind,3);
        R_stats(row,5) = mean(amp);
        if isnan(R_stats(row,5)) == 1
            R_stats(row,5) = 0;
        end
    end

    toinsert = nonzeros(R_stats(:,5));
    MeanCellAmpsR = cat(1,MeanCellAmpsR,toinsert);

    %% Right Arm Peak Widths
    WidthR = cat(1,WidthR,R_peakdata(:,4));

    %% Mean widths of peaks fired in right arm by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=R_peakdata(:,1)==iCell;
        wid = R_peakdata(ind,4);
        R_stats(row,4) = mean(wid);
        if isnan(R_stats(row,4)) == 1
            R_stats(row,4) = 0;
        end
    end

    toinsert = nonzeros(R_stats(:,4));
    MeanCellWidthR = cat(1,MeanCellWidthR,toinsert);

    %% Frequency of each cell active in right arm

    R_stats(:,3)=R_stats(:,2)/(YM(2,2));
    toinsert = R_stats(:,3);
    % toinsert = nonzeros(R_stats(:,3));
    FreqR = cat(1,FreqR,toinsert);

    %%%%%%%%%%%%%%%%

    %% FAMILIAR ARMS DATA

    indF = final_peakdata(:,12) == 1 | final_peakdata(:,12) == 2;
    F_peakdata = final_peakdata(indF,:); %All peaks that fire in familiar arms

    F_stats = [];

    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=F_peakdata(:,1)==iCell;
        F_stats(row,1)=iCell;
        F_stats(row,2)=sum(ind);
    end

    %% Familiar Arms Peak Amplitudes
    AmpsF = cat(1,AmpsF,F_peakdata(:,3));

    %% Mean amplitudes of peaks fired in familiar arms by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=F_peakdata(:,1)==iCell;
        amp = F_peakdata(ind,3);
        F_stats(row,5) = mean(amp);
        if isnan(F_stats(row,5)) == 1
            F_stats(row,5) = 0;
        end
    end

    toinsert = nonzeros(F_stats(:,5));
    MeanCellAmpsF = cat(1,MeanCellAmpsF,toinsert);

    %% Familiar Arms Peak Widths
    WidthF = cat(1,WidthF,F_peakdata(:,4));

    %% Mean widths of peaks fired in familiar arms by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=F_peakdata(:,1)==iCell;
        wid = F_peakdata(ind,4);
        F_stats(row,4) = mean(wid);
        if isnan(F_stats(row,4)) == 1
            F_stats(row,4) = 0;
        end
    end

    toinsert = nonzeros(F_stats(:,4));
    MeanCellWidthF = cat(1,MeanCellWidthF,toinsert);

    %% Frequency of each cell active in familiar arms

    F_stats(:,3)=F_stats(:,2)/(YM(3,2));
    toinsert = F_stats(:,3);
    % toinsert = nonzeros(F_stats(:,3));
    FreqF = cat(1,FreqF,toinsert);

    %%%%%%%

    %% NOVEL ARM DATA

    indN = final_peakdata(:,12) == 3;
    N_peakdata = final_peakdata(indN,:); %All peaks that fire in novel arm

    N_stats = [];

    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=N_peakdata(:,1)==iCell;
        N_stats(row,1)=iCell;
        N_stats(row,2)=sum(ind);
    end

    %% Novel Arm Peak Amplitudes
    AmpsN = cat(1,AmpsN,N_peakdata(:,3));

    %% Mean amplitudes of peaks fired in novel arm by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=N_peakdata(:,1)==iCell;
        amp = N_peakdata(ind,3);
        N_stats(row,5) = mean(amp);
        if isnan(N_stats(row,5)) == 1
            N_stats(row,5) = 0;
        end
    end

    toinsert = nonzeros(N_stats(:,5));
    MeanCellAmpsN = cat(1,MeanCellAmpsN,toinsert);

    %% Novel Arm Peak Widths
    WidthN = cat(1,WidthN,N_peakdata(:,4));

    %% Mean widths of peaks fired in novel arm by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=N_peakdata(:,1)==iCell;
        wid = N_peakdata(ind,4);
        N_stats(row,4) = mean(wid);
        if isnan(N_stats(row,4)) == 1
            N_stats(row,4) = 0;
        end
    end

    toinsert = nonzeros(N_stats(:,4));
    MeanCellWidthN = cat(1,MeanCellWidthN,toinsert);

    %% Frequency of each cell active in novel arm

    N_stats(:,3)=N_stats(:,2)/(YM(4,2));
    toinsert = N_stats(:,3);
    % toinsert = nonzeros(N_stats(:,3));
    FreqN = cat(1,FreqN,toinsert);

    %%%%%%%%%%%%%%%%

    %% CENTRE DATA

    indC = final_peakdata(:,12) == 0;
    C_peakdata = final_peakdata(indC,:); %All peaks that fire in the centre

    C_stats = [];

    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=C_peakdata(:,1)==iCell;
        C_stats(row,1)=iCell;
        C_stats(row,2)=sum(ind);
    end

    %% Centre Peak Amplitudes
    AmpsC = cat(1,AmpsC,C_peakdata(:,3));

    %% Mean amplitudes of peaks fired in centre by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=C_peakdata(:,1)==iCell;
        amp = C_peakdata(ind,3);
        C_stats(row,5) = mean(amp);
        if isnan(C_stats(row,5)) == 1
            C_stats(row,5) = 0;
        end
    end

    toinsert = nonzeros(C_stats(:,5));
    MeanCellAmpsC = cat(1,MeanCellAmpsC,toinsert);

    %% Centre Peak Widths
    WidthC = cat(1,WidthC,C_peakdata(:,4));

    %% Mean widths of peaks fired in centre by each active cell
    for iCell=NeuKeep
        row = find(NeuKeep == iCell);
        ind=C_peakdata(:,1)==iCell;
        wid = C_peakdata(ind,4);
        C_stats(row,4) = mean(wid);
        if isnan(C_stats(row,4)) == 1
            C_stats(row,4) = 0;
        end
    end

    toinsert = nonzeros(C_stats(:,4));
    MeanCellWidthC = cat(1,MeanCellWidthC,toinsert);

    %% Frequency of each cell active in centre

    C_stats(:,3)=C_stats(:,2)/(YM(5,2));
    toinsert = C_stats(:,3);
    % toinsert = nonzeros(C_stats(:,3));
    FreqC = cat(1,FreqC,toinsert);

    %%%%%%%%%%%%%%%%%
    save arm_peakdata 'L_peakdata' 'R_peakdata' 'F_peakdata' 'N_peakdata' 'C_peakdata'
    cd ..

end

%% Save overall arrays
prompt = 'Input name to save arrays under:   ';
overallfilename=input(prompt,'s');
overallfilename = convertCharsToStrings(overallfilename);
%%%%%%

mkdir('L_Peaks');
cd L_Peaks\

OutputTable = array2table(AmpsL,"VariableNames",{'L Amps'});
Filename = sprintf(overallfilename+"_L_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellAmpsL,"VariableNames",{'Mean Cell L Amps'});
Filename = sprintf(overallfilename+"_Mean_Cell_L_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(WidthL,"VariableNames",{'L Widths'});
Filename = sprintf(overallfilename+"_L_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellWidthL,"VariableNames",{'Mean Cell L Widths'});
Filename = sprintf(overallfilename+"_Mean_Cell_L_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(FreqL,"VariableNames",{'L Cell Frequencies'});
Filename = sprintf(overallfilename+"_L_Cell_Frequencies.xlsx");
writetable(OutputTable,Filename);

cd ..

mkdir('R_Peaks');
cd R_Peaks\

OutputTable = array2table(AmpsR,"VariableNames",{'R Amps'});
Filename = sprintf(overallfilename+"_R_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellAmpsR,"VariableNames",{'Mean Cell R Amps'});
Filename = sprintf(overallfilename+"_Mean_Cell_R_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(WidthR,"VariableNames",{'R Widths'});
Filename = sprintf(overallfilename+"_R_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellWidthR,"VariableNames",{'Mean Cell R Widths'});
Filename = sprintf(overallfilename+"_Mean_Cell_R_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(FreqR,"VariableNames",{'R Cell Frequencies'});
Filename = sprintf(overallfilename+"_R_Cell_Frequencies.xlsx");
writetable(OutputTable,Filename);

cd ..

mkdir('F_Peaks');
cd F_Peaks\

OutputTable = array2table(AmpsF,"VariableNames",{'F Amps'});
Filename = sprintf(overallfilename+"_F_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellAmpsF,"VariableNames",{'Mean Cell F Amps'});
Filename = sprintf(overallfilename+"_Mean_Cell_F_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(WidthF,"VariableNames",{'F Widths'});
Filename = sprintf(overallfilename+"_F_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellWidthF,"VariableNames",{'Mean Cell F Widths'});
Filename = sprintf(overallfilename+"_Mean_Cell_F_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(FreqF,"VariableNames",{'F Cell Frequencies'});
Filename = sprintf(overallfilename+"_F_Cell_Frequencies.xlsx");
writetable(OutputTable,Filename);

cd ..

mkdir('N_Peaks');
cd N_Peaks\

OutputTable = array2table(AmpsN,"VariableNames",{'N Amps'});
Filename = sprintf(overallfilename+"_N_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellAmpsN,"VariableNames",{'Mean Cell N Amps'});
Filename = sprintf(overallfilename+"_Mean_Cell_N_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(WidthN,"VariableNames",{'N Widths'});
Filename = sprintf(overallfilename+"_N_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellWidthN,"VariableNames",{'Mean Cell N Widths'});
Filename = sprintf(overallfilename+"_Mean_Cell_N_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(FreqN,"VariableNames",{'N Cell Frequencies'});
Filename = sprintf(overallfilename+"_N_Cell_Frequencies.xlsx");
writetable(OutputTable,Filename);

cd ..

mkdir('C_Peaks');
cd C_Peaks\

OutputTable = array2table(AmpsC,"VariableNames",{'C Amps'});
Filename = sprintf(overallfilename+"_C_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellAmpsC,"VariableNames",{'Mean Cell C Amps'});
Filename = sprintf(overallfilename+"_Mean_Cell_C_Amps.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(WidthC,"VariableNames",{'C Widths'});
Filename = sprintf(overallfilename+"_C_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(MeanCellWidthC,"VariableNames",{'Mean Cell C Widths'});
Filename = sprintf(overallfilename+"_Mean_Cell_C_Widths.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(FreqC,"VariableNames",{'C Cell Frequencies'});
Filename = sprintf(overallfilename+"_C_Cell_Frequencies.xlsx");
writetable(OutputTable,Filename);

cd ..