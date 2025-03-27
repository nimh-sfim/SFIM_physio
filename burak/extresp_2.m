% Parameters
TR = 0.75;  % seconds
fs = 1000;  % adjust to 500 if needed

% Load volumes table
volTable = readtable('/data/SFIM_physio/scripts/nifti_volumes.txt', 'Delimiter', '\t');
runs = {'inhold', 'outhold', 'resting'};

% Loop over subjects
subjects = 11:34;

for s = subjects
    subj_str = sprintf('sub%d', s);
    output_dir = fullfile('/vf/users/SFIM_physio/physio/physio_results', subj_str);

    % Get volume counts for this subject
    bp_id = sprintf('bp%d', s);
    row_idx = find(strcmp(volTable.Subjects, bp_id));
    if isempty(row_idx)
        warning('No volume info for %s', bp_id);
        continue;
    end

    for r = 1:length(runs)
        run = runs{r};
        % Match column name in volume table
        switch run
            case 'inhold', vol_col = 'binh';
            case 'outhold', vol_col = 'bouh';
            case 'resting', vol_col = 'rest';
        end

        n_vols = volTable{row_idx, vol_col};

        % File paths
        input_file = fullfile(output_dir, sprintf('%s_rvt_%s.mat', subj_str, run));
        output_file = fullfile(output_dir, sprintf('%s_rvt_%s_2TR.mat', subj_str, run));

        if isfile(input_file)
            try
                load(input_file, 'respiration_signal');

                % Lowpass filter below 1 Hz
                nyq = fs / 2;
                d = designfilt('lowpassiir', 'FilterOrder', 8, ...
                    'HalfPowerFrequency', 1, 'SampleRate', fs);
                filt_signal = filtfilt(d, respiration_signal);

                % Downsample to match n_vols
                total_samples_needed = round(n_vols * TR * fs);
                filt_signal = filt_signal(1:min(end, total_samples_needed));
                downsampled = resample(filt_signal, n_vols, length(filt_signal));

                % Save
                respiration_signal_2TR = downsampled; %#ok<NASGU>
                save(output_file, 'respiration_signal_2TR');
                fprintf('? Saved: %s\n', output_file);

            catch ME
                warning('Failed to process %s: %s', input_file, ME.message);
            end
        else
            warning('Missing input: %s', input_file);
        end
    end
end

disp('? RVT filtering + downsampling complete.');
