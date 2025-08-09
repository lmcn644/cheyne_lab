
clear; clc; close all;

%%
animals=dir;
animals(1:2,:)=[];
animals = natsortfiles(animals);
filter = {animals.name}; % Filters out any '.db' files in the animal folder
filter = ~(contains(filter,'.db'))';
animals = animals(filter,:);
nAnimals=size(animals,1);

AllbinFreq = [];
AlltDist = [];

for iAnimal = 1%:nAnimals;
    iAnimal
    animal=animals(iAnimal).name;
    folder=animal;
    cd(folder)

    load scope
    load behave
    load NeuKeep
    load framerate
    load nFrames
    load nCells
    load final_peakdata
    load cell_stats

    %     if nCells >= 30
    %% Number of action potentials in each bin over time

    Freq=[];
    tDist=[];
    bin=300; %300 frames/10 seconds

    for iBin=1:nFrames/bin
        ind=final_peakdata(:,2)>=bin*iBin+1-bin & final_peakdata(:,2)<bin*iBin+1; %Index indicating which cells fired in a particular bin
        Freq=cat(1,Freq,sum(ind)); %Number of peaks in that bin
        ind=behave(:,3)>=bin*iBin+1-bin & behave(:,3)<bin*iBin+1; %Index that filters for locomotion occuring within that specific bin
        tDist=cat(1,tDist,sum(behave(ind,6))); %Total distance travelled within a particular bin
    end


    Freq = Freq/nCells;  %Normalises number of peaks to number of cells
    AllbinFreq = cat(1,AllbinFreq,Freq);
    AlltDist = cat(1,AlltDist,tDist);

    %     end

    cd ..

end

prompt = 'Input name to save arrays under:   ';
overallfilename=input(prompt,'s');
overallfilename = convertCharsToStrings(overallfilename);
%%%%

OutputTable = array2table(AllbinFreq,"VariableNames",{'Binned Firing Freqs'});
Filename = sprintf(overallfilename+"_All_Normalised_Binned_Firing_Frequencies.xlsx");
writetable(OutputTable,Filename);

OutputTable = array2table(AlltDist,"VariableNames",{'Binned Distances'});
Filename = sprintf(overallfilename+"_All_Binned_Distances.xlsx");
writetable(OutputTable,Filename);
