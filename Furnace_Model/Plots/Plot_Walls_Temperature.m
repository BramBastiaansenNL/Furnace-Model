function Plot_Walls_Temperature(T_walls, fm)
    %% Plot Wall Temperature Distribution for 6 walls (Separate Subplots)
    
    % Convert to appropriate settings (Celcius to Kelvin)
    C2K = 273.15;   % Celcius to degrees
    T_walls = T_walls - C2K;  % Convert to Celsius if needed

    % Wall names for labeling
    wall_names = {'side1', 'side2', 'top', 'bottom', 'front', 'back'};
    
    % Set the number of rows and columns for the subplots (3x2 grid)
    num_rows = 3;
    num_cols = 2;
    
    % Start the figure
    figure; 
    sgtitle('Wall Temperature Distributions', 'Interpreter', 'latex', 'FontSize', 16);
    
    % Loop over all 6 walls to plot each wall's temperature distribution in subplots
    for i = 1:6
        % Retrieve wall layer dimensions
        wall = fm.walls.(wall_names{i});
        x_positions = linspace(0, wall.L_wall, wall.Nx);
    
        % Temperature for this wall
        T_wall = T_walls(i, :);
        y_min = min(T_wall) - 10;
        y_max = max(T_wall) + 10;
    
        % Subplot
        subplot(num_rows, num_cols, i);
    
        % --- Draw layer shading first ---
        hold on; % Needed to layer multiple plots
    
        % Layer 1: insulation
        fill([0, wall.boundary1, wall.boundary1, 0], ...
             [y_min, y_min, y_max, y_max], ...
             [1 0.95 0.8], 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    
        % Layer 2: structural material
        fill([wall.boundary1, wall.L_wall, wall.L_wall, wall.boundary1], ...
             [y_min, y_min, y_max, y_max], ...
             [0.7 0.7 0.7], 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    
        % --- Then plot the data ---
        area(x_positions, T_wall, 'FaceColor', [1 0.8 0.8], ...
             'FaceAlpha', 0.3, 'EdgeAlpha', 0);
        plot(x_positions, T_wall, 'LineWidth', 2, 'Color', 'r');
    
        % --- Boundary lines on top ---
        plot([0, 0], [y_min, y_max], 'k', 'LineWidth', 2);
        plot([wall.boundary1, wall.boundary1], [y_min, y_max], 'k--', 'LineWidth', 1.5);
        plot([wall.L_wall, wall.L_wall], [y_min, y_max], 'k', 'LineWidth', 2);
    
        % Axis and title
        xlim([-0.02 * wall.L_wall, wall.L_wall]);
        ylim([y_min, y_max]);
        title([wall_names{i}], 'Interpreter', 'latex', 'FontSize', 14);
        xlabel('$\textbf{Position } (m)$', 'Interpreter', 'latex', 'FontSize', 12);
        ylabel('$\textbf{Temp } (^{\circ}C)$', 'Interpreter', 'latex', 'FontSize', 12);
    
        % Optional: label layer text
        text(wall.boundary1/2, y_max - 2, 'Insulation', ...
             'Interpreter', 'latex', 'FontSize', 10, 'HorizontalAlignment', 'center');
        % text((wall.boundary1 + wall.L_wall)/2, y_max - 2, 'Structure', ...
        %      'Interpreter', 'latex', 'FontSize', 10, 'HorizontalAlignment', 'center');
    
        grid on;
        hold off;
    end
end