 %% Script to find auditory stimuli (abf recording) and reponses (calcium imaging)
% This script uses third part script 'abfload', and requires an excel file of stimuli sequence

clear
close all
clc

parent_dir = pwd; 

recLength = 5;   % recording length in minutes

%% Make a new folder

aFile= isfolder('abf');
if aFile==1;
    ;
else aFile == 0;
    mkdir ('abf');
end

%% Get nFrames for all images

FolderList = dir(['DFs/','*mat']);

for iFile = 1:size(FolderList,1);
    file = FolderList(iFile).name;
    matObj = matfile(['DFs/',file]);
    [nrows ncol nframe] = size(matObj,'stack');    
    nFrameInfo(iFile,1) = nframe; 
end

clear matObj
clear ncol
clear nrow
clear nFrames

%% Getting tone file 

cd('P:\1. Auditory Recordings Data\Tonefile');
tonesequence = xlsread('Tone sequence3');

% tonefile = dir(['Tonefile/','*.xls']); %tonefile is the sequence of sound frequencies as an excel file
% tonename = tonefile(1).name;
% tonesequence = xlsread(['Tonefile/',tonename]); %load the excel file


% cd('F:\Mayas data\Tonefile'); 
% tonesequence = xlsread('Tone sequence 1.xls');

cd(parent_dir);


%% Getting abf recordings.

FileList = dir(['EP/', '*.abf']);       % Get EP file names
nFiles = size(FileList, 1);

imageFile = dir(['DFs/','*.mat']);

for iFile = 1 :nFiles  % set trial to be run
    
    imFilename = imageFile(iFile).name;
        
    nFrames=nFrameInfo(iFile,1); %change this iFile+ number to choose correct images for chosen stimfile   
    stimuli=[];
    % Set file
    file = [FileList(iFile).name];  % Get EP file name
    data=abfload (['EP/',file],'channels',{'IN 1'}); %load EP file
    data=reshape(data,[size(data,1)*size(data,3),size(data,2)]);
   

    filename = sprintf([num2str(imFilename(1:end-4)),'abf.mat']);
    save(['abf/',filename],'data'); 
    
%     data = detrend(data); % baseline

    temp(iFile,1)=std(data);
    temp(iFile,2)=max(data);
    temp(iFile,3)=min(data);
    
    figure;
    plot(data); %create figure of EP trace
    
    if size(temp,2)<4 || temp(iFile,4)==0 % if no threshold present
        [r,c]= find(temp(1:iFile-1,1)<temp(iFile,1)*1.2 & temp(1:iFile-1,1)>temp(iFile,1)*0.8); % if similar SD already given threshold use the same
        if size(r,1)>0
            temp(iFile,4)=temp(r(1,1),4);
        end
        if size(r,1)==0 % else enter a threshold
            t = input('Threshold: '); %request entering a value
            temp(iFile,4)=t;
        end
    end
    
    
    %% Get start and end of stimuli
    
    t=temp(iFile,4);
    if t<0 %if threshold is set as a negative value
        startframe = find (data<t);
    elseif t>0  %altered to find positive and negative values over threshold
        startframe = find (data>t | data<(0-t));
    end
    
    if  size(startframe,1)>1
        startframe = cat(1,0,startframe);
        interval = 10000; %number of data points between each stimuli
        % The distance between the start of the first tone and the start of the second tone
        % 10000 for different dB
        
        %get ends of stimuli
        diffStart = diff(startframe);
        ind = diffStart > interval;
        endframe=startframe(ind,:);
        endframe(1,:)=[];
        
        % get start of stimuli
        diffStart = cat(1,0,diffStart);
        ind = diffStart > interval;
        startframe = startframe(ind,:);
        cali=size(data,1)/nFrames; % Convert abf time to frames
        
        %create first figure
        x=[(1/cali):(1/cali):nFrames];
        
        figure
        plot(x,data);
        hold on
        scatter(startframe/cali,[repmat(0,size(startframe,1),1)],'g') %add stimuli onsets
        scatter(endframe/cali,[repmat(0,size(endframe,1),1)],'r') %add stimuli offsets
               
        
        % ensure they are the same length
        if length(startframe)>length(endframe)&& max(startframe)>= max(endframe)
            % When there is one extra incomplete startframe at the end
            % When there are more startframe because there is an extra incomplete startframe
            startframe(end,:)=[];
        elseif size(endframe,1)>size(startframe,1)&& min(startframe)>= min(endframe)
            % When there is an extra endframe at the beginning of the recording
            startframe=cat(1,NaN,startframe);
            % insert a NaN at the top to balance the unpaired endframe.
        end
        
        % check start and end in right places
        gap=endframe-startframe;
        [r,c]=find(gap>mode(gap)*1.5 | gap<mode(gap)*0.5);
        startframe(r,c)=NaN;
        endframe(r,c)=NaN;
        
        startframe = fillmissing(startframe,'linear'); 
        endframe = fillmissing(endframe,'linear');
        %Fills in the missing values using linear interpolation
        
        % Remove the first repeated tone
        startframe(1,:) = [];
        endframe(1,:) = [];
        
        figure
        plot(x,data);
        hold on
        scatter(startframe/cali,[repmat(0,size(startframe,1),1)],'g')
        scatter(endframe/cali,[repmat(0,size(endframe,1),1)],'r')
        xlabel('Time (frames)');
        ylabel('Voltage (mV)');

