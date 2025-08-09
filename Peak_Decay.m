
clear; clc; close all;

%%
animals=dir;
animals(1:2,:)=[];
animals = natsortfiles(animals);
filter = {animals.name}; % Filters out any '.db' files in the animal folder
filter = ~(contains(filter,'.db'))';
animals = animals(filter,:);
filter2 = {animals.name}; % Filters out any '.mat' files in the animal folder
filter2 = ~(contains(filter2,'.xlsx'))';
animals = animals(filter2,:);
nAnimals=size(animals,1);

AllAnimalsDecayData = [];
AllAnimalsMeanDecayData = [];

for iAnimal = 1:nAnimals;
    iAnimal;
    animal=animals(iAnimal).name;
    folder=animal;
    cd(folder)
    load scope
    load duration
    load behave
    load final_peakdata
    load NeuKeep

    folderlist=dir('*extraction');
    load("Cell_Sorting.mat");
    cd(folderlist(1).name)
    folderlist=dir('frames*');
    cd(folderlist(1).name)
    folderlist=dir('LOGS*');
    cd(folderlist(1).name)
    matfile = dir('*.mat');
    matfile = matfile(1,:);
    matfile = matfile.name;
    load ([matfile]);  %% opens workspace with raw cnmf_e output data

    C = neuron.C; %All Neuronal temporal info
    C_raw = neuron.C_raw; % All unfiltered neuronal temporal info

    cd ..
    cd ..
    cd ..

    %     HalfDecayData = [];
    %
    %     for iCell = NeuKeep
    %         row = find(NeuKeep == iCell);
    %         ind=final_peakdata(:,1)==iCell;
    %         iCellPeaks = final_peakdata(ind,:);
    %         iPeakn = size(iCellPeaks,1);
    %         DecayData = [];
    %         for i = 1:iPeakn
    %             PeakFrame = iCellPeaks(i,2);
    %             PeakAmp = iCellPeaks(i,3); %a
    %
    %             HalfWidFrame = iCellPeaks(i,7); %x
    %             HalfWidAmp = C(iCell,round(HalfWidFrame)); %y
    %
    %             %% f(x) = a(b)^x
    %             Decay = ((HalfWidAmp/PeakAmp)^(1/HalfWidFrame))-1;
    %             DecayData(i,1) = Decay;
    %         end
    %         HalfDecayData = cat(1,HalfDecayData,DecayData);
    %     end

    %     QuartDecayData = [];
    %
    %     for iCell = NeuKeep
    %         row = find(NeuKeep == iCell);
    %         ind=final_peakdata(:,1)==iCell;
    %         iCellPeaks = final_peakdata(ind,:);
    %         iPeakn = size(iCellPeaks,1);
    %         DecayData = [];
    %         for i = 1:iPeakn
    %             PeakFrame = iCellPeaks(i,2);
    %             PeakAmp = iCellPeaks(i,3); %a
    %
    %             HalfWidFrame = iCellPeaks(i,7); %x
    %             QuartWidFrame = round((HalfWidFrame + PeakFrame)/2);
    %
    %             QuartWidAmp = C(iCell,round(QuartWidFrame)); %y
    %
    %             %% f(x) = a(b)^x
    %             Decay = ((QuartWidAmp/PeakAmp)^(1/QuartWidFrame))-1;
    %             DecayData(i,1) = Decay;
    %         end
    %         QuartDecayData = cat(1,QuartDecayData,DecayData);
    %     end

    %%%%%%%%%

    %% Peak Decay Rate at T1/3 (of the way down total prominence) 

    RawThirdDecayData = [];
    CellMeanRawThirdDecayData = [];

    for iCell = NeuKeep
        row = find(NeuKeep == iCell);
        ind=final_peakdata(:,1)==iCell;
        iCellPeaks = final_peakdata(ind,:);
        iPeakn = size(iCellPeaks,1);
        DecayData = [];
        SmoothedRaw = smoothdata(C_raw(iCell,:),"sgolay",Degree=12);  %Raw calcium trace smoothed by sgolay with a degree of 12

        for i = 1:iPeakn
            PeakFrame = iCellPeaks(i,2);
            PeakAmp = iCellPeaks(i,3); %a

            PeakPromThird = [1/3]*(iCellPeaks(i,5));
            CleanAmp = PeakAmp-PeakPromThird;

            inflect = C(iCell,PeakFrame:end) - CleanAmp;
            ind = inflect < 0;
            [r,c] = find(ind == 1);
            ThirdWidFrame = PeakFrame + c(1,1); %x
            ThirdWidAmp = SmoothedRaw(:,round(ThirdWidFrame)); %y

            %% f(x) = a(b)^x
            Decay = ((ThirdWidAmp/PeakAmp)^(1/ThirdWidFrame))-1;  %Decay rate isolated from basic exponential decay function
            DecayData(i,1) = Decay;
        end

        if isreal(DecayData)             %% used to exclude rare instances of imaginary decays
            MeanDecayData = mean(DecayData);
        else
            ImagFilter = imag(DecayData);
            [r,c] = find(ImagFilter ~= 0);
            ModDecayData = DecayData;
            ModDecayData(r,:) = [];
            MeanDecayData = mean(ModDecayData);
        end

        RawThirdDecayData = cat(1,RawThirdDecayData,DecayData);
        CellMeanRawThirdDecayData = cat(1,CellMeanRawThirdDecayData,MeanDecayData);
    end

%%%%%%

