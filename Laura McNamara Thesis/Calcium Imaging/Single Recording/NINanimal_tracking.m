%% Check and scale animal tracking data
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

    % get co-ordinates
    num=d1(:,14:15); %location coordinates for each frame
    num=num{:,:};
    %num = str2double(num);

    %Expands array to ensure size of DLC output and behave.mat outputs match
    if size(num,1)<size(behave,1)
        prompt = (['DLC output could be truncated for ' num2str(animal) ', proceed anyway? [y/n]   ']);
     Input = input(prompt,"s")
       switch Input
       case 'y'
       num(end+1,:)=num(end,:);
       case 'n'
       cd ..
       return
       otherwise
       disp("Invalid input")
       cd ..
       return
       end
    end

    behave(:,4:5)=round(num(1:size(behave,1),:)); %Adds DLC behavioural coordinates to c4 & c5 of behave.mat

    %get distance travelled

    num=d2(:,end);
    num=num{:,:};
    %num = str2double(num);
    if size(num,1)<size(behave,1)
        prompt = (['DLC output could be truncated for ' num2str(animal) ', proceed anyway? [y/n]   ']);
     Input = input(prompt,"s")
       switch Input
       case 'y'
       num(end+1,:)=num(end,:);
       case 'n'
       cd ..
       return
       otherwise
       disp("Invalid input")
       cd ..
       return
       end
    end
    behave(:,6)=num(1:size(behave,1),:); %Adds distance travelled to c6 of behave.mat


    %% plot animal tracing data
    nLocs=size(behave,1);
    cmap = [1 1 1;parula(nLocs)]; %creates colourmap the size of the the number of frames (since animal should be in distinct position for each frame)
    figure

    prompt = ("Is this a YM recording? [y/n]     "); %sets size of figure, scale to vid dimensions with (401,401) for OF/NO or (480,640) for YM

    Input = input(prompt,"s")
    switch Input
     case 'y'

    of=zeros(480,640);

    case 'n'
    of=zeros(401,401);

    otherwise
    disp("Invalid input")
    cd ..
    return
    end
    
    for i= 1:nLocs
        xcoords=behave(i,4); %X coords
        ycoords=behave(i,5); %y coords
        if ~isnan(xcoords) & ~isnan(ycoords)  %Provided these values ARE NOT NAN, colour inserted at that coordinate
            of(ycoords,xcoords)=i+1; %+1 so first pixel isn't white
        end
    end
  
    trace = imshow(of(10:end,10:end),cmap);
   
    hold on
    axis on
    cb = colorbar;
    cb.Label.String = 'Frames';
    cb.Label.FontSize = 12;
    title(['Position Trace'],'FontSize',14);
    filename = sprintf(['Position Trace_',(animal),'%d.png']);
    saveas(gcf,filename,'png'); % saves animal position trace as .png

    %%
    filename='behave';
    save (filename,'behave')  %c1 = Behav frames, c2 = behav milliseconds, c3 = scope frame, c4 & c5 = behavioural x and y coordinates, c6 = distance travalled for each frame

% % Enable section below if using joined recordings
% 
%     prompt = (['Does ', sprintf(animal),' contain a joined Y-maze file? [y/n]     ']);  %Needed to update behave_joined file with c4-6
%     Input = input(prompt,"s")
%     switch Input
%         case 'y'
%             behaveYM2 = behave;
%             load behave_joined;
%             cd ..
%             animaltemp = animals(iAnimal-1).name;
%             folder=animaltemp;
%             cd(folder);
%             load behave
%             behaveYM1 = behave;
%             newcol = cat(1,behaveYM1(:,4:6),behaveYM2(:,4:6));
%             behave_joined = cat(2,behave_joined,newcol);
%             cd ..
%             folder = animal;
%             cd(folder);
%             filename='behave_joined';
%             save (filename,'behave_joined')
% 
%         case 'n'
%             prompt2 = (['Does ', sprintf(animal),' contain a joined novel object file? [y/n]     ']);
%             Input2 = input(prompt2,"s")
%             switch Input2
%                 case 'y'
%                     behaveNO4 = behave;
%                     load behave_joined;
%                     cd ..
%                     animaltemp = animals(iAnimal-1).name;
%                     folder=animaltemp;
%                     cd(folder);
%                     load behave
%                     behaveNO3 = behave;
%                     newcol = cat(1,behaveNO3(:,4:6),behaveNO4(:,4:6));
%                     cd ..
%                     animaltemp = animals(iAnimal-2).name;
%                     folder=animaltemp;
%                     cd(folder);
%                     load behave
%                     behaveNO2 = behave;
%                     newcol = cat(1,behaveNO2(:,4:6),newcol);
%                     cd ..
%                     animaltemp = animals(iAnimal-3).name;
%                     folder=animaltemp;
%                     cd(folder);
%                     load behave
%                     behaveNO1 = behave;
%                     newcol = cat(1,behaveNO1(:,4:6),newcol);
%                     cd ..
%                     folder = animal;
%                     cd(folder);
%                     behave_joined = cat(2,behave_joined,newcol);
%                     filename='behave_joined';
%                     save (filename,'behave_joined');
%                 case 'n'
%             disp('No joined recordings')
%                 otherwise 
%             end 
%             
% 
%         otherwise
%     end


    clearvars -except animals iAnimal nAnimals
    close all

    cd ..
end
