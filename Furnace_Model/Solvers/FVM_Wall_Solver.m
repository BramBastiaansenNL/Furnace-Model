function [T_w_new, fm] = FVM_Wall_Solver(T_w_old, T_furnace, T_heater, fm, k)
    %% Updates temperatures for all 6 walls using implicit finite volume method and Thomas algorithm
    
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

    % Main update loop
    for i = 1:num_walls
        name = wall_names{i};
        wall = walls.(name);

        if strcmp(name, 'side2') && isequal(T_w_old(1, :), T_w_old(2, :))
            T_w_new(i, :) = T_w_side1;
            continue
        end

        % Grab previous temperature of wall i
        T_wall_old = T_w_old(i, :);
        [gamma, alpha, beta, b, fm] = Build_Tridiagonal_System(i, wall, T_wall_old, T_furnace, T_heater, ...
                                              A_w, Nx, h_f_w, h_out, T_out, sigma, VF_h_w, k, fm);

        % Solve and Store updated wall temperature
        T_wall_new = Thomas_Solver(gamma, alpha, beta, b);
        T_w_new(i, :) = T_wall_new';

        % Cache side1's result for reuse in side2
        if strcmp(name, 'side1')
            T_w_side1 = T_w_new(i, :);
        end
    end
end