function P_processed = Smooth_Power_Moving_Average(t, P, window_size, plotting, fm)
    %% Smooth out the power curve through a filtered signal

    % Parameters
    P_max = fm.controller.P_max;
    P_percent = (P / P_max) * 100;  % Normalize for logic
    power_trust_threshold = 90;  % Percent; values ≥ this are considered reliable high power
    noise_threshold = 10;        % Percent; values ≤ this are suspect
    min_zero_duration = 10;      % Number of points for a real shutdown
    t_total = sum(t);
    t_h = linspace(0, t_total, length(P)) / 3600;
    
    % Detect real shutdown (sustained zeros at end)
    shutdown_index = length(P_percent);
    zero_run = 0;
    for i = length(P_percent):-1:1
        if P_percent(i) <= noise_threshold
            zero_run = zero_run + 1;
            if zero_run >= min_zero_duration
                shutdown_index = i;
            end
        else
            if zero_run < min_zero_duration
                zero_run = 0;
            else
                break;
            end
        end
    end

    % Create a copy of the power vector to clean up
    P_interp = P;
    % Mark single-point or short glitches for interpolation
    for i = 2:shutdown_index-1
        if P_percent(i) <= noise_threshold && ...
           P_percent(i-1) >= power_trust_threshold && ...
           P_percent(i+1) >= power_trust_threshold
            P_interp(i) = NaN;
        end
    end

    % Interpolate only over NaNs
    nan_locs = isnan(P_interp);
    valid_locs = ~nan_locs;
    if any(nan_locs)
        P_interp(nan_locs) = interp1(t_h(valid_locs), P_interp(valid_locs), t_h(nan_locs), 'linear');
    end

    % Optional smoothing (e.g., moving average)
    P_smoothed = movmean(P_interp, window_size);
    high_power = P_percent >= power_trust_threshold;
    P_smoothed(high_power) = P(high_power);

    % Return final result
    P_processed = P_smoothed;

    % Power input plot
    if plotting
        P_plot_percent = (P_processed / P_max) * 100;
        color_power   = [0.47, 0.67, 0.19];  % Soft green 
    
        figure;
        area(t_h, P_plot_percent, 'FaceColor', color_power, 'EdgeColor', 'none', 'FaceAlpha', 0.5);
        plot(t_h, P_plot_percent, 'Color', color_power, 'LineWidth', 2);
        xlabel('$\textbf{Time } (h)$', 'Interpreter', 'latex', 'FontSize', 14);
        ylabel('$\textbf{Power } (\%)$', 'Interpreter', 'latex', 'FontSize', 14);
        title('$\textbf{Filtered Power Input}$', 'Interpreter', 'latex', 'FontSize', 16);
        grid on;
        set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex', 'LineWidth', 1.2);
        xlim([0, max(t_h)]);
    end
end
