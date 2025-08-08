function [fm, dT_dx] = Compute_Monolithic_Sensitivities_FEM(fm, T_heater, T_wall, T_wall_prev, ...
                       k, Nx, sigma, VF_h_w, A_w, h_f_w, dt)
    %% Solves for dT/dx and dTw/dx using a joint monolithic system for FEM
    
    % Flatten wall temperature matrix to column vector
    d = 3;  % Furnace state dimension
    T_w_vec      = reshape(T_wall.', [], 1);                % [6*N_x×1]
    
    %% Retrieve stored derivatives
    dR_dT      = fm.derivatives.dR_dT_series{k};            % [3×3]
    dR_dT_prev = fm.derivatives.dR_dT_prev;                 % [3x3] (but actually just -I = -1)
    dR_dT_h    = fm.derivatives.dR_dT_h_series{k};          % [3×1]
    dR_dT_w1   = fm.derivatives.dR_dT_w1_series{k};         % [3×6]

    dT_dx_prev    = fm.derivatives.dT_dx_series{k-1};       % [3x1]
    dT_h_dx       = fm.derivatives.dT_h_dx_series{k};       % [1x1]
    dT_w1_dx_prev = fm.derivatives.dT_w1_dx_series{k-1};    % [6x1]

    % Flatten wall sensitivities into one vector: [6*Nx × 1]
    dT_w_dx_prev_vec = zeros(6*Nx, 1);
    for i_wall = 1:6
        idx_start = (i_wall - 1)*Nx + 1;
        idx_end   = i_wall * Nx;
        dT_w_dx_prev_vec(idx_start:idx_end) = fm.derivatives.dT_w_dx_series{k-1, i_wall};
    end
    
    %% Build derivatives and wall system matrix. [6*N_x×3], [6*N_x×1], [6*N_x×6*N_x]
    [dG_dT, dG_dTh, dG_dTw_prev] = Build_Full_G_vec_Derivatives( ...
        fm, T_wall_prev, T_heater, sigma, A_w, VF_h_w, Nx, h_f_w);
    
    % [6*N_x×6*N_x] 
    [A_global, dB_dx, M] = ...                                                
        Build_Full_A_Block_FEM(fm, k, T_wall_prev, dT_w1_dx_prev, sigma, A_w, VF_h_w, Nx, dt);
    
    %% Construct Jacobian
    % Top-left: dR/dT (3×3)
    J11 = dR_dT;
    
    % Top-right: dR/dTw1 — only first node of each wall matters
    rows = repmat((1:d)', 6, 1);                     % [1; 2; ...; d] repeated 6 times
    cols = kron((0:5)*Nx + 1, ones(d,1));            % inject into columns 1, Nx+1, ..., 5*Nx+1
    vals = reshape(dR_dT_w1, [], 1);                 % all columns stacked vertically
    J12 = sparse(rows, cols, vals, d, 6*Nx);
    
    % Bottom-left: -A^{-1} * dd/dT
    J21 = - dt * (A_global \ dG_dT);  % (6*N_x × 3)
    J21 = sparse(J21);
    
    % Bottom-right: Identity
    J22 = speye(6*Nx);
    
    % Full Jacobian
    J = [J11, J12;
         J21, J22];
    
    %% Construct RHS
    % Top part: furnace sensitivity residual
    R1 = - (dR_dT_prev * dT_dx_prev + dR_dT_h * dT_h_dx);  % (3 × 1)
    
    % Bottom part: wall sensitivity RHS
    R2 = A_global \ (dt * dG_dTh * dT_h_dx + (M + dt * dG_dTw_prev) * dT_w_dx_prev_vec ...
              - dB_dx * T_w_vec);                          % (6*N_x × 1)
    
    % Full RHS
    RHS = [R1; R2];
    
    %% Solve system and Extract sensitivities
    dz = J \ RHS;                  % (3 + 6*N_x)
    dT_dx  = dz(1:d, :);           % (3 × 1)
    dT_w_dx = dz(d+1:end, :);      % (6*N_x × 1)

    %% Store derivatives
    for i_wall = 1:6
        idx_start = (i_wall - 1) * Nx + 1;
        idx_end   = i_wall * Nx;
        dT_w_dx_i = dT_w_dx(idx_start:idx_end);

        % Store each wall's full derivative
        fm.derivatives.dT_w_dx_series{k, i_wall} = dT_w_dx_i;
    
        % Also store the boundary node derivative (1st node) of each wall
        fm.derivatives.dT_w1_dx_series{k}(i_wall) = dT_w_dx_i(1);
    end
    
    % Compute and store temperature sensitivity
    dT_alloy_dx = fm.derivatives.dT_alloy_dT * dT_dx;
    fm.derivatives.dT_dx_series{k} = dT_dx;
    fm.derivatives.dT_alloy_dx_series{k} = dT_alloy_dx;
end
