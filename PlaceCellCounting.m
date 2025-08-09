
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

PlaceCellTally = [];

for iAnimal = 1:nAnimals;
    iAnimal
    animal=animals(iAnimal).name;
    folder=animal;
    cd(folder)

    load NeuKeep
    PlaceCellTally(iAnimal,1) = size(NeuKeep,2); %Total number of cells the animal has
    PCCheck = exist('NoPlaceCells.mat');

    if PCCheck == 2
        PlaceCellTally(iAnimal,2) = 0;
    else
        load PlaceCells
        PCCheck2 = isempty(PlaceCells);
        if PCCheck2 == 1
            PlaceCellTally(iAnimal,2) = 0;
        else
            PlaceCellTally(iAnimal,2) = size(PlaceCells,1); %Total number of place cells the animal has
        end
    end

    PlaceCellTally(iAnimal,3) = 100*(PlaceCellTally(iAnimal,2)/PlaceCellTally(iAnimal,1));  %percentage of place cells the animal has

    cd ..
end

prompt = 'Input name to save arrays under:   ';
overallfilename=input(prompt,'s');
overallfilename = convertCharsToStrings(overallfilename);
%%%%%%

OutputTable = array2table(PlaceCellTally,"VariableNames",{'Total Cells','Place Cells','% Place Cells'});
Filename = sprintf(overallfilename+"_Place_Cell_Numbers.xlsx");
writetable(OutputTable,Filename);

clearvars
