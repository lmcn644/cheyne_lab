%% Make sure folder has the ethovision and modified deeplabcut output for every animal

clear; clc; close all;

animals=dir;
animals(1:2,:)=[];
animals = natsortfiles(animals);

filter = {animals.name}; % Filters out any '.mat' files in the animal folder
filter = ~(contains(filter,'.mat'))';
animals = animals(filter,:);
filter2 = {animals.name}; % Filters out any '.db' files in the animal folder
filter2 = ~(contains(filter2,'.db'))';
animals = animals(filter2,:);
nAnimals=(size(animals,1))/2;
ALLFREEZEDATA = {};

mkdir Freezing_Outputs

for iAnimal = 1:nAnimals;
    iAnimal
    animal=animals(iAnimal).name;
    DLCoutput = readtable(animal);  %Modified DeepLabCut output
    i2 = iAnimal+nAnimals;
    animal2=animals(i2).name;
    Ethooutput = readtable(animal2);

    DLCframes = table2array(DLCoutput(:,1))+1;
    Ethoframes = (1:(size(Ethooutput,1)))';

    ind = ismember(Ethoframes,DLCframes); %Identifies which frames were removed from DLC output
    Ethofreeze = table2array(Ethooutput(:,10));
    EthofreezeFINAL = (Ethofreeze(ind,:));

    Freezetime = (sum(EthofreezeFINAL))/15;
    Freezepercent = ((sum(EthofreezeFINAL))/(size(EthofreezeFINAL,1)))*100;
    filename = animal2(28:end-5);

    %%%%%%%%%%%%%%%%

    ALLFREEZEDATA(iAnimal,:) = {(filename), (Freezetime), (Freezepercent)}; %Combined data table with all animals

    Output = [(1:size(EthofreezeFINAL,1))' EthofreezeFINAL];
    OutputTable = array2table(Output,"VariableNames",{'Frames','Freezing'});
    FINALFilename = sprintf(filename+"_Freezing_output_NEW.xlsx");

    cd Freezing_Outputs\
    writetable(OutputTable,FINALFilename);

    cd ..

end

AllFreezeOutputs = cell2table(ALLFREEZEDATA, "VariableNames",{'Animal', 'Time spent freezing (s)', 'Time spent freezing (%)'});
AllFreezefilename = sprintf("Overall_Freeze_Data.xlsx");

cd Freezing_Outputs\
writetable(AllFreezeOutputs,AllFreezefilename);

cd ..

