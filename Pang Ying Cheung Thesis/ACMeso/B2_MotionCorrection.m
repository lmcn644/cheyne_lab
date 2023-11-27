%% Open and drift correct mesoscope files 
% Set up filenames and directory that matches your own data
% The file directory is set to read files recorded by Tarren the mesoscope

%%
clear
close all
clc

mkdir('cRaw');
mkdir('Corrected');

animals=dir('Raw/');
animals(1:2,:)=[];
nAnimals=size(animals,1);

for iAnimal = 1:nAnimals;   
    animal=animals(iAnimal).name; 
    
    mkdir(['cRaw/','c',animal]);   
   
    
    masks = [animal,'_ROI.mat'];    
    load(['MaskROI/',masks]);
    
    maskroi = imresize(maskroi,0.5);

    foldername = sprintf(['Raw/',animal,'/']);   
    cfoldername = sprintf(['cRaw/','c',animal,'/']);
   
 
    
    filelist=dir([foldername,'*.tif']);
    filelist = natsortfiles(filelist);    
    %% Drift correct and re-save as Tiffs but keep 10 frames of each corrected one
 
    %clearvars

    bits=[];
       
    %%% NormCorr Motion Correction
    for iFile= 1:size(filelist,1);        
       
       filename=filelist(iFile).name;
      
       D = ReadTiffStack([foldername, filename]);   
        
       D = imresize(D,0.5);
        
        stack = zeros(size(D));
        for xx = 1:size(stack,1);
            for yy = 1:size(stack,2);
                px = D(xx,yy,:);
                msk = maskroi(xx,yy);
                
                if msk == 0;
                    stack(xx,yy,:) = 0;
                else msk == 1;
                    stack(xx,yy,:) = px;
                end
            end
        end
        
        
        Yf = stack;
        [d1,d2,T] = size(Yf);
        % drift correct and save as tiff
        normcorre_juliette
        
        clearvars -except keepVariables Mr iFile filelist All bits filename frames nAnimals nAnimal animal animals iAnimal folder folder2 fullfolder foldername cfoldername maskroi
  
        Ma = single(Mr);
        fTIF = Fast_Tiff_Write([cfoldername,filename]);
        for k = 1:size(Ma,3)
            fTIF.WriteIMG(Ma(:,:,k)');
        end
        fTIF.close;
        
        clearvars Ma
 %       saveastiff(Mr,[cfoldername,filename]);
   
        temp=Mr(:,:,1:10);
        bits=cat(3,bits,temp);
      
    end
    
    %% Get shifts for each file and apply them. Join all TIFs and downsize
    
    Yf=bits;
    [d1,d2,T] = size(Yf);
    normcorre_juliette
   
    clearvars -except keepVariables Mr iFile filelist All GP shifts1 options_r bound bits nAnimals animal animals iAnimal folder folder2 fullfolder foldername cfoldername 
  
    % Reload and correct files, resize and concatenate
    filelist=dir([cfoldername,'*.tif']);
    filelist = natsortfiles(filelist);
   
    All=[];
    for iFile=1:size(filelist,1);

        filename=filelist(iFile).name;
        stack = ReadTiffStack([cfoldername,filename]);
        
        stack = single(stack);
        frames=size(stack,3);
        clearvars shifts
        for i=1:frames
            shifts(i)=shifts1(iFile*10);
        end
        Mr = apply_shifts(stack,shifts,options_r,bound/2,bound/2);
  %      stack=imresize(Mr,0.5); % original is downsized by 50
        stack = Mr;
        All=cat(3,All,stack);       
    end
    
    %% Make mat of corrected stack
   
    save(['Corrected/',animal],'All','-v7.3')   
    
    %% Save corrected downsized TIF
      
    filename=[animal,'.tif'];
    fTIF = Fast_Tiff_Write(['Corrected/',filename]);
    for k = 1:size(All,3)
        fTIF.WriteIMG(All(:,:,k)');
    end
    fTIF.close;

end


%% Second round of motion correction


clear
close all
clc

mkdir('Corrected 2x');

animals=dir('Corrected/*.mat');
nAnimals=size(animals,1);


for iAnimal = 1:nAnimals;
    animal=animals(iAnimal).name;
    
    load(['Corrected/', animal])
    
    %% NormCorr Motion Correction
    
    Yf = All;
    [d1,d2,T] = size(Yf);
    % drift correct and save as tiff
    normcorre_juliette
    
    clearvars -except keepVariables Mr iFile filelist All bits filename frames nAnimals nAnimal animal animals iAnimal folder folder2 fullfolder foldername cfoldername maskroi
     
    save(['Corrected 2x/',animal],'All','-v7.3')   
       
    filename = [animal(1:end-4),'.tif'];  
    Ma = single(Mr);
    fTIF = Fast_Tiff_Write(['Corrected 2x/',filename]);
    for k = 1:size(Ma,3)
        fTIF.WriteIMG(Ma(:,:,k)');
    end
    fTIF.close;
    
    clearvars Ma
    
end































