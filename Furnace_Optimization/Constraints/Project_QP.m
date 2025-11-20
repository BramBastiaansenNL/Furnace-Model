function T_f_proj = Project_QP(T_f_trial, lb, ub, alpha, t_total, constraints, N)
    %% Project the temperature onto the feasible set by solving a quadratic minimization problem

    % Objective
    H = 2*eye(N);
    f = -2*T_f_trial(:);

    % Slope constraints
    R_heat = constraints.R_heat_max;   % K/s
    R_cool = constraints.R_cool_max;   % K/s
    dt = alpha * t_total;

    A = zeros(2*(N-1), N);
    b = zeros(2*(N-1), 1);

    for i = 1:N-1
        % Heating: T(i+1) - T(i) <= r_heat * dt(i)
        A(2*i-1, i)   = -1;
        A(2*i-1, i+1) =  1;
        b(2*i-1)      =  R_heat * dt(i);

        % Cooling: T(i) - T(i+1) <= r_cool * dt(i)
        A(2*i, i)   =  1;
        A(2*i, i+1) = -1;
        b(2*i)      =  R_cool * dt(i);
    end

    % QP solve
    options = optimoptions('quadprog', 'Display', 'off');
    [T_f_proj, ~, exitflag] = quadprog(H, f, A, b, [], [], lb(:), ub(:), [], options);

    if exitflag <= 0
        warning('quadprog did not converge, falling back to trial T_f');
        T_f_proj = max(min(T_f_trial, ub), lb);
    end
end
