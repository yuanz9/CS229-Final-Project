function [data_i, lane_change_events] = data_process...
    (data_time_period_i, data_set_alias, feature_interval, time_span_of_sample)
%% column dicitonary
data_dictionary;

% data_dictionary:
%
%       1         2          3            4          5        6        7
% Vehicle_ID, Frame_ID, Total_Frames, Local_Time, Local_X, Local_Y, Global_X,
%
%      8        9        10      11       12     13     14        15
% Global_Y, v_length, v_Width, v_Class, v_Vel, v_Acc, Lane_ID, Preceding,
%
%      16         17            18
% Following, Space_Headway, Time_Headway

% environment parameters dictionary:
%  1        2        3        4
% [delta_x, delta_y, delta_v, delta_a]
% env_dic_delta_x = 1; env_dic_delta_y = 2;
% env_dic_delta_v = 3; env_dic_delta_a = 4;

% lane_change_event dictionary:
% eve_dic_ego_info_history = 1; eve_dic_preceding_v_id = 2;
% eve_dic_preceding_env_para = 3; eve_dic_target_lane_preceding_v_id = 4;
% eve_dic_target_lane_preceding_env_para = 5; eve_dic_target_lane_following_v_id = 6;
% eve_dic_target_lane_following_env_para = 7;

%% lane change samples:

vehicle_ids = unique(data_time_period_i(:, dic_Vehicle_ID));

% find vehicles that changed lanes
% i.e. unique lane_id of those vehicles > 1
lane_change_events = {};
valid_num_lane_change_events = 0;

