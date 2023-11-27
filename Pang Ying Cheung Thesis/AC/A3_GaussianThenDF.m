%% Own scripts:  Gaussian Filter then DF

clear
close all
clc

parent_dir = pwd;

filelist = dir(['Corrected/','*.mat']);

mkdir('Gaussian Filtered');

mkdir('DFs');

%% Gaussian filter the raw images

sigma = 2;

for iFile = 1:size(filelist,1)
    filename = filelist(iFile).name;
    load(['Corrected/',filename]);
    
    gaussstack = zeros(size(Mr));
    for xx = 1:size(Mr,1)
        for yy = 1:size(Mr,2)
            pixel = Mr(xx,yy,:);
            Iblur = imgaussfilt3(pixel,sigma); % Used 3D gaussian filter
            gaussstack (xx,yy,:) = Iblur;
        end
    end
    
%    gaussstack=single(gaussstack);
    
    save(['Gaussian Filtered/',filename],'gaussstack');
    
    gaussstack = single(gaussstack);
    newname2 = sprintf([num2str(filename(1:end-4)),'.tif']);
    saveastiff(gaussstack,['Gaussian Filtered/',newname2]);
end

%% DF the gaussian filtered Raw image

filelist = dir(['Gaussian Filtered/','*.mat']);

for iFile = 1:size(filelist,1)
    filename = filelist(iFile).name;
    load (['Gaussian Filtered/',filename]);

    % Finding the moving average for each pixel
    MovingAverage200 = zeros(size(gaussstack)); % 'RawStack' is the motion corrected raw-tiff file that was converted into a .mat file.
    for xx = 1:size(gaussstack,1)
        for yy = 1:size(gaussstack,2)
            g = gaussstack(xx,yy,:);
            imMovAv200 = movmean(g,200,'omitnan'); % Exclude NaN in the calculations
            MovingAverage200 (xx,yy,:)=imMovAv200;
        end
    end
    
    MovingAverage200 = single(MovingAverage200);
    
    % The DF calculations
    MovAv200_DF = zeros(size(gaussstack));
    for hh = 1:size(gaussstack,3)
        frame = gaussstack (:,:,hh);
        frame = double (frame); % convert the image into a double; uncomment if having errors.
        F0 = MovingAverage200(:,:,hh);
        pixel_DF = (frame-F0)./F0;
        MovAv200_DF(:,:,hh) = pixel_DF;
    end
    
    stack = MovAv200_DF*100;
     
%    stack = single(stack);    
    
    name = sprintf([num2str(filename(1:end-4)),'.mat']);
    save(['DFs/',name], 'stack');
    
    stack = single(stack);
    name2 = sprintf([num2str(filename(1:end-4)),'.tif']);
    saveastiff (stack,['DFs/',name2]);
    
    MovingAverage200 = [];
    MovAv200_DF = [];
end





    
    
    
    
    