function [gamma, alpha, beta, b, fm] = Build_Tridiagonal_System(i, wall, T_wall_old, T_furnace, T_heater, ...
                                               A_w, Nx, h_f_w, h_out, T_out, sigma, VF_h_w, k, fm)
    %% Builds the tridagional system resulting from FVM discretization of the heat equation

    % Precomputations and constants
    dx = wall.dx;
    epsilon_w = wall.epsilon_w;
    lambda_eff = wall.lambda_eff;
    heat_capacity = wall.heat_capacity;
    h_rad = sigma * VF_h_w * epsilon_w;

    %% Tridiagonal system
    % Interior nodes
    gamma = wall.gamma;
    alpha = wall.alpha;
    beta = wall.beta;
    b = heat_capacity(1:Nx) .* T_wall_old(1:Nx);

    % Inner boundary (to furnace and heater)
    alpha(1) = heat_capacity(1) + 2 * lambda_eff(1) * A_w / dx + ...
               h_f_w * A_w + ...
               4 * h_rad * A_w * T_wall_old(1)^3;
    b(1)     = heat_capacity(1) * T_wall_old(1) + ...
               h_f_w * A_w * T_furnace + ...
               h_rad * A_w * (T_heater^4 + 3 * T_wall_old(1)^4);

    % Outer boundary (to ambient)
    b(Nx) = heat_capacity(Nx) * T_wall_old(Nx) + h_out * A_w * T_out;

    % Store vectors for derivative purposes
    if fm.settings.store_derivatives
        fm.matrices.alpha_1_series{i}{k} = alpha(1);
        % Copy alpha_1 for side2
        if i == 1
            fm.matrices.alpha_1_series{2}{k} = alpha(1);
        end
    end
end
