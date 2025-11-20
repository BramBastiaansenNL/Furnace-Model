function F = Compute_Residuals(T_vec, T_f_old, T_a_old, T_ms_old, T_h_old, T_w_old, T_w_fixed, ...
                               Q_power, fm, dt, constants)
    %% Function to compute the numerical Jacobian

    T_f = T_vec(1);
    T_a = T_vec(2);
    T_ms = T_vec(3);
    T_h = T_vec(4);

    [Q_f_w, Q_f_alloy, Q_h_ms, Q_ms_f, Q_h_f, Q_h_w] = ...
        Compute_Heat_Transfers(T_w_fixed(:,1), T_f, T_a, T_ms, T_h, fm, T_w_old(:,1));

    F1 = T_f - T_f_old - dt/constants.m_fCp_f * (Q_h_f + 2 * Q_ms_f - Q_f_w - Q_f_alloy);
    F2 = T_a - T_a_old - dt/constants.m_aCp_a * Q_f_alloy;
    F3 = T_ms - T_ms_old - dt/constants.m_msCp_ms * (Q_h_ms - 2 * Q_ms_f);
    F4 = T_h - T_h_old - dt/constants.m_hCp_h * (Q_power - Q_h_ms - Q_h_w - Q_h_f);

    F = [F1; F2; F3; F4];
end