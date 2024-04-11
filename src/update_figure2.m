function [t_max, t_min] = update_figure2(animatedLines, timestamp, features, feature_idx, t_max, t_min, mav_thresh, tc_app)

   
        %flex plot
        addpoints(animatedLines{1}, timestamp, features(1, feature_idx))
        %threshold 1
        addpoints(animatedLines{2}, timestamp, mav_thresh);
      
    if timestamp > t_max
        t_max = t_max + 10;
        t_min = t_min + 10;
        tc_app.UIAxes_mav.XLim = [t_min t_max];
    end
    drawnow limitrate %update the plot, but limit update rate to 20 fps
end



