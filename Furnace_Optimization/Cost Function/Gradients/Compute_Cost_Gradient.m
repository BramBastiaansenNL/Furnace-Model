function dJ_dx = Compute_Cost_Gradient(fm, constraints, cached_result)
    %% Sum total derivative of cost function with respect to optimization variables
    
    % Unpack
    derivatives = cached_result.derivatives;
    dt = fm.model.dt;
    N = fm.model.N;
    power_w = fm.model.power_w;           % Power weight
    time_w = fm.model.time_w;             % Time weight
    mech_w = fm.model.mech_w;             % Mechanical properties weight

    %% Time component: dJ_time/dx = dJ_time/dt * dt/dx
    dt_dx = [zeros(1, 2*N), 1];
    dJ_time_dt = 1 / constraints.t_max;
    dJ_time_dx = dJ_time_dt * dt_dx; % [1 x 2N+1] row vector

    %% Power component: J_power = sum P_k * dt / P_max
    dJ_power_dx = dt / fm.controller.P_max * derivatives.dP_dx_full;

    if fm.settings.mechanical_loss
        M = cached_result.mechanical_properties;
        X = cached_result.phase_fractions;
        dJ_mech_dx = Compute_Mechanical_Loss_Gradient(M, X, dt_dx, fm);
        
        %% Sum all components
        dJ_dx = time_w * dJ_time_dx + power_w * dJ_power_dx + mech_w * dJ_mech_dx;
    else
        dJ_dx = time_w * dJ_time_dx + power_w * dJ_power_dx;
    end
end
