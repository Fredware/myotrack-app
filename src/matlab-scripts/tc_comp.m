function [tc_init, tc_term] = tc_comp(mav_time,mav,mav_thresh)


%exit flags
exit_success = 1;


 % Peak

 try      
 % Find Value and Index at Peak in Window
        [MAVpeak,IdxPeak] = max(mav);

        % Find Time at Peak in Window
        TimePeak = mav_time(IdxPeak); %7.10.23 should be called mav_time

   % Baseline Crossing Point at Start of MVC

        % Find where MAV is above baseline (Prior to Peak)
        AboveBaselineLog =  mav(1:IdxPeak) > mav_thresh;


        % Detect where MAV crosses the baseline
        BaselineX = ischange(double(AboveBaselineLog));

        % Find Indices after MAV last crosses Baseline before Peak

        %Last Index

        %%
        IdxBaselineX = find(BaselineX,1,"last");

        % If statement added by DL 7.6.23
            if isempty(IdxBaselineX)
                exit_success = 0; 
            else
            end

            
            
        % Before and After Cross Indices
        Idxs2BaselineX = [IdxBaselineX - 1, IdxBaselineX];

        %Find MAVs at Baseline Crossing Idxs
        MAVsBaselineX = mav(Idxs2BaselineX);

        %Find Time at Baseline Crossing Idxs
        TimesBaselineX = mav_time(Idxs2BaselineX);

    % Initiation and Termination points: 1 - 1/e and 1e of difference

    % between peak and Baseline

        % Find difference between Peak MAV and Baseline MAV
        peakDiff = MAVpeak - mav_thresh;

        % Find MAVs at Time Constant points (1 - 1/e) (Initiation) and (1/e) (Termination) of difference

        % between Peak and Baseline MAVs
        MAVInit = peakDiff*(1 - (1/exp(1))) + mav_thresh; %7.10.23 really just initiation threshold
        MAVTerm = peakDiff*(1/exp(1)) + mav_thresh;

        % Find MAVs above Initiation MAV points and Below Termination MAV points
        AboveMAVInitLog = mav > MAVInit; 
        AboveMAVTermLog = mav < MAVTerm;

        % Detect where MAV crosses Initiation and Termination MAVs
        MAVInitX = ischange(double(AboveMAVInitLog));
        MAVTermX = ischange(double(AboveMAVTermLog));

        %Find Indices of the points after these crosses.
        IdxMAVInitX = find(MAVInitX,1,"first");

        
        % If statement added by DL 7.6.23
            if length(IdxMAVInitX) ~= 1
                exit_success = 0;
            else
            end

        % If statement added by DL 7.6.23
        
        IdxMAVTermX = find(MAVTermX,1,"last");
            if length(IdxMAVTermX) ~= 1
               exit_success = 0;
            else
            end

        % Find indices  before and after first time crossing Initation MAV
        
       try
        Idxs2InitX = [IdxMAVInitX(1) - 1, IdxMAVInitX(1)];
       catch e
        fprintf(1,'The identifier was:\n%s',e.identifier);
        fprintf(1,'There was an error! The message was:\n%s',e.message);
       end

        %Find indices before and after the last time crossing the Termination MAV
        Idxs2TermX = [IdxMAVTermX(end) - 1, IdxMAVTermX(end)];

        % Find MAVs before and after first time crossing Initiation MAV
        MAVsInitX = mav(Idxs2InitX);

        % Find MAVs before and after the last time crossing Termination MAV
        MAVsTermX = mav(Idxs2TermX);

        % Find Times before and after first time crossing Initiation MAV
        TimesInitX = mav_time(Idxs2InitX);

        % Find Times before and after the last time crossing Termination MAV
        TimesTermX = mav_time(Idxs2TermX);

    % Interpolation, Interpolate Times where crossings happened from the points

    % around them, 

        % Baseline: 

        % MAVsBaselineXDiff = MAVsBaselineX(2) - MAVsBaselineX(1);

        % TimesBaselineXDiff = TimesBaselineX(2) - TimesBaselineX(1);

        % x = mav_thresh - MAVsBaselineX(1);

        % BaselineTime = (x./MAVsBaselineXDiff).*TimesBaselineXDiff + TimesBaselineX(1);
        BaselineTime = interp1(MAVsBaselineX,TimesBaselineX,mav_thresh);

        % Initiation: 

        % MAVsInitXDiff = MAVsInitX(2) - MAVsInitX(1);

        % TimesInitXDiff = TimesInitX(2) - TimesInitX(1);

        % x = MAVInit - MAVsInitX(1);

        % InitTime = (x./MAVsInitXDiff).*TimesInitXDiff + TimesInitX(1);
        InitTime =  interp1(MAVsInitX,TimesInitX,MAVInit);

        % Termination: 

        % MAVsTermXDiff = MAVsTermX(1) - MAVsTermX(2);

        % TimesTermXDiff = TimesTermX(2) - TimesTermX(1);

        % x = MAVsTermX(1) - MAVTerm;

        % TermTime = (x./MAVsTermXDiff).*TimesTermXDiff + TimesTermX(1);
        TermTime =  interp1(MAVsTermX,TimesTermX,MAVTerm);

    % Time Constant Calculation
    tc_init = InitTime - BaselineTime;
    tc_term = TermTime - TimePeak ;        
    
    catch 
        tc_term = NaN;
        tc_init = NaN;
        exit_success = 0;
        if(exit_success == 0)
            warning("TC Failed");
        end
 end
end
