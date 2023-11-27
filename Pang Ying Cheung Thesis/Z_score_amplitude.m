%% Finding Outliers 

% load all amplitude 


av_amp = mean(in_amp);
SD_amp = std(in_amp);


% using z-score

z_score = [];
for ii = 1:size(in_amp,1);
    z_num = (in_amp(ii,1)-av_amp)/(SD_amp);
    z_score = cat(1,z_score,z_num);
end

outlier_check(:,1) = in_amp;
outlier_check(:,2) = z_score;

save('Tone_av_amplitude_z_score.mat','in_amp','z_score');

% skewness

sk = skewness(z_score);
