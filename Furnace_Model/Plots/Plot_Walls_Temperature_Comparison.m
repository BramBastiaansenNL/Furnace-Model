function Plot_Walls_Temperature_Comparison(T_walls_NR, T_walls_FS, fm)
    %% Compare wall temperature distributions (NR vs fsolve)

    C2K = 273.15;
    T_walls_NR = T_walls_NR - C2K;
    T_walls_FS = T_walls_FS - C2K;

    wall_names = {'side1', 'side2', 'top', 'bottom', 'front', 'back'};
    num_rows = 3;
    num_cols = 2;

    figure;
    sgtitle('Wall Temperature Comparison: NR vs fsolve', 'Interpreter', 'latex', 'FontSize', 16);

    % Loop through each wall
    for i = 1:6
        wall = fm.walls.(wall_names{i});
        x = linspace(0, wall.L_wall, wall.Nx);
        T_NR = T_walls_NR(i, :);
        T_FS = T_walls_FS(i, :);

        y_min = min([T_NR, T_FS]) - 5;
        y_max = max([T_NR, T_FS]) + 5;

        subplot(num_rows, num_cols, i); hold on;

        % Shaded regions for layers
        fill([0, wall.boundary1, wall.boundary1, 0], ...
             [y_min, y_min, y_max, y_max], ...
             [1 0.95 0.8], 'FaceAlpha', 0.2, 'EdgeColor', 'none');
        fill([wall.boundary1, wall.L_wall, wall.L_wall, wall.boundary1], ...
             [y_min, y_min, y_max, y_max], ...
             [0.7 0.7 0.7], 'FaceAlpha', 0.2, 'EdgeColor', 'none');

        % Plot temperature curves
        area(x, T_NR, 'FaceColor', [1 0.6 0.6], 'FaceAlpha', 0.3, 'EdgeAlpha', 0);
        plot(x, T_NR, 'r-', 'LineWidth', 2); % Newton-Raphson

        area(x, T_FS, 'FaceColor', [0.6 0.8 1.0], 'FaceAlpha', 0.3, 'EdgeAlpha', 0);
        plot(x, T_FS, 'b-', 'LineWidth', 2); % fsolve

        % Boundaries
        plot([0, 0], [y_min, y_max], 'k', 'LineWidth', 2);
        plot([wall.boundary1, wall.boundary1], [y_min, y_max], 'k--', 'LineWidth', 1.2);
        plot([wall.L_wall, wall.L_wall], [y_min, y_max], 'k', 'LineWidth', 2);

        % Labels and grid
        title(wall_names{i}, 'Interpreter', 'latex', 'FontSize', 14);
        xlabel('$\textbf{Position (m)}$', 'Interpreter', 'latex', 'FontSize', 12);
        ylabel('$\textbf{Temp } (^{\circ}C)$', 'Interpreter', 'latex', 'FontSize', 12);
        legend('NR (area)', 'NR', 'fsolve (area)', 'fsolve', 'Location', 'Best');

        xlim([-0.02 * wall.L_wall, wall.L_wall]);
        ylim([y_min, y_max]);
        grid on;
        set(gca, 'FontSize', 11, 'TickLabelInterpreter', 'latex', 'LineWidth', 1.2);
        hold off;
    end
end
