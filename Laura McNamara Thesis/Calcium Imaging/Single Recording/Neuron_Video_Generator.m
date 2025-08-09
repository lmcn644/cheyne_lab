clear; clc; close all;
set(0,'DefaultFigureVisible','on'); %Ensures figure visibility is enabled
%parpool;

files=dir;
files(1:2,:)=[];
files = natsortfiles(files);
nFiles=size(files,1);

for iFile = 1:nFiles;
    iFile
    file=files(iFile).name;
    folder=file;
    cd(folder)
    folderlist=dir('*extraction');
    cd(folderlist(1).name)
    folderlist=dir('frames*');
    cd(folderlist(1).name)
    folderlist=dir('LOGS*');
    cd(folderlist(1).name)
    matfile = dir('*.mat');
    matfile = matfile(1,:);
    matfile = matfile.name;
    load ([matfile]);  %% opens workspace with raw cnmf_e output data

    Cn = neuron.Cn; %PNR map
    A = neuron.A; %Neuronal spatial info
    C = neuron.C; %All Neuronal temporal info
    C_raw = neuron.C_raw; % All unfiltered neuronal temporal info

    plotControl.Cn=Cn;
    plotControl.thr=0.95;
    plotControl.option=1;
    plotControl.displayLabel = 0;
    d1=size(Cn,1);
    d2=size(Cn,2);

    cd ..
    cd ..
    cd ..

    filecheck = isfile(fullfile(cd, "Cell_Sorting.mat")); %Get neurons assigned for having videos made, these are stored in 'Cell_Sorting.mat'
    if filecheck == 1;
        load Cell_Sorting.mat
    else
        disp("Cells have not been sorted yet, run 'Post_CNMFE_sorting.m' first.");
        return
    end

    Cellnum = Video';  %Uses Video variable to obtain relevant cell numbers (can override if desired)

    for celli = 2      %Cellnum
        cell = A(:,celli);

        [coor, contourInfo] = plotROIContour(cell, d1, d2, plotControl); %%third-party function that plots contours for neurons
        hold on
        t = title("Neuron "+celli);
        t.FontSize = 16;
        hold off
        movegui([5 550]); %specifies location on screen

        %%%%%%%%%%%%%%%%%%
        
        trace = C(celli,:); %filtered temporal data of specific neuron
        raw_trace = C_raw(celli,:); %raw temporal data of specific neuron

        width=30; % set min peak width
        height=(std((C_raw(iCell,:))))/2; % set min peak height
        peakdata = [];
        [PKS,LOCS]=findpeaks(C(celli,:),'MinPeakWidth',width,'MinPeakHeight',height,'MinPeakDistance',85);
        nPeaks=size(PKS,2); %Loop that identifies what would be considered peaks in the calcium data
        if nPeaks>0;
            peakdata(:,1)=LOCS';
            peakdata(:,2)=PKS';
        end
        
        %% plots the temporal data and peaks onto a graph - use to determine which frames should be made into a video
        figure
        traceplot = plot(trace,LineWidth=2);
        xlim([0 size(trace,2)]);
        Ct = title("Neuron "+celli+" Calcium Trace");
        Ct.FontSize = 16;
        xlabel("Frame");
        ylabel("dF / F0");
        hold on
        rawtraceplot = plot(raw_trace);
        
        if nPeaks>0;
        scattersz = 100;
        Peaks = scatter(peakdata(:,1),peakdata(:,2),scattersz,"filled");
        legend(["Calcium Trace","Raw Calcium Trace","Peaks"],'fontsize',10);
        hold off
        movegui([575 50]);
        else 
        legend(["Calcium Trace","Raw Calcium Trace"],'fontsize',10);
        hold off
        movegui([575 50]);
        end
        
        %%%%%%%%%%%%%%%

        minframe = input('Set the first frame of the video:   ');  %Manually assign first frame of the video
        maxframe = input('Set the final frame of the video:   ');  %Manually assign last frame of the video, don't recommend making longer than 5000 frames 

        close all

        contourarray = coor{1,1};  %array with pixel coordinates for neuron contour position
        contourarray(:,1) = [];
        mask =  poly2mask(contourarray(2,:),contourarray(1,:),d1,d2); %Creates mask for the neuron of interest
        mask = double(mask(:,:)); %Turns logical array to a double
%         mask(mask==0) = NaN;

        stackdir = dir('*joined2.tif'); %stack directory requires having the post-normcorre scope footage

        %Create file for frames
        filename = string(stackdir.name(1:end-4));
        newfolname = (filename+'_NeuronContourCell'+string(celli)+'_frames'+string(minframe)+'-'+string(maxframe));
        newfol = mkdir(newfolname);
        addpath(newfolname+'\');
        cd(newfolname);
        Folder = cd;
        vidname = string(newfolname+'.avi');

        newframestack = [];

      %% Applies neuron mask to every frame of the recording and creates a stack from these new frames
        for framei = minframe:maxframe
            frame = imread(stackdir.name,'Index',framei);
            frame = mat2gray(frame);
            maskedframe = bsxfun(@times, frame, cast(mask, 'like', frame));
            newframestack = cat(3,newframestack,maskedframe);
        end
      
%%%%%%%%%%%%%%

        v = VideoWriter(vidname,'Uncompressed AVI');  %creates object to write video onto
        open(v);
        set(0,'DefaultFigureVisible','off'); %stops frames from popping up while code runs

        for i = 1:[maxframe-minframe+1]
        figure
%         f = imshow(newframestack(:,:,i));
        f = imagesc(newframestack(:,:,i)); axis off;
        colormap jet;   %applies colourmap to every frame of the recording   

%% Can have colorbar and title, but these will reduce the resolution of the neuron itself 
%         colorbar;
%         title("Frame "+string([i+minframe-1])); 
        fim = getframe(gcf); %captures frame for the video
        writeVideo(v,fim); %writes frame to video
        close all
        end
        close(v);

        close all
        set(0,'DefaultFigureVisible','on'); %makes figures visible again
       
        cd .. 

        Video(Video == celli) = []; %Removes cell from Video for variable after the video is created
        Redo(end+1) = celli;  % Adds cell to the Redo variable so it can be reassigned in 'Post-CNMFE_sorting.m'
        Redo = sort(Redo);
end

save("Cell_Sorting.mat","Keep","Delete","Video","Redo");
cd ..
clearvars -except nFiles iFile files

end