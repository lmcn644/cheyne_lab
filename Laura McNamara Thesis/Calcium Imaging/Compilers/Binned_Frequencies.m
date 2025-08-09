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

OveralltFreq = [];
OveralltPart = [];

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
    load tFreq
    load tPart

    if nCells >= 18

    tFreq = mean(tFreq,2);  %Mean frequency of all individual cells in each bin

    OveralltFreq = cat(1,OveralltFreq,tFreq);
    OveralltPart = cat(1,OveralltPart,tPart);

    end

    cd ..

    clearvars -except animals filter filter2 nAnimals OveralltFreq OveralltPart iAnimal

end

prompt = 'Input name to save arrays under:   ';
overallfilename=input(prompt,'s');
overallfilename = convertCharsToStrings(overallfilename);

mkdir('Data');
cd Data\

OutputTable = array2table(OveralltFreq,"VariableNames",{'Binned Frequencies (Hz/Cell)'});
Filename = sprintf(overallfilename+"_Binned_Frequencies.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(OveralltPart,"VariableNames",{'Binned Cell Participation (%)'});
Filename = sprintf(overallfilename+"_Binned_Cell_Participation.xlsx");
writetable(OutputTable,Filename);
