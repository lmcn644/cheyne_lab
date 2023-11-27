%% Making a DF using moving average

clear
close all
clc

mkdir('preDFs');

filelist = dir(['Corrected 2x/','*.mat']); % all NormCore corrected mat files
filelist = natsortfiles(filelist);   

 masklist = dir(['MaskROI/','*.mat']);
 masklist = natsortfiles(masklist);

for iFile = 1:size(filelist,1)

    clearvars All
     
   
    fprintf('Loading corrected image...\n');

    filename = filelist(iFile).name;
    load (['Corrected 2x/',filename]);
    All = Mr;
    maskfile = masklist(iFile).name;
    load (['MaskROI/',maskfile]);

   maskroi = imresize(maskroi, [359 429]);
   All = imresize(All, [359 429]);

  %  All = Mr;

    fprintf('Calculating F0...\n');

    % Finding the moving average for each pixel (moving window = 200)
    MovingAverage200 = zeros(size(All)); % 'Mr' is the corrected file
    for xx = 1:size(All,1)
        for yy = 1:size(All,2)
            g = All(xx,yy,:);
            if maskroi(xx,yy) == 0;
                MovingAverage200(xx,yy,:) = NaN;
            else maskroi (xx,yy) == 1;
                imMovAv200 = movmean(g,200,'omitnan'); % Exclude NaN in the calculations
                MovingAverage200(xx,yy,:)=imMovAv200;
            end
        end
    end

    %    MovingAverage200 = single(MovingAverage200); % 'Mr' file was originally single but the 'movmean' function returns double

    fprintf('Calculating DF...\n');

    % The DF calculations
    MovAv200_DF = zeros(size(All));
    for hh = 1:size(All,3)
        frame =    All(:,:,hh);
        %        frame = double (frame); % convert the image into a double; uncomment if having errors.
        F0 = MovingAverage200(:,:,hh);
        pixel_DF = (frame-F0)./F0;
        MovAv200_DF(:,:,hh) = pixel_DF;
    end

    stack = MovAv200_DF*100; %Convert the DF calculation into a percentage

    clearvars -except keepVariables iFile stack MovAv200_DF filename filelist masklist

    fprintf('Saving...\n');

    % saving as .mat file
    name = sprintf([num2str(filename(1:end-4)),'.mat']);
    save(['preDFs/',name], 'stack', '-v7.3');

    % saving as a tif stack
    stack = single(stack); % Must be a type single to open stack on imageJ
    name2 = sprintf([num2str(filename(1:end-4)),'.tif']);

    fTIF = Fast_Tiff_Write(['preDFs/',name2]);
    for k = 1:size(stack,3)
        fTIF.WriteIMG(stack(:,:,k)');
    end
    fTIF.close;
    
    %   MovingAverage200 = [];
    MovAv200_DF = [];
end
