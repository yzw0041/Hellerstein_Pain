

% This script loads MNI coordinates specified in a user-created file,
% PainNet_16_coord.txt, and generates .mat and .img ROI files for use with
% Marsbar, MRIcron etc. 
% X1 Y1 Z1
% X2 Y2 Z2 etc
% .mat sphere ROIs will be saved in the script-created mat directory.
% .img sphere ROIs will be saved in the script-created img directory.
% SPM Toolbox Marsbar should be installed and started before running script.
% specify radius of spheres to build in mm
function coord_to_img(file)
radiusmm = 10;
C=load(file)
% Specify Output Folders for two sets of images (.img format and .mat format)
roi_dir_img = 'img';
roi_dir_mat = 'mat';
% Make an img and an mat directory to save resulting ROIs
mkdir('img');
mkdir('mat');
% Go through each set of coordinates from the specified file (line 2)
Crows = length(C(:,1));
for spherenumbers = 1:Crows
% maximum is specified as the centre of the sphere in mm in MNI space
maximum = C(spherenumbers,1:3);
sphere_centre = maximum;
sphere_radius = radiusmm;
sphere_roi = maroi_sphere(struct('centre', sphere_centre, 'radius', sphere_radius));
% Define sphere name using coordinates
coordsx = num2str(maximum(1));
coordsy = num2str(maximum(2));
coordsz = num2str(maximum(3));
spherelabel = sprintf('%s_%s_%s', coordsx, coordsy, coordsz);
sphere_roi = label(sphere_roi, spherelabel);
% save ROI as MarsBaR ROI file
saveroi(sphere_roi, fullfile(roi_dir_mat, sprintf('%dmmsphere_%s_roi.mat',radiusmm, spherelabel)));
% Save as image
save_as_image(sphere_roi, fullfile(roi_dir_img, sprintf('%dmmsphere_%s_roi.nii',radiusmm, spherelabel)));
end

[path,name,ext]=fileparts(file)
roi_atlas_label(sprintf('%s.nii',name))

end