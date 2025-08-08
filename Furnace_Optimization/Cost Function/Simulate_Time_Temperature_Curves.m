function [T_w_curve, T_f_curve, T_m_curve, T_ms_curve, Power_curve] = ...
    Simulate_Time_Temperature_Curves(T_f_desired, t, fm)
    %% Simulate the time-temperature curve and compute power expenditure [OUTDATED!]

    [T_w_curve, T_f_curve, T_m_curve, T_ms_curve, Power_curve] = ...
        Simulate_Furnace(T_f_desired, t, fm);

    if fm.settings.dynamic_plotting
        % Create or update iteration counter
        if evalin('base', 'exist(''iteration'', ''var'')')
            iteration = evalin('base', 'iteration');
            iteration = iteration + 1;
        else
            iteration = 1;
        end
        assignin('base', 'iteration', iteration);
        
        % Plot every 3 iterations
        if mod(iteration, 3) == 0 || iteration == 1
            Plot_Time_Temperature_Curve(T_f_curve, fm.model.t_final, iteration);
        end
    end
end