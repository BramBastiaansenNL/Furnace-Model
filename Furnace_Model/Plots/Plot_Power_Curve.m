function Plot_Power_Curve(t, Power_Curve, fm)
    %% Plots power input over time
    
    % Convert to appropriate settings
    t_total = sum(t);
    t_h = t_total / 3600; 
    Power_Curve = Power_Curve * round(fm.controller.n_heaters) / fm.controller.P_max * 100; % Percentage
    time_vector = linspace(0, t_h, length(Power_Curve));
    power_color = [0.47, 0.67, 0.19];    % Soft green 

    %% Plot Power Consumption
    figure();
    area(time_vector, Power_Curve, 'FaceColor', power_color, 'EdgeColor', 'none', 'FaceAlpha', 0.5);
    hold on;
    plot(time_vector, Power_Curve, 'Color', power_color, 'LineWidth', 2); % Outline for sharpness
    xlabel('$\textbf{Time } (h)$', 'Interpreter', 'latex', 'FontSize', 14);
    ylabel('$\textbf{Power Consumption } (\%)$', 'Interpreter', 'latex', 'FontSize', 14);
    title('$\textbf{Power Consumption Over Time}$', 'Interpreter', 'latex', 'FontSize', 16);
    grid on; xlim([0, max(time_vector)]);
    set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex', 'LineWidth', 1.2);
    box on;
end