function dT_dx = Compute_dT_dx(fm, dR_dT, dR_dT_prev, dT_dx_prev, dR_dT_h, dT_h_dx, dR_dT_w1, dT_w1_dx)
    %% Compute the derivative of the temperature states w.r.t. x
    
    rhs = dR_dT_prev * dT_dx_prev + dR_dT_h * dT_h_dx + dR_dT_w1 * dT_w1_dx;
    dT_dx = - dR_dT \ rhs;
end