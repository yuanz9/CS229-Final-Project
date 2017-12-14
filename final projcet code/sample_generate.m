clear;

feature_interval = 30;
time_span_of_sample = 7;

%% i-80
i_80_RAW_data = csvread('i-80-dt.csv', 1, 0);
i_80_data_time_period_1 = i_80_RAW_data(     1:209712, :);
i_80_data_time_period_2 = i_80_RAW_data(209713:419403, :);
i_80_data_time_period_3 = i_80_RAW_data(419404:end,    :);


[i_80_data_1, i_80_LCE_1] = data_process(i_80_data_time_period_1, 'i-80-1', feature_interval, time_span_of_sample);
[i_80_data_2, i_80_LCE_2] = data_process(i_80_data_time_period_2, 'i-80-2', feature_interval, time_span_of_sample);
[i_80_data_3, i_80_LCE_3] = data_process(i_80_data_time_period_3, 'i-80-3', feature_interval, time_span_of_sample);


%% us-101
us101_RAW_data = csvread('us101-dt.csv', 1, 0);
us101_data_time_period_1 = us101_RAW_data(     1:209712, :);
us101_data_time_period_2 = us101_RAW_data(209713:560200, :);
us101_data_time_period_3 = us101_RAW_data(560201:end,    :);

[us101_data_1, us101_LCE_1] = data_process(us101_data_time_period_1, 'us101-1', feature_interval, time_span_of_sample);
[us101_data_2, us101_LCE_2] = data_process(us101_data_time_period_2, 'us101-2', feature_interval, time_span_of_sample);
[us101_data_3, us101_LCE_3] = data_process(us101_data_time_period_3, 'us101-3', feature_interval, time_span_of_sample);

%%
data = [i_80_data_1; i_80_data_2; i_80_data_3; ... 
        us101_data_1; us101_data_2; us101_data_3];

% data = data(:, [1,21,60,17]);

csvwrite('data.temp.csv',data);

