function Plot_Time_Temperature_Curves(t, T_f_desired, T_furnace, T_walls, T_alloy, T_ms, T_heater, fm, alpha_opt)
    %% Plots time-temperature curves
    
    if nargin < 9
        alpha_opt = 0;
    end

    % Constants
    C2K = 273.15;   % Celcius to Kelvin
    t_total = sum(t);
    t_h = linspace(0, t_total, length(T_furnace)) / 3600;  % Second to hours

    % Generate desired curve
    if isscalar(T_f_desired)
        T_desired_curve = T_f_desired * ones(size(t_h));
    elseif fm.settings.desired_temperature_curve
        T_desired_curve = Generate_Desired_Temperature_Curve(T_f_desired, t, fm, alpha_opt);
    else
        T_desired_curve = T_f_desired;
    end

    % Convert to Celsius
    T_desired_curve = T_desired_curve - C2K;
    T_walls = T_walls - C2K; 
    T_alloy = T_alloy - C2K;
    T_furnace = T_furnace - C2K;
    T_ms = T_ms - C2K;
    T_heater = T_heater - C2K;

    % Define aesthetically pleasing colors
    furnace_color = [0.85, 0.33, 0.1];   % Soft reddish-orange
    metal_sheet_color = [0.2, 0.6, 0.8]; % Soft teal blue
    alloy_color = [0.47, 0.67, 0.19];    % Soft green 
    heater_color = [0.8 0.8 0.8];
    
    % Start plot
    figure; hold on; grid on;
    
    % Initialize arrays for handles and labels
    plot_handles = [];
    plot_labels = {};
    
    % Plot furnace
    h_furnace = plot(t_h, T_furnace, 'Color', furnace_color, 'LineWidth', 2);
    plot_handles(end+1) = h_furnace;
    plot_labels{end+1} = '\textbf{Furnace}';
    
    % Plot metal sheet
    h_ms = plot(t_h, T_ms, 'Color', metal_sheet_color, 'LineWidth', 2);
    plot_handles(end+1) = h_ms;
    plot_labels{end+1} = '\textbf{Metal Sheet}';
    
    % Plot alloy if present
    if fm.settings.alloy_present
        h_alloy = plot(t_h, T_alloy, 'Color', alloy_color, 'LineWidth', 2);
        plot_handles(end+1) = h_alloy;
        plot_labels{end+1} = '\textbf{Alloy}';
    end
    
    % Plot heater
    h_heater = plot(t_h, T_heater, 'Color', heater_color, 'LineWidth', 2);
    plot_handles(end+1) = h_heater;
    plot_labels{end+1} = '\textbf{Heater}';

    % Optional wall plot: wall 1, node 1
    if fm.settings.add_wall_plot
        wall_color = [0.7, 0.5, 0.9];  % Brighter purple (start)
        T_wall_1_1 = squeeze(T_walls(1, 1, :));
        h_wall = plot(t_h, T_wall_1_1, 'Color', wall_color, 'LineWidth', 2);
        plot_handles(end+1) = h_wall;
        plot_labels{end+1} = '\textbf{Wall (1,1)}';
        
        wall_color = [0.6, 0.4, 0.8];  % Base soft purple (middle)
        middle_node = round(fm.walls.Nx / 2);
        T_wall_1_middle = squeeze(T_walls(1, middle_node, :));
        h_wall = plot(t_h, T_wall_1_middle, 'Color', wall_color, 'LineWidth', 2);
        plot_handles(end+1) = h_wall;
        plot_labels{end+1} = '\textbf{Wall (1,middle)}';

        wall_color = [0.45, 0.3, 0.65];% Darker muted purple (end)
        T_wall_1_end = squeeze(T_walls(1, end, :));
        h_wall = plot(t_h, T_wall_1_end, 'Color', wall_color, 'LineWidth', 2);
        plot_handles(end+1) = h_wall;
        plot_labels{end+1} = '\textbf{Wall (1,Nx)}';
    end
    
    % Plot desired curve
    h_desired = plot(t_h, T_desired_curve, 'k--', 'LineWidth', 1.5);
    plot_handles(end+1) = h_desired;
    plot_labels{end+1} = '$T_f^*$';
    
    % LaTeX Labels and Title
    xlabel('$\textbf{Time } (h)$', 'Interpreter', 'latex', 'FontSize', 14);
    ylabel('$\textbf{Temperature } (^{\circ}C)$', 'Interpreter', 'latex', 'FontSize', 14);
    title('$\textbf{Time-Temperature Curves}$', 'Interpreter', 'latex', 'FontSize', 16);
    
    % Aesthetic Legend
    legend(plot_handles, plot_labels, ...
       'Interpreter', 'latex', 'FontSize', 12, 'Location', 'Best');
    
    % Additional Plot Aesthetics
    set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex', 'LineWidth', 1.2);
    box on; xlim([0, max(t_h)]);
    hold off;
end