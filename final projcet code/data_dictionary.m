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

dic_Vehicle_ID = 1; dic_Frame_ID = 2; dic_Total_Frames = 3; dic_Local_Time = 4; 
dic_Local_X = 5; dic_Local_Y = 6; dic_Global_X = 7; dic_Global_Y = 8; 
dic_v_length = 9; dic_v_Width = 10; dic_v_Class = 11; dic_v_Vel = 12; 
dic_v_Acc = 13; dic_Lane_ID = 14; dic_Preceding = 15; dic_Following = 16;
dic_Space_Headway = 17; dic_Time_Headway = 18;


% environment parameters dictionary:
%  1        2        3        4
% [delta_x, delta_y, delta_v, delta_a]
env_dic_delta_x = 1; env_dic_delta_y = 2;
env_dic_delta_v = 3; env_dic_delta_a = 4;

% lane_change_event dictionary:
eve_dic_ego_info_history = 1; eve_dic_preceding_v_id = 2; 
eve_dic_preceding_env_para = 3; eve_dic_target_lane_preceding_v_id = 4; 
eve_dic_target_lane_preceding_env_para = 5; eve_dic_target_lane_following_v_id = 6; 
eve_dic_target_lane_following_env_para = 7;


