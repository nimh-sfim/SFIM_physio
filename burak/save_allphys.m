% Define subjects and run types
subjects = 11:34;
runs = {'inhold', 'outhold', 'resting'};

% Base path
base_dir = '/vf/users/SFIM_physio/physio/physio_results';

for s = subjects
    subj_str = sprintf('sub%d', s);
    subj_dir = fullfile(base_dir, subj_str);

    for r = 1:length(runs)
        run = runs{r};

        % File naming rules
        if strcmp(run, 'resting')
            map_file = fullfile(subj_dir, sprintf('%s_MAP_downsampled2TR.tsv', subj_str));
            lfo_file = fullfile(subj_dir, sprintf('%s_lfo_downsampled2TR.tsv', subj_str));
        else
            map_file = fullfile(subj_dir, sprintf('%s_MAP_downsampled2TR_%s.tsv', subj_str, run));
            lfo_file = fullfile(subj_dir, sprintf('%s_lfo_downsampled2TR_%s.tsv', subj_str, run));
        end

        rvt_file = fullfile(subj_dir, sprintf('%s_rvt_%s_2TR.mat', subj_str, run));
        output_file = fullfile(subj_dir, sprintf('%s_allphys_%s.mat', subj_str, run));

        try
            % --- Read MAP ---
            if isfile(map_file)
                tmp = readmatrix(map_file, 'FileType', 'text', 'Delimiter', '\t');
                if size(tmp, 2) >= 2
                    map_trace = tmp(:, 2);
                else
                    map_trace = tmp;
                end
            else
                warning('Missing MAP file: %s', map_file);
                map_trace = [];
            end

            % --- Read LFO ---
            if isfile(lfo_file)
                tmp = readmatrix(lfo_file, 'FileType', 'text', 'Delimiter', '\t');
                if size(tmp, 2) >= 2
                    lfo_trace = tmp(:, 2);
                else
                    lfo_trace = tmp;
                end
            else
                warning('Missing LFO file: %s', lfo_file);
                lfo_trace = [];
            end

            % --- Read RVT ---
            if isfile(rvt_file)
                load(rvt_file, 'respiration_signal_2TR');
            else
                warning('Missing RVT file: %s', rvt_file);
                respiration_signal_2TR = [];
            end

            % --- Package and Save ---
            allphys.map = map_trace;
            allphys.lfo = lfo_trace;
            allphys.rvt = respiration_signal_2TR;

            save(output_file, 'allphys');
            fprintf('? Saved: %s\n', output_file);

        catch ME
            warning('? Error processing subject %s %s: %s', subj_str, run, ME.message);
        end
    end
end

disp('? Allphys struct generation complete.');