for i = 1:length(vehicle_ids)
    
    v_id = vehicle_ids(i);
    data_idces = find(data_time_period_i(:, dic_Vehicle_ID) == v_id);
    lane_history = data_time_period_i(data_idces, dic_Lane_ID);
    
    % assuming vehicles do not switch back to original lane
    times_of_lane_changes = length(unique(lane_history)) - 1;
    
    if times_of_lane_changes > 0
        
        complete_info_history = data_time_period_i(data_idces, :);
        
        original_lane_id = lane_history(1);
        
        target_lane_idx = find(lane_history ~= original_lane_id);
        
        % ASSUMPTION:
        % only look at first lane change event of each vehicle
        target_lane_idx = target_lane_idx(1);
        
        interval_start_idx = target_lane_idx - feature_interval;
        feature_sample_idces = interval_start_idx : target_lane_idx;
        
        % ensure that the feature interval is feasible;
        % no 0 indexed preceding vehicle;
        % no 0 indexed following vehicle in target lane;
        % singular preceding vehicle in feature interval;
        if interval_start_idx >= 1 ...
                && isempty(find(...
                complete_info_history(feature_sample_idces, dic_Preceding) == 0)) ...
                && length(unique(...
                complete_info_history(feature_sample_idces, dic_Preceding))) == 2 ...
                && isempty(find(...
                complete_info_history(target_lane_idx, dic_Following) == 0)) ...
                && max(complete_info_history(feature_sample_idces, dic_Preceding)) ...
                <= max(vehicle_ids)...
                && max(complete_info_history(feature_sample_idces, dic_Following)) ...
                <= max(vehicle_ids)
            
            ego_info_history = complete_info_history(feature_sample_idces, :);
            lane_change_events{valid_num_lane_change_events + 1, 1} = ego_info_history;
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % find surrounding environment:
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            local_time_seq_of_ego_v = ego_info_history(:, dic_Local_Time);
            
            % put environment parameters into lane_change_events
            % environment parameters structure:
            %  1        2        3        4
            % [delta_x, delta_y, delta_v, delta_a]
            
            % find preceding -> lane_change_events{:, 2}
            preceding_v_id = ego_info_history(1, dic_Preceding);
            lane_change_events{valid_num_lane_change_events + 1, 2} = preceding_v_id;
            
            % find the environment parameters wrt preceding vehicle
            %   -> lane_change_events{:, 3}
            preceding_info_history_start_idx = ...
                find(data_time_period_i(:, dic_Vehicle_ID) == preceding_v_id ...
                & data_time_period_i(:, dic_Local_Time) == local_time_seq_of_ego_v(1));
            preceding_info_history = ...
                data_time_period_i(preceding_info_history_start_idx: ...
                preceding_info_history_start_idx + feature_interval, :);
            
            if ~isempty(preceding_info_history)
                delta_x = preceding_info_history(:, dic_Local_X) -...
                    ego_info_history(:, dic_Local_X);
                delta_y = preceding_info_history(:, dic_Local_Y) -...
                    ego_info_history(:, dic_Local_Y);
                delta_v = preceding_info_history(:, dic_v_Vel) -...
                    ego_info_history(:, dic_v_Vel);
                delta_a = preceding_info_history(:, dic_v_Acc) -...
                    ego_info_history(:, dic_v_Acc);
                
                lane_change_events{valid_num_lane_change_events + 1, 3} = ...
                    [delta_x delta_y delta_v delta_a];
                
                lane_change_events_increment_flag_1 = true;
            else
                lane_change_events_increment_flag_1 = false;
            end
            
            
            % find target-lane-preceding_v_id -> lane_change_events{:, 4}
            target_lane_preceding_v_id = ego_info_history(end, dic_Preceding);
            lane_change_events{valid_num_lane_change_events + 1, 4} = ...
                target_lane_preceding_v_id;
            
            % find the environment parameters wrt target-lane-preceding vehicle
            %   -> lane_change_events{:, 5}
            target_lane_preceding_info_history_start_idx = ...
                find(data_time_period_i(:, dic_Vehicle_ID) == target_lane_preceding_v_id ...
                & data_time_period_i(:, dic_Local_Time) == local_time_seq_of_ego_v(1));
            target_lane_preceding_info_history = ...
                data_time_period_i(target_lane_preceding_info_history_start_idx: ...
                target_lane_preceding_info_history_start_idx + feature_interval, :);
            
            if ~isempty(target_lane_preceding_info_history)
                delta_x = target_lane_preceding_info_history(:, dic_Local_X) -...
                    ego_info_history(:, dic_Local_X);
                delta_y = target_lane_preceding_info_history(:, dic_Local_Y) -...
                    ego_info_history(:, dic_Local_Y);
                delta_v = target_lane_preceding_info_history(:, dic_v_Vel) -...
                    ego_info_history(:, dic_v_Vel);
                delta_a = target_lane_preceding_info_history(:, dic_v_Acc) -...
                    ego_info_history(:, dic_v_Acc);
                
                lane_change_events{valid_num_lane_change_events + 1, 5} = ...
                    [delta_x delta_y delta_v delta_a];
                lane_change_events_increment_flag_2 = true;
            else
                lane_change_events_increment_flag_2 = false;
            end
            
            % find target-lane-following_v_id -> lane_change_events{:, 6}
            target_lane_following_v_id = ego_info_history(end, dic_Following);
            lane_change_events{valid_num_lane_change_events + 1, 6} = ...
                target_lane_following_v_id;
            
            % find the environment parameters wrt target-lane-preceding vehicle
            %   -> lane_change_events{:, 7}
            target_lane_following_info_history_start_idx = ...
                find(data_time_period_i(:, dic_Vehicle_ID) == target_lane_following_v_id ...
                & data_time_period_i(:, dic_Local_Time) == local_time_seq_of_ego_v(1));
            
            target_lane_following_info_history = ...
                data_time_period_i(target_lane_following_info_history_start_idx: ...
                target_lane_following_info_history_start_idx + feature_interval, :);
            
            
            if ~isempty(target_lane_following_info_history)
                delta_x = target_lane_following_info_history(:, dic_Local_X) -...
                    ego_info_history(:, dic_Local_X);
                delta_y = target_lane_following_info_history(:, dic_Local_Y) -...
                    ego_info_history(:, dic_Local_Y);
                delta_v = target_lane_following_info_history(:, dic_v_Vel) -...
                    ego_info_history(:, dic_v_Vel);
                delta_a = target_lane_following_info_history(:, dic_v_Acc) -...
                    ego_info_history(:, dic_v_Acc);
                
                lane_change_events{valid_num_lane_change_events + 1, 7} = ...
                    [delta_x delta_y delta_v delta_a];
                lane_change_events_increment_flag_3 = true;
            else
                lane_change_events_increment_flag_3 = false;
            end
            
            
            % finally:
            if lane_change_events_increment_flag_1 == true ...
                    && lane_change_events_increment_flag_2 == true ...
                    && lane_change_events_increment_flag_3 == true
                valid_num_lane_change_events = valid_num_lane_change_events + 1;
            end
            
        end % if target_lane_idx - feature_interval >= 1
        
    end % if times_of_lane_changes > 0
    
end % for i = 1:length(vehicle_ids)

%% construct x-vectors and y-labels
% iterate through lane_change_events cell
data_i = [];
data_row_num = 1;

for i = 1:valid_num_lane_change_events
    
    % lane keep
    if_lane_change = false;
    data_i(data_row_num, 1) = - 1; % y
    X = [lane_change_events{i, eve_dic_ego_info_history}(1:time_span_of_sample-1, dic_v_Vel); ...
         lane_change_events{i, eve_dic_ego_info_history}(1:time_span_of_sample-1, dic_v_Acc); ...
         lane_change_events{i, eve_dic_preceding_env_para}(1:time_span_of_sample-1, env_dic_delta_x); ...
         lane_change_events{i, eve_dic_preceding_env_para}(1:time_span_of_sample-1, env_dic_delta_y); ...
         lane_change_events{i, eve_dic_preceding_env_para}(1:time_span_of_sample-1, env_dic_delta_v); ...
         lane_change_events{i, eve_dic_preceding_env_para}(1:time_span_of_sample-1, env_dic_delta_a)]';
