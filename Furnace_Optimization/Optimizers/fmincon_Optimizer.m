function [T_f_opt, t_opt, J_hist, results] = ...
    fmincon_Optimizer(furnace_model, constraints, initial_guess, N)
    %% Optimize the furnace time-temperature curve with constant/linear/spline interpolation

    % Initial guesses (T_f, alpha, t)
    T_f_init = initial_guess(1:N);
    t_total_init = initial_guess(end);          % Scalar
    alpha_init = (1/N) * ones(1, N);            % Equal time weights initially
    x_init = [T_f_init, alpha_init, t_total_init]; 
    Aeq = [zeros(1, N), ones(1, N), 0];   % Sum of alphas = 1
    beq = 1;
    
    % Define the cost function
    J = @(x) Compute_Cost_Function(x, furnace_model, constraints, N);

    % Get constraints
    nonlinear_constraints = @(x) Get_Constraints(x, furnace_model, constraints, N);

    % Initialize bounds
    [lb, ub] = Get_Bounds(furnace_model, constraints, N);

    % Define optimization settings
    options = Get_Fmincon_Options(furnace_model);

    % Check and compare analytical to numerical gradients
    if furnace_model.settings.compare_cost_gradients
        checkGradients(J, x_init, Display="on") 
    end

    % Solve the optimization problem
    x_opt = fmincon(J, x_init, [], [], Aeq, beq, lb, ub, nonlinear_constraints, options);

    % After fmincon:
    if evalin('base', 'exist(''J_hist_fmincon'', ''var'')')
        J_hist = evalin('base', 'J_hist_fmincon');
    else
        J_hist = [];
    end

    % Extract optimized variables
    T_f_opt = x_opt(1:N); 
    alpha_opt = x_opt(N+1:2*N);
    t_opt = x_opt(end);
    furnace_model = Update_Time(furnace_model, t_opt);   % Updates the process duration and the number of time steps

    % Extract the modelled time-temperature curves
    [results] = Get_Or_Run_Simulation(x_opt, furnace_model);
    results.alpha_opt = alpha_opt;
end