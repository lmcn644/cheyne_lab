
clear
close all
clc

mkdir('DFs/');

filelist = dir(['preDFs/','*.mat']); % all NormCore corrected mat files
filelist = natsortfiles(filelist);   

masklist = dir(['MaskROI/','*.mat']);
masklist = natsortfiles(masklist);


sigma = 5;

for iFile = 1:size(filelist,1)
    filename = filelist(iFile).name;
    load(['preDFs/',filename]);
    
  %  stack = imresize(stack,0.5);
    
    maskfile = masklist(iFile).name;
    load (['MaskROI/',maskfile]);
    
   maskroi = imresize(maskroi, [356 429]);
    stacked = stack;
    clearvars stack
    stacked(isnan(stacked))=0;
    stacked(:,:,3001:end)=[];
    
    stack = zeros(size(stacked));
    for xx = 1:size(stacked,1)
        for yy = 1:size(stacked,2)
            pixel = stacked(xx,yy,:);
          
            if maskroi(xx,yy) == 0;
                stack(xx,yy,:) = NaN;
            else maskroi(xx,yy) == 1;
                Iblur = imgaussfilt3(pixel,sigma); % Used 3D gaussian filter
                stack (xx,yy,:) = Iblur;
            end
        end
    end
    
%    gaussstack=single(gaussstack);
     
    save(['DFs/',filename],'stack','-v7.3');
    
    clearvars -except keepVariables iFile filelist filename masklist sigma gstack stack
    
    stack = single(stack);
    name2 = sprintf([num2str(filename(1:end-4)),'.tif']);
    %     saveastiff(gaussstack,['Gaussian Filtered/',name2]);
    
    fTIF = Fast_Tiff_Write(['DFs/',name2]);
    for k = 1:size(stack,3)
        fTIF.WriteIMG(stack(:,:,k)');
    end
    fTIF.close;    
end







