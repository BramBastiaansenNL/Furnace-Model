function J_matrix = Sensitivity_Test(furnace_model, constraints, Temp_range, t_range)
    % Investigates the sensitivity of the cost function

    J_matrix = NaN(length(Temp_range), length(t_range));
    feasible_mask = false(length(Temp_range), length(t_range));

    for i = 1:length(Temp_range)
        for j = 1:length(t_range)

            % Extract current test
            T_f = Temp_range(i);
            t = t_range(j);
            x = [T_f, t];

            % Evaluate cost
            try
                J_matrix(i, j) = Compute_Cost_Function(x, furnace_model, constraints);
                feasible_mask(i, j) = Check_Feasibility(x, constraints, furnace_model);
            catch
                J_matrix(i, j) = NaN;
                feasible_mask(i, j) = false;
            end
        end
    end
    
    % Plot 3D surface
    Plot_3D_Cost_Surface(t_range, Temp_range, log10(J_matrix), 'Log10 Cost Function Sensitivity');

    % Plot 2D contour lines
    Plot_Contour(t_range, Temp_range, J_matrix, feasible_mask, '2D Cost Function Sensitivity')

    % Plot 3D contour lines
    Plot_3D_Contour(t_range, Temp_range, J_matrix, feasible_mask, '3D Cost Function Sensitivity');
end