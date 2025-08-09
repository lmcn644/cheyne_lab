%% PARAMETERS MODIFIED

clear; clc; close all;

files=dir;
files(1:2,:)=[];
files = natsortfiles(files);
nFiles=size(files,1);

for iFile = 2:2:nFiles;
    iFile;
    file=files(iFile).name;
    folder=file;
    cd(folder)
        load scope_joined
        load duration_joined
        load behave_joined
    folderlist=dir('*extraction');
        load("Cell_Sorting.mat");
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
    NeuKeep = [];

    plotControl.Cn=Cn;
    plotControl.thr=0.95;
    plotControl.option=1;
    plotControl.displayLabel = 0;
    d1=size(Cn,1);
    d2=size(Cn,2);
    
    cd ..
    cd ..
    cd ..

    mkdir('Calcium_Peaks');

    NeuKeep = [Keep_clean;Keep_noisy]'; %Neurons selected via 'Post-CNMFE_sorting.m'
    NeuKeep = sort(NeuKeep);

%     NeuNum = size(A,2); %Number of neurons
    final_amps = [];
    final_peakdata = [];

for celli = NeuKeep

    trace = C(celli,:); %filtered temporal data of specific neuron
    raw_trace = C_raw(celli,:); %raw temporal data of specific neuron
%     corr_fac = xcorr(C_raw(celli,:),C(celli,:),0,'coeff'); %Level of correlation between raw C trace and filtered C trace

%% Identifies prominent peaks in the data
        width=30; % set generous fixed min peak width
%         height = 0.05; % set fixed min peak height
        peakdata = [];
        [PKS,LOCS,W,Pr]=findpeaks(C(celli,:),'MinPeakWidth',width,'WidthReference','halfprom');  %,'MinPeakHeight',height
        nPeaks=size(PKS,2); %Loop that identifies what would be considered peaks in the calcium data
        if nPeaks>0
            peakdata(:,1)=LOCS';
            peakdata(:,2)=PKS';
            peakdata(:,3)=W';
            peakdata(:,4)=Pr';
        end

    amps = [];

    if nPeaks>0

        wtrace = plot(C(celli,:));
        hold on
        findpeaks(C(celli,:),'MinPeakWidth',width,'WidthReference','halfprom','Annotate','extents');
        hold off
