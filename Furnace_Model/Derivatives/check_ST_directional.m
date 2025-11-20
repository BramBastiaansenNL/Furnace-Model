function rel_err = check_ST_directional(t, T_m, u, par_model, beta)
    % Forward run (baseline)
    X0 = Calc_Phases_from_t_T(t, T_m).X;          % [Nx x Nt]
    S_T = Compute_Sensitivity_Tm(t, T_m, X0, u, par_model, beta);  % [Nx x Nt]

    Nt = numel(T_m);
    Nx = size(X0,1);

    % random direction in temperature space
    v = randn(Nt,1); v = v / norm(v);

    % analytic directional derivative of terminal state
    dir_an = S_T * v;                              % [Nx x 1]

    % finite-difference directional derivative
    h = 1e-10 * max(1, norm(T_m, inf));            % step in K (scale as needed)
    Xp = Calc_Phases_from_t_T(t, T_m + h*v').X;
    Xm = Calc_Phases_from_t_T(t, T_m - h*v').X;
    dir_fd = (Xp(:,end) - Xm(:,end)) / (2*h);     % [Nx x 1]

    [dir_an, dir_fd]

    rel_err = norm(dir_an - dir_fd) / max(1, norm(dir_an));
    fprintf('Directional check: rel. error = %.3e\n', rel_err);
end