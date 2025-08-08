function Plot_Time_Temperature_Curve(T_f, t, iteration)
    %% Plots results for the time-temperature curve of the simulated furnace.

    % Convert to appropriate settings
    C2K = 273.15;   % Celcius to degrees
    t_h = t / 3600; 
    T_f = T_f + C2K;
    t_grid = linspace(0, t_h, length(T_f));

    % Initialize figure
    figure(1);
    hold on;    % Keeps previous plots

    % Plot the current curve
    plot(t_grid, T_f, 'LineWidth', 1.5, 'DisplayName', sprintf('Iteration %d', iteration));

    % Dynamically adjust x-axis to current simulation time
    xlim([0, max(t_grid)]); 
    ylim([min(T_f) - 10, max(T_f) + 10]); % Add some padding

    % Customize plot with LaTeX formatting
    xlabel('$\textbf{Time} (h)$', 'Interpreter', 'latex', 'FontSize', 14);
    ylabel('$\textbf{Furnace Temperature} (^{\circ}C)$', 'Interpreter', 'latex', 'FontSize', 14);
    title('$\textbf{Time-Temperature Curves (All Iterations)}$', 'Interpreter', 'latex', 'FontSize', 16);

    % Enhance plot aesthetics
    grid on;
    set(gca, 'FontSize', 12, 'FontName', 'Times New Roman');
    set(gca, 'GridAlpha', 0.3, 'GridColor', [0.2 0.2 0.2]);

    % Add box and tight layout
    box on;
    set(gcf, 'Color', 'w');
    set(gca, 'TickLabelInterpreter', 'latex');

    % Update legend
    legend('show', 'Location', 'best');

    % Keep holding for the next plot
    hold on;
end