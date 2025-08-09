%% script to readin timestamps and sync
%% clear the workspace and select data
clear; clc; close all;

%%
animals=dir;
animals(1:2,:)=[];
animals = natsortfiles(animals);
%animals(end,:)=[];
nAnimals=size(animals,1);
scope_joined=[];
behave_joined=[];
duration_joined=[];

for iAnimal = 1:4:nAnimals;
    for iRec=1:4;
        animal=animals(iAnimal+iRec-1).name
        folder=animal;
        cd(folder)
        if isfile('scope.mat')
            % load first animal
            load scope
            scope(scope == 0) = NaN;
            if iRec==1
                scope_joined=scope;
            end
            if iRec>1
                scope=scope+max(scope_joined);
                scope_joined=cat(1,scope_joined,scope);
            end
            
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

            if iRec==1
                behave_joined=behave;
            end
            if iRec>1
                behave=behave+max(behave_joined);
                behave_joined=cat(1,behave_joined,behave);
            end
            
            load duration
            if iRec==1
                duration_joined=duration;
            end
            if iRec>1
                duration_joined=duration_joined+duration;
            end
            
            
            
            
            if iRec==4
                save ('scope_joined','scope_joined')
                save ('behave_joined','behave_joined')
                save ('duration_joined','duration_joined')
            end
            cd ..
        end
    end
    
end
