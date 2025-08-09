%Open YM ROIoutput .xlsx file
clc
[file,path] = uigetfile('*_ROIoutput.xlsx');
if isequal(file,0);
   disp('User selected Cancel')
else
   disp(['User selected ', fullfile(file)])
end

ROIdata = file;
ROIdata = open(ROIdata);
ROIs = ROIdata.data(:,4:6);
[rows,cols] = size(ROIs);
AllData=[];

%Calculate alterations
alt=diff(ROIs);
alt(isnan(alt))=0;
ind=alt==1;

%Corrects for if animal is positioned in an arm from first frame
check = find(ROIs(1,:),1);
    if check == 1
        startpos = "left arm";
        ind(1,1) = ind(1,1) + 1;
    elseif check == 2
        startpos = "right arm";
        ind(1,2) = ind(1,2) + 1;
    elseif check == 3
        startpos = "novel arm";
        ind(1,3) = ind(1,3) + 1;
    else
    end

AllData=cat(1,AllData,sum(ind)); %number of entries into each arm

%Spontaneous alterations
entries=[];
count=0;
for iFrame=1:size(alt,1)
   if sum(ind(iFrame,:))>0
       count=count+1;
       entries(count,1:3)=ind(iFrame,:);
       entries(count,4)=iFrame;
   end
end

nEntries=size(entries,1);
for iFrame=3:nEntries;
    if sum(sum(entries(iFrame-2:iFrame,1:3))==[1,1,1])==3
        entries(iFrame,5)=1;
    elseif sum(sum(entries(iFrame-2:iFrame,1:3))==[1,1,1])~=3
        entries(iFrame,5)=0;
    end
end 
if size(entries,2)==4
   entries(:,5)=0;
end

alt_num = sum(entries(:,5)); %Number of spontaneous alterations
leftent = AllData(1,1); %Number of entries into left arm
rightent = AllData(1,2); %Number of entries into right arm
novent = AllData(1,3); %Number of entries into novel arm

%Percentage of Spontaneous Alterations
entries(nEntries+1:end,:)=[];
Percent_alt = [];
percent_SA=alt_num/(nEntries-2)*100;

%Outputs
FOutput = [leftent rightent novent nEntries alt_num percent_SA];
OutputTable = array2table(FOutput,"VariableNames",{'Left Entries' 'Right Entries' 'Novel Entries' 'Total Entries','SA','SA %'});
Filename = sprintf(file(1:end-24)+"_Spontaneous_Alterations.xlsx");
writetable(OutputTable,Filename); %Disable if don't want results written to Excel

clc
disp("Number of left arm entries: "+leftent)
disp("Number of right arm entries: "+rightent)
disp("Number of novel arm entries: "+novent)
disp("Total number of arm entries: "+nEntries)
disp("Spontaneous alterations: "+alt_num)
disp("Spontaneous alteration %: "+percent_SA)

