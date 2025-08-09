%% Rename, align and downscale AVIs

clear
animals=dir;
animals(1:2,:)=[];
animals = natsortfiles(animals);
nAnimals=size(animals,1);
%% 
for iAnimal = 1:nAnimals;
    tic
    animal=animals(iAnimal).name
    folder=animal;
    folder2='\Scope1\';
    fullfolder=[folder,folder2];
    if isfolder(fullfolder)
        filelist=dir([fullfolder,'*.tiff']);
        %filelist(1:2,:)=[];
        %filelist(end,:)=[];
        filelist = natsortfiles(filelist);
        nFrames=size(filelist,1);
       % if nFrames > 6000
            cd(folder)
            %% Read AVIs, drift correct and save as Tiffs but keep 10 frames of each corrected one
            if not(isfolder('Correctedi2'))
                mkdir('Correctedi2')                
                bits=[];
                chunk=500;
                for iChunk=1:round(nFrames/chunk)
                    cd('Scope1')
                    iChunk
                    tic
                    stack=[];
                    stack=zeros(480,752,chunk);
                    count=0;
                    for iFile=chunk*iChunk-(chunk-1):chunk*iChunk;                     
                        if iFile<=nFrames
                            count=count+1;
                            filename=filelist(iFile).name;
                            t = Tiff(filename,'r');
                            imageData = read(t);
                            %stack=cat(3,stack,imageData);
                            stack(:,:,count)=imageData;
                        end                       
                    end
                    if iChunk==round(nFrames/chunk)
                        for iFile=chunk*iChunk+1:nFrames;
                            filename=filelist(iFile).name;
                            t = Tiff(filename,'r');
                            imageData = read(t);
                            stack=cat(3,stack,imageData);                            
                        end
                    end
                    %stack=ReadTiffStack(filename); might be faster but won't work
                    Yf = single(stack);
                    [d1,d2,T] = size(Yf);
                    % drift correct and save as tiff
                    normcorre_juliette
                    clearvars -except nAnimals chunk nFrames keepVariables Mr iFile filelist All bits filename frames animals iAnimal folder folder2 fullfolder
                    cd ..
                    cd('Correctedi2')
                    fTIF = Fast_Tiff_Write(filename);
                    for k = 1:size(Mr,3)
                        fTIF.WriteIMG(Mr(:,:,k)');
                    end
                    fTIF.close;
                    % also keep 10 frames
                    temp=Mr(:,:,1:10);
                    bits=cat(3,bits,temp);
                    %clearvars stack vid a
                    cd ..                    
                    toc
                end
                save bitsi2 'bits' %'bits' 
            end
            cd ..
            toc
        %end
    end
end