%          lane_change_events{i, eve_dic_preceding_env_para}(1:time_span_of_sample-1, env_dic_delta_x); ...
%              lane_change_events{i, eve_dic_target_lane_preceding_env_para}(1:time_span_of_sample-1, env_dic_delta_x); ...
%              lane_change_events{i, eve_dic_target_lane_preceding_env_para}(1:time_span_of_sample-1, env_dic_delta_y); ...
%              lane_change_events{i, eve_dic_target_lane_preceding_env_para}(1:time_span_of_sample-1, env_dic_delta_v); ...
%              lane_change_events{i, eve_dic_target_lane_preceding_env_para}(1:time_span_of_sample-1, env_dic_delta_a); ...
%              lane_change_events{i, eve_dic_target_lane_following_env_para}(1:time_span_of_sample-1, env_dic_delta_x); ...
%              lane_change_events{i, eve_dic_target_lane_following_env_para}(1:time_span_of_sample-1, env_dic_delta_y); ...
%              lane_change_events{i, eve_dic_target_lane_following_env_para}(1:time_span_of_sample-1, env_dic_delta_v); ...
%              lane_change_events{i, eve_dic_target_lane_following_env_para}(1:time_span_of_sample-1, env_dic_delta_a)]';
    
    
    [env_paras, env_paras_empty_flag] = get_neighbor_vehicle_env_paras...
        (data_time_period_i, data_set_alias, lane_change_events, i, time_span_of_sample, if_lane_change);
    
    
    if env_paras_empty_flag
        % goto next loop
        continue;
    else
        % add env_paras to data_i
        data_i(data_row_num, 2 : 1+length(X)) = X;
        data_i(data_row_num, 2+length(X) : 1+length(X)+length(env_paras)) = env_paras;
        
        % discard congestion
        if length(find(data_i(data_row_num, :) == 0)) > 6
            data_i(data_row_num, :) = [];
            continue;
        else
            data_row_num = data_row_num + 1;
        end
    end
    
    
    % lane change
    data_i(data_row_num, 1) = 1; % y
    if_lane_change = true;
    X = [lane_change_events{i, eve_dic_ego_info_history}(end - time_span_of_sample + 1:end-1, dic_v_Vel); ...
         lane_change_events{i, eve_dic_ego_info_history}(end - time_span_of_sample + 1:end-1, dic_v_Acc); ...
         lane_change_events{i, eve_dic_preceding_env_para}(end - time_span_of_sample + 1:end-1, env_dic_delta_x); ...
         lane_change_events{i, eve_dic_preceding_env_para}(end - time_span_of_sample + 1:end-1, env_dic_delta_y); ...
         lane_change_events{i, eve_dic_preceding_env_para}(end - time_span_of_sample + 1:end-1, env_dic_delta_v); ...
         lane_change_events{i, eve_dic_preceding_env_para}(end - time_span_of_sample + 1:end-1, env_dic_delta_a)]';
%          lane_change_events{i, eve_dic_preceding_env_para}(end - time_span_of_sample + 1:end-1, env_dic_delta_x); ...
%              lane_change_events{i, eve_dic_target_lane_preceding_env_para}(end - time_span_of_sample + 1:end-1, env_dic_delta_x); ...
%              lane_change_events{i, eve_dic_target_lane_preceding_env_para}(end - time_span_of_sample + 1:end-1, env_dic_delta_y); ...
%              lane_change_events{i, eve_dic_target_lane_preceding_env_para}(end - time_span_of_sample + 1:end-1, env_dic_delta_v); ...
%              lane_change_events{i, eve_dic_target_lane_preceding_env_para}(end - time_span_of_sample + 1:end-1, env_dic_delta_a); ...
%              lane_change_events{i, eve_dic_target_lane_following_env_para}(end - time_span_of_sample + 1:end-1, env_dic_delta_x); ...
%              lane_change_events{i, eve_dic_target_lane_following_env_para}(end - time_span_of_sample + 1:end-1, env_dic_delta_y); ...
%              lane_change_events{i, eve_dic_target_lane_following_env_para}(end - time_span_of_sample + 1:end-1, env_dic_delta_v); ...
%              lane_change_events{i, eve_dic_target_lane_following_env_para}(end - time_span_of_sample + 1:end-1, env_dic_delta_a)]';
    %      data_i(data_row_num, 2:1+length(X)) = X;
    %      data_row_num = data_row_num + 1;
    
    [env_paras, env_paras_empty_flag] = get_neighbor_vehicle_env_paras...
        (data_time_period_i, data_set_alias, lane_change_events, i, time_span_of_sample, if_lane_change);
    
    
    if env_paras_empty_flag
        % goto next loop
        continue;
    else
        % add env_paras to data_i
        data_i(data_row_num, 2 : 1+length(X)) = X;
        data_i(data_row_num, 2+length(X) : 1+length(X)+length(env_paras)) = env_paras;
        
        % discard congestion
        if length(find(data_i(data_row_num, :) == 0)) > 6
            data_i(data_row_num, :) = [];
            continue;
        else
            data_row_num = data_row_num + 1;
        end
    end
    
    
    
end

invalid_data = find(data_i(:, 1) == 0);
data_i(invalid_data, :) = [];

end



