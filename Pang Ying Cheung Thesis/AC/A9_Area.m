%% Finding the area of all tone responsive 



mkdir('Area and Frequency')
load('BF_coordinates.mat');

sum_pixel = size(coordinates,1);

% look for the total pixel allocated with a BF
% the length on side of a pixel is 0.13039 mm

Area = (0.013039^2)*size(coordinates,1); % unit is mm


save(['Area and Frequency/Area.mat'],'Area');


