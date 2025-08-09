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

%Create Masks
Rec = file;
Rec = VideoReader(Rec);
FrameData = read(Rec,200);
Frame = imshow(FrameData);
hold on
title("Draw ROI for Left Arm")
ROIL = drawpolygon;
title("Draw ROI for Right Arm")
ROIR = drawpolygon;
title("Draw ROI for Novel Arm")
ROIN = drawpolygon;
hold off
MaskL = createMask(ROIL);
MaskL = 1*MaskL;
MaskR = createMask(ROIR);
MaskR = 2*MaskR;
MaskN = createMask(ROIN);
MaskN = 3*MaskN;
MaskFinal = MaskL + MaskR + MaskN;
%imshow(Mask'') %Can use to see mask if needed.

Location = []; 

%ROI Analysis
for i = 1:rows;
x = MaskFinal(MidCoordsrd(i,2), MidCoordsrd(i,1));
 if x == abs(0);
       y = abs(x);
    elseif x == abs(1);
       y = abs(x);
    elseif x == abs(2);
       y = abs(x);
    elseif x == abs(3);
       y = abs(x);
    else
 end
Location(i,1) = y;
end

%Excel Output
Output = [[1:rows]' MidCoords Location];
OutputTable = array2table(Output,"VariableNames",{'Frames','Xcoords','Ycoords','Arm'}); %NOTE: 0=in centre, 1=left, 2=right, 3=novel
Filename = sprintf(Rec.Name(1:end-4)+"_ROIoutput.xlsx");
writetable(OutputTable,Filename);

disp("ROI analysis complete")
