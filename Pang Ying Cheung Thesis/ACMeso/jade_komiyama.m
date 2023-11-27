%% This code is based on Ren et al, 2022,
% 'Global and subtype-specific modulation of cortical inhibitory neurons regulated by acetylcholine during motor learning
% Involves PCA and ICA
% See paper to access the github


clear 
close all
clc


mkdir('PCA-ICA analysis');
mkdir('PCA-ICA analysis/PCA-ICA');

mkdir(['PCA-ICA analysis/PCA-ICA/Unwanted IC'])

mkdir(['PCA-ICA analysis/PCA-ICA/PCA']);
mkdir(['PCA-ICA analysis/PCA-ICA/ICA']);

mkdir(['PCA-ICA analysis/Raw DF analysis']);
mkdir(['PCA-ICA analysis/Raw DF analysis/DFs']);
mkdir(['PCA-ICA analysis/PCA-ICA DF analysis']);
mkdir(['PCA-ICA analysis/PCA-ICA DF analysis/DFs']);


filelist = dir(['DFs/','*.mat']); % all NormCore corrected mat files
filelist = natsortfiles(filelist);   
 masklist = dir(['MaskROI/','*.mat']);
 masklist = natsortfiles(masklist);

%% 
iFile = iFile + 1

% iFile = 1;


clearvars  -except keepVariables filelist masklist iFile

filename = filelist(iFile).name;
load(['DFs/',filename]);

stack = imresize(stack,0.5); % Both dimensions must be in the 100s or less or else get an error about not enough space to run jader.
stack(:,:,12001:end) = [];
 
% save(['PCA-ICA analysis/Raw DF analysis/DFs/', filename(1:11),'.mat'],'stack');

maskname = masklist(iFile).name;
load(['MaskROI/',maskname]);

% maskroi = imresize(maskroi,0.125);

% temporal_mean = zeros(1,size(stack,3));
% for ff = 1:size(stack,3);
%     temporal_mean (:,ff) = mean((stack(:,:,ff)),'all','omitnan');
% end


stack(isnan(stack))=0;
X = reshape(stack,size(stack,1)*size(stack,2),size(stack,3));

%% PCA

