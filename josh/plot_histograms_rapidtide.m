% Plot delay (and corr?) histogram distributions of results from Rapidtide 3.0
% to see the across subject variability and how that collapses when averaging at the group level

% Set up variables
clc;clear;
phys_type = 'MAP';          %MAP, lfo
info_type = 'delay';        %delay, corr
taskOI='resting';           %resting, inhold, outhold
delay_range = '1030';   %-9sto18s or 0sto21s
dir1 = '/data/SFIM_physio/physio/physio_results';
dir2 = '/data/SFIM_physio/data/derivatives/group_rapidtide3.0';
counter = 1;

%% Load masks (the below maps are slightly off, use a different set of masks later)
% Some masks are not from 0 to 1. Correct this by normalizing
% Also, beware. GM and WM mask is of uint8 datatype, which only includes 0:1:255, so convert to double to allow for non-integers
dir_mask = '/data/SFIM_physio/atlases_rs';
csf_mask = load_nii([dir_mask '/aparc.a2009s+aseg_REN_vent_rs.nii']);
csf_mask_img = csf_mask.img;
csf_mask_img_norm = (csf_mask_img - double(min(csf_mask_img(:)))) ./ double(max(csf_mask_img(:)));

gm_mask = load_nii([dir_mask '/aparc.a2009s+aseg_REN_gm_rs.nii']);
gm_mask_img = gm_mask.img;
gm_mask_img_norm = (double(gm_mask_img) - double(min(gm_mask_img(:)))) ./ double(max(gm_mask_img(:)));

wm_mask = load_nii([dir_mask '/aparc.a2009s+aseg_REN_wmat_rs.nii']);
wm_mask_img = wm_mask.img;
wm_mask_img_norm = (double(wm_mask_img) - double(min(wm_mask_img(:)))) ./ double(max(wm_mask_img(:)));

brain_mask = load_nii([dir_mask '/HarvardOxford-sub-maxprob-thr0-2mm_rs.nii']);
brain_mask_img = brain_mask.img;

% Threshold to binary maps
csf_mask_thr = csf_mask_img_norm;
csf_mask_thr(csf_mask_thr>0)=1;
csf_mask_thr(csf_mask_thr<=0)=NaN;
gm_mask_thr = gm_mask_img_norm;
gm_mask_thr(gm_mask_thr>0)=1;
gm_mask_thr(gm_mask_thr<=0)=NaN;
wm_mask_thr = wm_mask_img_norm;
wm_mask_thr(wm_mask_thr>0)=1;
wm_mask_thr(wm_mask_thr<=0)=NaN;
brain_mask_thr = brain_mask_img;
brain_mask_thr(brain_mask_thr>0)=1;
brain_mask_thr(brain_mask_thr<=0)=NaN;
%imagesc(csf_mask_thr(:,:,50)); colorbar;

%% Start for loop
%subjects = ["18"];      %testing
subjects = ["10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34"];

