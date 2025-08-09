%% script to make AVI from behavioural TIFFS for ezytrack

clear
close all
animals=dir;
animals(1:2,:)=[];
animals = natsortfiles(animals);
nAnimals=size(animals,1);

%%
for iAnimal = 1:nAnimals;
    tic
    animal=animals(iAnimal).name
    folder=animal;
    folder2='\Behaviour\';
    fullfolder=[folder,folder2];
    filelist=dir([fullfolder]);
    filelist(1:2,:)=[];
    filelist(end,:)=[];
    filelist = natsortfiles(filelist);
    nFrames=size(filelist,1);
    cd(folder)
    
    %% Read in files and stack
    if not(isfolder('Behaviour AVI'))
        mkdir('Behaviour AVI')        
        cd('Behaviour')
        stack=[];
        stack=zeros(480,640,nFrames);
        %stack=zeros(480,640,nFrames);   
        for iFile=1:nFrames;
        
        
            if iFile<=nFrames
                filename=filelist(iFile).name;
                t = Tiff(filename,'r');
                imageData = read(t);
                imageData=rgb2gray(imageData);
                %imageData=imresize(imageData,0.8);
                %             if iFile==1
                %             imshow(imageData(50:450,100:500))
                %             end
                stack(:,:,iFile)=imageData;
                %stack(:,:,iFile)=imageData;                
            end        
        end 
        cd ..
        %% save AVI
        cd('Behaviour AVI')
        I=[];
        I=mat2gray(stack); 
        %I=imresize(I,0.8);
        filename=[animal,'.avi'];
        v = VideoWriter(filename,'Grayscale AVI');
        open(v)
        writeVideo(v,I)
        close(v)
         cd ..
    end
   % clearvars -except iAnimal nAnimals nFrames filelist animals
    toc   
    cd ..
end

%imshow(imageData(50:450,150:550))