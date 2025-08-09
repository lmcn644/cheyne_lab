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

AlltFreqInt = [];
AlltFreqExt = [];

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
    load Int_peakdata

    if nCells >= 9

        %% Interior
        filelist=dir('*ROIoutput.xlsx');
        d1 = readtable(filelist(1).name, 'readvariablenames', false);
        % get interior
        num = d1(1:end,4);
        num=num{:,:};

        behave(:,7) = num;
        ind=behave(:,7)==1;
        quadrant=[];
        quadrant(:,1)=ind; %c1 = animal is in interior
        quadrant(:,2)=~ind; %c2 = animal is in exterior

        %% Binned Frequencies during Interior
        intframes = [(1:size(quadrant(:,1)))' quadrant(:,1)];
        ind = logical(quadrant(:,1));
        intframes = intframes(ind,1); % frames where animal is in interior in sequential order

        intn = sum(quadrant(:,1)); %total number of frames spent in interior

        %% Number of action potentials in each bin over time
        tFreq=[];
        bin=150; % 150 frames = 5 seconds

        for iBin=1:intn/bin; %total number of bins

            limslower = bin*iBin+1-bin;
            limslower = intframes(limslower(1,1),1);

            limsupper = bin*iBin+1;
            if limsupper <= size(intframes,1)
                limsupper = intframes(limsupper(1,1),1);
            else
                limsupper = limsupper-1;
                limsupper = intframes(limsupper(1,1),1);
            end

            ind=Int_peakdata(:,11)>=limslower & Int_peakdata(:,11)<limsupper; %ensures index only encompasses bin of interest for each iteration
            tFreq=cat(1,tFreq,sum(ind));

        end

        tFreqInt = (tFreq/(bin/framerate))/nCells; %Peaks per second per cell


        %% Binned Frequencies during Exterior

        extframes = [(1:size(quadrant(:,2)))' quadrant(:,2)];
        ind = logical(quadrant(:,2));
        extframes = extframes(ind,1); % frames where animal is in exterior in sequential order

        extn = sum(quadrant(:,2)); %total number of frames spent in exterior

        %% Number of action potentials in each bin over time
        tFreq=[];
        bin=150; % 150 frames = 5 seconds

        for iBin=1:extn/bin; %total number of bins

            limslower = bin*iBin+1-bin;
            limslower = extframes(limslower(1,1),1);

            limsupper = bin*iBin+1;
            if limsupper <= size(extframes,1)
                limsupper = extframes(limsupper(1,1),1);
            else
                limsupper = limsupper-1;
                limsupper = extframes(limsupper(1,1),1);
            end

            ind=Ext_peakdata(:,11)>=limslower & Ext_peakdata(:,11)<limsupper; %ensures index only encompasses bin of interest for each iteration
            tFreq=cat(1,tFreq,sum(ind));

        end

        tFreqExt = (tFreq/(bin/framerate))/nCells; %Peaks per second per cell

        AlltFreqInt = cat(1,AlltFreqInt,tFreqInt);
        AlltFreqExt = cat(1,AlltFreqExt,tFreqExt);

    end

    cd ..
    
    clearvars -except animals filter filter2 nAnimals AlltFreqInt AlltFreqExt iAnimal

end

prompt = 'Input name to save arrays under:   ';
overallfilename=input(prompt,'s');
overallfilename = convertCharsToStrings(overallfilename);

mkdir('Int_Binned_Freq');
cd Int_Binned_Freq\

OutputTable = array2table(AlltFreqInt,"VariableNames",{'Binned Frequencies (Hz/Cell)'});
Filename = sprintf(overallfilename+"_Binned_Frequencies_Int.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(AlltFreqExt,"VariableNames",{'Binned Frequencies (Hz/Cell)'});
Filename = sprintf(overallfilename+"_Binned_Frequencies_Ext.xlsx");
writetable(OutputTable,Filename);
