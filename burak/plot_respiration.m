function plot_respiration(subject_num, type)
    % Validate input type
    valid_types = {'inhold', 'outhold', 'resting'};
    if ~ismember(type, valid_types)
        error('Invalid type. Choose from: inhold, outhold, resting');
    end

    % Build path and filename
    subj_str = sprintf('sub%d', subject_num);
    base_dir = '/vf/users/SFIM_physio/physio/physio_results';
    file_path = fullfile(base_dir, subj_str, sprintf('%s_rvt_%s.mat', subj_str, type));

    % Check file existence
    if ~isfile(file_path)
        error('Respiration file not found: %s', file_path);
    end

    % Load the respiration signal
    load(file_path, 'respiration_signal');

    % Plot
    figure;
    plot(respiration_signal);
    xlabel('Sample Index');
    ylabel('Amplitude');
    title(sprintf('Respiration Signal - %s (%s)', subj_str, type), 'Interpreter', 'none');
    grid on;
end
