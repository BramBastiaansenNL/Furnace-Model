function [db_dT, db_dTw_prev] = Build_Full_b_vec_Derivatives( ...
            fm, T_wall_prev, T_heater, sigma, A_w, VF_h_w, Nx, h_f_w)
    %% Compute [6*Nx x 4], [6*Nx x 1] sensitivity matrices for b_vec

    wall_names = {'side1', 'side2', 'top', 'bottom', 'front', 'back'};
    N_walls = length(wall_names);

    db_dT_blocks = cell(N_walls, 1);      % each [Nx x 4]
    db_dTw_prev_blocks = cell(N_walls, 1);     % each [Nx x 1]

    for i = 1:N_walls
        % Extract quantities
        name = wall_names{i};
        wall = fm.walls.(name);
        T_w1_prev = T_wall_prev(i, :);                     % [1 x Nx]
        epsilon = wall.epsilon_w;
        heat_capacity = wall.heat_capacity;             % [Nx x 1]
        h_rad = sigma * VF_h_w * epsilon;

        % Derivative w.r.t T_furnace, T_heater, T_wall_prev

        % Interior nodes (2:Nx)
        db_dTw_prev_i = diag(heat_capacity(:)); % [Nx x Nx]
        % First node (boundary with heater/furnace)
        db_dTw_prev_i(1,1) = heat_capacity(1) + 12 * h_rad * A_w * T_w1_prev(1)^3; 
        
        db_dT_i = zeros(Nx, 4);        % [Nx x 4]
        db_dT_i(1, 1) = h_f_w * A_w;  
        db_dT_i(1, 4) = 4 * h_rad * A_w * (T_heater)^3;

        % Store
        db_dT_blocks{i} = db_dT_i;
        db_dTw_prev_blocks{i} = db_dTw_prev_i;
    end

    % Stack into full 6*Nx by ...
    db_dT = sparse(vertcat(db_dT_blocks{:}));                % [6*Nx x 4]
    db_dTw_prev = blkdiag(db_dTw_prev_blocks{:});            % [6*Nx x 6*Nx]
end
