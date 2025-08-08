function [lb, ub] = Get_Bounds(fm, constraints, N)
    %% Defines bounds (dynamically updated) for temperature and time

    % Temperature bounds for each step
    lb_T_f = repmat(constraints.T_f_min, 1, N);  % Lower bound for T_f
    ub_T_f = repmat(constraints.T_f_max, 1, N);  % Upper bound for T_f
    
    % Time bounds for each step
    lb_t = repmat(constraints.t_min, 1, N);  % Lower bound for time
    ub_t = repmat(constraints.t_max, 1, N);  % Upper bound for time
    
    % Combine bounds
    lb = [lb_T_f, lb_t];
    ub = [ub_T_f, ub_t];

    if fm.settings.desired_temperature_curve
        lb_t = constraints.t_min;
        ub_t = constraints.t_max;
        lb_alpha = zeros(1, N);
        ub_alpha = ones(1, N);
        lb = [lb_T_f, lb_alpha, lb_t];
        ub = [ub_T_f, ub_alpha, ub_t];
    end
end