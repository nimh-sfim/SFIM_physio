% List of subjects
subjects = 11:34;

% Run types and file suffixes
runs = {'inhold', 'outhold', 'resting'};

for s = subjects
    subj_str = sprintf('sub%d', s);
    input_dir = fullfile('/data/SFIM_physio/physio/physio_files', subj_str);
    output_dir = fullfile('/vf/users/SFIM_physio/physio/physio_results', subj_str);

    % Create output directory if it doesn't exist
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    for r = 1:length(runs)
        run = runs{r};
        acq_file = fullfile(input_dir, sprintf('%s_%s.acq', subj_str, run));
        output_file = fullfile(output_dir, sprintf('%s_rvt_%s.mat', subj_str, run));

        if isfile(acq_file)
            try
                % Load with load_acq (returns struct with signals in .data)
                acq_data = load_acq(acq_file);

                % Extract first row (respiration)
                respiration_signal = acq_data.data(:, 1);  % First row = respiration

                % Save result
                save(output_file, 'respiration_signal');
                fprintf('Saved: %s\n', output_file);

            catch ME
                warning('Failed to load or process %s: %s', acq_file, ME.message);
            end
        else
            warning('File not found: %s', acq_file);
        end
    end
end

disp('? Respiration signal extraction complete.');
