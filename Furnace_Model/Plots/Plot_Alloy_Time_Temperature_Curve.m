function Plot_Alloy_Time_Temperature_Curve(t, T_f_desired, T_furnace, T_walls, T_alloy, T_ms, T_heater, fm, alpha_opt)
    %% Plots time-temperature curves
    
    if nargin < 9
        alpha_opt = 1;
    end

    % Constants
    C2K = 273.15;   % Celcius to Kelvin
    t_total = sum(t);
    t_h = linspace(0, t_total, length(T_furnace)) / 3600;  % Second to hours

    % Generate desired curve
    if isscalar(T_f_desired)
        T_desired_curve = T_f_desired * ones(size(t_h));
    elseif fm.settings.desired_temp_curve_specified
        T_desired_curve = T_f_desired;
    elseif fm.settings.desired_temperature_curve
        T_desired_curve = Generate_Desired_Temperature_Curve(T_f_desired, t, fm, alpha_opt);
    end

    % Convert to Celsius
    T_desired_curve = T_desired_curve - C2K;
    T_alloy = T_alloy - C2K;


    % Define aesthetically pleasing colors
    furnace_color =  [0.95, 0.70, 0.2];   % Soft reddish-orange
    metal_sheet_color = [0.8 0.8 0.8]; % Soft teal blue
    alloy_color = [0.47, 0.67, 0.19];    % Soft green 
    heater_color = [0.85, 0.33, 0.1];
    
    % Start plot
    figure; hold on; grid on;
    
    % Initialize arrays for handles and labels
    plot_handles = [];
    plot_labels = {};
    
    % Plot alloy if present
    if fm.settings.alloy_present
        h_alloy = plot(t_h, T_alloy, 'Color', alloy_color, 'LineWidth', 2);
        plot_handles(end+1) = h_alloy;
        plot_labels{end+1} = '$T_{alloy}$';
    end
    
    % Plot desired curve only if it's not zero
    if ~(isscalar(T_f_desired) && T_f_desired == 0)
        h_desired = plot(t_h, T_desired_curve, 'k--', 'LineWidth', 1.5);
        plot_handles(end+1) = h_desired;
        plot_labels{end+1} = '$T_f^*$';
    end
    
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