function dT_dX = Compute_Spline_T_f_desired_Derivatives(temp_knots, time_knots, t_vec, alpha, t_total, N)
    %% Computes derivative of spline-interpolated temperature profile using finite differences

    Nt = numel(t_vec);
    dT_dT = zeros(Nt, N);         % Derivatives w.r.t. temperature knots
    dT_dalpha = zeros(Nt, N);       % Derivatives w.r.t. alpha
    % dT_dt_total = zeros(Nt, 1);     % Derivatives w.r.t. t_total
    
    % === Derivative w.r.t. T_i (temp_knots): use finite difference ===
    eps_fd = 1e-6;
    for i = 1:N
        dT_i = zeros(size(temp_knots));
        dT_i(i+1) = eps_fd;
        T_plus = ppval(pchip(time_knots, temp_knots + dT_i), t_vec);
        T_minus = ppval(pchip(time_knots, temp_knots - dT_i), t_vec);
        dT_dT(:, i) = (T_plus - T_minus) / (2 * eps_fd);
    end
    
    % === Derivative w.r.t. alpha_i: via time_knots ===
    for j = 1:N
        d_time_knots = zeros(size(time_knots));
        d_time_knots(2:end) = cumsum(1:N == j) * t_total;  % ∂t_i/∂alpha_j
    
        % Construct perturbed time_knots
        eps_fd = 1e-6;
        tk_plus = time_knots + eps_fd * d_time_knots;
        tk_minus = time_knots - eps_fd * d_time_knots;
        T_plus = ppval(pchip(tk_plus, temp_knots), t_vec);
        T_minus = ppval(pchip(tk_minus, temp_knots), t_vec);
        dT_dalpha(:, j) = (T_plus - T_minus) / (2 * eps_fd);
    end
    
    % === Derivative w.r.t. t_total ===
    % time_knots(i) = t_total * sum(alpha(1:i-1))
    dt_dt_total = [0, cumsum(alpha)];
    eps_fd = 1e-6;
    tk_plus = time_knots + eps_fd * dt_dt_total;
    tk_minus = time_knots - eps_fd * dt_dt_total;
    T_plus = ppval(pchip(tk_plus, temp_knots), t_vec);
    T_minus = ppval(pchip(tk_minus, temp_knots), t_vec);
    dT_dt_total = (T_plus - T_minus) / (2 * eps_fd);
    
    % === Assemble full derivative matrix ===
    dT_dX = [dT_dT, dT_dalpha, dT_dt_total(:)];
end
