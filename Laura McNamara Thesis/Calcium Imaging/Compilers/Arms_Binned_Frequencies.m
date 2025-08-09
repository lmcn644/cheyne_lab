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

AlltFreqL = [];
AlltFreqR = [];
AlltFreqN = [];
AlltFreqC = [];

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

        %% Binned Frequencies during Left Arm Occupancy

        Lframes = [(1:size(quadrant(:,1)))' quadrant(:,1)];
        ind = logical(quadrant(:,1));
        Lframes = Lframes(ind,1); % frames where animal is in left arm in sequential order

        Ln = sum(quadrant(:,1)); %total number of frames spent in left arm

        %% Number of action potentials in each bin over time
        tFreq=[];
        bin=150; % 150 frames = 5 seconds

        for iBin=1:Ln/bin; %total number of bins

            limslower = bin*iBin+1-bin;
            limslower = Lframes(limslower(1,1),1);

            limsupper = bin*iBin+1;
            if limsupper <= size(Lframes,1)
                limsupper = Lframes(limsupper(1,1),1);
            else
                limsupper = limsupper-1;
                limsupper = Lframes(limsupper(1,1),1);
            end

            ind=L_peakdata(:,11)>=limslower & L_peakdata(:,11)<limsupper; %ensures index only encompasses bin of interest for each iteration
            tFreq=cat(1,tFreq,sum(ind));

        end

        tFreqL = (tFreq/(bin/framerate))/nCells; %Peaks per second per cell

        %% Binned Frequencies during Right Arm Occupancy

        Rframes = [(1:size(quadrant(:,2)))' quadrant(:,2)];
        ind = logical(quadrant(:,2));
        Rframes = Rframes(ind,1); % frames where animal is in right arm in sequential order

        Rn = sum(quadrant(:,2)); %total number of frames spent in right arm

        %% Number of action potentials in each bin over time
        tFreq=[];
        bin=150; % 150 frames = 5 seconds

        for iBin=1:Rn/bin; %total number of bins

            limslower = bin*iBin+1-bin;
            limslower = Rframes(limslower(1,1),1);

            limsupper = bin*iBin+1;
            if limsupper <= size(Rframes,1)
                limsupper = Rframes(limsupper(1,1),1);
            else
                limsupper = limsupper-1;
                limsupper = Rframes(limsupper(1,1),1);
            end

            ind=R_peakdata(:,11)>=limslower & R_peakdata(:,11)<limsupper; %ensures index only encompasses bin of interest for each iteration
            tFreq=cat(1,tFreq,sum(ind));

        end

        tFreqR = (tFreq/(bin/framerate))/nCells; %Peaks per second per cell

        %% Binned Frequencies during Novel Arm Occupancy

        Nframes = [(1:size(quadrant(:,3)))' quadrant(:,3)];
        ind = logical(quadrant(:,3));
        Nframes = Nframes(ind,1); % frames where animal is in novel arm in sequential order

        Nn = sum(quadrant(:,3)); %total number of frames spent in novel arm

        %% Number of action potentials in each bin over time
        tFreq=[];
        bin=150; % 150 frames = 5 seconds

        for iBin=1:Nn/bin; %total number of bins

            limslower = bin*iBin+1-bin;
            limslower = Nframes(limslower(1,1),1);

            limsupper = bin*iBin+1;
            if limsupper <= size(Nframes,1)
                limsupper = Nframes(limsupper(1,1),1);
            else
                limsupper = limsupper-1;
                limsupper = Nframes(limsupper(1,1),1);
            end

            ind=N_peakdata(:,11)>=limslower & N_peakdata(:,11)<limsupper; %ensures index only encompasses bin of interest for each iteration
            tFreq=cat(1,tFreq,sum(ind));

        end

        tFreqN = (tFreq/(bin/framerate))/nCells; %Peaks per second per cell

        %% Binned Frequencies during Centre Occupancy

        Cframes = [(1:size(quadrant(:,4)))' quadrant(:,4)];
        ind = logical(quadrant(:,4));
        Cframes = Cframes(ind,1); % frames where animal is in centre in sequential order

        Cn = sum(quadrant(:,4)); %total number of frames spent in centre

        %% Number of action potentials in each bin over time
        tFreq=[];
        bin=150; % 150 frames = 5 seconds

        for iBin=1:Cn/bin; %total number of bins

            limslower = bin*iBin+1-bin;
            limslower = Cframes(limslower(1,1),1);

            limsupper = bin*iBin+1;
            if limsupper <= size(Cframes,1)
                limsupper = Cframes(limsupper(1,1),1);
            else
                limsupper = limsupper-1;
                limsupper = Cframes(limsupper(1,1),1);
            end

            ind=C_peakdata(:,11)>=limslower & C_peakdata(:,11)<limsupper; %ensures index only encompasses bin of interest for each iteration
            tFreq=cat(1,tFreq,sum(ind));

        end

        tFreqC = (tFreq/(bin/framerate))/nCells; %Peaks per second per cell

        AlltFreqL = cat(1,AlltFreqL,tFreqL);
        AlltFreqR = cat(1,AlltFreqR,tFreqR);
        AlltFreqN = cat(1,AlltFreqN,tFreqN);
        AlltFreqC = cat(1,AlltFreqC,tFreqC);


    end

    cd ..

    clearvars -except animals filter filter2 nAnimals AlltFreqL AlltFreqR AlltFreqN AlltFreqC iAnimal

end

prompt = 'Input name to save arrays under:   ';
overallfilename=input(prompt,'s');
overallfilename = convertCharsToStrings(overallfilename);

mkdir('Arm_Binned_Freq');
cd Arm_Binned_Freq\

OutputTable = array2table(AlltFreqL,"VariableNames",{'Binned Frequencies (Hz/Cell)'});
Filename = sprintf(overallfilename+"_Binned_Frequencies_L.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(AlltFreqR,"VariableNames",{'Binned Frequencies (Hz/Cell)'});
Filename = sprintf(overallfilename+"_Binned_Frequencies_R.xlsx");
writetable(OutputTable,Filename);

YM1check = isempty(AlltFreqN);

if YM1check == 0

    OutputTable = array2table(AlltFreqN,"VariableNames",{'Binned Frequencies (Hz/Cell)'});
    Filename = sprintf(overallfilename+"_Binned_Frequencies_N.xlsx");
    writetable(OutputTable,Filename);

end

OutputTable = array2table(AlltFreqC,"VariableNames",{'Binned Frequencies (Hz/Cell)'});
Filename = sprintf(overallfilename+"_Binned_Frequencies_C.xlsx");
writetable(OutputTable,Filename);