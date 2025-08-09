%% clear the workspace and select data
clear; clc; close all;

%%
animals=dir;
animals(1:2,:)=[];
animals = natsortfiles(animals);
filter = {animals.name}; % Filters out any '.mat' files in the animal folder
filter = ~(contains(filter,'.mat'))';
animals = animals(filter,:);
filter2 = {animals.name}; % Filters out any '.db' files in the animal folder
filter2 = ~(contains(filter2,'.db'))';
animals = animals(filter2,:);
nAnimals=size(animals,1);

AllPlctFreq = [];
AllPlctPart = [];

for iAnimal = 1:nAnimals;
    iAnimal
    animal=animals(iAnimal).name;
    folder=animal;
    cd(folder)
    load final_peakdata
    load scope
    load behave
    load nFrames
    load nCells
    load NeuKeep
    load framerate
    load nFrames
    load nCells
    load duration

    PCCheck = exist('NoPlaceCells.mat');

    if PCCheck == 2
        PlctFreq = [];
        PlctPart = [];
    else
        load PlaceCells
        PCCheck2 = isempty(PlaceCells);
        if PCCheck2 == 1
            PlctFreq = [];
            PlctPart = [];
        else
            PC = PlaceCells(:,1)';
            PCn = size(PC,2);  %number of place cells

            if nCells >= 18

                %% Binned firing rate of place cells

                PC_peakdata = [];
                for i = PC
                    ind = final_peakdata(:,1)==i;
                    ipeaks = final_peakdata(ind,:);
                    PC_peakdata = cat(1,PC_peakdata,ipeaks);
                end

                tFreq=[];
                bin=150; % 150 frames = 5 seconds

                for iBin=1:nFrames/bin; %total number of bins
                    ind=PC_peakdata(:,2)>=bin*iBin+1-bin & PC_peakdata(:,2)<bin*iBin+1; %ensures index only encompasses bin of interest for each iteration
                    tFreq=cat(1,tFreq,sum(ind));
                end

                PlctFreq = (tFreq/(bin/framerate))/PCn; %Peaks per second per place cell


                %% Participation of place cells

                PlctPart=[];
                bin=150;

                for iBin=1:nFrames/bin;
                    ind=PC_peakdata(:,2)>=bin*iBin+1-bin & PC_peakdata(:,2)<bin*iBin+1;  %Determines which bin we're working in
                    temp=unique(PC_peakdata(ind,1));  %Determines how many unique place cells fired within the specified bin
                    part=size(temp,1)/PCn*100; %Calculates percentage of all places cells active during that bin
                    PlctPart=cat(1,PlctPart,part);
                end

            else

              PlctFreq = [];
              PlctPart = [];

            end
        end
    end

    AllPlctFreq = cat(1,AllPlctFreq,PlctFreq);
    AllPlctPart = cat(1,AllPlctPart,PlctPart);

    cd ..

    clearvars -except animals filter filter2 nAnimals AllPlctFreq AllPlctPart iAnimal
end

prompt = 'Input name to save arrays under:   ';
overallfilename=input(prompt,'s');
overallfilename = convertCharsToStrings(overallfilename);

mkdir('PC_Binned_Freq');
cd PC_Binned_Freq\

OutputTable = array2table(AllPlctFreq,"VariableNames",{'Binned Frequencies (Hz/Cell)'});
Filename = sprintf(overallfilename+"_Binned_PC_Frequencies.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(AllPlctPart,"VariableNames",{'Binned Cell Participation (%)'});
Filename = sprintf(overallfilename+"_Binned_PC_Participation.xlsx");
writetable(OutputTable,Filename);