[coeff, score, latent,~,explained] = pca(X');

variance = sum(explained(1:1,1));
q = 1;
while variance <= 95 % While-loop keeps going as long as the statment holds true
    variance = sum(explained(1:(1*q),1));
    q = q +1;
end
disp(['number of PC explaining >95% of variance = ' num2str(q)])

q = 10; % number of the components to use

ModePCA = coeff(:,1:q); % COEFF: Row: Pixel, Column: Component
% Gets the first n-PC

figure
set(gcf, 'color','w')
 tiledlayout(2,5,'TileSpacing','Compact')      
% tiledlayout(1,3,'TileSpacing','Compact')      
clims = [0 0.05];
for ii = 1:size(ModePCA, 2)
    comp = ModePCA(:,ii);
    im = reshape(comp, size(stack,1),size(stack,2));
           
    % Plot
    nexttile
    imshow(im,[clims])
   colormap turbo;
 %  colormap (gca, lightzero);
    title (strcat("PC ", string(ii)));

end
c = colorbar
c.Label.String = 'Weights'
set(gca,'YTick',[clims]);


     
save(['PCA-ICA analysis/PCA-ICA/PCA/', filename(1:end-4),'_coeff.mat'],'coeff');
save(['PCA-ICA analysis/PCA-ICA/PCA/', filename(1:end-4),'_score.mat'],'score');
save(['PCA-ICA analysis/PCA-ICA/PCA/', filename(1:end-4),'_explained.mat'],'explained');

saveas(gcf,['PCA-ICA analysis/PCA-ICA/',filename(1:end-4),' PCA - turbo']);


%% ICA - jader
     
%% SECTION TITLE
% DESCRIPTIVE TEXT
B = jader(ModePCA'); % Input: Row: Mode, Column: Pixel; Get: B: Row: Independent Component(IC), Column: Component from PCA;

ModeICA = (B*ModePCA')'; 

A = inv(B)'; % column: PCA, row: IC, each column: PCA project on IC;

icascore = A*score(:,1:q)';    
    
figure
set(gcf, 'color','w')
tiledlayout(2,5,'TileSpacing','Compact')      
clims = [-2 10];   

for ii = 1:size(ModeICA,2);
    IC = ModeICA(:,ii);
    im = reshape(IC,size(stack,1),size(stack,2));

     % Plot
    nexttile
    imshow(im,[clims])
  colormap turbo
%     colormap (gca, darkzero); 
    title (strcat("IC ", string(ii)));
end
c = colorbar
c.Label.String = 'Weights'
set(gca,'YTick',[clims]);



save(['PCA-ICA analysis/PCA-ICA/ICA/', filename(1:end-4),'_ModeICA.mat'],'ModeICA');
save(['PCA-ICA analysis/PCA-ICA/ICA/', filename(1:end-4),'_icascore.mat'],'icascore');
save(['PCA-ICA analysis/PCA-ICA/ICA/', filename(1:end-4),'_B.mat'],'B');

saveas(gca,['PCA-ICA analysis/PCA-ICA/',filename(1:end-4),' ICA turbo']);

saveas(gca,['PCA-ICA analysis/PCA-ICA/',filename(1:end-4),' ICA']);


clearvars -except keepVariables A B coeff latent ModeICA ModePCA mu q score icascore stack X temporal_mean maskroi masklist filename iFile filelist clims



%% Removing IC and recontructing 

clearvars unwanted
HowMany = input('Number of unwanted IC: '); % 

if HowMany > 0
    for bb = 1:HowMany
        IfAny = input('Unwanted IC number: ');
        unwanted(1,bb) = IfAny;
    end
else HowMany == 0;
        unwanted = 0;
end

select_ica = [];
for rr = 1:size(ModeICA,2)
    v = ModeICA(:,rr);
    selected = rr == unwanted;
    s = sum(selected); 
    if s == 0;
        select_ica = cat(2,select_ica,v);
    else s > 0;
        ;
    end
end

select_icascore = [];
for aa = 1:size(icascore,1)
    p = icascore(aa,:);
    selected = aa == unwanted;
    s = sum(selected);
     if s == 0;
        select_icascore = cat(1,select_icascore,p);
     else s > 0;
         ;
     end
end


rec_ica = (select_ica*select_icascore); % + temporal_mean;

% ROIstack = NaN(size(stack));
% for xx = 1:size(rec_ica,1);
%     for yy = 1:size(rec_ica,2);
%        if maskroi == 0;
%            ;
%        else maskroi == 1;
%            ROIstack(xx,yy,:) = rec_ica(xx,yy,:);
%        end
%    end
% end


% the temporal mean is first removed and added back in jader? 
stack = reshape(rec_ica,size(stack,1),size(stack,2),[]);



save(['PCA-ICA analysis/PCA-ICA DF analysis/DFs/',filename(1:end-4),'_reconstructed.mat'],'stack','-v7.3');

% save([filename(1:end-4),'_reconstructed.mat'],'rec','-v7.3');


stack=single(stack);

% saveastiff(rec,'recreated pca-ica + mean.tif');

name2 = [filename(1:end-4),'.tif'];

fTIF = Fast_Tiff_Write(['PCA-ICA analysis/PCA-ICA DF analysis/DFs/',name2]);
for k = 1:size(stack,3)
    fTIF.WriteIMG(stack(:,:,k)');
end
fTIF.close;

close all


figure(1)
set(gcf,'color','w');
for jj = 1:size(unwanted, 2);
    k = unwanted(:,jj);
    
    figure(1)
    clf
    imshow((reshape(ModeICA(:,k),size(stack,1),size(stack,2))),[clims],'InitialMagnification','fit');
    titlename = ['IC',num2str(k(1:end))]
    title(titlename)
    colormap turbo
    saveas(gcf,['PCA-ICA analysis/PCA-ICA/Unwanted IC/',filename(1:11),'_',titlename])
end
close

%% 


% DF from corrected raw tif stack
% stack = imresize(stack,0.25);

% a = [];
% for ii = 1:size(stack,3);
%    a = cat(1,a,(mean((stack(:,:,ii)),'all','omitnan')));
% end
    
% Recontructed DFs from PCA-ICA
%b = [];
% for jj = 1:size(rec,3);
%    b = cat(1,b,(mean((rec(:,:,jj)),'all','omitnan')));
% end

% figure
% set(gcf,'color','w')
% hold on
% p1 = plot(a)
% p2 = plot(b)
% legend ([p1 p2],'ΔF raw','ΔF reconstructed');
% xlabel ('Frames')
% ylabel ('ΔF/F')

% saveas(gcf,'raw vs reconstructed DF');

















    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    