function [avg_max] = plot_avg(tc_app, animatedLines, avg_max, avg_min, tc_condition, trialCount)
       
   
            addpoints(animatedLines{3}, trialCount, tc_condition)
    
           % addpoints(animatedLines{4}, trialCount, tc_condition)
    
    
       
      if trialCount > avg_max
        avg_max = trialCount;
        tc_app.UIAxes.XLim = [avg_min avg_max];
      end
    drawnow limitrate %update the plot, but limit update rate to 20 fps 
end





     % input = timeConst.DataLogger;
     % write(mav_Buff, input);
     % dataToAvg = read(mavBuff);
     % trialAvg = mean(dataToAvg);








% classdef queue < handle
%     properties (Access = private)
%         elements
%         insert
%         remove
%     end
% 
%     properties (Dependent = true)
%         NumElements
%     end
% 
%     methods
%         function obj = queue
%             obj.elements = tc_app.UIAxes_mav(:,3); 
%             obj.insert = 1;
%             obj.remove = 1;
%         end
% 
%         function enqueue(obj, elements)
%             if obj.insert == length(obj.elements)
%                 obj.elements = [obj.elements, cell( 1, length(obj.elements))];
%             end
%             obj.elements{obj.insert} = elements;
%             obj.insert = obj.insert + 1;
%         end
% 
%         function check = isEmpty(obj)
%             check = (obj.remove >= obj.enqueue);
%         end
% 
%         % function num = get.NumElements(obj)
%         %     num = obj.enqueue - obj.remove;
%         % end
% 
%         function average = avg(queue, average)
%             if get.NumElements(obj) == 3
%                 average = mean(queue, 3);
%             end
%         end
%     end
% end
