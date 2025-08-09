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
MidCoords = Coords(:,14:15);
Testname = string(file(1:7));
rows = size(Coords,1);

%Open DLC .avi file
[file,path] = uigetfile(Testname+'*.avi');
if isequal(file,0);
   disp('User selected Cancel');
else
   disp(['User selected ', fullfile(file)]);
end

%Generate pixels to cm conversion factor
Rec = file;
Rec = VideoReader(Rec);
FrameData = read(Rec,200);
Frame = imshow(FrameData);
hold on
title("Position ruler for distance calibration, double-click ruler to proceed")
pixscale = imdistline;
wait(pixscale);
pixscale = getDistance(pixscale);
cmscale = 50;   % 40 for OF/NO, 50 for YM
convfac = pixscale/cmscale;

%Midbody distance travelled in pixels
DisOutput=[];
for i = 1:rows
Dis = sqrt((MidCoords((i+1),1)-MidCoords(i,1))^2+(MidCoords((i+1),2)-MidCoords(i,2))^2);
if (i+1)>=rows
    break    
end
DisOutput(i,1) = Dis;
end
DisEnd = sqrt((MidCoords((end),1)-MidCoords(end-1,1))^2+(MidCoords((end),2)-MidCoords(end-1,2))^2);
DisOutput = [0;DisOutput;DisEnd];

disp("Midbody distances calculated in pixels")
pause(3)

%Midbody distance travelled in cm
DisOutputcm = DisOutput/convfac;
disp("Midbody distances calculated in cm")
pause(3)

prompt = ("Calculate snout distances too? [y/n]     ");

Input = input(prompt,"s")

switch Input
    case 'y'
        disp("Proceeding with snout distances analysis")
        pause(3)

    SntCoords = Coords(:,2:3);
    
    %Snout distance travelled in pixels
    SntDisOutput=[];
    for i = 1:rows
    SntDis = sqrt((SntCoords((i+1),1)-SntCoords(i,1))^2+(SntCoords((i+1),2)-SntCoords(i,2))^2);
    if (i+1)>=rows
        break    
    end
    SntDisOutput(i,1) = SntDis;
    end
    SntDisEnd = sqrt((SntCoords((end),1)-SntCoords(end-1,1))^2+(SntCoords((end),2)-SntCoords(end-1,2))^2);
    SntDisOutput = [0;SntDisOutput;SntDisEnd];

    disp("Snout distances calculated in pixels")
    pause(3)

    %Snout distance travelled in cm
    SntDisOutputcm = SntDisOutput/convfac;
    disp("Snout distances calculated in cm")
    pause(3)
    
    FOutput = [[1:rows]' MidCoords DisOutput DisOutputcm SntCoords SntDisOutput SntDisOutputcm];
    OutputTable = array2table(FOutput,"VariableNames",{'Frames','XcoordsMid','YcoordsMid','MidDistance_pix','MidDistance_cm','XcoordsSnt','YcoordsSnt','SntDistance_pix','SntDistance_cm'});
    Filename = sprintf(Rec.Name(1:end-4)+"_Distance_Travelled.xlsx");
    writetable(OutputTable,Filename);

    disp("Ambulation output generated")

    case 'n'
        disp("Snout distances analysis skipped")
        pause(3)

    FOutput = [[1:rows]' MidCoords DisOutput DisOutputcm];
    OutputTable = array2table(FOutput,"VariableNames",{'Frames','Xcoords','Ycoords','Distance_pix','Distance_cm'});
    Filename = sprintf(Rec.Name(1:end-4)+"_Distance_Travelled.xlsx");
    writetable(OutputTable,Filename);

    disp("Ambulation output generated")

    otherwise
        disp("Proceeding with snout distances analysis by default")
        pause(3)
    
        SntCoords = Coords(:,2:3);
    
    %Snout distance travelled in pixels
    SntDisOutput=[];
    for i = 1:rows
    SntDis = sqrt((SntCoords((i+1),1)-SntCoords(i,1))^2+(SntCoords((i+1),2)-SntCoords(i,2))^2);
    if (i+1)>=rows
        break    
    end
    SntDisOutput(i,1) = SntDis;
    end
    SntDisEnd = sqrt((SntCoords((end),1)-SntCoords(end-1,1))^2+(SntCoords((end),2)-SntCoords(end-1,2))^2);
    SntDisOutput = [0;SntDisOutput;SntDisEnd];

    disp("Snout distances calculated in pixels")
    pause(3)

    %Snout distance travelled in cm
    SntDisOutputcm = SntDisOutput/convfac;
    disp("Snout distances calculated in cm")
    pause(3)
    
    FOutput = [[1:rows]' MidCoords DisOutput DisOutputcm SntCoords SntDisOutput SntDisOutputcm];
    OutputTable = array2table(FOutput,"VariableNames",{'Frames','XcoordsMid','YcoordsMid','MidDistance_pix','MidDistance_cm','XcoordsSnt','YcoordsSnt','SntDistance_pix','SntDistance_cm'});
    Filename = sprintf(Rec.Name(1:end-4)+"_Distance_Travelled.xlsx");
    writetable(OutputTable,Filename);

    disp("Ambulation output generated")
end
