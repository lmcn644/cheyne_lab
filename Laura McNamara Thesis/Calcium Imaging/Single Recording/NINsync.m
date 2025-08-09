%% script to readin timestamps and sync
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
    %if not(isfile('scope.mat'))
    d1 = readtable('TimeStamp.csv', 'readvariablenames', false);  %TimeStamp.csv file from raw data must be accessible
    d1(1,:)=[];
    %d1(end,:)=[];
    channel=unique(d1.Var1); 
    Output = sortrows(d1,1);   %Organises table by scope versus behav
    num = Output(:,2:3);
    num=num{:,:};
    %num = str2double(num);
    shift=diff(num);  %  Number of milliseconds between each frame
    shift=shift*-1;
    x=max(shift(:,2)); % Identifies point where scope output switches to behav
    [r c] = find(shift(:,2)==x);
    behave=num(1:r,:);  % Split scope and behav frame/millsecond alignments
    scope=num(r+1:end,:);
    
    % Loop that aligns scope and behavioural frames

    for i=1:size(behave,1);
        frame=behave(i,2);
        temp=scope(:,2)-frame;  %Can get alignment by doing this because we can assume smallest millisecond interval where the two recordings align
        temp=abs(temp);
        [r c]=find(temp==min(temp)); % Gets position of the alignment in the array
        scope(r(1,1),3)=frame; %Therefore the current behavioural frame we're working with must align with this scope position in milliseconds
        scope(r(1,1),4)=i; %Equivalent frame from behavioural array
        behave(i,3)=scope(r(1,1),1); %Conversely, inserting equivalent frame from scope array into behavioural array
    end
    scope(:,5)=scope(:,3);
    scope(:,6)=scope(:,4);
    
    %Given scope has a higher fps than behav, this loop determines how
    %'extra' frames within scope are grouped in the context of behav
    %recording frames
    
    for i=1:size(scope,1);
        if scope(i,3)==0;
            frame=scope(i,2);
            temp=scope(:,3)-frame; %Can assume smallest millisecond interval for specific frame this iteration aligns with
            temp=abs(temp);
            [r c]=find(temp==min(temp));
            scope(i,5)=scope(r(1,1),3);
            scope(i,6)=scope(r(1,1),4);
        end
    end
    %     scatter(scope(:,1),scope(:,2))
    %     hold on
    %     scatter(behave(:,3),behave(:,2))
    
    save ('scope','scope')
    save ('behave','behave')

    % scope: c1 = Scope frames, c2 = scope milliseconds, c3 = behav millisecond alignment, c4 = behav frame alignment, c5 = behav millisecond alignment (every frame assigned) c6 = behav frame alignment (every frame assigned)
    % behave: c1 = Behav frames, c2 = behav milliseconds, c3 = scope frame alignment
    
    duration=max(scope(:,2))-min(scope(:,2));
    save ('duration','duration')
    
    clearvars -except animals iAnimal nAnimal
    % end
    toc
    cd ..
    
end
