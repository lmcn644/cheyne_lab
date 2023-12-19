function  roiactivity(varargin )
%RoiActivity. Reads rois from 'ROIs' dir and gives activity plots of df
%files.
%   Detailed explanation goes here

%% Parse optional inputs.
p = inputParser;
p.addParamValue('StdThres', 3); 
p.addParamValue('DiffThres', 2); 
p.addParamValue('Range', [-1,20]); 
p.addParamValue('Chunk', 1000); 
p.addOptional('Review',true);
p.parse(varargin{:});
Parameter = p.Results;

%% Read ROI mask
mkdir('Act');
load([pwd,'\ROIs\roiMask.mat']);
nROIs = max(max(mask));

%% List Files.
FileList = dir( 'DFs\*.mat');
nFiles = size(FileList, 1); 
fprintf('%d DF File(s) Found',nFiles);
if Parameter.Review, figure(); end

%% Perform review one recording at a time.
for iFile = 1:nFiles
    
    %% Prepare DF file
    file = [FileList(iFile).name];
    fprintf('\nFile: %s',file);
    dfObj = matfile(['DFs\', file]);
    sizeStack = size(dfObj,'stack');
    nFrames = sizeStack(3);
    act = zeros(nFrames,nROIs);
    
    %% load in Chunks
    for iFrame=1:Parameter.Chunk:nFrames
        %% Get next Chunk.
        endFrame = iFrame+Parameter.Chunk-1;
        if endFrame>nFrames, endFrame=nFrames;end
        fprintf('\n[%s]Processing Frame %i:%i ..',datestr(now, 'HH:MM'), iFrame, endFrame); 
        stack = dfObj.stack(:,:,iFrame:endFrame);
        
        %% Get Intensities
        for i=1:size(stack,3)
            for iRoi = 1:nROIs
                cMask = mask == iRoi;
                cStack = stack(:,:,i);
                cStack = cStack(cMask);
                cStack(isinf(cStack))=NaN('single');
                act(i+iFrame-1,iRoi) = nanmean(cStack);
            end
%             STATS = regionprops(mask,stack(:,:,i), 'MeanIntensity');
%             act(:,i+iFrame-1) = vertcat(STATS(:).MeanIntensity);
        end
    end
    
    %% Plot Results.
    if Parameter.Review
        subplot(nFiles,1,iFile);
        imshow(act(:,:)',[Parameter.Range(1),Parameter.Range(2)]); 
        title(file(1:end-4));
        colormap(calcium_lut());
        pause(1)
    end
    
    %% Save
    save([pwd,'\Act\',file(1:end-4)],'act');
    
end
fprintf('\n');
end

