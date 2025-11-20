function Compare_fmincon_Gradients(furnace_model, constraints, initial_guess, N)
    %% Compares different optimizers' performance given an initial guess

    % fmincon Optimization
    fprintf('\n--- Running fmincon Optimizer without gradient ---\n');
    tic;
    furnace_model.settings.symbolic_differentiation = false;
    [T_f_FMINCON, t_FMINCON, J_hist_FMINCON, results_FMINCON, time_FMINCON_log] = ...
        fmincon_Optimizer(furnace_model, constraints, initial_guess, N);
    time_FMINCON = toc;

    % fmincon Optimization
    fprintf('\n--- Running fmincon Optimizer with gradient ---\n');
    tic;
    furnace_model.settings.symbolic_differentiation = true;
    [T_f_FMINCON_GRAD, t_FMINCON_GRAD, J_hist_FMINCON_GRAD, results_FMINCON_GRAD, time_FMINCON_GRAD_log] = ...
        fmincon_Optimizer(furnace_model, constraints, initial_guess, N);
    time_FMINCON_GRAD = toc;

    T_f_init = initial_guess(1:N);
    t_total_init = initial_guess(end);
    alpha_init = (1/N) * ones(1, N);
    x_init = [T_f_init, alpha_init, t_total_init]; 
    J_init = Compute_Cost_Function(x_init, furnace_model, constraints, N);
    J_hist_FMINCON_GRAD = [J_init, J_hist_FMINCON_GRAD];
    J_hist_FMINCON     = [J_init, J_hist_FMINCON];
    
    % Summary of optimiation comparison
    fprintf('\n--- Summary of Optimization Variables ---\n');
    fprintf('fmincon with gradient:\n  T_f = [%s]\n  t = [%s]\n  J = %.4f\n', ...
        num2str(T_f_FMINCON_GRAD, ' %.2f'), num2str(t_FMINCON_GRAD, ' %.2f'), J_hist_FMINCON_GRAD(end));
    
    fprintf('fmincon without gradient:\n  T_f = [%s]\n  t = [%s]\n  J = %.4f\n', ...
        num2str(T_f_FMINCON, ' %.2f'), num2str(t_FMINCON, ' %.2f'), J_hist_FMINCON(end));

    % Plot cost function histories
    figure('Name', 'Cost vs Iteration', 'Color', 'w');
    plot(1:length(J_hist_FMINCON_GRAD), J_hist_FMINCON_GRAD, 'b-o', 'LineWidth', 1.5, 'DisplayName', 'With gradient'); hold on;
    plot(1:length(J_hist_FMINCON), J_hist_FMINCON, 'r-s', 'LineWidth', 1.5, 'DisplayName', 'Without gradient');
    xlabel('Iteration', 'Interpreter', 'latex');
    ylabel('Objective function $J$', 'Interpreter', 'latex');
    title('Convergence over iterations', 'Interpreter', 'latex');
    legend('Location', 'southeast', 'Interpreter', 'latex'); grid on;
    
    figure('Name', 'Cost vs Time', 'Color', 'w');
    plot(time_FMINCON_GRAD_log, J_hist_FMINCON_GRAD, 'b-o', 'LineWidth', 1.5, 'DisplayName', 'With gradient'); hold on;
    plot(time_FMINCON_log, J_hist_FMINCON, 'r-s', 'LineWidth', 1.5, 'DisplayName', 'Without gradient');
    xlabel('Computation time [s]', 'Interpreter', 'latex');
    ylabel('Objective function $J$', 'Interpreter', 'latex');
    title('Convergence over computation time', 'Interpreter', 'latex');
    legend('Location', 'southeast', 'Interpreter', 'latex'); grid on;

    % % Plot optimized time-temperature profiles
    % Plot_Results(furnace_model, t_FMINCON_GRAD, T_f_FMINCON_GRAD, results_FMINCON_GRAD)
    % Plot_Results(furnace_model, t_FMINCON, T_f_FMINCON, results_FMINCON)

    % Display cost and timing
    fprintf('\n--- Final Cost and Timing ---\n');
    fprintf('PGD:\n  Cost: %.4f\n  Time: %.2f seconds\n', J_hist_FMINCON_GRAD(end), time_FMINCON_GRAD);
    fprintf('fmincon:\n  Cost: %.4f\n  Time: %.2f seconds\n', J_hist_FMINCON(end), time_FMINCON);

    speed_ratio = time_FMINCON_log(end) / time_FMINCON_GRAD_log(end);
    cost_diff   = J_hist_FMINCON_GRAD(end) - J_hist_FMINCON(end);
    fprintf('Gradient speeds up by %.2fx but increases final cost by %.4f\n', speed_ratio, cost_diff);
end