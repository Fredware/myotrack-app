%% Step 1: Verify you are using the right version of MATLAB
version_devel = "R2023b";
version_current = strcat("R", version('-release'));
if (version_current ~= version_devel)
    warning("This code was developed in %s, you are using %s. Proceed with caution", version_devel, version_current)
end
%% Step 2: Ensure you are in the right directory
cd(fileparts(matlab.desktop.editor.getActiveFilename));
%% Step 3: Clear system states from previous sessions
try
    uno.close;
end
clear all;
clc;
%% Step 4: Connect the Arduino
[uno, uno_connected] = connect_board(); 
%% Step 5: Initialize and instance of the app and connect it to the Arduino
fs = 1e3; %[Hz]
tc_app = TCApp;
%tc.appCalibrateButton.Color = 'white';
tc_app.DataLogger = uno;
uno.getEMG
%%
calibration_data = tc_app.CalibrationData(1,:);
mav_thresh = compute_threshold(calibration_data');

calibration_data = tc_app.CalibrationData(1,:);
[mav_thresh, mav_data] = compute_threshold(calibration_data');

[numRows, numCols] = size(mav_data);
%%
calibrationPlot = figure;
plot(calibration_data, 'k:');
hold on
plot(mav_data, 'b', LineWidth=3)
yline(mav_thresh,'Color', 'r', 'LineWidth', 3, 'LineStyle', '-.');
hold off
legend(["","", sprintf("%0.3f", mav_thresh)])

%%
if(tc_app.threshold ~= 0)
    mav_thresh = tc_app.threshold;
end

%mav_Buff = dsp.AsyncBuffer;

tc_init_buff = [0,0,0];
tc_term_buff = [0,0,0];

n_lines = 4;

t_max = 10;
t_min = 0;

avg_max = 10;
avg_min = 0;

tc_init_idx = 1;
tc_term_idx = 1;

if(tc_app.PracticeCheckBox.Value == 1)
    trial_count_limit = 6;
else
    trial_count_limit = 10;
end

tc_init_arr = nan(1,2*trial_count_limit);
tc_term_arr = nan(1,2*trial_count_limit);

min_event_len = 0.5*fs;


line_handles = cell(1, n_lines);


line_handles{1} = animatedline(tc_app.UIAxes_mav, 'Color', 'b', 'LineWidth', 1);
line_handles{2} = animatedline(tc_app.UIAxes_mav, 'Color', 'r', 'LineWidth', 2.5, 'LineStyle', '-');
line_handles{3} = animatedline(tc_app.UIAxes, 'Color', '#23E8DB', 'LineWidth', 3.5);
line_handles{4} = animatedline(tc_app.UIAxes, 'Color', '#FF00BD', 'LineWidth', 3.5);



animated_lines = line_handles;

MONITORING_MAV = 0;
START_DETECTED = 1;
STOP_DETECTED = 2;
state = MONITORING_MAV;

n_chans = 1;
n_feats = 1;

trialCount = 0;

mav_win_len = 300;
event_padding = 3; %units are in samples

data_buff_len = 300*fs;
[data, features, data_idx, features_idx] = initialize_data_structures(data_buff_len, n_feats);
t_features = [];
pause (0.5);
figure_update_limit = 1;%samples
figure_update_counter = 0;

while( tc_app.RecordSession && trialCount < trial_count_limit)
    % SAMPLE ARDUINO
    pause(0.0111111)
    try
        emg = uno.getRecentEMG; % value range: [-2.5:2.5]; length range: [1:buffer length]
        if ~isempty(emg)
            % determine how many EMG samples were received
            [~, new_samples] = size(emg);
            % add new EMG samples to the data buffer
            data( 1, data_idx:data_idx + new_samples - 1) = emg(1,:);
            % update the data buffer index for inserting future data
            data_idx = data_idx + new_samples;
            features_idx = features_idx + 1;
        end
    catch e
        disp("Data Acquisition: FAILED")
        fprintf(1,'The identifier was:\n%s\n',e.identifier);
        fprintf(1,'There was an error! The message was:\n%s\n',e.message);
    end

    % The buffer must not be empty and  must contain enough data to compute features
    if ~isempty(emg) && data_idx > mav_win_len
        % Calculate MAV
        try
            mav_feat = compute_amplitude_feats(data(1, data_idx-mav_win_len: data_idx-1));
            features(:, features_idx) = mav_feat;
        catch e
            disp('Feature Calculation: FAILED')
            fprintf(1,'The identifier was:\n%s\n',e.identifier);
            fprintf(1,'There was an error! The message was:\n%s\n',e.message);
        end

        % Get time in seconds from sample index
        timestamp = (data_idx - 1) / fs;

        t_features(features_idx) = timestamp;

        % UPDATE PLOT
        if figure_update_counter >= figure_update_limit
            if(tc_app.FeedbackButton == tc_app.FeedbackTypeButtonGroup.SelectedObject) %8/3/23
                [t_max, t_min] = update_figure2(animated_lines, timestamp, features, features_idx, t_max, t_min, mav_thresh, tc_app);
                figure_update_counter = 0;
                % else
                %     tc_app.ThresholdMeterGauge.Value = 0;
                %     tc_app.ThresholdMeterGauge.BackgroundColor = 'white';
                %     line_handles{3} = animatedline(tc_app.UIAxes, 'Color', 'white', 'LineWidth', 3.5);
                %     line_handles{4} = animatedline(tc_app.UIAxes, 'Color', 'white', 'LineWidth', 3.5);
                %     tc_app.TextArea.FontColor = "w";
                %                     tc_app.TextArea.Value = sprintf("Time constant init is:\n\n\t%.3f " + ...
                %                     "\n\nLast Three Trials Time Constant init is:\n\n\t %.3f ", tc_init, tcInit_mean);
                %
            end
        else
            figure_update_counter = figure_update_counter +1;
        end


        %detecting event and displaying time constant

        if state == MONITORING_MAV
            if mav_feat > mav_thresh
                state = START_DETECTED;
                event_start = data_idx-mav_win_len;
                %tc_app.ThresholdReachedLamp.Color = 'green';
                if(tc_app.FeedbackButton == tc_app.FeedbackTypeButtonGroup.SelectedObject)
                    tc_app.ThresholdMeterGauge.Value = 100;
                    tc_app.ThresholdMeterGauge.BackgroundColor = 'green';
                end
            end

        elseif state == START_DETECTED
            if mav_feat < mav_thresh
                state = STOP_DETECTED;
                event_stop = data_idx+1;
                t_stop = timestamp;
                if(tc_app.FeedbackButton == tc_app.FeedbackTypeButtonGroup.SelectedObject)
                    tc_app.ThresholdMeterGauge.Value = 0;
                    tc_app.ThresholdMeterGauge.BackgroundColor = 'white';
                end

            end

        elseif state == STOP_DETECTED
            if (timestamp - t_stop) > event_padding/fs
                state = MONITORING_MAV;
                event_data = data(event_start-event_padding:event_stop);
                if(length(event_data) > min_event_len)
                    event_mav = compute_running_mav(event_data, mav_win_len);

                    x = linspace(0, length(event_mav)/fs, length(event_mav));

                    [tc_init, tc_term]= tc_comp(x, event_mav, mav_thresh);

                    tc_init_arr(tc_init_idx) = tc_init;
                    tc_init_idx = tc_init_idx + 1;

                    tc_term_arr(tc_term_idx) = tc_term;
                    tc_term_idx = tc_term_idx + 1;

                    if(isnan(tc_term))
                        trial_count_limit = trial_count_limit + 1; %try to find a way to stop trialCount instead of increasing trial count limit 8/22/23
                    end

                    [tcTerm_mean, tc_term_buff] = calculate_avg(tc_term_buff, tc_term);

                    if(tc_app.FeedbackButton == tc_app.FeedbackTypeButtonGroup.SelectedObject)
                        avg_max = plot_avg(tc_app, animated_lines, avg_max, avg_min, tc_term, trialCount);
                    end

                    tc_app.ThresholdMeterGauge.Value = 0;
                    tc_app.ThresholdMeterGauge.BackgroundColor = 'white';
                    tc_app.TextArea.FontColor = "b";
                    tc_app.TextArea.Value = sprintf("Trial Count: %d", trialCount);

                    if(tcTerm_mean >= tc_term)
                        if(tc_app.FeedbackButton == tc_app.FeedbackTypeButtonGroup.SelectedObject)
                            tc_app.TextArea.FontColor = "g";
                            tc_app.TextArea.Value = sprintf("Time constant term is:\n\n\t %.3f" + ...
                                " \n\nLast Three Trials Time Constant term is:\n\n\t %.3f \n\nTrial Count: %d" , tc_term, tcTerm_mean, trialCount);
                            avg_max = plot_avg(tc_app, animated_lines, avg_max, avg_min, tc_term, trialCount);
                        end
                    else
                        if(tc_app.FeedbackButton == tc_app.FeedbackTypeButtonGroup.SelectedObject)
                            tc_app.TextArea.FontColor = "r";
                            tc_app.TextArea.Value = sprintf("Time constant term is:\n\n\t %.3f" + ...
                                " \n\nLast Three Trials Time Constant term is:\n\n\t %.3f \n\nTrial Count: %d", tc_term, tcTerm_mean, trialCount);
                            avg_max = plot_avg(tc_app, animated_lines, avg_max, avg_min, tc_term, trialCount);
                        end
                    end

                    trialCount = trialCount + 1;
                end

            end
        end
        prev_timestamp = timestamp;
        prev_sample = data_idx;
    end
end

fileFeedbackType = tc_app.FeedbackType;
filePatientCondition = tc_app.PatientCondition;

sessionEnd = msgbox("Session Ending!","App Closing","error");
pause(2);
%disp('Session Ending!');,


file_str = regexprep(string(datetime), ':', '');
file_str = regexprep(string(file_str), '-', '');
file_str = regexprep(string(file_str), ' ', '-');

if(tc_app.PracticeCheckBox.Value == 1)
    experiment_task = 'Practice';

elseif(tc_app.FeedbackButton == tc_app.FeedbackTypeButtonGroup.SelectedObject)
        if(tc_app.PareticButton == tc_app.PatientConditionButtonGroup.SelectedObject)
            experiment_task = 'Feedback_Paretic';
        else
            experiment_task = 'Feedback_NonParetic';
        end
else
    if(tc_app.NoFeedbackButton == tc_app.FeedbackTypeButtonGroup.SelectedObject)
        if(tc_app.PareticButton == tc_app.PatientConditionButtonGroup.SelectedObject)
            experiment_task = 'NoFeedback_Paretic';
        else
            experiment_task = 'NoFeedback_NonParetic';
        end
    end
end
%% 

filename = sprintf("%s %s.mat",file_str, experiment_task);
figname = sprintf("%s.fig", file_str);

save(filename, ...
    "tc_term_arr", "fileFeedbackType", "filePatientCondition", "data", "calibrationPlot", "calibration_data", "mav_thresh");
delete(tc_app);
savefig(calibrationPlot, figname);




