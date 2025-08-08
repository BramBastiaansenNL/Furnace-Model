function derivatives = Compute_Derivatives(fm, k)
    %% Computes all derivatives needed for optimization
        
    % Unpack derivative structure
    derivatives = fm.derivatives;

    %% Unpack relevant derivatives
    dF_dT      = derivatives.dF_dT;               % Jacobian from Newton-Raphson
    dF_dT_prev = derivatives.dF_dT_prev;          % - Identity
    dF_dT_h    = derivatives.dF_dT_h_series{k};   % From Compute_Heater_Temperature
    dF_dT_w1   = derivatives.dF_dT_w1_series{k};  % From Compute_Air_Density(T_furnace, fm, k)
    dT_dx_prev = derivatives.dT_dx_series{k-1};   % dT^(k)/dx
    dT_w1_dx   = derivatives.dT_w1_dx_series{k};  % dT_{w,1}^(k+1)/dx

    %% Gather dT_h_dx (dT_h^(k+1) / dx)
    dT_h_dx = fm.derivatives.dT_h_dx_series{k};

    %% Compute dT_dx (dT^(k+1) / dx)
    dT_dx = Compute_dT_dx(fm, dF_dT, dF_dT_prev, dT_dx_prev, dF_dT_h, dT_h_dx, dF_dT_w1, dT_w1_dx);

    %% Compute dT_alloy_dx (dT_a^(k+1) / dx)
    dT_alloy_dx = derivatives.dT_alloy_dT * dT_dx;

    %% Store results
    derivatives.dT_dx_series{k} = dT_dx;
    derivatives.dT_alloy_dx_series{k} = dT_alloy_dx;
end
