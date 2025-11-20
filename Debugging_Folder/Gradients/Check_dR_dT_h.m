function Check_dR_dT_h(P_base, T_w_surface_exposed, T_f, T_a, T_ms, ...
                     T_h_guess, T_f_old, T_a_old, T_w_old, T_ms_old, fm)
    %% Validates dR_dP

    epsilon = 1e-4;
    P_max = 650;
    P_min = 0;

    % Compute base T_h and residual F
    fm.settings.symbolic_differentiation = true;
    [T_h_base, fm_base] = Compute_Heater_Temperature(P_base, T_w_surface_exposed, T_f_old, T_ms_old, T_h_guess, fm);
    [F_base, ~] = Residual_System(T_f, T_a, T_ms, T_h_base, ...
                                  T_f_old, T_a_old, T_w_old, T_ms_old, fm_base);
    fm.settings.symbolic_differentiation = false;

     if P_base >= P_max
        P_bwd = max(P_base - epsilon, P_min);
        [T_h_bwd, ~] = Compute_Heater_Temperature(P_bwd, T_w_surface_exposed, T_f_old, T_ms_old, T_h_guess, fm);
        [F_bwd, ~] = Residual_System(T_f, T_a, T_ms, T_h_bwd, ...
                                     T_f_old, T_a_old, T_w_old, T_ms_old, fm);
        dR_dT_h_numeric = (F_base - F_bwd) / (P_base - P_bwd);
        method = "backward";

    elseif P_base <= P_min
        P_fwd = min(P_base + epsilon, P_max);
        [T_h_fwd, ~] = Compute_Heater_Temperature(P_fwd, T_w_surface_exposed, T_f_old, T_ms_old, T_h_guess, fm);
        [F_fwd, ~] = Residual_System(T_f, T_a, T_ms, T_h_fwd, ...
                                     T_f_old, T_a_old, T_w_old, T_ms_old, fm);
        dR_dT_h_numeric = (F_fwd - F_base) / (P_fwd - P_base);
        method = "forward";

    else
        [T_h_plus, ~] = Compute_Heater_Temperature(P_base + epsilon, T_w_surface_exposed, T_f_old, T_ms_old, T_h_guess, fm);
        [F_plus, ~] = Residual_System(T_f, T_a, T_ms, T_h_plus, ...
                                      T_f_old, T_a_old, T_w_old, T_ms_old, fm);

        [T_h_minus, ~] = Compute_Heater_Temperature(P_base - epsilon, T_w_surface_exposed, T_f_old, T_ms_old, T_h_guess, fm);
        [F_minus, ~] = Residual_System(T_f, T_a, T_ms, T_h_minus, ...
                                       T_f_old, T_a_old, T_w_old, T_ms_old, fm);

        dR_dT_h_numeric = (F_plus - F_minus) / (2 * epsilon);
        method = "central";
    end

    % Analytical derivative
    dR_dT_h_analytic = fm_base.derivatives.dR_dT_h;

    % Comparison
    abs_diff = norm(dR_dT_h_numeric - dR_dT_h_analytic);
    rel_err = abs_diff / max(norm(dR_dT_h_numeric), 1e-8);

    % Output
    fprintf("\n====== dR/dT_h Check (%s diff) ======\n", method);
    fprintf("Analytical dRdT_h:\n");
    disp(dR_dT_h_analytic);
    fprintf("Numerical  dR/dT_h:\n");
    disp(dR_dT_h_numeric);
    fprintf("Absolute Difference: %.6e\n", abs_diff);
    fprintf("Relative Error: %.6e\n", rel_err);
end
