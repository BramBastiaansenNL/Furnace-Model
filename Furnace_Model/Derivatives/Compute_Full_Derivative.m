function fm = Compute_Full_Derivative(T_walls, T_heater, fm)
    %% Computes all derivatives needed for optimization
        
    % Unpack constants
    Nt = fm.model.Nt;                            % Number of time steps
    dt = fm.model.dt;
    Kp = fm.controller.Kp;        % Proportional gain
    Ki = fm.controller.Ki;          % Integral gain
    Kd = fm.controller.Kd;          % Derivative gain
    n_heaters = fm.controller.n_heaters;

    % A = fm.constants.rad_constant_h_ms + fm.constants.rad_constant_h_w;  % coefficient for T_h^4
    % B = fm.constants.h_h_fA_h;   % coefficient for T_h

    Nx = fm.walls.Nx;
    sigma = fm.heater.sigma;
    VF_h_w = fm.heater.VF_h_w;
    A_w = fm.walls.A;
    h_f_w = fm.furnace.h_f_w;

    for k = 1:Nt-1

        % dP^(k) / dx
        [fm, dP_dx] = Compute_dP_dx(fm, k, Kp, Kd, Ki, dt, n_heaters);
    
        % dT_h^(k+1) / dx
        % [fm, dT_h_dx] = Compute_dT_h_dx(fm, A, B, T_heater(k), T_metal_sheet(k), T_walls(:,:,k), k+1, dt);

        % dT^(k+1) / dx and dT_w^(k+1) / dx
        if strcmpi(fm.discretization_method, 'FVM')
            [fm, dT_dx] = Compute_Monolithic_Sensitivities_FVM(fm, T_heater(k+1), T_walls(:,:,k+1), T_walls(:,:,k), ...
                            k+1, Nx, sigma, VF_h_w, A_w, h_f_w);
        elseif strcmpi(fm.discretization_method, 'FEM')
            [fm, dT_dx] = Compute_Monolithic_Sensitivities_FEM(fm, T_heater(k+1), T_walls(:,:,k+1), T_walls(:,:,k), ...
                            k+1, Nx, sigma, VF_h_w, A_w, h_f_w, dt);
        end
    end
    
    % Sum up the derivatives of P
    fm.derivatives.dP_dx_full = sum(cell2mat(fm.derivatives.dP_dx_series(1:end, :)));
end
