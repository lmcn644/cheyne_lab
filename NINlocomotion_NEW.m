%% Spiking during movement
%% clear the workspace and select data
clear; clc; close all;

%%
animals=dir;
animals(1:2,:)=[];
animals = natsortfiles(animals);
nAnimals=size(animals,1);
for iAnimal = 1:nAnimals; % 1:nAnimals for OF, 2:2:nAnimals for YM, 4:4:nAnimals for NO    %Will only work if cnmfe has been run
    iAnimal
    tic
    animal=animals(iAnimal).name;
    folder=animal;
    cd(folder)
    load firing_freq

%     prompt = ("Is this a joined recording? [y/n]     ");
%     Input = input(prompt,"s")
%     switch Input
% 
%         case 'y'
%             load behave_joined
%             behave = behave_joined;
% 
%         case 'n'
%             load behave
% 
%         otherwise
%             disp("Invalid input")
%             cd ..
%             return
%     end

    nLocs=size(behave,1);

    %% plot ambulation  
    plot(behave(:,2)/1000, behave(:,6));
    xlabel('Time (s)');
    ylabel('Distance (cm)');
    
    %% Correlate number of action potentials in each bin to distance moved
    Freq=[];
    tDist=[];
    bin=300; %300 frames/10 seconds
    
    for iBin=1:nFrames/bin
        ind=final_peakdata(:,2)>=bin*iBin+1-bin & final_peakdata(:,2)<bin*iBin+1; %Index indicating which cells fired in a particular bin
        Freq=cat(1,Freq,sum(ind)); %Number of peaks in that bin
        ind=behave(:,3)>=bin*iBin+1-bin & behave(:,3)<bin*iBin+1; %Index that filters for locomotion occuring within that specific bin
        tDist=cat(1,tDist,sum(behave(ind,6))); %Total distance travelled within a particular bin
    end
    
    figure
    scatter(tDist,Freq,'fill');
    hold on;
    % linear regression
    x=tDist;
    y=Freq;
    [P] = polyfit(x,y,1); %First degree polynomial means the line will be linear (y = mx + c), the outputs of 'P' will be the gradient P(1) and the y-axis intercept P(2)
    yfit = P(1)*x+P(2); % Gives approximated y-values for a line of best fit, based on the polynomial coefficients from 'P'. 
    plot(x,yfit,'r-.');
    Rsqu = "R^2 = " + string([corr(x,y)]^2); 
    dim = [.2 .6 .1 .1];
    annotation('textbox',dim,'String',Rsqu);
    xlabel('Distance (cm)'); %Distance travelled in that bin
    ylabel('Number of action potentials per 10-second bin');
    hold off;
%     pause

    filename = sprintf(['Action Potentials per 10-second Movement Bins', '%d.png']);
    saveas(gcf,filename,'png');
    
    %% Mean firing during movement vs stationary

    Freq=[];
    tDist=[];
    bin=15; %Every 15 frames
    
    for iBin=1:nFrames/bin;
        ind=final_peakdata(:,2)>=bin*iBin+1-bin & final_peakdata(:,2)<bin*iBin+1;
        Freq=cat(1,Freq,sum(ind));
        ind=behave(:,3)>=bin*iBin+1-bin & behave(:,3)<bin*iBin+1;
        tDist=cat(1,tDist,sum(behave(ind,6)));
    end
    
    t_move=0.1*bin; % threshold of movement
    
    %Animal is considered stationary if it moves less than t_move within a bin
    for i=1:size(tDist,1);
        if tDist(i,1)<t_move
            tDist(i,2)=1;
        end
    end

    ind = logical(tDist(:,2)); %creates an index indicating whether the animal is in motion or not for each bin (0 = moving, 1 = still)
    
    stats(1,1)=mean(Freq(ind,1)); %Calculates mean numbers of peaks fired per bin while the animal is stationary
    stats(1,2)=std(Freq(ind,1)); %Calculates std for previous mean
    ind=~ind; %inverses the index
    stats(2,1)=mean(Freq(ind,1)); %Calculates mean numbers of peaks fired per bin while the animal is in motion
    stats(2,2)=std(Freq(ind,1)); %Calculates std for previous mean
    
    figure
    x = 1:2;
    data = stats(:,1); %means
    errhigh = stats(:,2);
    errlow  = stats(:,2);
    bar(x,data)
    hold on
    er = errorbar(x,data,errlow,errhigh);
    er.Color = [0 0 0];
    er.LineStyle = 'none';
    
    xlabel('Still  vs   Moving')
    ylabel('Mean peaks per bin (peaks per 15 frames)')
    hold off
    pause
    
    %%
    
    save locomotion  %saves entire workspace for ease of figure generation
    clearvars -except animals iAnimal nAnimals
    close all
    cd ..
    
end
