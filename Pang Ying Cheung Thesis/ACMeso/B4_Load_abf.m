 %% Script to find auditory stimuli (abf recording) and reponses (calcium imaging)
% This script uses third part script 'abfload', and requires an excel file of stimuli sequence

clear
close all
clc


recLength = 20;   % recording length in minutes

%% Make a new folder

aFile= isfolder('abf');
if aFile==1;
    ;
else aFile == 0;
    mkdir ('abf');
end

%% Get nFrames for all images

imageFile = dir(['DFs/','*mat']);

for iFile = 1:size(imageFile,1);
    file = imageFile(iFile).name;
    matObj = matfile(['DFs/',file]);
    [nrows ncol nframe] = size(matObj,'stack');    
    nFrameInfo(iFile,1) = nframe; 
end

clear matObj
clear ncol
clear nrow
clear nFrames

%% Getting abf recordings.

FileList = dir(['EP/', '*.abf']);       % Get EP file names
nFiles = size(FileList, 1);


% for iFile = 1 :nFiles  % set trial to be run
    
iFile = 1


tonesequence = xlsread(['F:\Analysis\Mesoscope AC\March2023Tonelist.csv']);

imFilename = imageFile(iFile).name;

nFrames=nFrameInfo(iFile,1); %change this iFile+ number to choose correct images for chosen stimfile

if nFrames > 12000;
    nFrames = 12000;
else nFrames < 12000;
    nFrames = nFrames;
end

stimuli=[];
% Set file
file = [FileList(iFile).name];  % Get EP file name
data=abfload (['EP/',file],'channels',{'IN 1'}); %load EP file
data=reshape(data,[size(data,1)*size(data,3),size(data,2)]);


filename = sprintf([num2str(imFilename(1:end-4)),'_abf.mat']);
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

% Threshold = 0.3 for Mesoscope AC adult recordings

%% Get start and end of stimuli

t=temp(iFile,4);
if t<0 %if threshold is set as a negative value
    startframe = find (data<t);
elseif t>0  %altered to find positive and negative values over threshold
    startframe = find (data>t | data<(0-t));
end

size(startframe,1)>1
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

endframe(end+1,1) = startframe(end,1)+(round(mean(endframe-startframe(1:end-1,1)))) ;

figure
plot(x,data);
hold on
scatter(startframe/cali,[repmat(0,size(startframe,1),1)],'g') %add stimuli onsets
scatter(endframe/cali,[repmat(0,size(endframe,1),1)],'r') %add stimuli offsets

%%% Remove the first repeated tone
startframe(1,:) = [];
endframe (1,:) = [];

figure
plot(x,data);
hold on
scatter(startframe/cali,[repmat(0,size(startframe,1),1)],'g')
scatter(endframe/cali,[repmat(0,size(endframe,1),1)],'r')
xlabel('Time (frames)');
ylabel('Voltage (mV)');

%%% Check if some tones were not delivered (must be done manually)
% For this data set, look at row that show >16000 in 'placing', this means a tone delivery was missed
% Record row number for the first missing tone, record 1+row number of second missing tone and 2+row number of third missing tone
% In 'tonesequence' delete the rows that were recorded
% They tend to be 20 kHz, 60 dB 

st_diff = diff(startframe);
placing = cat(1,0,st_diff);



%%

cali=size(data,1)/nFrames;
stimuli(:,1)=round2(startframe/cali,0.05); %first column is onsets of stimuli
stimuli(:,2)=round2(endframe/cali,0.05); %second column is offsets of stimuli

stimuli(:,3)=tonesequence(:,1); %add the frequency of each stimuli in 3rd column
stimuli(:,4)=tonesequence(:,2);

newname=[imFilename(1:end-4) ' stimuli', '.mat']; %set name for stimuli file
save (newname,'stimuli') %save matfile of stimuli on and offsets and frequencies

close all

iFile = iFile + 1