for ii = 1:length(subjects)
    sbjid = subjects(ii);

    % Define directories for Rapidtide 3.0 maps (subject and group)
    if phys_type == 'MAP'
        dir3 = strjoin(['/data/SFIM_physio/data/derivatives/sub',sbjid,'/rapidtide/blood_pressure8'],'');
    elseif phys_type == 'lfo'
        dir3 = strjoin(['/data/SFIM_physio/data/derivatives/sub',sbjid,'/rapidtide/cardiac_lfo8'],'');
    end
    if strncmp(info_type, 'delay', 4)
        group_brain_file = [dir2 '/' phys_type '_time_' taskOI '_' delay_range '_group_mask.nii'];
        sbjid_brain_file = strjoin([dir3 '/sub' sbjid '_' taskOI '_MAP_delay_' delay_range '_desc-maxtime_map.nii.gz'],'');
    elseif strncmp(info_type, 'corr', 4)
        %LFO_corr_resting_1030_group_mask.nii
        group_brain_file = [dir2 '/' phys_type '_corr_' taskOI '_' delay_range '_group_mask.nii'];
        sbjid_brain_file = strjoin([dir3 '/sub' sbjid '_' taskOI '_MAP_delay_' delay_range '_desc-maxcorr_map.nii.gz'],'');
    end

    % Load Rapidtide 3.0 maps (group)
    group_brain = load_nii(char(group_brain_file));
    group_brain_img = group_brain.img;

    % Mask group maps (GM, WM, CSF, brain)
    group_brain_img_csf = group_brain_img .* double(csf_mask_thr) .* double(brain_mask_thr);
    group_brain_img_gm = group_brain_img .* double(gm_mask_thr) .* double(brain_mask_thr);
    group_brain_img_wm = group_brain_img .* double(wm_mask_thr) .* double(brain_mask_thr);
    group_brain_img_brain = group_brain_img .* double(brain_mask_thr);

    dim = size(group_brain_img);
    group_brain_img_csf_1d = reshape(group_brain_img_csf,[1,dim(1)*dim(2)*dim(3)]);
    group_brain_img_gm_1d = reshape(group_brain_img_gm,[1,dim(1)*dim(2)*dim(3)]);
    group_brain_img_wm_1d = reshape(group_brain_img_wm,[1,dim(1)*dim(2)*dim(3)]);
    group_brain_img_brain_1d = reshape(group_brain_img_brain,[1,dim(1)*dim(2)*dim(3)]);

    % if statement tests if subject file exists
    if exist(sbjid_brain_file, 'file') > 1
        % Load Rapidtide 3.0 maps (subject)
        sbjid_brain = load_nii(char(sbjid_brain_file));
        sbjid_brain_img = sbjid_brain.img;
        
        % Mask subject maps (GM, WM, CSF, whole brain)
        sbjid_brain_img_csf = sbjid_brain_img .* double(csf_mask_thr);
        sbjid_brain_img_gm = sbjid_brain_img .* double(gm_mask_thr);
        sbjid_brain_img_wm = sbjid_brain_img .* double(wm_mask_thr);
        sbjid_brain_img_brain = sbjid_brain_img .* double(brain_mask_thr);

        % Plot subject GM v. WM. CSF distributions
        %% Below is from applying_masks_histograms.m        
        sbjid_brain_img_csf_1d = reshape(sbjid_brain_img_csf,[1,dim(1)*dim(2)*dim(3)]);
        sbjid_brain_img_gm_1d = reshape(sbjid_brain_img_gm,[1,dim(1)*dim(2)*dim(3)]);
        sbjid_brain_img_wm_1d = reshape(sbjid_brain_img_wm,[1,dim(1)*dim(2)*dim(3)]);
        sbjid_brain_img_brain_1d = reshape(sbjid_brain_img_brain,[1,dim(1)*dim(2)*dim(3)]);
        
        if ii == 1
            tiledlayout(10,2);
            nexttile;
        end
        %figure(counter)
        font_size = 15; 
        if strncmp(info_type, 'delay', 4)
            xg=linspace(-10,30);
        elseif strncmp(info_type, 'corr', 4)
            xg=linspace(-1,1);
        end
        fa = ksdensity(sbjid_brain_img_csf_1d,xg);
        fb = ksdensity(sbjid_brain_img_gm_1d,xg);
        fc = ksdensity(sbjid_brain_img_wm_1d,xg);
        fd = ksdensity(sbjid_brain_img_brain_1d,xg);
        plot(xg,fa,'color','g','LineWidth',2,'DisplayName','CSF')
        hold on
        plot(xg,fb,'color','r','LineWidth',2,'DisplayName','GM')
        hold on
        plot(xg,fc,'color','b','LineWidth',2,'DisplayName','WM')
        hold on
        plot(xg,fd,'color','y','LineWidth',2,'DisplayName','Brain')
        legend()
        ylabel(strjoin(['sub' sbjid],''))
        grid on
        grid minor
        ax=gca;
        ax.FontSize = font_size;
        nexttile;

        % figure(2)
        % font_size = 15; 
        % xg=linspace(-3,3);
        % fx = ksdensity(group_hr_brainstem_nii_1d,xg);
        % fy = ksdensity(group_bp_brainstem_nii_1d,xg);
        % plot(xg,fx,'color','g','LineWidth',2,'DisplayName','HR')
        % hold on
        % plot(xg,fy,'color','r','LineWidth',2,'DisplayName','MAP')
        % legend()
        % title('Group Brainstem')
        % grid on
        % grid minor
        % ax=gca;
        % ax.FontSize = font_size;
        
        % Plot all subject whole brain distributions along with group averaged for task condition

        counter = counter + 1;
    else
        % File does not exist.
        warningMessage = sprintf('Warning: file does not exist:\n%s', sbjid_brain_file);
        disp(warningMessage);
    end

end


