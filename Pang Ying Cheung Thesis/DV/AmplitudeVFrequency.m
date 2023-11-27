
freq = [];
ampli = [];

match = [];

for ii = 1:size(folders,1);
    foldername = folders(ii).name;
    
    nDF = dir([foldername,'/DFs/*.mat']);
    load([foldername,'/Frequency/',foldername,'_Frequency_s.mat']);
    
     h = size(nDF,1) == size(freq_evt_s,2)
     match = cat(1,match,h);
     
end





freq = [];
ampli = [];

for ii = 1:size(folders,1);
    foldername = folders(ii).name;
    
    
    load([foldername,'/Frequency/',foldername,'_Frequency_s.mat']);
    load([foldername,'/Frequency/',foldername,'_avAmplitude.mat']);
    
    freq = cat(1,freq,(transpose(freq_evt_s)));
    ampli = cat(1,ampli,(transpose(amp)));
end


%%%%
mdl = fitlm(ampli,freq);

R_squared = mdl.Rsquared.Ordinary;
R_value = sqrt(mdl.Rsquared.Ordinary);
