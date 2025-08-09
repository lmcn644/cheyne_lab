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

AlltFreqTL = [];
AlltFreqBL = [];
AlltFreqTR = [];
AlltFreqBR = [];

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
    load quad_peakdata

    if nCells >= 9

        folderlist=dir('*quads');  %% Ensure ROI outputs for quadrants are stored in a folder called /quads
        cd(folderlist(1).name)

        filelist=dir('*ROIoutput.xlsx');
        d2 = readtable(filelist(1).name, 'readvariablenames', false);

        cd ..

        d2 = table2array(d2);
        q = d2(:,4:7); %array compiling the quadrant locations

        %% Binned Frequencies during TL

        TLframes = [(1:size(q(:,1)))' q(:,1)];
        ind = logical(q(:,1));
        TLframes = TLframes(ind,1); % frames where animal is in TL in sequential order

        TLn = sum(q(:,1)); %total number of frames spent in TL

        %% Number of action potentials in each bin over time
        tFreq=[];
        bin=150; % 150 frames = 5 seconds

        for iBin=1:TLn/bin; %total number of bins

            limslower = bin*iBin+1-bin;
            limslower = TLframes(limslower(1,1),1);

            limsupper = bin*iBin+1;
            if limsupper <= size(TLframes,1)
                limsupper = TLframes(limsupper(1,1),1);
            else
                limsupper = limsupper-1;
                limsupper = TLframes(limsupper(1,1),1);
            end

            ind=TL_peakdata(:,11)>=limslower & TL_peakdata(:,11)<limsupper; %ensures index only encompasses bin of interest for each iteration
            tFreq=cat(1,tFreq,sum(ind));

        end

        tFreqTL = (tFreq/(bin/framerate))/nCells; %Peaks per second per cell

        %% Binned Frequencies during BL

        BLframes = [(1:size(q(:,2)))' q(:,2)];
        ind = logical(q(:,2));
        BLframes = BLframes(ind,1); % frames where animal is in BL in sequential order

        BLn = sum(q(:,2)); %total number of frames spent in BL

        %% Number of action potentials in each bin over time
        tFreq=[];
        bin=150; % 150 frames = 5 seconds

        for iBin=1:BLn/bin; %total number of bins

            limslower = bin*iBin+1-bin;
            limslower = BLframes(limslower(1,1),1);

            limsupper = bin*iBin+1;
            if limsupper <= size(BLframes,1)
                limsupper = BLframes(limsupper(1,1),1);
            else
                limsupper = limsupper-1;
                limsupper = BLframes(limsupper(1,1),1);
            end

            ind=BL_peakdata(:,11)>=limslower & BL_peakdata(:,11)<limsupper; %ensures index only encompasses bin of interest for each iteration
            tFreq=cat(1,tFreq,sum(ind));

        end

        tFreqBL = (tFreq/(bin/framerate))/nCells; %Peaks per second per cell

        %% Binned Frequencies during TR

        TRframes = [(1:size(q(:,3)))' q(:,3)];
        ind = logical(q(:,3));
        TRframes = TRframes(ind,1); % frames where animal is in TR in sequential order

        TRn = sum(q(:,3)); %total number of frames spent in TR

        %% Number of action potentials in each bin over time
        tFreq=[];
        bin=150; % 150 frames = 5 seconds

        for iBin=1:TRn/bin; %total number of bins

            limslower = bin*iBin+1-bin;
            limslower = TRframes(limslower(1,1),1);

            limsupper = bin*iBin+1;
            if limsupper <= size(TRframes,1)
                limsupper = TRframes(limsupper(1,1),1);
            else
                limsupper = limsupper-1;
                limsupper = TRframes(limsupper(1,1),1);
            end

            ind=TR_peakdata(:,11)>=limslower & TR_peakdata(:,11)<limsupper; %ensures index only encompasses bin of interest for each iteration
            tFreq=cat(1,tFreq,sum(ind));

        end

        tFreqTR = (tFreq/(bin/framerate))/nCells; %Peaks per second per cell

        %% Binned Frequencies during BR

        BRframes = [(1:size(q(:,4)))' q(:,4)];
        ind = logical(q(:,4));
        BRframes = BRframes(ind,1); % frames where animal is in BR in sequential order

        BRn = sum(q(:,4)); %total number of frames spent in BR

        %% Number of action potentials in each bin over time
        tFreq=[];
        bin=150; % 150 frames = 5 seconds

        for iBin=1:BRn/bin; %total number of bins

            limslower = bin*iBin+1-bin;
            limslower = BRframes(limslower(1,1),1);

            limsupper = bin*iBin+1;
            if limsupper <= size(BRframes,1)
                limsupper = BRframes(limsupper(1,1),1);
            else
                limsupper = limsupper-1;
                limsupper = BRframes(limsupper(1,1),1);
            end

            ind=BR_peakdata(:,11)>=limslower & BR_peakdata(:,11)<limsupper; %ensures index only encompasses bin of interest for each iteration
            tFreq=cat(1,tFreq,sum(ind));

        end

        tFreqBR = (tFreq/(bin/framerate))/nCells; %Peaks per second per cell

        AlltFreqTL = cat(1,AlltFreqTL,tFreqTL);
        AlltFreqBL = cat(1,AlltFreqBL,tFreqBL);
        AlltFreqTR = cat(1,AlltFreqTR,tFreqTR);
        AlltFreqBR = cat(1,AlltFreqBR,tFreqBR);

    end

    cd ..

    clearvars -except animals filter filter2 nAnimals AlltFreqTL AlltFreqBL AlltFreqTR AlltFreqBR iAnimal

end

prompt = 'Input name to save arrays under:   ';
overallfilename=input(prompt,'s');
overallfilename = convertCharsToStrings(overallfilename);

mkdir('Quad_Binned_Freq');
cd Quad_Binned_Freq\

OutputTable = array2table(AlltFreqTL,"VariableNames",{'Binned Frequencies (Hz/Cell)'});
Filename = sprintf(overallfilename+"_Binned_Frequencies_TL.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(AlltFreqBL,"VariableNames",{'Binned Frequencies (Hz/Cell)'});
Filename = sprintf(overallfilename+"_Binned_Frequencies_BL.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(AlltFreqTR,"VariableNames",{'Binned Frequencies (Hz/Cell)'});
Filename = sprintf(overallfilename+"_Binned_Frequencies_TR.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(AlltFreqBR,"VariableNames",{'Binned Frequencies (Hz/Cell)'});
Filename = sprintf(overallfilename+"_Binned_Frequencies_BR.xlsx");
writetable(OutputTable,Filename);
