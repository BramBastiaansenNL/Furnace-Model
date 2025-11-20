function J = Compute_Newton_Raphson_Jacobian_4(dt, m_fCp_f, m_aCp_a, m_msCp_ms, m_hCp_h, ...
                                             h_f_aA_a, h_f_wA_w, h_ms_fA_w, h_h_fA_f, T_ms, T_h, ...
                                             rad_constant_h_ms, rad_constant_h_w)
    %% Computes the Jacobian matrix for Newton_Raphson

    J11 = 1 + dt/m_fCp_f * (h_h_fA_f + 2 * h_ms_fA_w + h_f_wA_w + h_f_aA_a);
    J12 = -dt/m_fCp_f * (h_f_aA_a);
    J13 = -dt/m_fCp_f * (2 * h_ms_fA_w);
    J14 = -dt/m_fCp_f * (h_h_fA_f);

    J21 = -dt/m_aCp_a * (h_f_aA_a);
    J22 = 1 + dt/m_aCp_a * (h_f_aA_a);
    J23 = 0;
    J24 = 0;

    J31 = -dt/m_msCp_ms * (2 * h_ms_fA_w);
    J32 = 0;
    J33 = 1 + dt/m_msCp_ms * (4*rad_constant_h_ms * T_ms^3 + 2 * h_ms_fA_w);
    J34 = -dt/m_msCp_ms * (4*rad_constant_h_ms * T_h^3);
    
    J41 = -dt/m_hCp_h * (h_h_fA_f);
    J42 = 0;
    J43 = -dt/m_hCp_h * (4*rad_constant_h_ms * T_ms^3);
    J44 = 1 + dt/m_hCp_h * (h_h_fA_f + 4*rad_constant_h_ms * T_h^3 + 4*rad_constant_h_w * T_h^3);
    
    J = [J11, J12, J13, J14; J21, J22, J23, J24; J31, J32, J33, J34; J41, J42, J43, J44];
end
