%Use to format .mp4 files from webcamera.io so they are analysable by DLC
%Before running code, use https://cloudconvert.com/mp4-to-avi to convert to .avi

%Open unformatted .avi file to convert
clc
[file,path] = uigetfile('*.avi');
if isequal(file,0);
   disp('User selected Cancel')
else
   disp(['User selected ', fullfile(file)])
end

vid = file;
vid = VideoReader(vid);
frameN = vid.NumFrames;

%Create file for frames
oldfol = cd;
filename = string(vid.Name(1:end-4));
vidname = string(filename+'.avi');
newfol = mkdir(filename+'_newvid\');
addpath(filename+'_newvid\')
cd(filename+'_newvid')
Folder = cd;

%Crop frame until view is similar to NINscope software
setframe = read(vid,200);
imshow(setframe)
hold on
dims = drawrectangle(FixedAspectRatio=true,AspectRatio=1); %AspectRatio=0.75 for YM, AspectRatio=1 for OF/NO
hold off

%Formats every frame
for i=1:frameN
frame = read(vid,i);    
frame = rgb2gray(frame);
%imshow(frame)
framecropped = imcrop(frame,dims.Position);
%imshow(framecropped);
finalframe = imresize(framecropped,[401 401]);  %[401 401] for OF/NO, [480 640] for YM
%imshow(finalframe)
imwrite(finalframe, fullfile(Folder, sprintf('%04d.tiff',i)));
end

Filelist = dir(Folder);
Filelist = Filelist(3:end,:)
stack=[];

%Creates stack from image data
for iFile=1:frameN
    filename=Filelist(iFile).name;
    t = Tiff(filename,'r');
    imageData = read(t);
    stack(:,:,iFile)=imageData;
end

%Writes stack into a video
I=[];
I=mat2gray(stack); 
v = VideoWriter(vidname,'Grayscale AVI');
open(v)
writeVideo(v,I)
close(v)
