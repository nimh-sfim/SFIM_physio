% This script performs a seed-based functional connectivity analysis across
% the whole brain on a subject level.

% Set up variables
clc;clear;
phys_type = 'MAP';          %MAP, lfo
taskOI='outhold';           %resting, inhold, outhold
task4let='bouh';            %rest, binh, bouh
ROI_locations = ["Som4", "Som6", "Vis2"];
phys_types=["MAP1D", "MAPxRF", "nah"];    %which phys regressor was regressed out. "nah" means no phys was regressed from data

addpath(genpath('/data/SFIM/akin/bin/burak'));
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'))
addpath(genpath('/data/SFIM_physio/dependencies/Tools for NIfTI and ANALYZE image'))

%% Define the folder path based on phys_type
%subjects = ["14"];
subjects = ["10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34"];

for ii = 1:length(subjects)
    sbjid=char(subjects(ii));

    dir1 = ['/data/SFIM_physio/data/derivatives/sub' sbjid '/func_' task4let '_MAPRF_out'];

    % /Volumes/SFIM_physio/data/derivatives/sub10/func_rest_MAPRF_out
    % sub10_denoised_data_MAP1D.nii
    % sub10_denoised_data_MAPxRF.nii

    phys_types=["MAP1D", "MAPxRF", "nah"];    %which phys regressor was regressed out. "nah" means no phys was regressed from data

    for kk = 1:length(phys_types)
        if kk == 1
            phys_type = char(phys_types(1));
            bpath = dir1;
            fname = ['sub' sbjid '_' taskOI '_denoised_data_MAP1D.nii'];
        elseif kk == 2
            phys_type = char(phys_types(2));
            bpath = dir1;
            fname = ['sub' sbjid '_' taskOI '_denoised_data_MAPxRF.nii'];
        elseif kk == 3
            phys_type = 'nah';
            %bpath=['/data/SFIM_physio/data/bp' sbjid '/func_' task4let];
            %fname=['pb04.bp' sbjid '.r01.scale.nii'];   %or nii.gz
            bpath = dir1;
            fname = ['pb04.bp' sbjid '_' taskOI '_detrended2.nii'];
        else
            disp('something funny happened when defining filename of brain map of interest')
        end

        disp(['Lets see if we go to the correct dir: ' bpath])
        cd(bpath)
        if exist(fname, 'file') > 1

            atlpath='/data/SFIM_physio/scripts/YEO100.nii';
            [tcs,overalltcs]=get_labeled_tc(fname,atlpath);     %overalltcs: average timeseries of ROI 
                                                                %tcs: all the voxel timeseries within the ROIs as cells
                                                                %size(tcs{roi},1): how many voxels there are in the roi
            for jj = 1:length(ROI_locations)
                if jj == 1
                    roi1=39;
                    roi2=89;
                    slices=[68 55 67];   %sag cor ax
                elseif jj == 2
                    roi1=41;
                    roi2=91;
                    slices=[76 63 42];
                elseif jj == 3
                    roi1=45;
                    roi2=95;
                    slices=[51 25 41];
                end
            
                %% Average the left and right hemisphere ROIs
                rois_both = [cell2mat(tcs(1,roi1)); cell2mat(tcs(1,roi2))];
                roitc_avg = mean(rois_both,1);
                
                %roitc1=overalltcs(roi1,:); roitc2=overalltcs(roi2,:);       %the average timeseries of the selected seed ROI
                %plot(roitc1); hold on; plot(roitc2); hold on; plot(roi_avg, 'DisplayName', 'avg'); legend()
                
                %% detrend average ROI timeseries up to third polynomial
                roitc_detrend0=detrend(roitc_avg, 0);
                roitc_detrend1=detrend(roitc_detrend0, 1);
                roitc_detrend2=detrend(roitc_detrend1, 2);
                roitc_detrend3=detrend(roitc_detrend2, 3);
                
                %plot(roitc_detrend3); hold on; plot(roitc_detrend0)
            
                %% Compute functional connectivity brain map
                [imo] = connii2(fname,roitc_detrend3);     %generates the functional connectivity brain map in struct structure
                corrim=imo.img;                             %pulls the 3D matrix information
                %imagesc(flipud(squeeze(corrim(:,:,65))'));
                
                cd(dir1)    %save in 
                save_untouch_nii(imo,['sub' sbjid '_' taskOI '_ROI-' char(ROI_locations(jj)) '_regropt-' char(phys_types(kk))])
                cd(bpath)

                %% Define the underlay (anatomical MNI)
                upath='/data/SFIM_physio/scripts/burak/MNIreg.nii';
                uim=load_untouch_nii(upath);
                usag=row_nii(uim.img,slices(1),1)';     %sagittal view
                ucor=row_nii(uim.img,slices(2),2)';     %coronal view
                uax=row_nii(uim.img,slices(3),3)';      %axial view
                
                under=cat(2,cat(1,zeros([9 114]),usag,zeros([9 114])),cat(1,zeros([9 96]), ucor,zeros([9 96])),... 
                    uax); %pad and concat; generates underlying sag, cor, and axial view within one image
                
                %% Define the overlay in the image
                osag=row_nii(corrim,slices(1),1)';
                ocor=row_nii(corrim,slices(2),2)';
                oax=row_nii(corrim,slices(3),3)';
                
                %padding below should be with zeros...
                over=cat(2,cat(1,zeros([9 114]),osag,zeros([9 114])),cat(1,zeros([9 96]),ocor,zeros([9 96])),...
                    oax); %pad and concat; generates overlay sag, cor, and axial view within one image
                
                over=mask_nii(under,over); %mask overlay based on underlay(anatomical)
        
                %% Plot
                minval=-1;maxval=1;    %lower and upper range
                valn=0; valp=0;        %zero means no negative threshold
                clustn=0;clustp=0;     %cluster threshold;
                finalim=overlay_nii(under,over,minval,valn,valp,maxval,clustn,clustp);
                
                imagesc(finalim); colorbar; %title(['sub' sbjid ' ' char(ROI_locations(jj)) ' ' char(phys_types(kk))])
                
                cd('/data/SFIM_physio/figures/func_conn')    %Save all the results at the same place
                imwrite(finalim, ['sub' sbjid '_' taskOI '_ROI-' char(ROI_locations(jj)) '_regropt-' char(phys_types(kk)) '.jpeg']);
            
                cd(bpath)

            end
        else
            % File does not exist.
            warningMessage = sprintf('Warning: file does not exist:\n%s', fname);
            disp(warningMessage);

        end
    end
end


