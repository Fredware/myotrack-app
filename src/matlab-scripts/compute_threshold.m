function [mav_thresh, mav_data] = compute_threshold(emg_data) 
    %one variable, access first row or second row
    %vectors and matrices
    % conversion of EMG Data to mean absolute value
   

    % dataMax = max(movmean(abs(data), 30, 1)); %use standard deviation instead of max
    mav_data = movmean(abs(emg_data),300,1);
    mav_max = max(mav_data);

% Rest of Data is for instantaneous MVCs after the 5 second baseline period
% Spike Detection and Framing:
    % Set a threshold for spike detection at the average MAV during the
    % baseline period + 4 times the standard deviation

    mav_thresh = 0.25*mav_max;

    % mav_thresh = 5*std(mav_data);
    %mav_thresh = 0.05;
end


