%Open DLC .csv file
clc
[file,path] = uigetfile('*MODIFIED.csv');
if isequal(file,0);
   disp('User selected Cancel')
else
   disp(['User selected ', fullfile(file)])
end

DLCfile = file;
DLCfile = open(DLCfile);
Coords = DLCfile.data;
MidCoords = Coords(:,14:15); %Ensure columns are for coordinates of interest
MidCoordsrd = round(MidCoords);
Testname = string(file(1:7));
rows = size(Coords,1);

%Open DLC .avi file
[file,path] = uigetfile(Testname+'*.avi');
if isequal(file,0);
   disp('User selected Cancel');
else
   disp(['User selected ', fullfile(file)]);
end

%Create Mask
Rec = file;
Rec = VideoReader(Rec);
FrameData = read(Rec,200);
Frame = imshow(FrameData);
hold on
title("Draw ROI for Interior")
ROI = drawpolygon; %Can use either drawpolygon or drawrectangle.
hold off
Mask = createMask(ROI);
%imshow(Mask) %Can use to see Interior mask if needed.

Location = [];

for i = 1:rows;
x = Mask(MidCoordsrd(i,2), MidCoordsrd(i,1));
 if x == logical(0);
       y = abs(x);
    elseif x == logical(1);
       y = abs(x);
    else
 end
Location(i,1) = y;
end

Output = [[1:rows]' MidCoords Location];
OutputTable = array2table(Output,"VariableNames",{'Frames','Xcoords','Ycoords','InInt'});
Filename = sprintf(Rec.Name(1:end-4)+"_ROIoutput.xlsx");
writetable(OutputTable,Filename);

disp("ROI analysis complete")