%        filename = sprintf([num2str(file(1:end-4)),' Auditory stimuli timing - frames'],'%d.png');
%        %saveas(gcf, [filename], 'png'); %uncomment to save image of plot with frames on x axis


        %% Finding wrong startframes and endframes
        % assume the wrong frame points has decimals numbers

        check=[];
        check(:,1)=startframe;
        check(:,2)=endframe;
        check(:,3)=endframe-startframe;
        
        und = [];
        for cc = 1:size(check,2)
            for rr = 1:size(check,1)
                box = check(rr,cc);
                string = num2str(box);
                h = strfind(string,'.');

                if  isempty(h);
                    und(rr,cc) = 0;
                else h > 0;
                    und(rr,cc) = 1;
                end
            end
        end
        
        [row col] = find(und == 1);
        want = unique(row);
      
      %  check(want,:) = [];

        startframe = check(:,1);
        endframe = check(:,2);

            
        %% Plot rescaled to minutes
        cali=size(data,1)/(recLength*60)*60;
        x=[(1/cali):(1/cali):recLength]; %scale for x axis converted to mins
        
        figure
        plot(x,data);
        hold on
        scatter(startframe/cali,[repmat(0,size(startframe,1),1)],'g')
        scatter(endframe/cali,[repmat(0,size(endframe,1),1)],'r')
        xlabel('Time (min)');
        ylabel('Voltage (mV)');
        % filename = sprintf([num2str(file(1:end-4)),' Auditory stimuli timing - mins'],'%d.png');
        % saveas(gcf, [filename], 'png'); %uncomment to save image of plot with minutes on x axis
      
       
        cali=size(data,1)/nFrames;
        stimuli(:,1)=round2(startframe/cali,0.05); %first column is onsets of stimuli
        stimuli(:,2)=round2(endframe/cali,0.05); %second column is offsets of stimuli
        
        if size(stimuli,1) > size(tonesequence,1)
           stimuli(121:end,:) = [];
        else size(stimuli,1) < size(tonesequence,1)
            tonesequence((size(stimuli,1)+1):end,:)=[];
        end

        %% Getting frequency
        
        stimuli(:,3)=tonesequence(:,1); %add the frequency of each stimuli in 3rd column
        stimuli(:,4)=tonesequence(:,2);

        newname=[imFilename(1:end-4) ' stimuli', '.mat']; %set name for stimuli file
        save (newname,'stimuli') %save matfile of stimuli on and offsets and frequencies
   
        close all
    end
end

% need to ensure only the 60 tones are included (there should be in total 120 tones


