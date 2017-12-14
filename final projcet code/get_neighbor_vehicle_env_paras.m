function [env_paras, env_paras_empty_flag] = get_neighbor_vehicle_env_paras...
         (data_time_period_i, data_set_alias, lane_change_events, event_idx, time_span_of_sample, if_lane_change)

% env_paras = [target_lane_preceding_delta_x; target_lane_preceding_delta_y;
%              target_lane_preceding_delta_v; target_lane_preceding_delta_a;
%              target_lane_following_delta_x; target_lane_following_delta_y; 
%              target_lane_following_delta_v; target_lane_following_delta_a;]'; 
% with the length of each entry = time_span_of_sample;

% Need to find two neighbor vehicles of ego at each time step 
% from t = 1 to time_span_of_sample, and extract their data

% Assuming the two neighbor vehicles are the two from the beginning of time
% sequence, i.e. the two neighbor vehicles of ego car at t = t1.

data_dictionary;
time_span_of_sample = time_span_of_sample - 1;

full_ego_history = lane_change_events{event_idx, eve_dic_ego_info_history};

if if_lane_change == false
    start_time = full_ego_history(1, dic_Local_Time);
    start_y_ego = full_ego_history(1, dic_Local_Y);
    ego_intervel_of_interest = 1:time_span_of_sample;
else
    start_time = full_ego_history(size(full_ego_history, 1) - time_span_of_sample, dic_Local_Time);
    start_y_ego = full_ego_history(size(full_ego_history, 1) - time_span_of_sample, dic_Local_Y);
    ego_intervel_of_interest = size(full_ego_history, 1) - time_span_of_sample : size(full_ego_history, 1) - 1;
end

target_lane_id = full_ego_history(end, dic_Lane_ID);


distance_threshold = 400;

ind = find(data_time_period_i(:, dic_Lane_ID) == target_lane_id ...
   & data_time_period_i(:, dic_Local_Time) ==  start_time ...
   & abs(data_time_period_i(:, dic_Local_Y) - start_y_ego) < distance_threshold);

if isempty(ind)
    env_paras = [];
    env_paras_empty_flag = true;

elseif ~isempty(ind) ...
    && ~isempty(find(data_time_period_i(ind, dic_Local_Y) > start_y_ego)) ...
    && ~isempty(find(data_time_period_i(ind, dic_Local_Y) < start_y_ego))


    possible_set = data_time_period_i(ind, :);

    % find neighbors
    possible_preceding_indces = find(possible_set(:, dic_Local_Y) > start_y_ego);

%     [~, closest_preceding_idx] = ... 
    [mini, ~] = ...
        min(possible_set(possible_preceding_indces, dic_Local_Y) - start_y_ego);
    
%     closest_preceding_idx_in_original_data = ind(closest_preceding_idx);
    
    closest_preceding_idx_in_original_data = find(data_time_period_i(:, dic_Local_Y) == mini + start_y_ego);
    preceding_history = ...
        data_time_period_i(closest_preceding_idx_in_original_data:...
                     closest_preceding_idx_in_original_data + time_span_of_sample - 1, :);

    preceding_delta_x = preceding_history(:, dic_Local_X) - ...
                            full_ego_history(ego_intervel_of_interest, dic_Local_X);
    preceding_delta_y = preceding_history(:, dic_Local_Y) - ...
                            full_ego_history(ego_intervel_of_interest, dic_Local_Y);
    preceding_delta_v = preceding_history(:, dic_v_Vel) - ...
                            full_ego_history(ego_intervel_of_interest, dic_v_Vel);
    preceding_delta_a = preceding_history(:, dic_v_Acc) - ...
                            full_ego_history(ego_intervel_of_interest, dic_v_Acc);




    possible_following_indces = find(possible_set(:, dic_Local_Y) < start_y_ego);
%     [~, closest_following_idx] = ... 
    [maxi, ~] = ... 
        max(possible_set(possible_following_indces, dic_Local_Y) - start_y_ego);
    
    closest_following_idx_in_original_data = find(data_time_period_i(:, dic_Local_Y) == maxi + start_y_ego);
    
%     closest_following_idx_in_original_data = ind(closest_following_idx);

    following_history = ...
        data_time_period_i(closest_following_idx_in_original_data:...
                     closest_following_idx_in_original_data + time_span_of_sample - 1, :);

    following_delta_x = following_history(:, dic_Local_X) - ...
                            full_ego_history(ego_intervel_of_interest, dic_Local_X);
    following_delta_y = following_history(:, dic_Local_Y) - ...
                            full_ego_history(ego_intervel_of_interest, dic_Local_Y);
    following_delta_v = following_history(:, dic_v_Vel) - ...
                            full_ego_history(ego_intervel_of_interest, dic_v_Vel);
    following_delta_a = following_history(:, dic_v_Acc) - ...
                            full_ego_history(ego_intervel_of_interest, dic_v_Acc);

% env_paras = [preceding_delta_y; preceding_delta_v; preceding_delta_a; 
%              following_delta_y; following_delta_v; following_delta_a]';
    
    env_paras = [preceding_delta_x; preceding_delta_y; preceding_delta_v; preceding_delta_a; 
                 following_delta_x; following_delta_y; following_delta_v; following_delta_a]';

%     env_paras = [preceding_delta_y; preceding_delta_v; preceding_delta_a; 
%                  following_delta_y; following_delta_v; following_delta_a]';

    env_paras_empty_flag = false;


else
    env_paras = [];
    env_paras_empty_flag = true;
end

end