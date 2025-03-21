% This script currently resamples the mean arterial pressure timeseries to every TR, 
% which had previously been re-sampled to an even grid

% dependencies
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'))
addpath(genpath('/data/SFIM/akin/bin/burak/'))
addpath(genpath('/data/SFIM_physio/dependencies/Scattered Data Interpolation and Approximation using Radial Base Functions/'))

phys = 'lfo';       %'MAP' or 'lfo'
taskOI = 'outhold';    %rest,inhold,outhold
%subjects = ["12"];
%subjects = ["13","14","15","16","18","19","20","21","22","23","24","25"];
subjects = ["27","28","30","31","32","33","34"];
%subjects = ["13","14","15","16","18","19","20","21","22","23","24","25","26","27","28","30","31","32","33","34"];

for ii = 1:length(subjects)
    sbjid = subjects(ii);
    disp(strjoin(["Processing sub" sbjid],''))

    dir1 = strjoin(["/data/SFIM_physio/physio/physio_results/sub",sbjid,"/"],'');
    
    if phys == 'MAP'
        filename1 = strjoin(["sub" sbjid "_MAP_upsampled_" taskOI ".tsv"],'');
    elseif phys == 'lfo'
        filename1 = strjoin(["sub" sbjid "_lfo_" taskOI ".tsv"],'');
    end
    file1 = strjoin([dir1 filename1],'');
    phys_ups = readtable(file1, "FileType","text",'Delimiter', '\t');

    if phys == 'MAP'
        phys_ups_time = table2array(phys_ups(:,1));
        phys_ups_time_norm = phys_ups_time - phys_ups_time(1); % Normalize the time.      
        phys_ups_arr = table2array(phys_ups(:,2));
    elseif phys == 'lfo'
        phys_ups_arr = table2array(phys_ups(:,1));
    end

    % Define the number of volumes in fMRI dataset, specific to task & subject
    % To make this step faster, consider calling the HEADER instead of the NIFTI
    if strncmp(taskOI,'rest',4)
        dir2 = strjoin(["/data/SFIM_physio/data/bp" sbjid "/func_rest/"],'');
    elseif strncmp(taskOI,'inhold',4)
        dir2 = strjoin(["/data/SFIM_physio/data/bp" sbjid "/func_binh/"],'');
    elseif strncmp(taskOI,'outhold',4)
        dir2 = strjoin(["/data/SFIM_physio/data/bp" sbjid "/func_bouh/"],'');
    end
    file = strjoin([dir2, "pb04.bp" sbjid ".r01.scale.nii"],'');
    
    if sbjid == "11" && strncmp(taskOI,'rest',4)
        nvols = 586;     %was cut short... See https://docs.google.com/spreadsheets/d/1aYZnXEzzgalY8HCcHlRt8VxOVOqxcbd1g3cfTOue9y4/edit?usp=sharing
        % PREVIOUSLY PUT DOWN THE NUMBER OF SECONDS!!!
    else
        nvols=get_nvols(convertStringsToChars(file));   %function only works with characters, not strings
    end
    scan_time=nvols*0.75;       %seconds

    %% Re-interpolate to every TR using RBF
    % okie dokie, so let's first define the timepoints  that we'll want to
    % interpolate from Pulse to Vitals
    TR = 0.75;
    new_time = [TR : TR : scan_time];   %If there are 1200 volumes, then there should not be 1201 timepoints in new_time. 
                                        %I originally was starting new_time
                                        %index 1 at time 0, but then
                                        %changed it to TR. ASK ABOUT THIS!?

    % Create coordinates of nodes    
    if phys == 'MAP'
        old_time = phys_ups_time_norm';
    elseif phys == 'lfo'
        % Sometimes the BIOPAC's sampling rate is 1000 Hz (for sub12 and sub13)
        if sbjid == "12" | sbjid == "13"
            fsamp_biopac = 1000;   %sampling rate for BIOPAC (ACQ data)
        else
            fsamp_biopac = 500;
        end
        old_time = [1/fsamp_biopac : 1/fsamp_biopac : scan_time]';
    end

    % Create values of function at the nodes
    phys_val_nodes = phys_ups_arr';

    %% Now, interpolate the Vitals to this timing information using RBF
    smooth_factor = 0;

    % Due to out of memory error, I need to downsample the LFO array... 
    if phys == 'MAP'
        rbf_phys = rbfcreate(old_time,phys_val_nodes,'RBFFunction','multiquadric','RBFSmooth',smooth_factor); 
    elseif phys == 'lfo'
        %old_time2 = decimate(old_time, 10);
        %phys_val_nodes2 = decimate(phys_val_nodes, 10);
        old_time2 = old_time([1:50:end]);
        phys_val_nodes2 = phys_val_nodes([1:50:end]);
        rbf_phys = rbfcreate(old_time2',phys_val_nodes2,'RBFFunction','multiquadric','RBFSmooth',smooth_factor); 
    end

    % Calculate interpolated values
    fi_phys = rbfinterp(new_time, rbf_phys);

    figure(ii)
    subplot(2,1,1)
    plot(phys_ups_arr); title('Phys prior to downsampling'); ylabel("sub" + sbjid)
    subplot(2,1,2)
    plot(fi_phys); title('Phys downsampled to TR'); ylabel("sub" + sbjid)

    %% Save variable, fi_phys... 
    cd(dir1)
    if phys == 'MAP'
        MAP_TR = array2table([new_time; fi_phys]');
        MAP_TR.Properties.VariableNames = [{'Time (sec)'} {'MAP (mmHg)'}];
        filename2save = strjoin(["sub" sbjid "_MAP_downsampled2TR_" taskOI ".tsv"],'');
        writetable(MAP_TR, filename2save,'filetype','text', 'delimiter','\t')
        % Save variable, fi_phys, without time... 
        MAP_TR_arr = fi_phys';
        filename2save_arr = strjoin(["sub" sbjid "_MAP_downsampled2TR_arr_" taskOI ".tsv"],'');
        writematrix(MAP_TR_arr, filename2save_arr,'filetype','text', 'delimiter','\t')
    elseif phys == 'lfo'
        LFO_TR = array2table([new_time; fi_phys]');
        LFO_TR.Properties.VariableNames = [{'Time (sec)'} {'LFO'}];
        filename2save = strjoin(["sub" sbjid "_lfo_downsampled2TR_" taskOI ".tsv"],'');
        writetable(LFO_TR, filename2save,'filetype','text', 'delimiter','\t')
        % Save variable, fi_phys, without time... 
        LFO_TR_arr = fi_phys';
        filename2save_arr = strjoin(["sub" sbjid "_lfo_downsampled2TR_arr_" taskOI ".tsv"],'');
        writematrix(LFO_TR_arr, filename2save_arr,'filetype','text', 'delimiter','\t')
    end

    %% Question:
    % Should I:
    % a) rescale
    % b) demean the data
    % At the moment, I'm doing none of these things

end