%         pause
%% Get frames for the start and end of half width
        ax = gca;
        wlines = ax.Children;
        wlims = wlines(1).XData';
        wlims = wlims(~isnan(wlims));
        wlims = transpose(reshape(wlims,2,[]));
        peakdata = [peakdata, wlims];
        close all

        workingpeakdata = peakdata;
        OLpeaks = [];

        for i = 1:size(peakdata,1)
            interval1 = fixed.Interval(peakdata(i,5),peakdata(i,6));
            workingpeakdata(i,:) = [];
            for i2 = 1:size(workingpeakdata,1)         
                interval2 = fixed.Interval(workingpeakdata(i2,5),workingpeakdata(i2,6));
                OL = overlaps(interval1, interval2);
                if OL == 1
                    w1 = peakdata(i,3);
                    w2 = workingpeakdata(i2,3);
                    toremove = min(w1,w2);
                    [r,c] = find(peakdata == toremove);
                    OLpeaks = [OLpeaks; peakdata(r,:)];
                end
            end
            workingpeakdata = peakdata;
        end

        OLpeaks = unique(OLpeaks,'rows');

        check = isempty(OLpeaks);
        if check == 0
        ind = ismember(peakdata(:,1),OLpeaks(:,1));
        peakdata(ind,:) = [];
        else
        end

        %%%%%%%%%%%%%%%%%%%%%%


            KeyFrames = [0 peakdata(:,1)' size(C,2)];  %Identifies frames where tentative peaks occur, plus the start and end of the recording
            Gaps = diff(KeyFrames); %Gaps (in frames) between these peaks
            MaxGap = max(Gaps); %Selects the widest gap between peaks
            [r,c] = find(Gaps == MaxGap); %gets the row and column position of this gap, the column and column+1 will correspond to the frames encompassing the gap

            if size(c,2) > 1
            c = c(1,1);
            end

            GapStart = KeyFrames(:,c); %Frame starting the maximum gap
            GapEnd = KeyFrames(:,c+1); %Frame ending the maximum gap
            if GapEnd ~= size(C,2) %If gap isn't at the end of the recording
                [r2,c2] = find(peakdata == GapEnd); %Find width of peak ending the gap
                GapEnd = round(GapEnd - (peakdata(r2,3)/2)); %Subtract half the peak width from the end of the gap to ensure start of the next peak isn't included
            end
            GapMid = round((GapStart+GapEnd)/2); %Midpoint, this is where sampling will begin to avoid capturing fluorescence decay as baseline
            SampleLength = 450; %Frame length to be sampled

            if GapEnd - GapMid >= SampleLength %checks to ensure the gap exceeds sample length
                SampleStart = GapMid;  %start sampling at gap midpoint
                SampleEnd = GapMid + SampleLength; %finish sampling + one sample length later
            else
                def = SampleLength-(GapEnd-GapMid);  %How much shorter the desired interval is than the sample length
                SampleStart = GapMid-def; %Extends the sample range to before the midpoint to encompass sample length
                SampleEnd = GapEnd;
                if SampleStart <0  %failsafe to prevent indexing beyond 0
                    SampleStart = 0;
                    disp('Max possible gap is '+ string(SampleEnd-SampleStart) +'.');
                end

            end

            minamp = min(C_raw(celli,SampleStart:SampleEnd)); %Min amp of baseline fluctuation
            maxamp = max(C_raw(celli,SampleStart:SampleEnd)); %Max amp of baseline fluctuation
            stdrange = std(C_raw(celli,SampleStart:SampleEnd)); %Standard deviation of baseline fluctuation
            amprange = maxamp - minamp; %Full range of baseline fluctuation
            meanamp = mean(C_raw(celli,SampleStart:SampleEnd)); %Mean amp of baseline fluctuation

            amps(:,1) = celli;  %cell number in c1
            amps(:,2) = amprange; %amp range in c2
            amps(:,3) = stdrange; %std range in c3
            final_amps = cat(1,final_amps,amps);  %baseline amplitude fluctuation data stored in 'final_amps'

            peakratio = (peakdata(:,2))/amprange;
            prratio = (peakdata(:,4))/amprange;
            peakdata(:,7) = peakratio;
            peakdata(:,8) = prratio;

            peakdata(peakdata(:,7)<0.75,:) = []; %Peaks must be at least 75% the size of the total amplitude range
            peakdata(peakdata(:,8)<0.5,:) = []; %Peak prominence must be at least 50% the size of the total amplitude range
            peakdata(peakdata(:,3)<45,:) = []; %Peak width must be at least 45 frames

            %%%%%%%%

            figure;
            plottest = plot(C_raw(celli,:));
            hold on
            xlim([0 size((C_raw(celli,:)),2)])
            plot(C(celli,:))
            start = scatter(SampleStart,0);
            finish = scatter(SampleEnd,0);
            ScatterPeaks = scatter(peakdata(:,1),peakdata(:,2),"filled");
            title(['Calcium Signals - Cell ',int2str(celli)],'FontSize',14);
            xlabel('Time (frames)');
            ylabel('\DeltaF/F0');
            hold off

            folder='Calcium_Peaks\';
            filename = sprintf(['Calcium Signals_Cell ',int2str(celli),'%d.png']);
            fullfilename=[folder,filename];
            saveas(gcf,fullfilename,'png');

%             pause 
            close all

            celln = repmat(celli,1,size(peakdata,1))';
            peakdata = [celln peakdata];
            final_peakdata = cat(1,final_peakdata,peakdata);

        else
            %Amp matrix values if no peaks are present
            amps(:,1) = celli;
            minamp = min(C_raw(celli,:)); %Min amp of baseline fluctuation
            maxamp = max(C_raw(celli,:)); %Max amp of baseline fluctuation
            amps(:,2) = maxamp - minamp;
            amps(:,3) = std(C_raw(celli,:));

            final_amps = cat(1,final_amps,amps);

    end

end

% Loop creates matrix showing the number of peaks corresponding to each cell
for iCell=NeuKeep
    row = find(NeuKeep == iCell);
    ind=final_peakdata(:,1)==iCell;
    cell_stats(row,1)=iCell;
    cell_stats(row,2)=sum(ind);
end

ind = cell_stats(:,2) > 0;
cell_stats = cell_stats(ind,:);
NeuKeep = cell_stats(:,1)'; % only cells that fire are included in NeuKeep now


%% Correct scope frame (according to adjustments in scope.mat) and add behavioural frame
nPeaks=size(final_peakdata,1);
for iPeak=1:nPeaks
    frame=final_peakdata(iPeak,2);
    scopeframecheck = size(scope_joined,1)-frame;

    if scopeframecheck<=0
        frame = size(scope_joined,1);
    end
    Cframe=scope_joined(frame,1);
    final_peakdata(iPeak,10)=Cframe; % corrected scope frame
    final_peakdata(iPeak,11)=scope_joined(frame,6); % behavioural frame
end

nCells = size(NeuKeep,2);
filename='nCells'; % total number of cells
    save (filename,'nCells');

filename='NeuKeep'; % matrix of cell identification numbers for future indexing
    save (filename,'NeuKeep');

nFrames = size(C_raw,2);
filename='nFrames'; % total number of scope frames
    save (filename,'nFrames');

save("final_peakdata.mat","final_peakdata");
save("final_amps.mat","final_amps");

cd ..

clearvars -except files iFile nFiles

end