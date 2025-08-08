function fm = Store_NR_Derivatives(fm, k, J, T_w_old, dt)
    %% Stores Jacobian and sensitivity matrices for one time step

    % Shorthand constants
    c = fm.constants;
    
    % Store Jacobian
    fm.derivatives.dF_dT_series{k} = J;

    % dF / dT_{w,1}^{(k+1)}
    dF_dT_w1_element_1 = - (dt / (c.m_fCp_f)) * c.h_f_wA_w;
    dF_dT_w1_element_4 = - (dt / (c.m_hCp_h)) * ...
        4 * c.rad_constant_h_w * [T_w_old(1, 1:4).^3, 0, 0];

    dF_dT_w1 = [
        dF_dT_w1_element_1 * ones(1, 6);
        zeros(2, 6);
        dF_dT_w1_element_4
    ];

    fm.derivatives.dF_dT_w1_series{k} = dF_dT_w1;

    %dF / dT_{w,1}^{(k)}
    dF_dT_w1_element_4_prev = (dt / (c.m_hCp_h)) * ...
        12 * c.rad_constant_h_w * [T_w_old(1, 1:4).^3, 0, 0];

    dF_dT_w1_prev = [
        zeros(3, 6);
        dF_dT_w1_element_4_prev
    ];

    fm.derivatives.dF_dT_w1_prev_series{k} = dF_dT_w1_prev;
end
