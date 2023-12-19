%% Open and drift correct mesoscope files 

%%
clear
animals=dir;
animals(1:2,:)=[];
nAnimals=size(animals,1);
%
for iAnimal = 1%:nAnimals;
    tic
    animal=animals(iAnimal).name; 
    mkdir(['c',animal]);   
    cd(animal)     
    filelist=dir('*.tif');
    filelist = natsortfiles(filelist);    
    %% Drift correct and re-save as Tiffs but keep 10 frames of each corrected one
    %clearvars
    tic
    bits=[];
    %%
    for iFile=1:size(filelist,1);        
        iFile
        tic
        filename=filelist(iFile).name;
        filename=filelist(iFile).name;
        stack=ReadTiffStack(filename);    
        Yf = stack;
        [d1,d2,T] = size(Yf);
        % drift correct and save as tiff
        normcorre_juliette
        clearvars -except keepVariables Mr iFile filelist All bits filename frames nAnimals nAnimal animal animals iAnimal folder folder2 fullfolder
        cd ..
        cd(['c',animal])
        fTIF = Fast_Tiff_Write(filename);
        for k = 1:size(Mr,3)
            fTIF.WriteIMG(Mr(:,:,k)');
        end
        fTIF.close;
        % also keep 10 frames
        temp=Mr(:,:,1:10);
        bits=cat(3,bits,temp);
        toc
        cd ..  
        cd(animal)
    end
    
    %% Get shifts for each file and apply them. Join all TIFs and downsize
    cd ..
    cd(['c',animal])
    Yf=bits;
    [d1,d2,T] = size(Yf);
    normcorre_juliette
    clearvars -except keepVariables Mr iFile filelist All GP shifts1 options_r bound bits nAnimals animal animals iAnimal folder folder2 fullfolder
    % Reload and correct files, resize and concatenate
    filelist=dir('*.tif');
    filelist = natsortfiles(filelist);
    All=[];
    for iFile=1:size(filelist,1);
        iFile
        filename=filelist(iFile).name;
        stack=ReadTiffStack(filename);
        stack = single(stack);
        frames=size(stack,3);
        clearvars shifts
        for i=1:frames
            shifts(i)=shifts1(iFile*10);
        end
        Mr = apply_shifts(stack,shifts,options_r,bound/2,bound/2);
       % stack=imresize(Mr,0.5);
        %All=cat(3,All,stack);    
        All=cat(3,All,Mr);          
    end
    %% Save corrected downsized TIF
    cd ..
    filename=[animal,'.tif'];
    fTIF = Fast_Tiff_Write(filename);
    for k = 1:size(All,3)
        fTIF.WriteIMG(All(:,:,k)');
    end
    fTIF.close;
    toc
    %% Make mat of corrected stack
    
    mkdir('Corrected'); 
    cd('Corrected');
    save(animal,'All','-v7.3')    
    cd ..
end



