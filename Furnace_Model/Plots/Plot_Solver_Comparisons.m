function Plot_Solver_Comparisons(T_furnace_NR, T_alloy_NR, T_metal_sheet_NR, T_walls_NR, Power_Curve_NR, ...
                                 T_furnace_FS, T_alloy_FS, T_metal_sheet_FS, T_walls_FS, Power_Curve_FS, ...
                                 fm)
    % Plot simulation results from Newton-Raphson and fsolve methods

    t = (0:fm.model.Nt-1) * fm.model.dt; % Time vector in seconds
    t_h = t / 3600;

    % Define color scheme
    colors_NR = [0.85, 0.33, 0.10]; % Orange-red
    colors_FS = [0.30, 0.75, 0.93]; % Cyan-blue
    fill_alpha = 0.3;
    
    %% Plot Furnace Temperature
    figure();
    area(t_h, T_furnace_NR, 'FaceColor', colors_NR, 'FaceAlpha', fill_alpha, 'EdgeColor', 'none'); hold on;
    plot(t_h, T_furnace_NR, 'Color', colors_NR, 'LineWidth', 2);
    area(t_h, T_furnace_FS, 'FaceColor', colors_FS, 'FaceAlpha', fill_alpha, 'EdgeColor', 'none');
    plot(t_h, T_furnace_FS, 'Color', colors_FS, 'LineWidth', 2);
    title('\textbf{Furnace Temperature Comparison}', 'Interpreter', 'latex');
    legend('NR (area)', 'NR (line)', 'fsolve (area)', 'fsolve (line)', 'Location', 'Best');
    xlabel('$\textbf{Time (h)}$', 'Interpreter', 'latex');
    ylabel('$T_F$ (K)', 'Interpreter', 'latex');
    grid on; box on;
    set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex', 'LineWidth', 1.2);

    %% Plot Alloy Temperature
    figure();
    area(t_h, T_alloy_NR, 'FaceColor', colors_NR, 'FaceAlpha', fill_alpha, 'EdgeColor', 'none'); hold on;
    plot(t_h, T_alloy_NR, 'Color', colors_NR, 'LineWidth', 2);
    area(t_h, T_alloy_FS, 'FaceColor', colors_FS, 'FaceAlpha', fill_alpha, 'EdgeColor', 'none');
    plot(t_h, T_alloy_FS, 'Color', colors_FS, 'LineWidth', 2);
    title('\textbf{Alloy Temperature Comparison}', 'Interpreter', 'latex');
    legend('NR (area)', 'NR (line)', 'fsolve (area)', 'fsolve (line)', 'Location', 'Best');
    xlabel('$\textbf{Time (h)}$', 'Interpreter', 'latex');
    ylabel('$T_A$ (K)', 'Interpreter', 'latex');
    grid on; box on;
    set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex', 'LineWidth', 1.2);

    %% Plot Metal Sheet Temperature
    figure();
    area(t_h, T_metal_sheet_NR, 'FaceColor', colors_NR, 'FaceAlpha', fill_alpha, 'EdgeColor', 'none'); hold on;
    plot(t_h, T_metal_sheet_NR, 'Color', colors_NR, 'LineWidth', 2);
    area(t_h, T_metal_sheet_FS, 'FaceColor', colors_FS, 'FaceAlpha', fill_alpha, 'EdgeColor', 'none');
    plot(t_h, T_metal_sheet_FS, 'Color', colors_FS, 'LineWidth', 2);
    title('\textbf{Metal Sheet Temperature Comparison}', 'Interpreter', 'latex');
    legend('NR (area)', 'NR (line)', 'fsolve (area)', 'fsolve (line)', 'Location', 'Best');
    xlabel('$\textbf{Time (h)}$', 'Interpreter', 'latex');
    ylabel('$T_{MS}$ (K)', 'Interpreter', 'latex');
    grid on; box on;
    set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex', 'LineWidth', 1.2);

    %% Plot Power Curve
    figure();
    area(t_h, Power_Curve_NR, 'FaceColor', colors_NR, 'FaceAlpha', fill_alpha, 'EdgeColor', 'none'); hold on;
    plot(t_h, Power_Curve_NR, 'Color', colors_NR, 'LineWidth', 2);
    area(t_h, Power_Curve_FS, 'FaceColor', colors_FS, 'FaceAlpha', fill_alpha, 'EdgeColor', 'none');
    plot(t_h, Power_Curve_FS, 'Color', colors_FS, 'LineWidth', 2);
    title('\textbf{Power Curve Comparison}', 'Interpreter', 'latex');
    legend('NR (area)', 'NR (line)', 'fsolve (area)', 'fsolve (line)', 'Location', 'Best');
    xlabel('$\textbf{Time (h)}$', 'Interpreter', 'latex');
    ylabel('Power (K)', 'Interpreter', 'latex');
    grid on; box on;
    set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex', 'LineWidth', 1.2);

    %% Plot Wall Temperature
    % Plot_Walls_Temperature_Comparison(T_walls_NR, T_walls_FS, fm);
end
