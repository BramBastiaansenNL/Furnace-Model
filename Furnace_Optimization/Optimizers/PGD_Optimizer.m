function [T_f_opt, t_opt, J_hist, results] = PGD_Optimizer(furnace_model, constraints, initial_guess, N)
    %% Projected Gradient Descent optimizer

    % Initialization
    T_f_init = initial_guess(1:N);
    t_total_init = initial_guess(end);          % Scalar
    alpha_init = (1/N) * ones(1, N);            % Equal time weights initially
    x = [T_f_init, alpha_init, t_total_init]; 

    max_iters = 100;
    tol = 1e-4;
    J_hist = zeros(max_iters, 1);

    % Get bounds
    [lb, ub] = Get_Bounds(furnace_model, constraints, N);
    
    % ----------------------------- Debugging ----------------------------%
    if furnace_model.settings.debugging_optimizer
        fprintf('=== Starting Projected Gradient Descent ===\n');
    end
    % ----------------------------- Debugging ----------------------------%
  
    for k = 1:max_iters

        % Parameters for line search
        step_size = 1.0;
        beta = 0.5;       % shrink factor
        c = 1e-4;         % sufficient decrease factor
        
        [J_current, gradJ] = Compute_Cost_Function(x, furnace_model, constraints, N);
        % Let's test if these are the same here
        g = Approximate_Gradient(@(x_) Compute_Cost_Function(x_, furnace_model, constraints), x);
        d = -gradJ;           % descent direction
        
        % Backtracking line search
        while true
            x_trial = max(min(x + step_size * d, ub), lb);  % projected trial step
            % Project alpha onto the unit simplex
            alpha_trial = x_trial(N+1:2*N);
            alpha_projected = projsplx(alpha_trial);
            x_trial(N+1:2*N) = alpha_projected;

            J_trial = Compute_Cost_Function(x_trial, furnace_model, constraints);
            if J_trial <= J_current + c * step_size * (g' * d)
                break;  % sufficient decrease achieved
            end
            step_size = beta * step_size;  % shrink step
            if step_size < 1e-6
                break;  % avoid getting stuck
            end
        end
        
        x = x_trial;
        J = J_trial;

        % Optional: evaluate constraint violation for debugging
        [c, ~] = Get_Constraints(x, furnace_model, constraints, N);
        max_violation = max(c);

        % Logging current state
        Temp = x(1:N);
        Time = x(N+1:end);

        % ----------------------------- Debugging ---------------------------- %
        if furnace_model.settings.debugging_optimizer
            fprintf('Iter %3d | Cost: %.4f | ||g||: %.4e | Max Violation: %.4e | Temp: %.2f | Time: %.2f\n', ...
            k, J, norm(g), max_violation, Temp, Time);
        end
        % ----------------------------- Debugging ---------------------------- %

        % Gradient descent step
        x_new = x - step_size * g;
        alpha_new = x_trial(N+1:2*N);
        alpha_projected = projsplx(alpha_new);
        x_new(N+1:2*N) = alpha_projected;

        % Project back into bounds
        x = max(min(x_new, ub), lb);

        % Store cost
        J_hist(k) = J;

        % Check convergence (norm of gradient, change in cost, etc.)
        if norm(g) < tol
            break;
        end
    end

    % ----------------------------- Debugging ---------------------------- %
    if furnace_model.settings.debugging_optimizer
        fprintf('=== PGD Finished (%d iterations) ===\n', k);
    
        % Plot cost function history
        figure;
        plot(1:k, J_hist(1:k), '-o', 'LineWidth', 1.5);
        xlabel('Iteration');
        ylabel('Cost Function J');
        title('PGD Optimization Progress');
        grid on;
    end
    % ----------------------------- Debugging ---------------------------- %
    
    % Extract optimized variables
    T_f_opt = x(1:N);     % Optimized stepwise furnace temperatures
    alpha_opt = x_opt(N+1:2*N);
    t_opt = x(end);   % Optimized time intervals
    J_hist = J_hist(1:k); % Trim unneeded entries
    furnace_model = Update_Time(furnace_model, t_opt); 

    % Extract the modelled time-temperature curves
    [results] = Get_Or_Run_Simulation(x, furnace_model);
    results.alpha_opt = alpha_opt;
end
