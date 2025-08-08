function Plot_Wall_Temperature(T_wall, wall)
    %% Plot Temperature Distribution for a Single Wall
    
    % Convert to appropriate settings
    C2K = 273.15;   % Celcius to degrees
    T_wall = T_wall - C2K;

    % Grid discretization
    x_positions = linspace(0, wall.L_wall, wall.Nx);

    % Start plot
    figure; hold on; grid on;

    % Area fill under curve
    area(x_positions, T_wall, 'FaceColor', [1 0.8 0.8], 'FaceAlpha', 0.3, 'EdgeAlpha', 0);

    % Layer shading (two layers)
    y_min = min(T_wall) - 10;
    y_max = max(T_wall) + 10;

    fill([0, wall.boundary1, wall.boundary1, 0], ...
         [y_min, y_min, y_max, y_max], ...
         [1 0.95 0.8], 'FaceAlpha', 0.2, 'EdgeColor', 'none');

    fill([wall.boundary1, wall.L_wall, wall.L_wall, wall.boundary1], ...
         [y_min, y_min, y_max, y_max], ...
         [0.7 0.7 0.7] , 'FaceAlpha', 0.2, 'EdgeColor', 'none');

    % Now plot the actual temperature curve
    plot(x_positions, T_wall, 'Color', [0.8 0.1 0.1], 'LineWidth', 2);

    % Vertical boundaries from bottom (y_min) to top (y_max)
    plot([0, 0], [y_min, y_max], 'k', 'LineWidth', 2);
    plot([wall.boundary1, wall.boundary1], [y_min, y_max], 'k--', 'LineWidth', 1.5);
    plot([wall.L_wall, wall.L_wall], [y_min, y_max], 'k', 'LineWidth', 2);

    % Axis limits
    padding = 0.02 * wall.L_wall;
    xlim([-padding, wall.L_wall]);
    ylim([y_min, y_max]);

    % Labels and title
    xlabel('$\textbf{Position in Wall } (m)$', 'Interpreter', 'latex', 'FontSize', 14);
    ylabel('$\textbf{Temperature } (^{\circ}C)$', 'Interpreter', 'latex', 'FontSize', 14);
    title('Temperature Distribution - (Side) Furnace Wall', 'Interpreter', 'latex', 'FontSize', 16);
    
    % Label the wall layers
    text(wall.boundary1/2, y_max - 2, 'Insulation', ...
         'Interpreter', 'latex', 'FontSize', 12, 'HorizontalAlignment', 'center');
end