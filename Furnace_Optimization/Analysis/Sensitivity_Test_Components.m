function J_total = Sensitivity_Test_Components(furnace_model, constraints)
    % Applies sensitivity analysis to the individual terms of the cost function

    % Define scan ranges
    T_range = linspace(400, 600, 12);  % Temperature in °C
    t_range = linspace(constraints.t_min, 3600, 12);  % Time in seconds

    J_total = NaN(length(T_range), length(t_range));
    J_power = NaN(size(J_total));
    J_time = NaN(size(J_total));
    J_mech = NaN(size(J_total));

    for i = 1:length(T_range)
        for j = 1:length(t_range)
            T_f = T_range(i);
            t = t_range(j);
            try
                [J_total(i,j), J_power(i,j), J_time(i,j), J_mech(i,j)] = ...
                    Compute_Cost_Components(T_f, t, furnace_model, constraints);
            catch
                % Leave as NaN
            end
        end
    end

    % Plot each component
    Plot_Heatmap(t_range, T_range, J_total, 'Total Cost Function');
    Plot_Heatmap(t_range, T_range, J_power, 'Power Cost');
    Plot_Heatmap(t_range, T_range, J_time, 'Time Cost');
    Plot_Heatmap(t_range, T_range, J_mech, 'Mechanical Property Penalty');
end