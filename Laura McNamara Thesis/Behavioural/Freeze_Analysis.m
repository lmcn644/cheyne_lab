%Open distance travelled .xlsx file
clc
[file,path] = uigetfile('*Distance_Travelled.xlsx');
if isequal(file,0);
   disp('User selected Cancel')
else
   disp(['User selected ', fullfile(file)])
end

DisFile = file;
DisFile = open(DisFile);
DisData = DisFile.data;
MidDiscm = DisData(:,5); %Midbody distance travelled data
SntDiscm = DisData(:,9); %Snout distance travelled data

Framegrp = 10 %Determines how many frames are grouped together, can change for accuracy

%Groups midbody distances travelled into bins specified by Framegrp
[row,col] = size(MidDiscm); %https://www.mathworks.com/matlabcentral/answers/409290-how-can-i-sum-every-nth-row 
index = 1:row;
scaffold = [repmat(Framegrp,1,floor(row/Framegrp))];
[scafrow,scafcol] = size(scaffold);
  rmndr = row-sum(scaffold);
   if(~rmndr)
     rmndr = [];
   end

indexF = mat2cell(index,1,[scaffold,rmndr])';
MidDiscm_sec = cell2mat(cellfun(@(x) sum(MidDiscm(x,:),1),indexF,'un',0));
MidDiscm_sec = MidDiscm_sec(1:scafcol,1); %Currently deleting rmndr, doesn't provide fair assessment of freezing.

%Groups snout distances travelled into bins specified by Framegrp
[row,col] = size(SntDiscm); %https://www.mathworks.com/matlabcentral/answers/409290-how-can-i-sum-every-nth-row 
index = 1:row;
scaffold = [repmat(Framegrp,1,floor(row/Framegrp))];
[scafrow,scafcol] = size(scaffold);
  rmndr = row-sum(scaffold);
   if(~rmndr)
     rmndr = [];
   end

indexF = mat2cell(index,1,[scaffold,rmndr])';
SntDiscm_sec = cell2mat(cellfun(@(x) sum(SntDiscm(x,:),1),indexF,'un',0));
SntDiscm_sec = SntDiscm_sec(1:scafcol,1); %Currently deleting rmndr, doesn't provide fair assessment of freezing.

DisArray = [SntDiscm_sec MidDiscm_sec];

freeze = []

%Determines if animal is freezing for each bin, based on if both snout and midbody distances are below a cutoff.
 for i = 1:scafcol
     if DisArray(i,1)<=1.75 && DisArray(i,2)<=3 %Can alter these to adjust distance threshold for freezing.
         x = 100
     else
         x = 0
     end
freeze(i,1) = x
 end

%Expands binned array back out into original frame count.
Finfreeze = repelem(freeze,Framegrp,1);
Outputsize = size(Finfreeze,1);

%Generates Excel output
Output = [[1:Outputsize]' SntDiscm(1:Outputsize) MidDiscm(1:Outputsize) Finfreeze];
OutputTable = array2table(Output,"VariableNames",{'Frames','Snout Distances','Midbody Distances','Freezing'});
Filename = sprintf(file(1:end-33)+"_Freezing_output.xlsx");
writetable(OutputTable,Filename);

%%%%%%%%%%%%%%%%%%%%%%%%%
%Can enable to generate graphs

%eztrack = open('F6_NO1_12_09_07_FreezingezTrack.csv')

%ezdata = eztrack.data;
%ezfreeze = ezdata(:,6)

%area(ezfreeze)
%hold on
%area(Finfreeze)
%hold on
%plot(MidDisData(:,4))
%hold off