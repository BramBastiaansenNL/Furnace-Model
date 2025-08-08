function [T_f_new, T_a_new, T_w_new, T_ms_new, T_h_new, dT, dT_w, fm] = Solve_Newton_Raphson_Iteration( ...
    T_f, T_a, T_w, T_ms, T_h, T_f_old, T_a_old, T_w_old, T_ms_old, T_h_old, ...
    Q_power, dt, fm, k)
    %% Solves a single Newton-Raphson iteration

    % Compute residual system (F = residual vector, T_w updated internally)
    [F, T_w_new, fm] = Residual_System(T_f, T_a, T_ms, T_h, ...
                                   T_f_old, T_a_old, T_w_old, T_ms_old, T_h_old, ...
                                   Q_power, fm, k);

    % Compute change in wall temperature
    dT_w = T_w_new - T_w;

    % Compute Jacobian matrix
    J = Compute_Newton_Raphson_Jacobian(dt, T_ms, T_h, fm);

    % Newton-Raphson update step
    dT = -J \ F;

    % Update solution
    T_f_new = T_f + dT(1);
    T_a_new = T_a + dT(2);
    T_ms_new = T_ms + dT(3);
    T_h_new = T_h + dT(4);

    % Optionally store derivatives
    if fm.settings.store_derivatives
        fm = Store_NR_Derivatives(fm, k, J, T_w_old, dt);
    end
end
