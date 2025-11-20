function Check_dT_w_dx(T_f_desired, T_furnace, T_alloy, T_walls, ...
                       T_metal_sheet, T_heater, integral_error, ...
                       prev_error, dt, fm, k, ...
                       T_furnace_prev, T_alloy_prev, T_metal_sheet_prev, T_heater_prev)
    %% Validates dT_w_dx

    epsilon = 1e-4;
    tolerance = 1e-5;

    % Forward perturbation
    T_f_desired_fwd = T_f_desired + epsilon;
    fm_fwd = fm;
    [P_fwd, ~, ~, fm_fwd] = Compute_Power_Supply(T_f_desired_fwd, T_furnace, ...
                                                 integral_error, prev_error, dt, fm_fwd, k);
    if fm_fwd.settings.alloy_present
        fm_fwd = Compute_Specific_Heat(T_alloy, fm_fwd);
    end
    fm_fwd = Compute_Air_Density(T_furnace, fm_fwd);
    [~, ~, T_w_fwd, ~, ~, ~, ~] = ...
        Solve_Newton_Raphson(T_furnace, T_alloy, T_walls, T_metal_sheet, ...
                             T_heater, fm_fwd, P_fwd, k, ...
                             T_furnace_prev, T_alloy_prev, T_metal_sheet_prev, T_heater_prev);

    % Backward perturbation
    T_f_desired_bwd = T_f_desired - epsilon;
    fm_bwd = fm;
    [P_bwd, ~, ~, fm_bwd] = Compute_Power_Supply(T_f_desired_bwd, T_furnace, ...
                                                 integral_error, prev_error, dt, fm_bwd, k);
    if fm_bwd.settings.alloy_present
        fm_bwd = Compute_Specific_Heat(T_alloy, fm_bwd);
    end
    fm_bwd = Compute_Air_Density(T_furnace, fm_bwd);
    [~, ~, T_w_bwd, ~, ~, ~, ~] = ...
        Solve_Newton_Raphson(T_furnace, T_alloy, T_walls, T_metal_sheet, ...
                             T_heater, fm_bwd, P_bwd, k, ...
                             T_furnace_prev, T_alloy_prev, T_metal_sheet_prev, T_heater_prev);

    if isempty(T_w_fwd) || isempty(T_w_bwd)
        error('T_w_fwd or T_w_bwd is empty. Check `Solve_Newton_Raphson` outputs.');
    end
    fprintf("P_fwd = %.6f, P_bwd = %.6f, ΔP = %.6e\n", P_fwd, P_bwd, P_fwd - P_bwd);

    % Extract only the first spatial node from each wall layer
    T_w_fwd_col1 = T_w_fwd(:, 1);   % [6×1]
    T_w_bwd_col1 = T_w_bwd(:, 1);   % [6×1]
    fprintf("ΔT_f = %+e → P = %.6f → ΔT_w(1) = %.6f\n", epsilon, P_fwd, T_w_fwd(1,1) - T_walls(1,1));

    % Numerical derivative [6×1]
    dT_w1_dx_numeric = (T_w_fwd_col1 - T_w_bwd_col1) / (2 * epsilon);

    % Analytical derivative
    dT_w1_dx_analytic = fm.derivatives.dT_w1_dx_series{k};

    % Compare
    abs_diff = dT_w1_dx_numeric - dT_w1_dx_analytic;
    abs_diff_norm = norm(abs_diff);
    rel_error = abs_diff_norm / max(norm(dT_w1_dx_numeric), 1e-8);

    fprintf("\n====== Wall Gradient Check @ k = %d ======\n", k);
    disp("Numerical dT_w/dx:"); disp(dT_w1_dx_numeric(:));
    disp("Analytical dT_w/dx:"); disp(dT_w1_dx_analytic(:));
    disp("Difference dT_w/dx:"); disp(dT_w1_dx_analytic(:) - dT_w1_dx_numeric(:));
    fprintf("Absolute Difference: %.3e\n", abs_diff_norm);
    fprintf("Relative Error: %.3e\n", rel_error);

    if abs_diff_norm > tolerance
        % for w = 1:6
        %     fprintf("Wall %d discrepancy:\n", w);
        %     fprintf("  Numerical : %.6f\n", dT_w_dx_numeric(w));
        %     fprintf("  Analytical: %.6f\n", dT_w_dx_analytic(w));
        %     fprintf("  Abs Diff  : %.3e\n\n", abs_diff(w));
        % end
        rel_errors = abs(abs_diff) ./ max(abs(dT_w1_dx_numeric), 1e-8);
        disp("Per-wall relative errors:"); disp(rel_errors(:));
        user_input = input('Continue gradient checking? Y/N [Y]: ', 's');
        if strcmpi(user_input, 'n')
            error('Gradient check terminated.');
        end

        % figure;
        % for w = 1:6
        %     subplot(3,2,w);
        %     plot(1, T_w_fwd_col1(w), 'r*'); hold on;
        %     plot(1, T_w_bwd_col1(w), 'b*');
        %     legend('Fwd', 'Bwd');
        %     title(sprintf('Wall %d @ node 1', w));
        % end
        % sgtitle('Wall Temperature Node 1 for Perturbations');
    end
end
