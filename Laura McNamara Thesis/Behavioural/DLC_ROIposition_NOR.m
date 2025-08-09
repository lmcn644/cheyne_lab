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
title("Draw ROI for Top Left")
ROITL = drawrectangle(LineWidth=0.1,FixedAspectRatio=1,AspectRatio=1);
title("Draw ROI for Bottom Left")
ROIBL = drawrectangle(LineWidth=0.1,FixedAspectRatio=1,AspectRatio=1);
title("Draw ROI for Top Right")
ROITR = drawrectangle(LineWidth=0.1,FixedAspectRatio=1,AspectRatio=1);
title("Draw ROI for Bottom Right")
ROIBR = drawrectangle(LineWidth=0.1,FixedAspectRatio=1,AspectRatio=1);
hold off
MaskTL = createMask(ROITL);
MaskTL = 1*MaskTL;
MaskBL = createMask(ROIBL);
MaskBL = 2*MaskBL;
MaskTR = createMask(ROITR);
MaskTR = 3*MaskTR;
MaskBR = createMask(ROIBR);
MaskBR = 4*MaskBR;

FinalMask = MaskTL + MaskBL + MaskTR + MaskBR;
%imshow(Mask'') %Can use to see mask if needed.

Location = []

%ROI Analysis
for i = 1:rows;
x = FinalMask(MidCoordsrd(i,2), MidCoordsrd(i,1));
 if x == abs(0);
       y = abs(x);
    elseif x == abs(1);
       y = abs(x);
    elseif x == abs(2);
       y = abs(x);
    elseif x == abs(3);
       y = abs(x);
    elseif x == abs(4);
       y = abs(x);
    else
 end
Location(i,1) = y
end

%Excel Output
Output = [[1:rows]' MidCoords Location];
OutputTable = array2table(Output,"VariableNames",{'Frames','Xcoords','Ycoords','Location'}); %NOTE: 1=TL, 2=BL, 3=TR, 4=BR
Filename = sprintf(Rec.Name(1:end-4)+"_ROIoutput.xlsx");
writetable(OutputTable,Filename);

disp("ROI analysis complete")
