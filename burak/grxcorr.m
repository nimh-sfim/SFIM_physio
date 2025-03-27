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
        output_file = fullfile(subj_dir, sprintf('%s_allphys_%s.mat', subj_str, run));
        load('output_file');
      