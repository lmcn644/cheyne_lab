%% NormCorre


%Y=loadtiff('msCam00-1.tif');

% Y = variable of the mat image you want to correct

%Yf = single (Y); % if your mat file is not set to type single 
[d1,d2,T] = size(All); % d1 = row, d2 = column, T = number of frames

%% perform rigid motion correction 

%set parameters:
MC_rigid = MotionCorrection(All);
options_rigid = NoRMCorreSetParms('d1',MC_rigid.dims(1),'d2',MC_rigid.dims(2),'bin_width',100,'max_shift',50,'iter',2,'correct_bidir',false);
% dims - dimensions of the field of view (should be the pixel size of the image)
% d1 = row, d2 = column, d3 = stack; number of frames
% bin_width = length of bin over which the registered frames are averaged to update the template i.e. update bin after every 50th frame
% max_shift = maximum allowed shift for rigid translation
% us_fac = 
% init_batch =
% iter = number of imes to go over the dataset % The MATLAB app was 5
% correct_bidir = check for offset due to bidirectional scanning (default is true; Bastjin's script was false)

% The actual motion correction
MC_rigid.motionCorrectSerial(options_rigid);
rigidCorrected = MC_rigid.M; 

% The corrected variable is 'M', which is in 'MC_rigid'. This code brings out the M from inside MC_rigid. 
%%
filename = sprintf('Corrected Rigid i2 b100.tif');


fTIF = Fast_Tiff_Write(filename);

for k = 1:length(rigidCorrected)
    fTIF.WriteIMG(rigidCorrected(:,:,k)');
end
fTIF.close;



%save([filename2],'rigidCorrected');
    

%% non-rigid motion correction
% Better, but takes forever to run
Yf = MC_rigid.M; 
% Set parameter
MC_nonrigid = MotionCorrection(Yf);
options_nonrigid = NoRMCorreSetParms('d1',size(Y,1),'d2',size(Y,2),'grid_size',[128,128],'mot_uf',4,'iter',1,'bin_width',100,'max_shift',30,'max_dev',3,'us_fac',50,'init_batch',200);
% grid_size = size of non-overlapping portion of each patch the grid in each direction (x-y-z);
% mot_uf = upsampling factor for smoothing and refinement of motion field

% The actual motion correction
MC_nonrigid.motionCorrectSerial(options_nonrigid);

nonrigCorrected = MC_nonrigid.M;
%%
%filename2 = sprintf('CorrectednonRigid.tif');
filename2 = sprintf('Both i20b.tif');
%save([filename2], 'nonrigCorrected');
saveastiff(nonrigCorrected,filename2)


