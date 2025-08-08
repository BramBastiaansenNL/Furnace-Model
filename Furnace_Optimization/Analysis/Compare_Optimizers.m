function Compare_Optimizers(furnace_model, constraints, initial_guess, N)
    %% Compares different optimizers' performance given an initial guess

    % fmincon Optimization
    fprintf('\n--- Running fmincon Optimizer ---\n');
    tic;
    [T_f_FMINCON, t_FMINCON, J_hist_FMINCON, results_FMINCON] = ...
        fmincon_Optimizer(furnace_model, constraints, initial_guess);
    time_FMINCON = toc;

    % PGD Optimization
    fprintf('\n--- Running PGD Optimizer ---\n');
    tic;
    [T_f_PGD, t_PGD, J_hist_PGD, results_PGD] = ...
        PGD_Optimizer(furnace_model, constraints, initial_guess);
    time_PGD = toc;
    
    % Summary of optimiation comparison
    fprintf('\n--- Summary of Optimization Variables ---\n');
    fprintf('PGD:\n  T_f = [%s]\n  t = [%s]\n  J = %.4f\n', ...
        num2str(T_f_PGD, ' %.2f'), num2str(t_PGD, ' %.2f'), J_hist_PGD(end));
    
    fprintf('fmincon:\n  T_f = [%s]\n  t = [%s]\n  J = %.4f\n', ...
        num2str(T_f_FMINCON, ' %.2f'), num2str(t_FMINCON, ' %.2f'), J_hist_FMINCON(end));

    % Plot cost function histories
    figure;
    plot(1:length(J_hist_PGD), J_hist_PGD, 'b-o', 'DisplayName', 'PGD', 'LineWidth', 1.5); hold on;
    plot(1:length(J_hist_FMINCON), J_hist_FMINCON, 'r-s', 'DisplayName', 'fmincon', 'LineWidth', 1.5);
    xlabel('Iteration');
    ylabel('Cost Function J');
    title('Cost History Comparison');
    legend show; grid on;

    % Plot optimized time-temperature profiles
    Plot_Results(furnace_model, t_PGD, T_f_PGD, results_PGD)
    Plot_Results(furnace_model, t_FMINCON, T_f_FMINCON, results_FMINCON)

    % Display cost and timing
    fprintf('\n--- Final Cost and Timing ---\n');
    fprintf('PGD:\n  Cost: %.4f\n  Time: %.2f seconds\n', J_hist_PGD(end), time_PGD);
    fprintf('fmincon:\n  Cost: %.4f\n  Time: %.2f seconds\n', J_hist_FMINCON(end), time_FMINCON);
end