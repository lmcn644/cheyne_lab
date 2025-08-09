clear; clc; close all;

files=dir;
files(1:2,:)=[];
files = natsortfiles(files);
nFiles=size(files,1);

for iFile = 1:nFiles;
    iFile;
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
    A = neuron.A; %All Neuronal spatial info
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

    NeuNum = size(A,2); %Number of neurons


    filecheck = isfile(fullfile(cd, "Cell_Sorting.mat"));
    if filecheck == 1;
        load Cell_Sorting.mat
    else
        Keep_clean = [];
        Keep_noisy = [];
        Delete = [];
        Video = [];
    end

    exist Redo;
    if ans == 1
        NeuNum = Redo';
        RedoNew = [];

for celli = NeuNum
        cell = A(:,celli); %spatial data of specific neuron

        [coor, contourInfo] = plotROIContour(cell, d1, d2, plotControl); axis off; %plots contour for specific neuron
        hold on
        t = title("Neuron "+celli);
        t.FontSize = 16;
        hold off
        movegui([5 550]); %specifies location on screen
        f= frame2im(getframe(gcf)); %capture image of figure for merging
        I=imresize(f,[d1,d2]); %specifies image dimensions

        cellfull = full(cell);
        cellfull = reshape(cellfull,[d1 d2]);
        cellfull = mat2gray(cellfull);  %These lines expand sparse matrix so the neuron PNR can be visualised

        figure
        cmap = parula;
        clims = [0 1];
        PNRim = imagesc(cellfull, clims); axis off; %Plots neuron PNR intensity
        hold on
        t = title("Neuron "+celli);
        t.FontSize = 16;
        hold off
        movegui([575 550]); %specifies location on screen
        f2= frame2im(getframe(gcf));  %capture image of figure for merging
        I2=imresize(f2,[d1,d2]); %specifies image dimensions

        figure
        merged = imfuse(f,f2,"ColorChannels","red-cyan"); %merges contour and PNR image to optimally visualise neuronal seed
        imshow(merged);
        movegui([1150 480]); %specifies location on screen

        %%%%%%%

        trace = C(celli,:); %filtered temporal data of specific neuron
        raw_trace = C_raw(celli,:); %raw temporal data of specific neuron
        corr_fac = xcorr(C_raw(celli,:),C(celli,:),0,'coeff'); %Level of correlation between raw C trace and filtered C trace

%% Identifies prominent peaks in the data
        width=30; % set min peak width
        height = 0.1;
%       height= (std((C_raw(celli,:))))/2; % set min peak height
        peakdata = [];
        [PKS,LOCS]=findpeaks(C(celli,:),'MinPeakWidth',width,'MinPeakHeight',height,'MinPeakProminence',0.05,'MinPeakDistance',100);
        nPeaks=size(PKS,2); %Loop that identifies what would be considered peaks in the calcium data
        if nPeaks>0;
            peakdata(:,1)=LOCS';
            peakdata(:,2)=PKS';
        end

%% Identifies noisy peaks in the data
        width_n=15; % set min peak width
        height_n = 0.05;
%       height_n = (std((C_raw(celli,:))))/2; % set min peak height
        noisedata = [];
        [PKS_n,LOCS_n]=findpeaks(C(celli,:),'MinPeakWidth',width_n,'MinPeakHeight',height_n,'MinPeakDistance',30);
        nNoise=size(PKS_n,2); %Loop that identifies what would be considered peaks in the calcium data
        if nNoise>0;
            noisedata(:,1)=LOCS_n';
            noisedata(:,2)=PKS_n';
        end
  
        %% plots the temporal data and peaks onto a graph
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
        end

        if nNoise>0
         scattersz = 75;
        Noise = scatter(noisedata(:,1),noisedata(:,2),scattersz,"x");
        end
        
        if nPeaks>0 && nNoise>0
             legend(["Calcium Trace","Raw Calcium Trace","Peaks","Noise"],'fontsize',10);
        elseif nPeaks>0 && nNoise==0
            legend(["Calcium Trace","Raw Calcium Trace","Peaks"],'fontsize',10);
        elseif nPeaks==0 && nNoise>0
            legend(["Calcium Trace","Raw Calcium Trace","Noise"],'fontsize',10);
        end

        hold off
        movegui([575 50]);

%         if nPeaks>0;
%         scattersz = 100;
%         Peaks = scatter(peakdata(:,1),peakdata(:,2),scattersz,"filled");
%         legend(["Calcium Trace","Raw Calcium Trace","Peaks"],'fontsize',10);
%         hold off
%         movegui([575 50]);
%         else 
%         legend(["Calcium Trace","Raw Calcium Trace"],'fontsize',10);
%          hold off
%         movegui([575 50]);
%         end
    
%%%%%%%%%%%%%%%%%%%%%%%

        prompt = ("Keep neuron "+celli+"? [keep(k)/delete(d)/generate video(v)]     ");
        Input = input(prompt,"s");
        switch Input
            
            case 'k'
                close all
                if corr_fac >= 0.9
                Keep_clean = cat(1,Keep_clean,celli);
                else
                Keep_noisy = cat(1,Keep_noisy,celli);
                end
            case 'd'
                close all
                Delete = cat(1,Delete,celli);
            case 'v'
                close all
                Video = cat(1,Video,celli);
            otherwise
                close all
                RedoNew = cat(1,RedoNew,celli);
                disp("Invalid input, added to 'Redo' list.");
        end

