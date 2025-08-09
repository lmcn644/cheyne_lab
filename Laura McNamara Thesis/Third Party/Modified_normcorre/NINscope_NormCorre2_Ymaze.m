%% Rename, align and downscale AVIs

clear
animals=dir;
animals(1:2,:)=[];
animals = natsortfiles(animals);
nAnimals=size(animals,1);
%%

for iAnimal = 1:2:2%nAnimals;
    %% check if joined already first
    %     animal=animals(iAnimal+1).name;
    %     cd(animal)
    %     [~,name,~]=fileparts(pwd);
    %     filename=[name(1:end-1),'joined','.tif'];
    %     if not(isfile(filename))
    %         cd ..
    %         bits=[];
    for iRec=1:2;
        if iRec==2;
            iAnimal=iAnimal+1;
        end
        animal=animals(iAnimal).name
        folder=animal;
        cd(folder)
        %% Read AVIs, drift correct and save as Tiffs but keep 10 frames of each corrected one
        if isfolder('Correctedi2\')
            if isfile('bitsi2.mat')
                if iRec==1
                    load bitsi2.mat
                end
                if iRec==2
                    bits1=bits;
                    load bitsi2.mat
                    bits=cat(3,bits1,bits);
                end
            end
            if not(isfile('bitsi2.mat'))
                %% load and save bits
                folder2='Correctedi2\';
                filelist=dir(folder2);
                filelist(1:2,:)=[];
                filelist = natsortfiles(filelist);
                nChunks=size(filelist,1);
                cd('Correctedi2')
                for iChunk=1:nChunks
                    stack=[];
                    filename=filelist(iChunk).name;
                    for i=1:10
                        stack(:,:,i)=imread(filename,i);
                    end
                    bits=cat(3,bits,stack);
                end
                cd ..
            end
            save bits 'bits'
        end
        cd ..
    end
    iAnimal=iAnimal-1;
    %% Get shifts for each file
    Yf=bits;
    [d1,d2,T] = size(Yf);
    normcorre_juliette
    clearvars -except nAnimals nChunks nFrames keepVariables Mr iFile filelist All GP shifts1 options_r bound bits animals iAnimal folder folder2 fullfolder
    %
    %         %% Run twice to see if aligns better
    %         shifts0=shifts1;
    %         Yf=Mr;
    %         [d1,d2,T] = size(Yf);
    %         normcorre_juliette
    %         clearvars -except nAnimals nChunks nFrames keepVariables Mr iFile filelist All GP shifts0 shifts1 options_r bound bits animals iAnimal folder folder2 fullfolder
    %
    
    %% Reload and correct files, resize and concatenate
    
    nChunks=18;
    All=[];
    %%
    for iFile=1:(nChunks*2-1)     %1:nChunks*2;
        iFile
        tic
        if iFile<=nChunks;
            iChunk=iFile;
        end
        if iFile==nChunks+1;
            iAnimal=iAnimal+1;
        end
        if iFile>nChunks;
            iChunk=iFile-nChunks;
        end
        animal=animals(iAnimal).name
        folder=animal;
        cd(folder)
        cd('Correctedi2')
        filelist=dir;
        filelist(1:2,:)=[];
        filelist = natsortfiles(filelist);
        filename=filelist(iChunk).name;
        stack=ReadTiffStack(filename);
        stack = single(stack);
        frames=size(stack,3);
        clearvars shifts
        for i=1:frames
            shifts(i)=shifts1(iFile*10);
        end
        Mr = apply_shifts(stack,shifts,options_r,bound/2,bound/2);
        stack=imresize(Mr,0.25);
        All=cat(3,All,stack);
        toc
        cd ..
        cd ..
    end
    %
    folder=animal;
    cd(folder)
    [~,name,~]=fileparts(pwd);
    filename=[name(1:end-1),'joined2','.tif'];
    fTIF = Fast_Tiff_Write(filename);
    for k = 1:size(All,3)
        fTIF.WriteIMG(All(:,:,k)');
    end
    fTIF.close;
    % save avi to check
    %         I=mat2gray(All);
    %         filename=[name,'joined','.avi'];
    %         v = VideoWriter(filename,'Grayscale AVI');
    %         open(v)
    %         writeVideo(v,I)
    %         close(v)
    clearvars -except nAnimals nChunks nFrames keepVariables iFile filelist All GP shifts1 options_r bound bits animals iAnimal folder folder2 fullfolder
    cd ..
    toc
end
%end








