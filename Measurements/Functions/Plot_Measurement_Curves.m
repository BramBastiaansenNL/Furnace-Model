function Plot_Measurement_Curves(t, T_set, T_furnace, T_material_ext, T_material_int, Segment, P)
    %% Plots measured time-temperature curves
    
    % Constants
    C2K = 273.15;   % Celcius to Kelvin
    t_total = sum(t);
    t_h = linspace(0, t_total, length(T_furnace)) / 3600;  % Second to hours

    % Convert temperatures to Celsius
    T_set          = T_set - C2K;
    T_furnace      = T_furnace - C2K;
    T_material_ext = T_material_ext - C2K;
    T_material_int = T_material_int - C2K;

    % Define distinct colors
    color_furnace      = [0.85, 0.33, 0.1];   % Reddish orange
    color_material_ext = [0.2, 0.6, 0.9];     % Light blue
    color_material_int = [0, 0.2, 0.5];       % Dark blue
    color_setpoint     = [0, 0, 0];           % Black
    color_power        = [0.47, 0.67, 0.19];  % Soft green 
    
    % Initialize figure
    figure; hold on; grid on;

    % Plot segment shading
    segment_changes = find(diff(Segment) ~= 0) + 1;
    segment_change_times_h = t_h(segment_changes);
    segment_edges_h = [t_h(1), segment_change_times_h, t_h(end)];
    y_limits = [0, max([T_set, T_furnace, T_material_ext, T_material_int]) + 20];

    for k = 1:length(segment_edges_h)-1
        if mod(k, 2) == 0
            patch([segment_edges_h(k), segment_edges_h(k+1), segment_edges_h(k+1), segment_edges_h(k)], ...
                  [y_limits(1), y_limits(1), y_limits(2), y_limits(2)], ...
                  [0.9, 0.9, 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
        end
    end
    
    % Plot curves
    h_furnace      = plot(t_h, T_furnace, 'Color', color_furnace, 'LineWidth', 2);
    h_material_ext = plot(t_h, T_material_ext, 'Color', color_material_ext, 'LineWidth', 2);
    h_material_int = plot(t_h, T_material_int, 'Color', color_material_int, 'LineWidth', 2);
    h_setpoint     = plot(t_h, T_set, '--', 'Color', color_setpoint, 'LineWidth', 1.5);

    % Labels and legend
    xlabel('$\textbf{Time } (h)$', 'Interpreter', 'latex', 'FontSize', 14);
    ylabel('$\textbf{Temperature } (^{\circ}C)$', 'Interpreter', 'latex', 'FontSize', 14);
    title('$\textbf{Measured Time-Temperature Curves}$', 'Interpreter', 'latex', 'FontSize', 16);

    legend([h_furnace, h_material_ext, h_material_int, h_setpoint], ...
        {'\textbf{Furnace}', '\textbf{Alloy Ext}', '\textbf{Alloy Int}', '$T_f^*$'}, ...
        'Interpreter', 'latex', 'FontSize', 12, 'Location', 'Best');

    set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex', 'LineWidth', 1.2);
    xlim([0, max(t_h)]);
    box on;
    hold off;
    
    % Power input plot
    figure;
    area(t_h, P, 'FaceColor', color_power, 'EdgeColor', 'none', 'FaceAlpha', 0.5);
    plot(t_h, P, 'Color', color_power, 'LineWidth', 2);
    xlabel('$\textbf{Time } (h)$', 'Interpreter', 'latex', 'FontSize', 14);
    ylabel('$\textbf{Power } (\%)$', 'Interpreter', 'latex', 'FontSize', 14);
    title('$\textbf{Measured Power Input}$', 'Interpreter', 'latex', 'FontSize', 16);
    grid on;
    set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex', 'LineWidth', 1.2);
    xlim([0, max(t_h)]);
end