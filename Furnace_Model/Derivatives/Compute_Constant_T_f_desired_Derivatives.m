function dT_dX = ...
    Compute_Constant_T_f_desired_Derivatives(time_knots, t_vec, N)
    %% Computes derivative of stepwise constant temperature profile with respect to x


    Nt = numel(t_vec);
    dT_dX = zeros(Nt, 2*N + 1);  % Columns: [T_1..T_N, alpha_1..alpha_N, t_total]
    
    % Find active segment index for each time point
    idx = arrayfun(@(u) find(time_knots <= u, 1, 'last'), t_vec);  % idx in 1..N
    
    % Derivative w.r.t. T_i: 1 only for the active segment
    for k = 1:Nt
        seg = idx(k);
        dT_dX(k, seg) = 1;  % dT/dT_i
    end
end
