function plot_respiration_2TR(subject_num, type)
    % Validate input type
    valid_types = {'inhold', 'outhold', 'resting'};
    if ~ismember(type, valid_types)
        error('Invalid type. Choose from: inhold, outhold, resting');
    end

    % Build subject string and file path
    subj_str = sprintf('sub%d', subject_num);
    base_dir = '/vf/users/SFIM_physio/physio/physio_results';
    file_path = fullfile(base_dir, subj_str, sprintf('%s_rvt_%s_2TR.mat', subj_str, type));

    % Check file existence
    if ~isfile(file_path)
        error('2TR Respiration file not found: %s', file_path);
    end

    % Load the respiration signal
    load(file_path, 'respiration_signal_2TR');

    % Plot
    figure;
    plot(respiration_signal_2TR, 'LineWidth', 1.5);
    xlabel('Volume Index (TR)');
    ylabel('Filtered Respiration');
    title(sprintf('Downsampled RVT (1 sample/TR) - %s (%s)', subj_str, type), 'Interpreter', 'none');
    grid on;
end
