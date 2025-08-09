%Open DLC .csv file
clc
[file,path] = uigetfile('*.csv');
if isequal(file,0);
   disp('User selected Cancel')
else
   disp(['User selected ', fullfile(file)])
end

DLCfile = file;
DLCfile = open(DLCfile);
Coords = DLCfile.data;
SntCoords = Coords(:,2:3); %Ensure columns are for coordinates of interest
SntCoordsrd = round(SntCoords);
Testname = string(file(1:7));
rows = size(Coords,1);

%Open DLC .avi file
[file,path] = uigetfile(Testname+'*.avi');
if isequal(file,0);
   disp('User selected Cancel');
else
   disp(['User selected ', fullfile(file)]);
end

%Create Masks
Rec = file;
Rec = VideoReader(Rec);
FrameData = read(Rec,200);
Frame = imshow(FrameData);
hold on
title("Position ROI for familiar object, double-click ROI to proceed")
ROIfam = images.roi.Circle(gca,'Center',[100 100],'Radius',[sqrt(625/pi)],'Color','r','Label','Familiar','LabelAlpha',[0],'LabelTextColor','r');
wait(ROIfam)
ROInov = images.roi.Circle(gca,'Center',[100 150],'Radius',[sqrt(625/pi)],'Color','b','Label','Novel','LabelAlpha',[0],'LabelTextColor','b');
title("Position ROI for novel object, double-click ROI to proceed")
wait(ROInov)
hold off
Maskfam = createMask(ROIfam);
Maskfam = 1*Maskfam;
Masknov = createMask(ROInov);
Masknov = 2*Masknov;
FinalMask = Maskfam + Masknov;
%imshow(Mask'') %Can use to see mask if needed.

Int = [];

%Interaction Analysis
for i = 1:rows;
x = FinalMask(SntCoordsrd(i,2), SntCoordsrd(i,1));
 if x == abs(0);
       y = abs(x);
    elseif x == abs(1);
       y = abs(x);
    elseif x ==abs(2);
       y = abs(x);
    else
 end
Int(i,1) = y
end

Intfam = changem(Int,0,2);
Intnov = changem(Int,0,1);
Intnov = changem(Intnov,1,2);

Output = [[1:rows]' SntCoords Intfam Intnov];
OutputTable = array2table(Output,"VariableNames",{'Frames','Xcoords','Ycoords','Familiar Int','Novel Int'});
Filename = sprintf(Rec.Name(1:end-4)+"_Interaction_output.xlsx");
writetable(OutputTable,Filename);

disp("Interaction analysis complete")

%%%Enable this section of code to check interaction numbers from existing outputs

%[file,path] = uigetfile("*_Interaction_output.xlsx");
%if isequal(file,0);
%   disp('User selected Cancel')
%else
%   disp(['User selected ', fullfile(file)])
%end

%Intfile = file;
%Intfile = open(Intfile);
%Output = Intfile.data;

%Calculates number of interactions
Intnum = diff(Output(:,4:5));
Intnum(isnan(Intnum)) = 0;
ind=Intnum==1;

%Corrects for if animal is interacting with object from first frame
check = find(Output(1,4:5),1);
    if check == 1
        startint = "familiar";
        ind(1,1) = ind(1,1) + 1;
    elseif check == 2
        startint = "novel";
        ind(1,2) = ind(1,2) + 1;
    else
    end

AllInt = [];
AllInt=cat(1,AllInt,sum(ind)); %number of interactions with each object
Intfamnum = AllInt(1,1);
Intnovnum = AllInt(1,2);

disp("Number of familiar object interactions: "+Intfamnum)
disp("Number of novel object interactions: "+Intnovnum)