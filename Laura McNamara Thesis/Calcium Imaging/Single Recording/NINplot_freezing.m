%% Plot Ambulation and Freezing
%% clear the workspace and select data
clear; clc; close all;

%%
animals=dir;
animals(1:2,:)=[];
animals = natsortfiles(animals);
nAnimals=size(animals,1);
for iAnimal = 1:nAnimals;
    iAnimal
    tic
    animal=animals(iAnimal).name;
    folder=animal;
    cd(folder)
    load locomotion %Entire workspace generated in NINlocomotion.m
    
    filelist=dir('*Freezing_output.xlsx');
    d1 = readtable(filelist(1).name, 'readvariablenames', false);
    % get co-ordinates
    num=d1(1:end,4);
    num=num{:,:};

    if size(num,1)<nLocs;  %extends freezing array to fit with behave.mat.
     num(end:nLocs,1)=0;
    end

    behave(:,7)=num(1:size(behave,1),:); %c7 of behave now indicates if the animal was freezing for that frame.
    
    
    
    %     distance(:,4)=distance(:,3)./framerate; %covert to seconds
    %     max_distance=round2(max(distance(:,1)),1)+1;
    
    behave(:,1)=[1:size(behave,1)];
    max_distance=round(max(behave(:,6)))+1; %Provides appropriate maximum Y-axis value for the graph
    
   
freeze = behave(:,7);
freeze = changem(freeze, max_distance, 100); %Swaps freeze values from '100' to max y-value to fit the graph

freezeplot = area(freeze);
freezeplot.LineStyle = "none";
freezeplot.FaceColor = "r";
 hold on

ambplot = plot(behave(:,1), behave(:,6),'k');
ambplot.Color(4) = 0.4;
ax = gca;
ax.XLim = [0 (max(behave(:,1)))];
    xlabel('Time (frames)');
    ylabel('Distance (cm)');
    
hold off
    
    saveas(gcf,'Freezing','svg')
    cd ..
    close all
end