%% Peak Decay Rate at T2/3 (of the way down total prominence) 

    RawtwoThirdDecayData = [];
    CellMeanRawtwoThirdDecayData = [];

    for iCell = NeuKeep
        row = find(NeuKeep == iCell);
        ind=final_peakdata(:,1)==iCell;
        iCellPeaks = final_peakdata(ind,:);
        iPeakn = size(iCellPeaks,1);
        DecayData = [];
        SmoothedRaw = smoothdata(C_raw(iCell,:),"sgolay",Degree=12);

        for i = 1:iPeakn
            PeakFrame = iCellPeaks(i,2);
            PeakAmp = iCellPeaks(i,3); %a

            PeakPromTwoThird = [2/3]*(iCellPeaks(i,5));
            CleanAmp = PeakAmp-PeakPromTwoThird;

            inflect = C(iCell,PeakFrame:end) - CleanAmp;
            ind = inflect < 0;
            [r,c] = find(ind == 1);
            twoThirdWidFrame = PeakFrame + c(1,1); %x
            twoThirdWidAmp = SmoothedRaw(:,round(twoThirdWidFrame)); %y

            %% f(x) = a(b)^x
            Decay = ((twoThirdWidAmp/PeakAmp)^(1/twoThirdWidFrame))-1;
            DecayData(i,1) = Decay;
        end

        if isreal(DecayData)
            MeanDecayData = mean(DecayData);
        else
            ImagFilter = imag(DecayData);
            [r,c] = find(ImagFilter ~= 0);
            ModDecayData = DecayData;
            ModDecayData(r,:) = [];
            MeanDecayData = mean(ModDecayData);
        end

        RawtwoThirdDecayData = cat(1,RawtwoThirdDecayData,DecayData);
        CellMeanRawtwoThirdDecayData = cat(1,CellMeanRawtwoThirdDecayData,MeanDecayData);

    end

    %     AllPeakDecayData = [HalfDecayData RawHalfDecayData QuartDecayData RawQuartDecayData];
    AllPeakDecayData = [RawThirdDecayData RawtwoThirdDecayData];
    AllAnimalsDecayData = cat(1,AllAnimalsDecayData,AllPeakDecayData);

    AllMeanPeakDecayData = [CellMeanRawThirdDecayData CellMeanRawtwoThirdDecayData];
    AllAnimalsMeanDecayData = cat(1,AllAnimalsMeanDecayData,AllMeanPeakDecayData);

    cd ..

end

%% Filters out imaginary numbers if they appear
ImagFilter = imag(AllAnimalsDecayData);
[r,c] = find(ImagFilter ~= 0);
AllAnimalsDecayData(r,:) = [];

% save("AllAnimalsDecayData","AllAnimalsDecayData");
% save("AllAnimalsMeanDecayData","AllAnimalsMeanDecayData");

%% Save overall arrays
prompt = 'Input name to save arrays under:   ';
overallfilename=input(prompt,'s');
overallfilename = convertCharsToStrings(overallfilename);

OutputTable = array2table(AllAnimalsDecayData,"VariableNames",{'All Third Prominence Decays','All twoThird Prominence Decays'});
Filename = sprintf(overallfilename+"_All_Peak_Decays.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(AllAnimalsMeanDecayData,"VariableNames",{'Mean Cell Third Prominence Decays','Mean Cell twoThird Prominence Decays'});
Filename = sprintf(overallfilename+"_Mean_Cell_Peak_Decays.xlsx");
writetable(OutputTable,Filename);

%%%%

%% Plots for checking data
% for iCell = 1 %% Cell number of interest
%     row = find(NeuKeep == iCell);
%     ind=final_peakdata(:,1)==iCell;
%     iCellPeaks = final_peakdata(ind,:);
%     iPeakn = size(iCellPeaks,1);
%     ThirdData = [];
%     twoThirdData = [];
%     Raw = C_raw(iCell,:);
%     SmoothedRaw = smoothdata(C_raw(iCell,:),"sgolay",Degree=12);
% 
%     plot(Raw);  % Plots raw trace
%     hold on
%     plot(SmoothedRaw);  %Plots raw trace after sgolay filtering
%     plot(C(iCell,:));
%     scatter(iCellPeaks(:,2),iCellPeaks(:,3));  % Peak amplitudes that serve as the first sampling points
% 
%     for i = 1:iPeakn
%         PeakFrame = iCellPeaks(i,2);
%         PeakAmp = iCellPeaks(i,3); %a
%         HalfWidFrame = iCellPeaks(i,7); %x
% 
%         sixthwidlength = round((HalfWidFrame-PeakFrame)/3);  %frame length for T1/6 of prominence
%         ThirdWidFrame = PeakFrame + 2*sixthwidlength;  %frame at T1/3 on the curve
%         ThirdWidAmp = SmoothedRaw(:,round(ThirdWidFrame));
%         ThirdData(i,1) = ThirdWidFrame;
%         ThirdData(i,2) = ThirdWidAmp;
% 
%         twoThirdWidFrame = PeakFrame + 4*sixthwidlength;  %frame at T1/3 on the curve
%         twoThirdWidAmp = SmoothedRaw(:,round(twoThirdWidFrame)); %y
%         twoThirdData(i,1) = twoThirdWidFrame;
%         twoThirdData(i,2) = twoThirdWidAmp; 
%     end
% 
%     scatter(ThirdData(:,1),ThirdData(:,2));
%     scatter(twoThirdData(:,1),twoThirdData(:,2));
% 
%     hold off
% %     pause
% %     close all
% end


