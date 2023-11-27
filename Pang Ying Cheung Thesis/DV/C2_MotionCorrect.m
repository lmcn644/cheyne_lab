%% Open and drift correct mesoscope files 

%%
clear
close all
clc

mkdir('cRaw');
mkdir('Corrected');

animals=dir('Raw/');
animals(1:2,:)=[];
nAnimals=size(animals,1);

msk_file=dir(['MaskROI/*.mat']);
msk_file = natsortfiles(msk_file);

for iAnimal = 1: nAnimals;   
    animal2=animals(iAnimal).name; 
 
    animal=animal2(1:7);

    mkdir(['cRaw/','c',animal]);   
    cfold = ['cRaw/','c',animal,'/']

    masks = msk_file(iAnimal).name;
    load(['MaskROI/',masks]);
    maskroi = imresize(maskroi,0.35);
    
    foldername = sprintf(['Raw/',animal2,'/']);   
    cfoldername = sprintf(['cRaw/','c',animal,'/']);
    
    filelist=dir([foldername,'*.tif']);
    filelist = natsortfiles(filelist);    
    %% Drift correct and re-save as Tiffs but keep 10 frames of each corrected one
    %clearvars

    bits=[];
    
    %% NormCorr Motion Correction
    for iFile=1:size(filelist,1);        
       
        filename=filelist(iFile).name;
      
        D = ReadTiffStack([foldername, filename]);   
        D = imresize(D,0.4);

        stack = zeros(size(D));
        for xx = 1:size(stack,1);
            for yy = 1:size(stack,2);
                px = D(xx,yy,:);
                if maskroi(xx,yy)==0;
                    stack(xx,yy,:) = 0;
                else maskroi(xx,yy)==1;
                    stack(xx,yy,:) = px;
                end
            end
        end
        
        Yf = stack;
        [d1,d2,T] = size(Yf);
        % drift correct and save as tiff
        normcorre_juliette

        clearvars -except keepVariables Mr iFile filelist All bits filename frames nAnimals nAnimal animal animals iAnimal folder folder2 fullfolder foldername cfoldername maskroi cfold msk_file

        if size(Mr,3) < 10;
            ;
        else size(Mr,3)> 9;
            Ma = single(Mr);
            fTIF = Fast_Tiff_Write([cfold,filename]);
            
            for k = 1:size(Ma,3)
                fTIF.WriteIMG(Ma(:,:,k)');
            end
            fTIF.close;
            clearvars Ma

            temp=Mr(:,:,1:10);
            bits=cat(3,bits,temp);
        end
    end
    
    %% Get shifts for each file and apply them. Join all TIFs and downsize
    
    Yf=bits;
    [d1,d2,T] = size(Yf);
    normcorre_juliette
   
    clearvars -except keepVariables Mr iFile filelist All GP shifts1 options_r bound bits nAnimals animal animals iAnimal folder folder2 fullfolder foldername cfoldername cfold msk_file
  
    % Reload and correct files, resize and concatenate
    filelist=dir([cfold,'*.tif']);
    filelist = natsortfiles(filelist);
   
    All=[];
    for iFilez=1:size(filelist,1);

        filename=filelist(iFilez).name;
        stack = ReadTiffStack([cfold,filename]);
        
        stack = single(stack);
        frames=size(stack,3);
        clearvars shifts
        for i=1:frames
            shifts(i)=shifts1(iFilez*10);
        end
        Mr = apply_shifts(stack,shifts,options_r,bound/2,bound/2);
  %      stack=imresize(Mr,0.5); % original is downsized by 50
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

% Run another round of motion correction

clear
clc

filelist=dir(['Corrected/','*.mat']);
filelist=natsortfiles(filelist);
% tic

YesFile = isfolder('Corrected 2x');
if YesFile == 1
    ;
else YesFile == 0
    mkdir('Corrected 2x');
end

clearvars YesFile

for iFile= 1:size(filelist,1);
    %   tic
    filename=filelist(iFile).name;
    load(['Corrected/',filename]);
    
    Yf = double(All);

    clearvars All;
    [d1,d2,T] = size(Yf);

    % drift correct and save as tiff
    normcorre_juliette
    clearvars -except keepVariables Mr iFile filelist filename 

    save(['Corrected 2x/',filename],'Mr','-v7.3');

    Ma = single(Mr);

    filename=sprintf([num2str(filename(1:end-4)),'.tif']);
    fTIF = Fast_Tiff_Write(['Corrected 2x/',filename]);
    for k = 1:size(Ma,3)
        fTIF.WriteIMG(Ma(:,:,k)');
    end
    fTIF.close
end





