function  networkroi(width,height, varargin )
%RoiActivity. Reads rois from 'ROIs' dir and gives activity plots of df
%files.
%   Detailed explanation goes here

%% Parse optional inputs.
p = inputParser;
p.parse(varargin{:});
Parameter = p.Results;

%% List ROI files
FileList = dir( [pwd,'\ROIs\*.roi']);
nFiles = size(FileList, 1); 
fprintf('%d ROI(s) Found',nFiles);



%% Prepare Roi Mask.
mask = zeros(height,width);
cRoi=1;
%% Read ROIs one at each time.
for iRoi = 1:nFiles
    %% Loading file
    file = [FileList(iRoi).name];
    [sROI] = ReadImageJROI([pwd,'\ROIs\',file]);
    box = sROI.vnRectBounds;   
    %% Process ROI to get pixels
    switch sROI.strType
        
        case 'Oval'
            I = [];
            %% Draw boundingbox and get elipse features.
            I(box(1):box(3),box(2):box(4))=1;
            s = regionprops(I, 'Orientation', 'MajorAxisLength', ...
            'MinorAxisLength', 'Eccentricity', 'Centroid');
        
            %% Get point of elipse.
            ret = draw_ellipse(s.Centroid(2), s.Centroid(1), s.MajorAxisLength/2, s.MinorAxisLength/2,  ...
                s.Orientation, zeros(height,width), 1);
            mask(logical(ret)) = cRoi;
                cRoi = cRoi+1;
            % Get center of ROI  
            center(iRoi,1)=box(3)-((box(3)-box(1))/2);
            center(iRoi,2)=box(4)-((box(4)-box(2))/2);
            
            
        case {'Polygon' , 'Freehand'}
            %% Get pixels inside polygon
            xgrid = 1 :height;
            ygrid = 1: width;
            [X, Y] = meshgrid(ygrid, xgrid);
            k_inside = inpolygon(Y, X,sROI.mnCoordinates(:,2), sROI.mnCoordinates(:,1));
            %% Mask only pixels within polygon not on the edge (or the indicators)
            mask(k_inside) = cRoi;
            mask(sub2ind([width,height],sROI.mnCoordinates(:,2),sROI.mnCoordinates(:,1))) = 0;
                cRoi = cRoi+1;
            
        case 'Rectangle'
            mask(box(1):box(3),box(2):box(4)) = cRoi;
                cRoi = cRoi+1;
           
        otherwise
            fprintf('\nSkipped %s: Not an area ROI',file);
            
    end
        
end

%% Display Results
figure();
imshow(mask, []); 
map = jet();
map(1,:)=[0,0,0];
colormap(map);

%% Save
save([pwd,'\ROIs\roiMask.mat'],'mask');
save([pwd,'\ROIs\roiCoordinates.mat'],'center');
fprintf('\n');
            
end