end
        Keep_clean = sort(Keep_clean);
        Keep_noisy = sort(Keep_noisy);
        Delete = sort(Delete);
        Video = sort(Video);
        RedoNew = sort(RedoNew);
        Redo = RedoNew;

        save("Cell_Sorting.mat","Keep_clean","Keep_noisy","Delete","Video","Redo");

    else
        Redo = [];  

    for celli = 1:NeuNum
        cell = A(:,celli); %spatial data of specific neuron

%         if celli == % cells that break the code
%             Delete = cat(1,Delete,celli);
%         else

            [coor, contourInfo] = plotROIContour(cell, d1, d2, plotControl); axis off; %plots contour for specific neuron
            hold on
            t = title("Neuron "+celli);
            t.FontSize = 16;
            hold off
            movegui([5 550]); %specifies location on screen
            f= frame2im(getframe(gcf)); %capture image of figure for merging
            I=imresize(f,[d1,d2]); %specifies image dimensions

            cellfull = full(cell);
            cellfull = reshape(cellfull,[d1 d2]);
            cellfull = mat2gray(cellfull);  %These lines expand sparse matrix so the neuron PNR can be visualised

            figure
            cmap = parula;
            clims = [0 1];
            PNRim = imagesc(cellfull, clims); axis off; %Plots neuron PNR intensity
            hold on
            t = title("Neuron "+celli);
            t.FontSize = 16;
            hold off
            movegui([575 550]); %specifies location on screen
            f2= frame2im(getframe(gcf));  %capture image of figure for merging
            I2=imresize(f2,[d1,d2]); %specifies image dimensions

            figure
            merged = imfuse(f,f2,"ColorChannels","red-cyan"); %merges contour and PNR image to optimally visualise neuronal seed
            imshow(merged);
            movegui([1150 480]); %specifies location on screen

            %%%%%%%

            trace = C(celli,:); %filtered temporal data of specific neuron
            raw_trace = C_raw(celli,:); %raw temporal data of specific neuron
            corr_fac = xcorr(C_raw(celli,:),C(celli,:),0,'coeff'); %Level of correlation between raw C trace and filtered C trace

            %% Identifies prominent peaks in the data
            width=30; % set min peak width
            height = 0.1;
            %       height= (std((C_raw(celli,:))))/2; % set min peak height
            peakdata = [];
            [PKS,LOCS]=findpeaks(C(celli,:),'MinPeakWidth',width,'MinPeakHeight',height,'MinPeakProminence',0.05,'MinPeakDistance',100);
            nPeaks=size(PKS,2); %Loop that identifies what would be considered peaks in the calcium data
            if nPeaks>0;
                peakdata(:,1)=LOCS';
                peakdata(:,2)=PKS';
            end

            %% Identifies noisy peaks in the data
            width_n=15; % set min peak width
            height_n = 0.05;
            %       height_n = (std((C_raw(celli,:))))/2; % set min peak height
            noisedata = [];
            [PKS_n,LOCS_n]=findpeaks(C(celli,:),'MinPeakWidth',width_n,'MinPeakHeight',height_n,'MinPeakDistance',30);
            nNoise=size(PKS_n,2); %Loop that identifies what would be considered peaks in the calcium data
            if nNoise>0;
                noisedata(:,1)=LOCS_n';
                noisedata(:,2)=PKS_n';
            end

            %% plots the temporal data and peaks onto a graph
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
            end

            if nNoise>0
                scattersz = 75;
                Noise = scatter(noisedata(:,1),noisedata(:,2),scattersz,"x");
            end

            if nPeaks>0 && nNoise>0
                legend(["Calcium Trace","Raw Calcium Trace","Peaks","Noise"],'fontsize',10);
            elseif nPeaks>0 && nNoise==0
                legend(["Calcium Trace","Raw Calcium Trace","Peaks"],'fontsize',10);
            elseif nPeaks==0 && nNoise>0
                legend(["Calcium Trace","Raw Calcium Trace","Noise"],'fontsize',10);
            end

            hold off
            movegui([575 50]);

            %         if nPeaks>0;
            %         scattersz = 100;
            %         Peaks = scatter(peakdata(:,1),peakdata(:,2),scattersz,"filled");
            %         legend(["Calcium Trace","Raw Calcium Trace","Peaks"],'fontsize',10);
            %         hold off
            %         movegui([575 50]);
            %         else
            %         legend(["Calcium Trace","Raw Calcium Trace"],'fontsize',10);
            %          hold off
            %         movegui([575 50]);
            %         end

            %%%%%%%%%%%%%%%%%%%%%%%

            prompt = ("Keep neuron "+celli+"? [keep(k)/delete(d)/generate video(v)]     ");
            Input = input(prompt,"s");
            switch Input

                case 'k'
                    close all
                    if corr_fac >= 0.9
                        Keep_clean = cat(1,Keep_clean,celli);
                    else
                        Keep_noisy = cat(1,Keep_noisy,celli);
                    end
                case 'd'
                    close all
                    Delete = cat(1,Delete,celli);
                case 'v'
                    close all
                    Video = cat(1,Video,celli);
                otherwise
                    close all
                    Redo = cat(1,Redo,celli);
                    disp("Invalid input, added to 'Redo' list.");
            end
%         end

        Keep_clean = sort(Keep_clean);
        Keep_noisy = sort(Keep_noisy);
        Delete = sort(Delete);
        Video = sort(Video);
        Redo = sort(Redo);

        save("Cell_Sorting.mat","Keep_clean","Keep_noisy","Delete","Video","Redo");

    end
    end
    cd ..
    clearvars -except nFiles iFile files
end
