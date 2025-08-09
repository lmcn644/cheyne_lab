% Script to separately save needed CNMF_E outputs

clear; clc; close all;

%%
files=dir;
files(1:2,:)=[];
files = natsortfiles(files);
nFiles=size(files,1);

for iFile = 1:nFiles;  % 1:nFiles for OF, 2:2:nFiles for YM, 4:4:nFiles for NO    %Will only work if cnmfe has been run
    iFile
    file=files(iFile).name;
    folder=file;
    cd(folder)
    folderlist=dir('*extraction');
    cd(folderlist(1).name)
    folderlist=dir('frames*');
    cd(folderlist(1).name)
    folderlist=dir('LOGS*');
    cd(folderlist(1).name)
    matfile = dir('*.mat');
    matfile = matfile(1,:);
    matfile = matfile.name;
    load ([matfile]);  %% opens workspace with raw cnmf_e output data

    %% saves all relevant variable to new workspaces
    
    A=neuron.A;
    %save ('A','A');

    C=neuron.C;
    %save ('C','C');

    C_raw = neuron.C_raw;

    Cn=neuron.Cn;
    %save ('Cn','Cn');

    PNR=neuron.PNR;
    %save ('PNR','PNR');

    clearvars -except A C C_raw Cn neuron PNR files iFile nFiles

    save ('needed');

    cd ..
    cd ..
    cd ..
    
    save A 'A'
    save C 'C'
    save C_raw 'C_raw'
    
    cd ..

    clearvars -except files iFile nFiles
end 

