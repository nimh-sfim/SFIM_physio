function plot_allphys(subject_num, type)
    % Validate type
    valid_types = {'inhold', 'outhold', 'resting'};
    if ~ismember(type, valid_types)
        error('Invalid type. Choose from: inhold, outhold, resting');
    end

    % File path
    subj_str = sprintf('sub%d', subject_num);
    base_dir = '/vf/users/SFIM_physio/physio/physio_results';
    input_file = fullfile(base_dir, subj_str, sprintf('%s_allphys_%s.mat', subj_str, type));

    if ~isfile(input_file)
        error('Allphys file not found: %s', input_file);
    end

    % Load data
    load(input_file, 'allphys');

    % Normalize traces (z-score)
    zmap = zscore(allphys.map(:));
    zresp = zscore(allphys.rvt(:));
    zlfo = zscore(allphys.lfo(:));

    % Determine min length (in case they differ slightly)
    min_len = min([length(zmap), length(zresp), length(zlfo)]);

    % Plot
    figure;
    hold on;
    plot(zmap(1:min_len), 'LineWidth', 2);
    plot(zlfo(1:min_len), 'LineWidth', 2);
    plot(zresp(1:min_len), 'LineWidth', 2);
    hold off;

    legend({'MAP', 'LFO', 'Respiration'}, 'Location', 'best');
    xlabel('Timepoint (TR)');
    ylabel('Z-scored Value');
    title(sprintf('Physio Traces - sub%d (%s)', subject_num, type), 'Interpreter', 'none');
    grid on;
end
