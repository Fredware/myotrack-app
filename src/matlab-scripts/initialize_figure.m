function [fig_handle, line_handles, t_max, t_min] = initialize_figure(n_chans, n_feats, my_app)
    % PLOTSETUP1CH  sets up plots to visualize EMG input and the control
    % value calculated later in EMG_live. 
    % 
    % This function sets up one graph for a single channel EMG input, 
    % and one for the control graph. (two graphs total)
    %
    % figHandle is the Figure handle for the graphs generated. 
    %
    % lineHandles are the handles for the animated lines that are used to
    % update the graphs in updatePlot1ch.m. It makes it so the graphs can 
    % be shown in real time
    % 
    % Tmax is the initial max xlimit of the graph in seconds
    % 
    % Tmin is the initial min xlimit of the graph in seconds
    % 
    % Tmax and Tmin are dynamically updated in updatePlot1ch.m
    
    n_plots = n_chans + n_feats;
    t_max = 5;
    t_min = 0;

    y_labels = cell( 1, n_plots);
    axes_handles = cell( 1, n_plots);
    line_handles = cell( 1, n_plots+1);

    feature_labels = ["MAV" "RMS" "Motor Cue" "Mean Frequency" "Median Frequency"];
    
    for i = 1:n_chans
        y_labels{i} = strcat('CH ', num2str(i), ' Amplitude [V]');
    end
    
    for i = 1:n_feats
        y_labels{n_chans + i} = feature_labels(i);
    end
    
    fig_handle = figure('units', 'normalized'); %open figure
    set( fig_handle, 'outerposition', [0, 0, 0.5, 1])%moveFigure to left half of screen
    
%     for i = 1:n_plots
%         axes_handles{i} = subplot(n_plots, 1, i);
%         line_handles{i} = animatedline;
%         if i == n_plots
%             line_handles{i+1} = animatedline;
%             end
%         xlim([0 t_max])
%         ylabel(y_labels{i})
%         xticks([]); 
%     end
    line_handles{1} = animatedline(my_app.UIAxes_3);
    line_handles{2} = animatedline(my_app.UIAxes_2);
    line_handles{3} = animatedline(my_app.UIAxes);
    % add MAV threshold line
%     linkaxes([axes_handles{:}],'x')
%     xlabel('Time [s]')

%     ylim(axes_handles{1}, [-2.5 2.5])
%     ylim(axes_handles{2}, [-0.1 2.0])
end