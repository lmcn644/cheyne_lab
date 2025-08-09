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

ALLnCells = [];

for iAnimal = 1:nAnimals;
    iAnimal
    animal=animals(iAnimal).name;
    folder=animal;
    cd(folder)

    load nCells

    ALLnCells = cat(1,ALLnCells,nCells);

    cd ..

    clearvars -except animals filter filter2 nAnimals ALLnCells iAnimal
end

prompt = 'Input name to save arrays under:   ';
overallfilename=input(prompt,'s');
overallfilename = convertCharsToStrings(overallfilename);

OutputTable = array2table(ALLnCells,"VariableNames",{'Total nCells'});
Filename = sprintf(overallfilename+"_Total_Cell_Numbers.xlsx");
writetable(OutputTable,Filename);
