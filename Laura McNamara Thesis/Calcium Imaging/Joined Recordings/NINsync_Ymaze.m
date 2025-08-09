%Connects YM1 and YM2 output files. Ensure NINsync.m has been run first.

%% script to readin timestamps and sync
%% clear the workspace and select data
clear; clc; close all;

%%
animals=dir;
animals(1:2,:)=[];
animals = natsortfiles(animals);
nAnimals=size(animals,1);
for iAnimal = 1:2:nAnimals; %Starts at every other animal (only syncs YM1 and YM2)
    animal=animals(iAnimal).name
    folder=animal;
    cd(folder)
    if isfile('scope.mat')
        % load first animal
        load scope
        scope(scope == 0) = NaN;
        load behave
    %% Added so animal tracking is consistent in joined recordings
            filelist=dir('*resnet*.csv'); %Use DeepLabCut for coordinates
            d1 = readtable(filelist(1).name, 'readvariablenames', false);
            filelist=dir('*Distance_Travelled.xlsx'); % Distance travelled output for distances
            d2 = readtable(filelist(1).name, 'readvariablenames', false);
    
            rawframes = table2array(d1(:,1))+1;  %All frames used in behavioural test analysis (+1 because DLC starts from frame 0)
            for i = rawframes'
                behave(i,4) = 1;  %Identified behavioural frames removed from the DLC output
            end
    
            ind = logical(behave(:,4));  %removes frames that aren't in the DLC output
            behave = behave(ind,:);
            behave(:,4) = [];
            
        load duration
        scope_joined=scope;
        behave_joined=behave;
        duration_joined=duration;
        % load second animal and join
        cd ..
        animal=animals(iAnimal+1).name %Ensure all files are in the correct order, i.e. YM2 immediately follows YM1 for this animal. 
        folder=animal;
        cd(folder)
        load scope
        scope(scope == 0) = NaN;
        scope=scope+max(scope_joined); %Adds maximum values of YM1 output to all values of YM2 output, making them continuous when concatenated together.
        scope_joined=cat(1,scope_joined,scope); %Concatenates YM1 and YM2 outputs
        load behave

            filelist=dir('*resnet*.csv'); %Use DeepLabCut for coordinates
            d1 = readtable(filelist(1).name, 'readvariablenames', false);
            filelist=dir('*Distance_Travelled.xlsx'); % Distance travelled output for distances
            d2 = readtable(filelist(1).name, 'readvariablenames', false);
    
            rawframes = table2array(d1(:,1))+1;  %All frames used in behavioural test analysis (+1 because DLC starts from frame 0)
            for i = rawframes'
                behave(i,4) = 1;  %Identified behavioural frames removed from the DLC output
            end
    
            ind = logical(behave(:,4));  %removes frames that aren't in the DLC output
            behave = behave(ind,:);
            behave(:,4) = [];

        behave=behave+max(behave_joined); %Same as above
        behave_joined=cat(1,behave_joined,behave);
        load duration
        duration_joined=duration_joined+duration;       
        save ('scope_joined','scope_joined')  %Note: all joined files are stored in the YM2 folder.
        save ('behave_joined','behave_joined')       
        save ('duration_joined','duration_joined')      
    end
    cd ..    
end
