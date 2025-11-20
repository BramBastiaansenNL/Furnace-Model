function x_proj = Project(x, lb, ub, N, constraints, furnace_model)
    %% Projects x onto the feasible set

    % Extract
    T_f     = x(1:N);
    alpha   = x(N+1:2*N);
    t_total = x(end);

    % Clamp time
    t_total = max(min(t_total, ub(end)), lb(end));

    % Project alphas onto simplex
    alpha = projsplx(alpha);

    % --- Step 1: Heuristic slope projection ---
    T_f_heur = max(min(T_f, ub(1:N)), lb(1:N));   % bounds
    R_heat = constraints.R_heat_max;
    R_cool = constraints.R_cool_max;
    dt = alpha * t_total;

    for i = 1:N-1
        dT = T_f_heur(i+1) - T_f_heur(i);
        max_up   =  R_heat * dt(i);
        max_down = -R_cool * dt(i);
        if dT > max_up
            T_f_heur(i+1) = T_f_heur(i) + max_up;
        elseif dT < max_down
            T_f_heur(i+1) = T_f_heur(i) + max_down;
        end
    end

    % --- Step 2: Check feasibility ---
    feasible = true;
    for i = 1:N-1
        dT = T_f_heur(i+1) - T_f_heur(i);
        if dT > R_heat*dt(i) + 1e-8 || dT < -R_cool*dt(i) - 1e-8
            feasible = false;
            break;
        end
    end

    % --- Step 3: If infeasible, fall back to QP projection ---
    if feasible
        T_f_proj = T_f_heur;
    else
        T_f_proj = Project_QP(T_f, lb(1:N), ub(1:N), alpha, t_total, constraints);
    end

    % Repack
    x_proj = [T_f_proj(:)', alpha(:)', t_total];

    % Step 4: Project into mechanical feasibility region
    x_proj = Project_Mechanical(x_proj, furnace_model, constraints);
end