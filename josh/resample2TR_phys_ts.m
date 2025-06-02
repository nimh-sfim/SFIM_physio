% This script currently resamples the mean arterial pressure timeseries, 
% which had previously been re-sampled to an even grid, or the
% LFO timeseries to every TR. 

% dependencies
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'))
addpath(genpath('/data/SFIM/akin/bin/burak/'))
addpath(genpath('/data/SFIM_physio/dependencies/Scattered Data Interpolation and Approximation using Radial Base Functions/'))

phys = 'lfo';       %'MAP' or 'lfo'
taskOI = 'outhold';    %resting,inhold,outhold
subjects = ["10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34"];
%no MAP for 17 or 29
%subjects = ["26","27","28","29","30","31","32","33","34"];

ii = 1;     % initialize

while ii <= length(subjects)

    is_data_synchronizable = true;  %by default, set to true to run the processing

    %for ii = 1:length(subjects)

    while is_data_synchronizable    %some subjects are not able to be synchronized
        
        sbjid = subjects(ii);
    
        %% Some subjects didn't have phys data. Skip these.
        if sbjid == "10" && strncmp(taskOI,'inhold',4)
            disp(strjoin(['Skipping sub' sbjid ' ' taskOI '. No breathing ACQ.'],''))
            is_data_synchronizable = false;      % don't continue processing and go to next subject
            ii = ii+1;  % otherwise will re-do the subject
            break
        elseif sbjid == "10" && strncmp(taskOI,'outhold',4)
            disp(strjoin(['Skipping sub' sbjid ' ' taskOI '. No breathing ACQ.'],''))
            is_data_synchronizable = false;
            ii = ii+1;  % otherwise will re-do the subject
            break 
        elseif sbjid == "26" && strncmp(taskOI,'inhold',4)
            disp(strjoin(['Skipping sub' sbjid ' ' taskOI '. No Inhold ACQ.'],''))
            is_data_synchronizable = false;
            ii = ii+1;  % otherwise will re-do the subject
            break           
        end

        %% Some subjects weren't able to be synchronized for MAP
        if strncmp(phys,'MAP',3)
            if sbjid == "25" && strncmp(taskOI,'rest',4)
                disp(strjoin(['Skipping sub' sbjid ' ' taskOI '. Not synchronizable'],''))
                is_data_synchronizable = false;      % don't continue processing and go to next subject
                ii = ii+1;  % otherwise will re-do the subject
                break
            elseif sbjid == "28" && strncmp(taskOI,'rest',4)
                disp(strjoin(['Skipping sub' sbjid ' ' taskOI '. Not synchronizable'],''))
                is_data_synchronizable = false;
                ii = ii+1;  % otherwise will re-do the subject
                break
            elseif sbjid == "33" && strncmp(taskOI,'rest',4)
                disp(strjoin(['Skipping sub' sbjid ' ' taskOI '. Not synchronizable'],''))
                is_data_synchronizable = false;
                ii = ii+1;  % otherwise will re-do the subject
                break
            elseif sbjid == "33" && strncmp(taskOI,'inhold',4)
                disp(strjoin(['Skipping sub' sbjid ' ' taskOI '. Not synchronizable'],''))
                is_data_synchronizable = false;
                ii = ii+1;  % otherwise will re-do the subject
                break
            elseif sbjid == "31" && strncmp(taskOI,'outhold',4)
                disp(strjoin(['Skipping sub' sbjid ' ' taskOI '. Not synchronizable'],''))
                disp('*Note: Im unsure whether index should be changed to 73184. Atm, Im choosing to not proceed.')
                is_data_synchronizable = false;
                ii = ii+1;  % otherwise will re-do the subject
                break
            elseif sbjid == "33" && strncmp(taskOI,'outhold',4)
                disp(strjoin(['Skipping sub' sbjid ' ' taskOI '. Not synchronizable'],''))
                is_data_synchronizable = false;
                ii = ii+1;  % otherwise will re-do the subject
                break
            end
        end

        %%
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
    
        %% Let's determine the nvols from the text file instead of reading in the NIFTI file
        nvols_table = readtable('/data/SFIM_physio/scripts/nifti_volumes.txt');
        nvols_sbj = nvols_table(:,1);
        nvols_task = nvols_table.Properties.VariableNames(2:4);
        
        expected_col_names = ["Subjects","bouh","binh","rest"];
        for kk = 1:length(nvols_table.Properties.VariableNames)
            if strcmp(nvols_table.Properties.VariableNames(kk),expected_col_names(kk)) == 0
                disp(['WARNING: COLUMN NAMES OF NVOLS TABLE DO NOT MEET MY EXPECTATIONS, index: ', num2str(kk), '.']); disp('THIS MAY INDICATE THAT IM USING THE WRONG NVOLS.')
            end
        end
        
        if strncmp(taskOI, 'outhold', 4)
            colOI = 2;      %task_tmp = 'bouh'
        elseif strncmp(taskOI, 'inhold', 4)
            colOI = 3;      %task_tmp = 'binh'
        elseif strncmp(taskOI, 'rest', 4)
            colOI = 4;      %task_tmp = 'rest'
        end
        rowOI = str2num(sbjid) - 10 + 1;
        nvols = table2array(nvols_table(rowOI, colOI));
        
        % Three phys datas were cut short, so set nvols accordingly
        if sbjid == "11" && strncmp(taskOI,'rest',4)
            nvols = 586;
        elseif sbjid == "11" && strncmp(taskOI,'inhold',4)
            nvols = 586;
        elseif sbjid == "26" && strncmp(taskOI,'outhold',4)
            nvols = 586;
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
    
        is_data_synchronizable = true;  %by default, set to true to run the processing
        
        if ii == length(subjects)
            ii = ii+1;  % otherwise will re-do the subject
            break       % indicates that we've reached the end of the subject list
        end
        
        ii = ii+1;      %increase while in for loop. Otherwise will continue to do the same subject.


        %% Question:
        % Should I:
        % a) rescale
        % b) demean the data
        % At the moment, I'm doing none of these things

    end
end


