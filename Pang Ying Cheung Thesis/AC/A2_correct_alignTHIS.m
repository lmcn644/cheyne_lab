%% Script to drift correct and align

clear
clc

filelist=dir(['Raw Tiff/','*.tif']);
% tic

% cd('Raw Tiff/');

YesFile = isfolder('Corrected');
if YesFile == 1
    ;
else YesFile == 0
    mkdir('Corrected');
end

YesFile = isfolder('Each Frame Corrected');
if YesFile == 1
    ;
else YesFile == 0
    mkdir('Each Frame Corrected');
end


bits=[];
for iFile=1:size(filelist,1);
 %   tic
    filename=filelist(iFile).name;
    stack=ReadTiffStack(['Raw Tiff/',filename]);
    Yf = double(stack);
    [d1,d2,T] = size(Yf);
    
    % drift correct and save as tiff
    normcorre_juliette
    clearvars -except keepVariables Yf Mr iFile filelist All bits filename frames animals iAnimal folder folder2 fullfolder
       
    filename=sprintf([num2str(filename(1:end-4)),'Corrected.tif']);
    fTIF = Fast_Tiff_Write(['Each Frame Corrected/',filename]);
    for k = 1:size(Mr,3)
        fTIF.WriteIMG(Mr(:,:,k)');
    end
    
    fTIF.close;
    % also keep 10 frames
    temp=Mr(:,:,1:10); %10 frames as template
    bits=cat(3,bits,temp);
    clearvars stack vid a
    % toc
end

% Get shifts for each file

Yf=bits;
[d1,d2,T] = size(Yf);
normcorre_juliette
clearvars -except keepVariables Mr iFile filelist All GP shifts1 options_r bound bits animals iAnimal folder folder2 fullfolder

% Reload and correct files, resize and concatenate
filelist=dir(['Each Frame Corrected/','*Corrected.tif']);

 All=[];
for iFile=1:size(filelist,1)
    %tic
    
    filename=filelist(iFile).name;
    corrected=ReadTiffStack(['Each Frame Corrected/',filename]);
    corrected = single(corrected);
    frames=size(corrected,3);
    clearvars shifts
    for i=1:frames
        shifts(i)=shifts1(iFile*10);
    end
    Mr = apply_shifts(corrected,shifts,options_r,bound/2,bound/2);

    corrected=imresize(Mr,0.25);
    All=cat(3,All,corrected); %one big file %easiest way to check the alignments are working;

    name = sprintf([num2str(filename(1:end-13)),'.mat']);
    save (['Corrected/',name],'Mr');
    %toc
end

%% When wanting to save one big as image tiff


name = sprintf('All Aligned');
filename=[name(1:end),'.tif'];
fTIF = Fast_Tiff_Write(filename);
for k = 1:size(All,3)
    fTIF.WriteIMG(All(:,:,k)');
end
fTIF.close;

