function Plot_Calibration_Results(time_experiment, T_measurement, T_simulation)
    %% Plots the model calibration results: a comparison between experimental and simulated temperatures

    % Construct time vector
    N = length(T_measurement.T_furnace);
    t_h = linspace(0, time_experiment, N) / 3600; % Time in hours

    % Extract and convert temperatures
    T_exp_f = T_measurement.T_furnace - 273.15;
    T_sim_f = T_simulation.T_f_curve - 273.15;
    T_exp_a = T_measurement.T_material_ext - 273.15;
    T_sim_a = T_simulation.T_m_curve - 273.15;

    % Compute residuals
    res_furnace = T_sim_f - T_exp_f;
    res_alloy   = T_sim_a - T_exp_a;

    % Compute error metrics
    rmse_furnace = sqrt(mean(res_furnace.^2));
    rmse_alloy   = sqrt(mean(res_alloy.^2));
    max_dev_furnace = max(abs(res_furnace));
    max_dev_alloy   = max(abs(res_alloy));
    mae_furnace = mean(abs(res_furnace));
    mae_alloy   = mean(abs(res_alloy));

    % Color settings
    exp_color = [0.2, 0.6, 0.8];     % teal-blue
    sim_color = [0.85, 0.33, 0.1];   % reddish-orange

    % Begin Plotting
    figure('Color','w', 'Position', [100, 100, 900, 600]);

    % Subplot 1: Furnace Temperature
    subplot(2,1,1); hold on; grid on;
    plot(t_h, T_exp_f, '-', 'Color', exp_color, 'LineWidth', 2);
    plot(t_h, T_sim_f, '--', 'Color', sim_color, 'LineWidth', 2);
    xlabel('$\textbf{Time (h)}$', 'Interpreter', 'latex', 'FontSize', 14);
    ylabel('$T_{\mathrm{furnace}} \ (^{\circ}C)$', 'Interpreter', 'latex', 'FontSize', 14);
    title('Furnace Temperature');
    legend({'$T_{\mathrm{exp}}$', '$T_{\mathrm{sim}}$'}, 'Interpreter', 'latex', 'FontSize', 12, 'Location', 'best');
    set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex', 'LineWidth', 1.2);
    box on;

    % Subplot 2: Alloy Temperature
    subplot(2,1,2); hold on; grid on;
    plot(t_h, T_exp_a, '-', 'Color', exp_color, 'LineWidth', 2);
    plot(t_h, T_sim_a, '--', 'Color', sim_color, 'LineWidth', 2);
    xlabel('$\textbf{Time (h)}$', 'Interpreter', 'latex', 'FontSize', 14);
    ylabel('$T_{\mathrm{alloy}} \ (^{\circ}C)$', 'Interpreter', 'latex', 'FontSize', 14);
    title('Alloy Temperature');
    legend({'$T_{\mathrm{exp}}$', '$T_{\mathrm{sim}}$'}, 'Interpreter', 'latex', 'FontSize', 12, 'Location', 'best');
    set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex', 'LineWidth', 1.2);
    box on;

    % Print summary
    fprintf('\nCalibration Error Metrics:\n');
    fprintf('  Furnace: RMSE = %.2f°C, Max Dev = %.2f°C, MAE = %.2f°C\n', rmse_furnace, max_dev_furnace, mae_furnace);
    fprintf('  Alloy:   RMSE = %.2f°C, Max Dev = %.2f°C, MAE = %.2f°C\n', rmse_alloy, max_dev_alloy, mae_alloy);
end