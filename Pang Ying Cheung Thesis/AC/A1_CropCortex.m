clear
close all
clc

mkdir('Mask')
mkdir('DF roi');

imageroi = dir(['Corrected/*.mat']);
imageroi = natsortfiles(imageroi);

DFim = dir(['DFs/*.mat']);
DFim = natsortfiles(DFim);


for iFile = 1:size(DFim,1);
               
    filename = DFim(iFile).name;
    load(['DFs/',filename]);
    load(['Corrected/',filename])
    
    av = mean(Mr,3,'omitnan');
    
    figure
    imshow(av, [],'InitialMagnification','fit');
    
    roi = drawfreehand(gca); 
    %roi = drawcircle(gca);
    cont = input ('Continue? 1 = yes, 0 = restart: ');   
    if cont == 1
        ;
    else cont == 0
        restart = input('Re-draw ROI? (1 = yes, 0 = no): ');
        while restart == 1
            delete(roi)
          roi = drawfreehand(gca); 
      % roi = drawcircle(gca);
            restart = input('Re-draw ROI? (1 = yes, 0 = no): ');
        end
        cont2 = input ('Continue? 1 = yes, 0 = add waypoint: ');
        if cont2 == 1
            ;
        else cont2 == 0;
            pause (60)
        end
    end
    
    roimask = createMask(roi);
    maskroi = imdilate(roimask,strel('disk',3));
    
    save(['Mask/',filename(1:end-4)],'maskroi');
    
    ROIstack = NaN(size(stack));
    for xx = 1:size(stack,1);
        for yy = 1:size(stack,2);
            if maskroi(xx,yy) == 0;
                ;
            else maskroi(xx,yy) == 1;
                ROIstack(xx,yy,:) = stack(xx,yy,:);
            end
        end
    end
    
    name = [filename(1:end-4),'_AC_ROI.mat']
    save(['DF roi/',name],'ROIstack','-v7.3')
    
    Ra = single(ROIstack);
          
    filename=[filename(1:end-4),'_AC_ROI.tif'];
    fTIF = Fast_Tiff_Write(['DF roi/',filename]);
    for k = 1:size(Ra,3)
        fTIF.WriteIMG(Ra(:,:,k)');
    end
    fTIF.close;
    
    close
end




