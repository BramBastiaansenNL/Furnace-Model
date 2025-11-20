function Compare_PGD_Step_Sizing(furnace_model, constraints, initial_guess, N)
    %% Compares different optimizers' performance given an initial guess

    % PGD constant step-sizing Optimization
    fprintf('\n--- Running PGD Optimizer with constant step-sizing ---\n');
    tic;
    furnace_model.settings.constant_step_size = true;
    [T_f_PGD_Constant, t_PGD_Constant, J_hist_PGD_Constant, results_PGD_Constant] = ...
        PGD_Optimizer(furnace_model, constraints, initial_guess, N);
    time_PGD_Constant = toc;

    % PGD Optimization
    fprintf('\n--- Running PGD Optimizer with adaptive step-sizing ---\n');
    tic;
    furnace_model.settings.constant_step_size = false;
    furnace_model.settings.adaptive_step_size = true;
    [T_f_PGD_adaptive, t_PGD_adaptive, J_hist_PGD_adaptive, results_PGD_adaptive] = ...
        PGD_Optimizer(furnace_model, constraints, initial_guess, N);
    time_PGD_adaptive = toc;
    
    % Summary of optimiation comparison
    fprintf('\n--- Summary of Optimization Variables ---\n');
    fprintf('PGD with constant step-sizing:\n  T_f = [%s]\n  t = [%s]\n  J = %.4f\n', ...
        num2str(T_f_PGD_Constant, ' %.2f'), num2str(t_PGD_Constant, ' %.2f'), J_hist_PGD_Constant(end));
    fprintf('PGD with adaptive step-sizing:\n  T_f = [%s]\n  t = [%s]\n  J = %.4f\n', ...
        num2str(T_f_PGD_adaptive, ' %.2f'), num2str(t_PGD_adaptive, ' %.2f'), J_hist_PGD_adaptive(end));

    % Plot cost function histories
    figure;
    plot(1:length(J_hist_PGD_Constant), J_hist_PGD_Constant, 'r-s', 'DisplayName', 'Constant Step Size', 'LineWidth', 1.5); hold on;
    plot(1:length(J_hist_PGD_adaptive), J_hist_PGD_adaptive, 'g-^', 'DisplayName', 'Adaptive Step Size', 'LineWidth', 1.5);
    xlabel('Iteration');
    ylabel('Cost Function J');
    title('Cost History Comparison');
    legend show; grid on;

    figure;
    plot(1:length(results_PGD_adaptive.lambda_hist), results_PGD_adaptive.lambda_hist, 'g-^', ...
        'LineWidth', 1.5, 'DisplayName', 'Adaptive Step Size');
    xlabel('Iteration');
    ylabel('Step Size \lambda');
    title('Step-Size over Iterations');
    legend show; grid on;

    % % Plot optimized time-temperature profiles
    % Plot_Results(furnace_model, t_PGD_Constant, T_f_PGD_Constant, results_PGD_Constant)
    % Plot_Results(furnace_model, t_PGD_adaptive, T_f_PGD_adaptive, results_PGD_adaptive)

    % Display cost and timing
    fprintf('\n--- Final Cost and Timing ---\n');
    fprintf('PGD constant:\n  Cost: %.4f\n  Time: %.2f seconds\n', J_hist_PGD_Constant(end), time_PGD_Constant);
    fprintf('PGD adaptive:\n  Cost: %.4f\n  Time: %.2f seconds\n', J_hist_PGD_adaptive(end), time_PGD_adaptive);
end