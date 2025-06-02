%% Define variables to characterize the spatial correlations

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Correlations between maps %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
dir = '/data/SFIM_physio';

coefs_slope = zeros(1,1);
coefs_int = zeros(1,1);
Rsq = zeros(1,1);
Z = zeros(1,1);

mask_of_choice=2;       %1 is cortex, 2 is brainstem
int=0;                  %allowing intercepts to vary, so set at 0

map1 = [dir '/group_hr/3dMEMA_hr.nii'];
map2 = [dir '/group_map/3dMEMA_map.nii'];

% map1 = strjoin([dir '/3dMEMA_' type(1) '_bi_clusters_05_05.nii.gz'], "");
% map2 = strjoin([dir '/3dMEMA_' type(2) '_bi_clusters_05_05.nii.gz'], "");

[input1_masked{1},input2_masked{1},Rsq(1),Z(1),coefs_slope(1),coefs_int(1)] = spatialcorr_function(map1,map2,int,mask_of_choice);  

    
