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

    % Color settings (distinct and colorblind-friendly)
    colors = struct( ...
        'exp_furnace', [0.2, 0.6, 0.8], ...    % teal-blue
        'sim_furnace', [0.85, 0.33, 0.1], ...  % reddish-orange
        'exp_alloy',   [0.4, 0.7, 0.2], ...
        'sim_alloy',   [0.6, 0.2, 0.6] ...
    );

    % Begin Plotting
    figure('Color','w', 'Position', [100, 100, 1000, 500]); hold on; grid on;

    % Plot all temperature curves
    plot(t_h, T_exp_f, '-', 'Color', colors.exp_furnace, 'LineWidth', 2);
    plot(t_h, T_sim_f, '--', 'Color', colors.sim_furnace, 'LineWidth', 2);
    plot(t_h, T_exp_a, '-', 'Color', colors.exp_alloy, 'LineWidth', 2);
    plot(t_h, T_sim_a, '--', 'Color', colors.sim_alloy, 'LineWidth', 2);

    % Labels and formatting
    xlabel('$\textbf{Time (h)}$', 'Interpreter', 'latex', 'FontSize', 16);
    ylabel('$\textbf{Temperature (}^{\circ} \textbf{C)}$', 'Interpreter', 'latex', 'FontSize', 16);
    title('Measured vs Simulated Temperatures', 'FontSize', 16, 'Interpreter', 'latex');

    legend({ ...
        '$T_{\mathrm{furnace,exp}}$', ...
        '$T_{\mathrm{furnace,sim}}$', ...
        '$T_{\mathrm{alloy,exp}}$', ...
        '$T_{\mathrm{alloy,sim}}$' ...
        }, ...
        'Interpreter', 'latex', 'FontSize', 12, 'Location', 'best');

    set(gca, 'FontSize', 13, 'TickLabelInterpreter', 'latex', 'LineWidth', 1.3);
    box on;

    % Print summary
    fprintf('\nCalibration Error Metrics:\n');
    fprintf('  Furnace: RMSE = %.2f°C, Max Dev = %.2f°C, MAE = %.2f°C\n', rmse_furnace, max_dev_furnace, mae_furnace);
    fprintf('  Alloy:   RMSE = %.2f°C, Max Dev = %.2f°C, MAE = %.2f°C\n', rmse_alloy, max_dev_alloy, mae_alloy);
end