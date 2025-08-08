function [T_w_new, fm] = FEM_Wall_Solver(T_w_old, T_furnace, T_heater, fm, k)
    %% Implicit FEM update for all 6 walls (1D transient heat conduction)
    
    % Load scripts
    walls = fm.walls;
    furnace = fm.furnace;
    heater = fm.heater;

    % Number of walls and nodes
    wall_names = {'side1', 'side2', 'top', 'bottom', 'front', 'back'};
    num_walls = length(wall_names);
    Nx = walls.Nx;
    
    % Preallocate
    T_w_new = zeros(num_walls, Nx);
    T_w_side1 = [];

    % Common parameters
    A_w = walls.A;               % Control area (cross-sectional)
    h_f_w = furnace.h_f_w;       % Convective heat transfer coefficient between furnace and wall
    h_out = walls.h_out;         % Convective heat transfer coefficient between wall surface and outside
    T_out = walls.T_out;         % External (ambient) temperature
    sigma = heater.sigma;        % Stefan-Boltzmann constant for radiation
    VF_h_w = heater.VF_h_w;      % View factor from heater to wall
    dt    = fm.model.dt;         % Time-step-size
    
    for i = 1:num_walls
        name = wall_names{i};
        wall = walls.(name);

        if strcmp(name, 'side2') && isequal(T_w_old(1, :), T_w_old(2, :))
            T_w_new(i, :) = T_w_side1;
            continue
        end

        % Grab previous temperature of wall i
        T_wall_old = T_w_old(i, :);
        epsilon_w  = wall.epsilon_w;
        h_rad      = sigma * VF_h_w * epsilon_w; % effective radiation
        
        % Mass matrix and stiffness matrix
        M = fm.matrices.M{i};
        A = fm.matrices.A{i};

        % Boundary stiffness contributions
        B = fm.matrices.B{i};
        B(1,1)   = h_f_w * A_w + 4 * h_rad * A_w * T_wall_old(1)^3;
        B(Nx,Nx) = h_out * A_w;
        
        % Boundary load vector G depends on T_in and T_out
        G        = zeros(Nx,1);
        G(1)     = h_f_w * A_w * T_furnace + ...
                   h_rad * A_w * (T_heater^4 + 3 * T_wall_old(1)^4);
        G(end)   = h_out * A_w * T_out;

        % Global system matrix (constant in time)
        Global_Matrix = M + dt * (A + sparse(B));
        
        % RHS: (1/dt * M * T_old) + G
        rhs = M * T_wall_old' + dt * G;
        
        % Solve linear system
        T_wall_new = Global_Matrix \ rhs;
        T_w_new(i,:) = T_wall_new';

        % Cache side1's result for reuse in side2
        if strcmp(name, 'side1')
            T_w_side1 = T_w_new(i, :);
        end

        % Store vectors for derivative purposes
        if fm.settings.store_derivatives
            fm.matrices.B_11_series{i}{k} = B(1,1);
            % Copy h_rad_1 for side2
            if i == 1
                fm.matrices.B_11_series{2}{k} = B(1,1);
            end
        end
    end
end
