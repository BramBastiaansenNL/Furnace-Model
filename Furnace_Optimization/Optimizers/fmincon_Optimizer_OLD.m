function [T_f_opt, t_opt, J_hist, results] = ...
    fmincon_Optimizer_OLD(furnace_model, constraints, initial_guess, N)
    % Optimize the furnace time-temperature curve with either 1-step or N-step profile

    % Initial guesses (T_f, t)
    x_init = initial_guess;                     % Combined optimization variable
    
    % Define the cost function
    J = @(x) Compute_Cost_Function(x, furnace_model, constraints, N);

    % Get constraints
    nonlinear_constraints = @(x) Get_Constraints(x, furnace_model, constraints, N);

    % Initialize bounds
    [lb, ub] = Get_Bounds(furnace_model, constraints, N);

    % Define optimization settings
    options = Get_Fmincon_Options(furnace_model);

    % Solve the optimization problem
    x_opt = fmincon(J, x_init, [], [], [], [], lb, ub, nonlinear_constraints, options);

    % After fmincon:
    if evalin('base', 'exist(''J_hist_fmincon'', ''var'')')
        J_hist = evalin('base', 'J_hist_fmincon');
    else
        J_hist = [];
    end

    % Extract optimized variables
    T_f_opt = x_opt(1:N);     % Optimized stepwise furnace temperatures
    t_opt = x_opt(N+1:end);   % Optimized time intervals
    furnace_model = Update_Time(furnace_model, sum(t_opt));   % Updates the process duration and the number of time steps

    % Extract the modelled time-temperature curves
    [results] = Get_Or_Run_Simulation(x_opt, furnace_model);
end