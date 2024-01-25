%define_interpolated_indices.m

%data = load('physio_bids/physio_files/sub12.mat')

% for card sub21: before_five_interp = [359.23, 360, 360.7, 361.47, 362.45];
before_five_interp = [35.12, 35.95, 36.91, 37.82, ];
after_five_interp = [, , , , ];

%% Before interpolation
diff_in_befores = zeros(length(before_five_interp)-1,1);
for ii = 1:(length(before_five_interp)-1)
    diff_in_befores(ii) = before_five_interp(ii+1) - before_five_interp(ii);
end
before_mean = mean(diff_in_befores);
before_stdev = sqrt(var(diff_in_befores));

%% After interpolation
diff_in_afters = zeros(length(after_five_interp)-1,1);
for jj = 1:(length(after_five_interp)-1)
    diff_in_afters(jj) = after_five_interp(jj+1) - after_five_interp(jj);
end
after_mean = mean(diff_in_afters);
after_stdev = sqrt(var(diff_in_afters));

%% Find out where to place
befores = [before_mean - before_stdev, before_mean + before_stdev]
afters = [after_mean - after_stdev, after_mean + after_stdev]

befores_and_afters = [(before_mean + after_mean)/2 - (before_stdev + after_stdev)/2, (before_mean + after_mean)/2 + (before_stdev + after_stdev)/2]
gap_size = after_five_interp(1) - before_five_interp(end)
how_many_placements = gap_size / mean(befores_and_afters)

%% Define new indices based on distances between the two last 
% trustworthy peaks pre- and post- bad data

new_indices_2 = zeros(1,round(how_many_placements)-1);
for kk = 1:round(how_many_placements)-1
    new_indices_2(1,kk) = before_five_interp(end)+((gap_size)*kk)/(round(how_many_placements));
end
disp(new_indices_2)


% %% Define new indices based on average distances; not using
% new_indices = zeros(round(how_many_placements),1);
% for kk = 1:round(how_many_placements)
%     new_indices(kk) = before_five_interp(end)+mean(befores_and_afters)*kk;
% end
