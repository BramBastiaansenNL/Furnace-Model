function [T_f_opt, t_opt, J_hist, results, time_log] = PGD_Optimizer(furnace_model, constraints, initial_guess, N)
    %% Projected Gradient Descent optimizer

    % Initialize optional time log
    time_log = []; 
    max_iters = 50;
    lambda_hist = zeros(max_iters, 1);

    % Initialization
    T_f_init = initial_guess(1:N);
    t_total_init = initial_guess(end);          % Scalar
    alpha_init = (1/N) * ones(1, N);            % Equal time weights initially
    x = [T_f_init, alpha_init, t_total_init]; 
    lambda = 1.0;          % λ0
    theta  = inf;          % θ0
    x_prev = []; grad_prev = [];
    use_adaptive = furnace_model.settings.adaptive_step_size;
    use_constant = furnace_model.settings.constant_step_size;

    % Split tolerances (aligned with fmincon settings)
    tol_grad      = 1e-6;   % Optimality tolerance
    tol_func      = 1e-6;   % Function tolerance
    tol_step      = 1e-8;   % Step tolerance
    tol_constraint= 1e-6;   % Constraint tolerance

    J_hist = zeros(max_iters, 1);

    % Get bounds
    [lb, ub] = Get_Bounds(furnace_model, constraints, N);
    
    % ----------------------------- Debugging ----------------------------%
    if furnace_model.settings.debugging_optimizer
        fprintf('=== Starting Projected Gradient Descent ===\n');
    end
    % ----------------------------- Debugging ----------------------------%

    %% --- Start timing ---
    start_time = tic;
    time_log(1) = 0;  % log initial time at iteration 0
  
    for k = 1:max_iters
        % Evaluate cost and gradient
        [J_current, gradJ] = Compute_Cost_Function(x, furnace_model, constraints, N);

        % Use analytic gradient if available, otherwise approximate
        if isempty(gradJ)
            grad = Approximate_Gradient(@(x_) Compute_Cost_Function(x_, furnace_model, constraints, N), x);
        else
            grad = gradJ;
        end

        % Line search with projection
        if use_adaptive
            [x_trial, lambda, theta] = Adaptive_Step_Size( ...
                x, grad, x_prev, grad_prev, lambda, theta, lb, ub, N, constraints, furnace_model);
            lambda_hist(k) = lambda;
        elseif use_constant
            x_tent = x - lambda * grad;
            x_trial = Project(x_tent, lb, ub, N, constraints, furnace_model);
        else
            x_trial = Line_Search(x, -grad, J_current, grad, furnace_model, constraints, N, lb, ub);
        end


        % Update
        x_prev = x; grad_prev = grad; x = x_trial;

        % Evaluate constraints
        [c, ~] = Get_Constraints(x, furnace_model, constraints, N);
        max_violation = max(c);

        % Store cost
        [J, ~] = Compute_Cost_Function(x, furnace_model, constraints, N);
        J_hist(k) = J;

        % Append timing
        time_log(k+1) = toc(start_time);

        % ----------------------------- Debugging ---------------------------- %
        if furnace_model.settings.debugging_optimizer
            % Logging current state
            Temp = x(1:N);
            Time = x(end);
            fprintf('Iter %3d | Cost: %.4f | ||g||: %.4e | Max Violation: %.4e | Temp: %.2f | Time: %.2f\n', ...
            k, J_current, norm(grad), max_violation, Temp, Time);
        end
        % ----------------------------- Debugging ---------------------------- %

        % Check convergence criteria
        func_change = abs(J - J_current);
        step_size = norm(x - x_prev);
        grad_ok   = (norm(grad) < tol_grad);
        func_ok   = (func_change <= tol_func * (1 + abs(J_current)));
        step_ok   = (step_size < tol_step);
        constr_ok = (max_violation < tol_constraint);
        
        % fmincon-style stopping:
        if grad_ok && constr_ok && (func_ok || step_ok)
            disp('Convergence reached.');
            break;
        end
    end

    % ----------------------------- Debugging ---------------------------- %
    if furnace_model.settings.debugging_optimizer
        fprintf('=== PGD Finished (%d iterations) ===\n', k);
        figure;
        plot(1:k, J_hist(1:k), '-o', 'LineWidth', 1.5);
        xlabel('Iteration'); ylabel('Cost Function J'); title('PGD Optimization Progress');
        grid on;
    end
    % ----------------------------- Debugging ---------------------------- %
    
    % Extract results
    T_f_opt    = x(1:N);
    alpha_opt  = x(N+1:2*N);
    t_opt      = x(end);
    J_hist     = J_hist(1:k);
    lambda_hist = lambda_hist(1:k);
    furnace_model = Update_Time(furnace_model, t_opt);
    results    = Get_Or_Run_Simulation(x, furnace_model);
    results.alpha_opt = alpha_opt;
    results.lambda_hist = lambda_hist;
end
