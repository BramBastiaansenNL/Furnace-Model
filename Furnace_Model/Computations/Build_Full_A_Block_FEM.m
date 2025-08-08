function [A_global, dB_dx, M_full] = ...
    Build_Full_A_Block_FEM(fm, k, T_wall_prev, dT_wall_1_prev_dx, sigma, A_w, VF_h_w, Nx, dt)
    %% Builds the full 6*Nx x 6*Nx block-diagonal matrix A at time step k
    
    % Preallocate cell array to hold individual wall matrices
    wall_names = {'side1', 'side2', 'top', 'bottom', 'front', 'back'};
    N_walls = length(wall_names);
    A_global_blocks = cell(N_walls, 1);
    dB_blocks = cell(N_walls, 1);
    M_blocks  = cell(N_walls, 1);

    for i = 1:N_walls
        name = wall_names{i};
        wall = fm.walls.(name);
        epsilon_w = wall.epsilon_w;
        Tw1_old = T_wall_prev(i, 1);
        dTw1_dx = dT_wall_1_prev_dx(i);

        %% Global matrix (A, M and B)
        A = fm.matrices.A{i};
        M = fm.matrices.M{i};
        M_blocks{i} = M;
        B = fm.matrices.B{i};
        B(1,1) = fm.matrices.B_11_series{i}{k};
        A_global_i = M + dt * (A + B);     
        A_global_blocks{i} = A_global_i;

        %% dB/dx
        % Derivative of effective radiation coefficient
        d_eff_rad = 12 * sigma * VF_h_w * epsilon_w * A_w * Tw1_old^2;
        % Construct dB_i_dx as sparse Nx×Nx with only (1,1) entry
        dB_i_dx = sparse(1, 1, d_eff_rad * dTw1_dx, Nx, Nx);
        dB_blocks{i} = dB_i_dx;
    end

    % Construct sparse block-diagonal matrix
    A_global = blkdiag(A_global_blocks{:});  % [6*Nx x 6*Nx]
    dB_dx = blkdiag(dB_blocks{:});  % [6*Nx x 6*Nx]
    M_full = blkdiag(M_blocks{:});  % [6*Nx x 6*Nx]
end
