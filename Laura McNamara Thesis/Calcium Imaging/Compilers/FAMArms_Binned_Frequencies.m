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

AlltFreqF = [];

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
    load arm_peakdata

    if nCells >= 9

        filelist=dir('*ROIoutput.xlsx');
        d1 = readtable(filelist(1).name, 'readvariablenames', false);
        num=d1(1:end,4:6);
        num=num{:,:};
        if size(num,1)<max(scope(:,4))   %Expands YM arm location array to match scope array
            num(end+1: max(scope(:,4)),:)=0;
        end
        quadrant=num(1:max(scope(:,4)),:);

        centrequad = double(~(any(quadrant,2))); %adds column for centre occupancy
        quadrant = [quadrant centrequad];

        %% Binned Frequencies during Familiar Arm Occupancy

        Lframes = [(1:size(quadrant(:,1)))' quadrant(:,1)];
        ind = logical(quadrant(:,1));
        Lframes = Lframes(ind,1); % frames where animal is in left arm in sequential order

        Ln = sum(quadrant(:,1)); %total number of frames spent in left arm

                Rframes = [(1:size(quadrant(:,2)))' quadrant(:,2)];
        ind = logical(quadrant(:,2));
        Rframes = Rframes(ind,1); % frames where animal is in right arm in sequential order

        Rn = sum(quadrant(:,2)); %total number of frames spent in right arm

        Fn = Ln+Rn; %total number of frames spent in the left or right arm

        Fframes = cat(1,Lframes,Rframes);
        Fframes = sort(Fframes);

        %% Number of action potentials in each bin over time
        tFreq=[];
        bin=150; % 150 frames = 5 seconds

        for iBin=1:Fn/bin; %total number of bins

            limslower = bin*iBin+1-bin;
            limslower = Fframes(limslower(1,1),1);

            limsupper = bin*iBin+1;
            if limsupper <= size(Fframes,1)
                limsupper = Fframes(limsupper(1,1),1);
            else
                limsupper = limsupper-1;
                limsupper = Fframes(limsupper(1,1),1);
            end

            ind=F_peakdata(:,11)>=limslower & F_peakdata(:,11)<limsupper; %ensures index only encompasses bin of interest for each iteration
            tFreq=cat(1,tFreq,sum(ind));

        end

        tFreqF = (tFreq/(bin/framerate))/nCells; %Peaks per second per cell

        AlltFreqF = cat(1,AlltFreqF,tFreqF);

    end

    cd ..

    clearvars -except animals filter filter2 nAnimals AlltFreqF iAnimal

end

prompt = 'Input name to save arrays under:   ';
overallfilename=input(prompt,'s');
overallfilename = convertCharsToStrings(overallfilename);

mkdir('Arm_Binned_Freq');
cd Arm_Binned_Freq\

OutputTable = array2table(AlltFreqF,"VariableNames",{'Binned Frequencies (Hz/Cell)'});
Filename = sprintf(overallfilename+"_Binned_Frequencies_F.xlsx");
writetable(OutputTable,Filename);
