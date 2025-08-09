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

AlltFreqFreeze = [];
AlltFreqMove = [];

for iAnimal = 1:nAnimals;
    iAnimal
    animal=animals(iAnimal).name;
    folder=animal;
    cd(folder)
    load final_peakdata
    load scope
    load behave
    load nFrames
    load NeuKeep
    load framerate
    load nFrames
    load nCells
    load duration
    load Freeze_peakdata

    if nCells >= 9

        filelist=dir('*Freezing_output.xlsx');

        d1 = readtable(filelist(1).name, 'readvariablenames', false);

        num=d1(1:end,4);
        num=num{:,:};

        if size(num,1)<size(behave(:,1),1)
            num(end+1: size(behave(:,1),1),:)=0;
        end
        if size(num,1)>size(behave(:,1),1)
            num(size(behave(:,1),1)+1:end,:)=[];
        end

        ind=num(:,:)==100; %Index for when animal is freezing
        quadrant=[];
        quadrant(:,1)=ind; % c1 = animal is freezing
        quadrant(:,2)=~ind; % c2 = animal is in motion

        %% Binned Frequencies during Freezing

        freezeframes = [(1:size(quadrant(:,1)))' quadrant(:,1)];
        ind = logical(quadrant(:,1));
        freezeframes = freezeframes(ind,1); % frames where animal is freezing in sequential order

        freezen = sum(quadrant(:,1)); %total number of frames spent freezing

        %% Number of action potentials in each bin over time
        tFreq=[];
        bin=150; % 150 frames = 5 seconds

        for iBin=1:freezen/bin; %total number of bins

            limslower = bin*iBin+1-bin;
            limslower = freezeframes(limslower(1,1),1);

            limsupper = bin*iBin+1;

            if limsupper <= size(freezeframes,1)
                limsupper = freezeframes(limsupper(1,1),1);
            else
                limsupper = limsupper-1;
                limsupper = freezeframes(limsupper(1,1),1);
            end

            ind=Freeze_peakdata(:,11)>=limslower & Freeze_peakdata(:,11)<limsupper; %ensures index only encompasses bin of interest for each iteration
            tFreq=cat(1,tFreq,sum(ind));

        end

        tFreqFreeze = (tFreq/(bin/framerate))/nCells; %Peaks per second per cell

        %% Binned Frequencies during Motion

        moveframes = [(1:size(quadrant(:,2)))' quadrant(:,2)];
        ind = logical(quadrant(:,2));
        moveframes = moveframes(ind,1); % frames where animal is moving in sequential order

        moven = sum(quadrant(:,2)); %total number of frames spent moving

        %% Number of action potentials in each bin over time
        tFreq=[];
        bin=150; % 150 frames = 5 seconds

        for iBin=1:moven/bin; %total number of bins

            limslower = bin*iBin+1-bin;
            limslower = moveframes(limslower(1,1),1);

            limsupper = bin*iBin+1;

            if limsupper <= size(moveframes,1)
                limsupper = moveframes(limsupper(1,1),1);
            else
                limsupper = limsupper-1;
                limsupper = moveframes(limsupper(1,1),1);
            end

            ind=Motion_peakdata(:,11)>=limslower & Motion_peakdata(:,11)<limsupper; %ensures index only encompasses bin of interest for each iteration
            tFreq=cat(1,tFreq,sum(ind));

        end

        tFreqMove = (tFreq/(bin/framerate))/nCells; %Peaks per second per cell


        AlltFreqFreeze = cat(1,AlltFreqFreeze,tFreqFreeze);
        AlltFreqMove = cat(1,AlltFreqMove,tFreqMove);

    end

    cd ..
    
    clearvars -except animals filter filter2 nAnimals AlltFreqFreeze AlltFreqMove iAnimal

end

prompt = 'Input name to save arrays under:   ';
overallfilename=input(prompt,'s');
overallfilename = convertCharsToStrings(overallfilename);

mkdir('Freeze_Binned_Freq');
cd Freeze_Binned_Freq\

OutputTable = array2table(AlltFreqFreeze,"VariableNames",{'Binned Frequencies (Hz/Cell)'});
Filename = sprintf(overallfilename+"_Binned_Frequencies_Freezing.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(AlltFreqMove,"VariableNames",{'Binned Frequencies (Hz/Cell)'});
Filename = sprintf(overallfilename+"_Binned_Frequencies_Motion.xlsx");
writetable(OutputTable,Filename);
