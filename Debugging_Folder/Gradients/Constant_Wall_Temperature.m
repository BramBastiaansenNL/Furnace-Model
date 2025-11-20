function [T_w_new, fm] = Constant_Wall_Temperature(T_w_old, fm, k)
    %% Updates temperatures for all 6 walls using implicit finite volume method and Thomas algorithm
    
    % Change nothing
    T_w_new = T_w_old;

    % Load scripts
    walls = fm.walls;

    % Constants
    wall_names = {'side1', 'side2', 'top', 'bottom', 'front', 'back'};
    num_walls = length(wall_names);

    % Main update loop
    for i = 1:num_walls
        % Store derivatives after NR convergence
        if fm.settings.symbolic_differentiation %&& fm.settings.NR_converged
                dT_w_dx = zeros(1, walls.Nx);
                fm.derivatives.dT_w_dx_series{k, i} = dT_w_dx;
                fm.derivatives.dT_w1_dx_series{k}(i, :) = dT_w_dx(1);
        end
    end
end