function [tcTerm_mean, tc_term_buff] = calculate_avg(tc_term_buff, tc_term)

    %tc_init_buff = circshift(tc_init_buff, 1);
    tc_term_buff = circshift(tc_term_buff, 1);

    %tc_init_buff(1) = tc_init;
    tc_term_buff(1) = tc_term;

    %tcInit_mean = mean(tc_init_buff);
    tcTerm_mean = mean(tc_term_buff);


end

