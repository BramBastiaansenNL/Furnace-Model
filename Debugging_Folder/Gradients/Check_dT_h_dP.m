function Check_dT_h_dP(P_base, T_w_surface, T_f_prev, T_ms_prev, T_h_guess, fm)
    %% Verifies the derivative dT_h/dP using finite differences.

    epsilon = 1e-4;
    P_max = 650;  % Maximum power
    P_min = 0;    % Minimum power

    % Call with baseline power
    fm.settings.symbolic_differentiation = true;
    [T_h_base, fm] = Compute_Heater_Temperature(P_base, T_w_surface, T_f_prev, T_ms_prev, T_h_guess, fm);
    disp(fm.derivatives.dT_h_dP);

    % Use central difference unless at boundary
    if P_base >= P_max
        % Use backward difference
        P_bwd = max(P_base - epsilon, P_min);
        [T_h_bwd, ~] = Compute_Heater_Temperature(P_bwd, T_w_surface, T_f_prev, T_ms_prev, T_h_guess, fm);
        dT_h_dP_numeric = (T_h_base - T_h_bwd) / (P_base - P_bwd);
        method = "backward";

    elseif P_base <= P_min
        % Use forward difference
        P_fwd = min(P_base + epsilon, P_max);
        [T_h_fwd, ~] = Compute_Heater_Temperature(P_fwd, T_w_surface, T_f_prev, T_ms_prev, T_h_guess, fm);
        dT_h_dP_numeric = (T_h_fwd - T_h_base) / (P_fwd - P_base);
        method = "forward";

    else
        % Use central difference
        [T_h_plus, ~] = Compute_Heater_Temperature(P_base + epsilon, T_w_surface, T_f_prev, T_ms_prev, T_h_guess, fm);
        [T_h_minus, ~] = Compute_Heater_Temperature(P_base - epsilon, T_w_surface, T_f_prev, T_ms_prev, T_h_guess, fm);
        dT_h_dP_numeric = (T_h_plus - T_h_minus) / (2 * epsilon);
        method = "central";
    end

    % Analytical derivative (assumed stored inside the function)
    dT_h_dP_analytic = fm.derivatives.dT_h_dP;

    % Display results
    fprintf("\n====== dT_h/dP Check (%s diff) ======\n", method);
    fprintf("P = %.4f\n", P_base);
    fprintf("Analytical dT_h/dP: %.6f\n", dT_h_dP_analytic);
    fprintf("Numerical  dT_h/dP: %.6f\n", dT_h_dP_numeric);
    fprintf("Absolute Difference: %.6e\n", abs(dT_h_dP_numeric - dT_h_dP_analytic));
    fprintf("Relative Error: %.6e\n", abs(dT_h_dP_numeric - dT_h_dP_analytic) / max(abs(dT_h_dP_numeric), 1e-8));
end

