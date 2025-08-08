function [fm, dT_h_dx] = Compute_dT_h_dx(fm, A, B, T_h, T_ms, T_w, k, dt)
    %% Compute the derivative of the heater temperature w.r.t. x, with saturation handling
    
    % Derivative coefficients
    df_dP = -1;
    df_dT_h = 4*A*T_h^3 + B;
    df_dT = [-B, 0, -4 * fm.constants.rad_constant_h_ms * T_ms^3];
    df_dT_w = - fm.constants.rad_constant_h_w * [T_w(1, 1:4).^3, 0, 0];

    % Previous step derivatives (including dP^(k)/dx
    dT_dx_prev = fm.derivatives.dT_dx_series{k-1};
    dT_w1_dx_prev = fm.derivatives.dT_w1_dx_series{k-1};
    dP_dx_prev = fm.derivatives.dP_dx_series{k-1};
    fm.derivatives.dF_dT_h_series{k} = ...
        [- dt/fm.constants.m_fCp_f * B;
         0; 
         - 4 * dt/fm.constants.m_msCp_ms * fm.constants.rad_constant_h_ms * T_h^3];

    rhs = df_dP * dP_dx_prev + df_dT * dT_dx_prev + df_dT_w * dT_w1_dx_prev;
    dT_h_dx = - df_dT_h \ rhs;
    fm.derivatives.dT_h_dx_series{k} = dT_h_dx;
end