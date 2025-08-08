function Plot_Newton_Raphson_Iterations(Nt, iterations_per_time_step, dt)
    %% Plots the number of iterations to converge over time
    
    % Convert time steps to hours
    t_h = Nt * dt / 3600;  % Total time in hours
    time_vector = linspace(0, t_h, length(iterations_per_time_step));
    
    % Plot Settings
    iteration_color = [0.19, 0.47, 0.67];  % Soft blue for iterations

    %% Plot Iteration Steps
    figure();
    area(time_vector, iterations_per_time_step, 'FaceColor', iteration_color, 'EdgeColor', 'none', 'FaceAlpha', 0.5);
    hold on;
    plot(time_vector, iterations_per_time_step, 'Color', iteration_color, 'LineWidth', 2); % Outline for sharpness
    xlabel('$\textbf{Time } (h)$', 'Interpreter', 'latex', 'FontSize', 14);
    ylabel('$\textbf{Iterations to Converge}$', 'Interpreter', 'latex', 'FontSize', 14);
    title('$\textbf{Newton-Raphson Iterations Over Time}$', 'Interpreter', 'latex', 'FontSize', 16);
    grid on;
    xlim([0, max(time_vector)]);
    set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex', 'LineWidth', 1.2);
    box on;
end
