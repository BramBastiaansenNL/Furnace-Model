function [A_full, dA_dx_T] = ...
    Build_Full_A_Block_FVM(fm, k, T_wall, T_wall_prev, dT_wall_1_prev_dx, sigma, A_w, VF_h_w, Nx)
    %% Builds the full 6*Nx x 6*Nx block-diagonal matrix A at time step k
    
    % Preallocate cell array to hold individual wall matrices
    wall_names = {'side1', 'side2', 'top', 'bottom', 'front', 'back'};
    N_walls = length(wall_names);
    N = fm.model.N;
    A_blocks = cell(N_walls, 1);
    dA_dx_T = zeros(6*Nx, 2*N+1);

    for i = 1:N_walls
        name = wall_names{i};
        wall = fm.walls.(name);
        epsilon = wall.epsilon_w;
        Tw1_old = T_wall_prev(i, 1);
        dTw1_old_dx = dT_wall_1_prev_dx(i, :);

        %% A
        A_i = fm.matrices.A_template{i};     % Get template [Nx x Nx]
        alpha_1  = fm.matrices.alpha_1_series{i}{k};   % Get time-varying b(1)
        A_i(1,1) = alpha_1;   % Overwrite (1,1) entry in A_i to reflect correct diagonal value
        A_blocks{i} = A_i;

        %% dA/dx * T_wall
        % Derivative of effective radiation coefficient
        d_alpha_1_dx = 12 * sigma * VF_h_w * epsilon * A_w * Tw1_old^2 * dTw1_old_dx;

        % Construct dA_i_dx as sparse Nx×Nx with only (1,1) entry
        for j = 1:2*N+1
            idx = (i-1)*Nx + 1;
            dA_dx_T(idx, j) = d_alpha_1_dx(j) * T_wall(idx);  % (∂A/∂x_j) * T_w
        end
    end

    % Construct sparse block-diagonal matrix
    A_full = blkdiag(A_blocks{:});  % [6*Nx x 6*Nx]
end
