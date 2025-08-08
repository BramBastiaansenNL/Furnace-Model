function fm = Compute_dT_w_dx(fm, Nx, sigma, VF_h_w, A_w, T_w_new, T_w_old, ...
                              h_f_w, h_out, T_heater, k, iter)
    %% Compute the derivative of the wall temperature w.r.t. x (OUTDATED)

    % Compute dT_w/dx per wall
    wall_names = {'side1', 'side2', 'top', 'bottom', 'front', 'back'};
    for i = 1:6
        name = wall_names{i};
        wall = fm.walls.(name);
        dx = wall.dx;
        epsilon_w = wall.epsilon_w;
        lambda_eff = wall.lambda_eff;
        heat_capacity = wall.heat_capacity;

        T_wall_old = T_w_old(i, :);
        T_wall_new = T_w_new(i, :);
        Tw1_old = T_wall_old(1);
        h_rad   = sigma * VF_h_w * epsilon_w;

        %% Construct tridiagonal matrix
        alpha = heat_capacity + ([lambda_eff(1:end), 0] + [0, lambda_eff(1:end)]) * A_w / dx;
        gamma = -lambda_eff(1:Nx-1) * A_w / dx;
        beta = -lambda_eff(1:Nx-1) * A_w / dx;
        % alpha = wall.alpha;
        % gamma = wall.gamma;
        % beta = wall.beta;

        % Fix boundaries
        alpha(1)   = heat_capacity(1) +  lambda_eff(1) * A_w / dx + h_f_w * A_w + 4 * h_rad * A_w * Tw1_old^3;
        alpha(end) = heat_capacity(end) +  lambda_eff(end) * A_w / dx + h_out * A_w;
        % alpha(1)   = heat_capacity(1) + 2 * lambda_eff(1) * A_w / dx + h_f_w * A_w + 4 * h_rad * A_w * Tw1_old^3;
        % alpha(end) = heat_capacity(end) + 2 * lambda_eff(end) * A_w / dx + h_out * A_w;
        
        %% First iteration: use guess from previous time steps
        if iter == 1
            if k >= 3
                guess = 2 * fm.derivatives.dT_w_dx_series{k-1, i} - fm.derivatives.dT_w_dx_series{k-2, i};
            else
                guess = fm.derivatives.dT_w_dx_series{k-1, i};
            end
            fm.derivatives.dT_w_dx_series{k, i} = guess;
            fm.derivatives.dT_w1_dx_series{k}(i) = guess(1);
            continue
        end

        %% Later iterations: compute full dT/dx using chain rule + Thomas solver
        dT_w_old_dx = fm.derivatives.dT_w_dx_series{k-1, i};
        dT_f_dx     = fm.derivatives.dT_dx_series{k}(1);
        dT_h_dx     = fm.derivatives.dT_h_dx_series{k};

        % RHS: d(d)/dx
        db_dx = zeros(Nx, 1);
        db_dx(2:Nx) = heat_capacity(2:Nx)' .* dT_w_old_dx(2:Nx);
        db_dx(1) = ...
            heat_capacity(1) * dT_w_old_dx(1) + ...
            h_f_w * A_w * dT_f_dx + ...
            4 * h_rad * A_w * Tw1_old^3 * dT_h_dx + ...
            12 * h_rad * A_w * Tw1_old^2 * dT_w_old_dx(1) * T_heater;
        % db_dx(1) = ...
        %     heat_capacity(1) * dT_w_old_dx(1) + ...
        %     h_f_w * A_w * dT_f_dx + ...
        %     4 * h_rad * A_w * T_heater^3 * dT_h_dx + ...
        %     12 * h_rad * A_w * Tw1_old^3 * dT_w_old_dx(1);

        % Derivative of A only at (1,1)
        dA_dx = zeros(Nx, 1);
        dA_dx(1) = 12 * h_rad * A_w * Tw1_old^2 * dT_w_old_dx(1);
        
        % -A^{-1} * (dA/dx * T_w) + A^{-1} * dd/dx
        % rhs = - dA_dx .* T_wall_new' + db_dx;

        % gA = -A^{-1} * (dA/dx * T_w1)
        gA = Thomas_Solver(gamma, alpha, beta, -dA_dx .* T_wall_new');
        % gB = A^{-1} * (db_dx)
        gB = Thomas_Solver(gamma, alpha, beta, db_dx);

        % Split B into components for debugging/tracing
        gB_parts = {
            Thomas_Solver(gamma, alpha, beta, [heat_capacity(1) * dT_w_old_dx(1); zeros(Nx-1,1)]), ...
            Thomas_Solver(gamma, alpha, beta, [h_f_w * A_w * dT_f_dx; zeros(Nx-1,1)]), ...
            Thomas_Solver(gamma, alpha, beta, [4 * h_rad * A_w * Tw1_old^3 * dT_h_dx; zeros(Nx-1,1)]), ...
            Thomas_Solver(gamma, alpha, beta, [12 * h_rad * A_w * Tw1_old^2 * dT_w_old_dx(1) * T_heater; zeros(Nx-1,1)])
        };
            
        dT_w_dx = gA + gB;
        
        % Store derivatives
        fm.derivatives.dT_w_dx_series{k, i} = dT_w_dx;
        fm.derivatives.dT_w1_dx_series{k}(i) = dT_w_dx(1);
        fm.derivatives.gA_series{k}(i) = gA(1); 
        fm.derivatives.gB1_series{k}(i) = gB_parts{1}(1);
        fm.derivatives.gB2_series{k}(i) = gB_parts{2}(1);
        fm.derivatives.gB3_series{k}(i) = gB_parts{3}(1);
        fm.derivatives.gB4_series{k}(i) = gB_parts{4}(1);
    end
end