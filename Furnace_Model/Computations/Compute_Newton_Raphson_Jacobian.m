function J = Compute_Newton_Raphson_Jacobian(dt, T_ms, T_h, fm)
    %% Computes the Jacobian matrix for Newton_Raphson

    constants = fm.constants;

    J11 = 1 + dt/constants.m_fCp_f * (constants.h_h_fA_h + 2 * constants.h_ms_fA_ms + ...
          6 * constants.h_f_wA_w + constants.h_f_aA_a);
    J12 = -dt/constants.m_fCp_f * (constants.h_f_aA_a);
    J13 = -dt/constants.m_fCp_f * (2 * constants.h_ms_fA_ms);
    J14 = -dt/constants.m_fCp_f * (constants.h_h_fA_h);

    J21 = -dt/constants.m_aCp_a * (constants.h_f_aA_a);
    J22 = 1 + dt/constants.m_aCp_a * (constants.h_f_aA_a);
    J23 = 0;
    J24 = 0;

    J31 = -dt/constants.m_msCp_ms * (2 * constants.h_ms_fA_ms);
    J32 = 0;
    J33 = 1 + dt/constants.m_msCp_ms * (4*constants.rad_constant_h_ms * T_ms^3 + ...
          2 * constants.h_ms_fA_ms);
    J34 = -dt/constants.m_msCp_ms * (4*constants.rad_constant_h_ms * T_h^3);

    J41 = -dt/constants.m_hCp_h * (constants.h_h_fA_h);
    J42 = 0;
    J43 = -dt/constants.m_hCp_h * (4*constants.rad_constant_h_ms * T_ms^3);
    % J44 = 1 + dt/constants.m_hCp_h * (4*constants.rad_constant_h_ms * T_h^3 + ...
    %       16*constants.rad_constant_h_w * T_h^3 + constants.h_h_fA_h);
    J44 = 1 + dt/constants.m_hCp_h * (4*constants.rad_constant_h_ms * T_h^3 + ...
          16*constants.rad_constant_h_w * T_h^3 + constants.h_h_fA_h);
    
    J = [J11, J12, J13, J14; J21, J22, J23, J24; ...
         J31, J32, J33, J34; J41, J42, J43, J44];
end
