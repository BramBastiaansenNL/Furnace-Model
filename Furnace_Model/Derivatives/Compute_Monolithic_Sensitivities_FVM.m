function [fm, dT_dx] = Compute_Monolithic_Sensitivities_FVM(fm, T_heater, T_wall, T_wall_prev, ...
                       k, Nx, sigma, VF_h_w, A_w, h_f_w)
    %% Solves for dT/dx and dTw/dx using a joint monolithic system
    
    % Flatten wall temperature matrix to column vector
    d = 4;  % Furnace state dimension
    N = fm.model.N;
    
    %% Retrieve stored derivatives
    dF_dT         = fm.derivatives.dF_dT_series{k};            % [4×4]
    dF_dT_prev    = fm.derivatives.dF_dT_prev;                 % [4x4] (but actually just -I = -1)
    dF_dP_prev    = fm.derivatives.dF_dP_prev;                 % [4×1]
    dF_dT_w1      = fm.derivatives.dF_dT_w1_series{k};         % [4×6]
    dF_dT_w1_prev = fm.derivatives.dF_dT_w1_prev_series{k};    % [4×6]

    dT_dx_prev    = fm.derivatives.dT_dx_series{k-1};       % [4 x 2N+1]
    dT_w1_dx_prev = fm.derivatives.dT_w1_dx_series{k-1};    % [6 x 2N+1]
    dP_dx_prev    = fm.derivatives.dP_dx_series{k-1};       % [1 x 2N+1]

    % Flatten wall sensitivities into one vector: [6*Nx × 2N+1]
    dT_w_dx_prev_vec = zeros(6*Nx, 2*N+1);
    for i_wall = 1:6
        idx_start = (i_wall - 1)*Nx + 1;
        idx_end   = i_wall * Nx;
        dT_w_dx_prev_vec(idx_start:idx_end, :) = fm.derivatives.dT_w_dx_series{k-1, i_wall};
    end
    
    %% Build derivatives and wall system matrix. [6*N_x×4], [6*N_x×1], [6*N_x×6*N_x]
    [db_dT, db_dTw_prev] = Build_Full_b_vec_Derivatives( ...
        fm, T_wall_prev, T_heater, sigma, A_w, VF_h_w, Nx, h_f_w);
    
    % [6*N_x×6*N_x] 
    [A, dA_dx_T] = ...                                                
        Build_Full_A_Block_FVM(fm, k, T_wall, T_wall_prev, dT_w1_dx_prev, sigma, A_w, VF_h_w, Nx);
    
    %% Construct Jacobian
    % Top-left: dR/dT (4×4)
    J11 = dF_dT;
    
    % Top-right: dR/dTw1 — only first node of each wall matters
    rows = repmat((1:d)', 6, 1);                     % [1; 2; ...; d] repeated 6 times
    cols = kron((0:5)*Nx + 1, ones(d,1));            % inject into columns 1, Nx+1, ..., 5*Nx+1
    vals = reshape(dF_dT_w1, [], 1);                 % all columns stacked vertically
    J12 = sparse(rows, cols, vals, d, 6*Nx);
    
    % Bottom-left: -A^{-1} * dd/dT
    J21 = - (A \ db_dT);  % (6*N_x × 4)
    J21 = sparse(J21);
    
    % Bottom-right: Identity
    J22 = speye(6*Nx);
    
    % Full Jacobian
    J = [J11, J12;
         J21, J22];
    
    %% Construct RHS
    % Top part: furnace sensitivity residual
    R1 = - (dF_dT_prev * dT_dx_prev + dF_dT_w1_prev * dT_w1_dx_prev + dF_dP_prev * dP_dx_prev);  % (4 × 2N+1)
    
    % Bottom part: wall sensitivity RHS
    R2 = A \ (db_dTw_prev * dT_w_dx_prev_vec - dA_dx_T);  % (6*N_x × 2N+1) 
    
    % Full RHS
    RHS = [R1; R2];
    
    %% Solve system and Extract sensitivities
    dz = J \ RHS;                  % (4+6*N_x x 2N+1)
    dT_dx  = dz(1:d, :);           % (4 × 2N+1)
    dT_w_dx = dz(d+1:end, :);      % (6*N_x 2N+1)

    %% Store derivatives
    for i_wall = 1:6
        idx_start = (i_wall - 1) * Nx + 1;
        idx_end   = i_wall * Nx;
        dT_w_dx_i = dT_w_dx(idx_start:idx_end, :);

        % Store each wall's full derivative
        fm.derivatives.dT_w_dx_series{k, i_wall} = dT_w_dx_i;
    
        % Also store the boundary node derivative (1st node) of each wall
        fm.derivatives.dT_w1_dx_series{k}(i_wall, :) = dT_w_dx_i(1, :);
    end
    
    % Compute and store temperature sensitivity
    dT_alloy_dx = fm.derivatives.dT_alloy_dT * dT_dx;
    fm.derivatives.dT_dx_series{k} = dT_dx;
    fm.derivatives.dT_alloy_dx_series{k} = dT_alloy_dx;
end
