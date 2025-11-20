function Check_dT_h_dx(T_f_desired, T_furnace, T_alloy, T_walls, ...
                                T_metal_sheet, T_heater, integral_error, ...
                                prev_error, dt, fm, k, ...
                                T_furnace_prev, T_alloy_prev, T_metal_sheet_prev, T_heater_prev)
    %% Validates dT_h/dx

    epsilon = 1e-4;
    tolerance = 1e-5;

    % Forward perturbation
    T_f_desired_fwd = T_f_desired + epsilon;
    fm_fwd = fm;  % shallow copy is sufficient if no persistent fields
    [P_fwd, ~, ~, fm_fwd] = Compute_Power_Supply(T_f_desired_fwd, T_furnace, ...
                                                 integral_error, prev_error, dt, fm_fwd);
    [~, ~, ~, ~, T_h_fwd, ~, ~] = ...
        Solve_Newton_Raphson(T_furnace, T_alloy, T_walls, T_metal_sheet, ...
                             T_heater, fm_fwd, P_fwd, ...
                             T_furnace_prev, T_alloy_prev, T_metal_sheet_prev, T_heater_prev);

    % Backward perturbation
    T_f_desired_bwd = T_f_desired - epsilon;
    fm_bwd = fm;
    [P_bwd, ~, ~, fm_bwd] = Compute_Power_Supply(T_f_desired_bwd, T_furnace, ...
                                                 integral_error, prev_error, dt, fm_bwd);
    [~, ~, ~, ~, T_h_bwd, ~, ~] = ...
        Solve_Newton_Raphson(T_furnace, T_alloy, T_walls, T_metal_sheet, ...
                             T_heater, fm_bwd, P_bwd, ...
                             T_furnace_prev, T_alloy_prev, T_metal_sheet_prev, T_heater_prev);

    % Numerical derivative
    dT_h_dx_numeric = (T_h_fwd - T_h_bwd) / (2 * epsilon);

    % Analytical derivative (1st column of stored Jacobian)
    dT_h_dx_analytic = fm.derivatives.dT_h_dx_series{k}(:, 1);

    % Error metrics
    abs_diff = norm(dT_h_dx_numeric - dT_h_dx_analytic);
    rel_error = abs_diff / max(norm(dT_h_dx_numeric), 1e-8);

    % Report if error exceeds tolerance
    if abs_diff > tolerance
        fprintf("\n====== Gradient Check Failed at Time Step %d ======\n", k);
        fprintf("Numerical dT_h/dx:\n"); disp(dT_h_dx_numeric);
        fprintf("Analytical dT_h/dx:\n"); disp(dT_h_dx_analytic);
        fprintf("Absolute Difference: %.3e\n", abs_diff);
        fprintf("Relative Error: %.3e\n", rel_error);
        user_input = input('Continue gradient checking? Y/N [Y]: ', 's');
        if strcmpi(user_input, 'n')
            error('Gradient check terminated.');
        end
    end
end
