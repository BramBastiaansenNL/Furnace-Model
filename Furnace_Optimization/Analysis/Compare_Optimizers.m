function Compare_Optimizers(furnace_model, constraints, initial_guess, N)
    %% Compares different optimizers' performance given an initial guess

    %% === fmincon Optimization ===
    fprintf('\n--- Running fmincon Optimizer ---\n');
    tic;
    [T_f_FMINCON, t_FMINCON, J_hist_FMINCON, results_FMINCON, time_log_FMINCON] = ...
        fmincon_Optimizer(furnace_model, constraints, initial_guess, N);
    total_time_FMINCON = toc;

    %% === PGD Optimization ===
    fprintf('\n--- Running PGD Optimizer ---\n');
    tic;
    [T_f_PGD, t_PGD, J_hist_PGD, results_PGD, time_log_PGD] = ...
        PGD_Optimizer(furnace_model, constraints, initial_guess, N);
    total_time_PGD = toc;

    T_f_init = initial_guess(1:N);
    t_total_init = initial_guess(end);
    alpha_init = (1/N) * ones(1, N);
    x_init = [T_f_init, alpha_init, t_total_init]; 
    J_init = Compute_Cost_Function(x_init, furnace_model, constraints, N);
    J_hist_FMINCON = [J_init, J_hist_FMINCON];
    J_hist_PGD     = [J_init, J_hist_PGD'];

    %% === Summary ===
    fprintf('\n--- Summary of Optimization Variables ---\n');
    fprintf('PGD:\n  T_f = [%s]\n  t = [%s]\n  J = %.4f\n', ...
        num2str(T_f_PGD, ' %.2f'), num2str(t_PGD, ' %.2f'), J_hist_PGD(end));
    fprintf('fmincon:\n  T_f = [%s]\n  t = [%s]\n  J = %.4f\n', ...
        num2str(T_f_FMINCON, ' %.2f'), num2str(t_FMINCON, ' %.2f'), J_hist_FMINCON(end));

    %% === Plot 1: Cost vs Computation Time ===
    figure('Name', 'Cost vs Time', 'Color', 'w');
    if exist('time_log_FMINCON', 'var') && ~isempty(time_log_FMINCON)
        plot(time_log_FMINCON, J_hist_FMINCON, 'r-', 'LineWidth', 1.8, 'DisplayName', 'fmincon'); hold on;
    else
        plot(linspace(0, total_time_FMINCON, length(J_hist_FMINCON)), J_hist_FMINCON, 'r-', 'LineWidth', 1.8, 'DisplayName', 'fmincon'); hold on;
    end
    if exist('time_log_PGD', 'var') && ~isempty(time_log_PGD)
        plot(time_log_PGD, J_hist_PGD, 'b--', 'LineWidth', 1.8, 'DisplayName', 'PGD');
    else
        plot(linspace(0, total_time_PGD, length(J_hist_PGD)), J_hist_PGD, 'b--', 'LineWidth', 1.8, 'DisplayName', 'PGD');
    end
    xlabel('Computation time [s]', 'Interpreter', 'latex');
    ylabel('Objective function $J$', 'Interpreter', 'latex');
    title('Convergence over computation time', 'Interpreter', 'latex');
    legend('Location', 'northeast', 'Interpreter', 'latex');
    grid on; set(gca, 'FontSize', 12, 'LineWidth', 1.2);

    %% === Plot 2: Runtime vs Final Cost (Scatter Plot) ===
    figure('Name', 'Runtime vs Final Cost', 'Color', 'w');
    scatter(total_time_PGD, J_hist_PGD(end), 80, 'b', 'filled'); hold on;
    scatter(total_time_FMINCON, J_hist_FMINCON(end), 80, 'r', 'filled');
    xlabel('Total runtime [s]', 'Interpreter', 'latex');
    ylabel('Final objective value $J_{final}$', 'Interpreter', 'latex');
    title('Runtime vs. Final Cost', 'Interpreter', 'latex');
    legend({'PGD', 'fmincon'}, 'Location', 'best', 'Interpreter', 'latex');
    grid on; set(gca, 'FontSize', 12, 'LineWidth', 1.2);

    %% === Plot 3: Progress per Iteration (semi-log) ===
    figure('Name', 'Progress per Iteration', 'Color', 'w');
    semilogy(1:length(J_hist_FMINCON)-1, abs(diff(J_hist_FMINCON)), 'r-', 'LineWidth', 1.8, 'DisplayName', 'fmincon'); hold on;
    semilogy(1:length(J_hist_PGD)-1, abs(diff(J_hist_PGD)), 'b--', 'LineWidth', 1.8, 'DisplayName', 'PGD');
    xlabel('Iteration', 'Interpreter', 'latex');
    ylabel('$|\Delta J|$ per iteration', 'Interpreter', 'latex');
    title('Rate of convergence per iteration', 'Interpreter', 'latex');
    legend('Location', 'southwest', 'Interpreter', 'latex');
    grid on; set(gca, 'FontSize', 12, 'LineWidth', 1.2);

    %% === Plot 4: Normalized Cost Reduction vs Time ===
    J0_FMINCON = J_hist_FMINCON(1);
    J0_PGD = J_hist_PGD(1);
    figure('Name', 'Normalized Cost Reduction', 'Color', 'w');
    if exist('time_log_FMINCON', 'var') && ~isempty(time_log_FMINCON)
        plot(time_log_FMINCON, (J0_FMINCON - J_hist_FMINCON) / J0_FMINCON, 'r-', 'LineWidth', 1.8, 'DisplayName', 'fmincon'); hold on;
    else
        plot(linspace(0, total_time_FMINCON, length(J_hist_FMINCON)), ...
            (J0_FMINCON - J_hist_FMINCON) / J0_FMINCON, 'r-', 'LineWidth', 1.8, 'DisplayName', 'fmincon'); hold on;
    end
    if exist('time_log_PGD', 'var') && ~isempty(time_log_PGD)
        plot(time_log_PGD, (J0_PGD - J_hist_PGD) / J0_PGD, 'b--', 'LineWidth', 1.8, 'DisplayName', 'PGD');
    else
        plot(linspace(0, total_time_PGD, length(J_hist_PGD)), ...
            (J0_PGD - J_hist_PGD) / J0_PGD, 'b--', 'LineWidth', 1.8, 'DisplayName', 'PGD');
    end
    xlabel('Computation time [s]', 'Interpreter', 'latex');
    ylabel('Normalized cost reduction $(J_0 - J)/J_0$', 'Interpreter', 'latex');
    title('Relative cost reduction efficiency', 'Interpreter', 'latex');
    legend('Location', 'southeast', 'Interpreter', 'latex');
    grid on; set(gca, 'FontSize', 12, 'LineWidth', 1.2);

    %% === Print Timing Summary ===
    fprintf('\n--- Final Cost and Timing ---\n');
    fprintf('PGD:\n  Cost: %.4f\n  Time: %.2f seconds\n', J_hist_PGD(end), total_time_PGD);
    fprintf('fmincon:\n  Cost: %.4f\n  Time: %.2f seconds\n', J_hist_FMINCON(end), total_time_FMINCON);

    % Plot optimized time-temperature profiles 
    % Plot_Results(furnace_model, t_PGD, T_f_PGD, results_PGD) 
    % Plot_Results(furnace_model, t_FMINCON, T_f_FMINCON, results_FMINCON)
end