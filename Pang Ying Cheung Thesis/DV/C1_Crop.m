%% Cropping the image 

clear 
close all
clc

mkdir('MaskROI');

animals=dir('Raw/');
animals(1:2,:)=[];
nAnimals=size(animals,1);

figure(1)
for iAnimal = 1:nAnimals
    animal=animals(iAnimal).name; 
    foldername = sprintf([animal,'/']);
    image_name = dir(['Raw/',foldername,'*.tif']);
    
    picture = ReadTiffStack(['Raw/',foldername,image_name(1).name]);

    avAll = mean(picture,3);
    save([animal, '_avAll.mat'],'avAll')
      
    imax = max(avAll,[],'all');
    imin = min(avAll,[],'all');
    
    
    figure(1)
    clf    
    imshow(avAll,[imin-50 (mean(picture,'all')+100)]);
    hold on
    
    roi = drawfreehand(gca);
    %%% if need to add a way point, right click > aff way point
    
    cont = input ('Continue? 1 = yes, 0 = restart: ');
    if cont == 1
        ;      
    else cont == 0
        restart = input('Re-draw ROI? (1 = yes, 0 = no): ');
        while restart == 1
            delete(roi)
            roi = drawfreehand(gca);
            restart = input('Re-draw ROI? (1 = yes, 0 = no): ');
        end            
    end
    
             
    roimask = createMask(roi);
    
    maskroi = imdilate(roimask,strel('disk',3));
       
 %   filename = sprintf([animal(1:end-4),'_ROI']);
    filename = sprintf([animal(1:end),'_ROI']);
    save(['MaskROI/',filename],'maskroi');
    
end

close all


























