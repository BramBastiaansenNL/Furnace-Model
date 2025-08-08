function [dG_dT, dG_dTh, dG_dTw_prev] = Build_Full_G_vec_Derivatives( ...
            fm, T_wall_prev, T_heater, sigma, A_w, VF_h_w, Nx, h_f_w)
    %% Compute [6*Nx x 3], [6*Nx x 1], [6*Nx x 1] sensitivity matrices for d_vec

    wall_names = {'side1', 'side2', 'top', 'bottom', 'front', 'back'};
    N_walls = length(wall_names);

    dG_dT_blocks = cell(N_walls, 1);      % each [Nx x 3]
    dG_dTh_blocks = cell(N_walls, 1);     % each [Nx x 1]
    dG_dTw_prev_blocks = cell(N_walls, 1);     % each [Nx x 1]

    for i = 1:N_walls
        % Extract quantities
        name = wall_names{i};
        wall = fm.walls.(name);
        T_w1 = T_wall_prev(i, :);                     % [1 x Nx]
        epsilon = wall.epsilon_w;
        eff_rad = 4 * sigma * VF_h_w * epsilon * A_w * T_w1(1)^3;
        d_eff_rad = 12 * sigma * VF_h_w * epsilon * A_w * T_w1(1)^2;

        % Derivative w.r.t T_furnace, T_heater, T_wall_prev
        dG_dT_i = zeros(Nx, 3);        % [Nx x 3]
        dG_dTh_i = zeros(Nx, 1);       % [Nx x 1]
        dG_dTw_prev_i = zeros(Nx, Nx); % [Nx x Nx]

        % First node (boundary with heater/furnace)
        dG_dTw_prev_i(1,1) = d_eff_rad * T_heater;
        dG_dT_i(1, 1) = h_f_w * A_w;  
        dG_dTh_i(1)   = eff_rad;      

        % Store
        dG_dT_blocks{i} = dG_dT_i;
        dG_dTh_blocks{i} = dG_dTh_i;
        dG_dTw_prev_blocks{i} = dG_dTw_prev_i;
    end

    % Stack into full 6*Nx by ...
    dG_dT = sparse(vertcat(dG_dT_blocks{:}));                % [6*Nx x 3]
    dG_dTh = sparse(vertcat(dG_dTh_blocks{:}));              % [6*Nx x 1]
    dG_dTw_prev = blkdiag(dG_dTw_prev_blocks{:});    % [6*Nx x 6*Nx]
end
