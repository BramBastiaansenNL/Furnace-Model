function x_proj = Project_Mechanical(x, furnace_model, constraints)
    %% Projects x onto the feasible mechanical set by solving a QP.

    % Extract
    N = furnace_model.model.N;
    T_f = x(1:N);
    alpha = x(N+1:2*N);
    t_total = x(end);

    % Evaluate current mechanical properties
    [cached_result] = Get_Or_Run_Simulation(x, furnace_model);
    M = cached_result.mechanical_properties;
    YS = M.YS(end);
    UTS = M.UTS(end);
    UE = M.UE(end);

    % Check feasibility
    feasible = (YS >= constraints.YS_min - 1e-6) && ...
               (UTS >= constraints.UTS_min - 1e-6) && ...
               (UE >= constraints.UE_min - 1e-6);

    if feasible
        x_proj = x;
        return;
    end

    % Otherwise, project using linearized QP
    grad_mech = Compute_Mechanical_Gradients(T_f, t_total, alpha, furnace_model);
    % grads: struct with .sigma_y, .sigma_u, .epsilon_u as row vectors

    % --- Build QP ---
    A = [-grad_mech.YS;        % σ_y >= σ_y_min
         -grad_mech.UTS;       % σ_u >= σ_u_min
         -grad_mech.UE];       % ε_u >= ε_u_min

    b = [YS  - constraints.YS_min;
         UTS - constraints.UTS_min;
         UE  - constraints.UE_min];

    H = eye(length(x)); 
    f = zeros(length(x),1);
    options = optimoptions('quadprog','Display','off','Algorithm','interior-point-convex');

    [delta,~,exitflag] = quadprog(H,f,A,b,[],[],[],[],[],options);

    if exitflag <= 0
        % fallback to direct fmincon repair if QP fails
        x_proj = Repair_Mechanical_Fmincon(x, furnace_model, constraints);
    else
        x_proj = x + delta';
    end

    % Optional debug print
    new_result = Get_Or_Run_Simulation(x_proj, furnace_model);
    M2 = new_result.mechanical_properties;
    fprintf('Mechanical proj: [YS %.2f→%.2f | UTS %.2f→%.2f | UE %.2f→%.2f]\n', ...
        YS, M2.YS(end), UTS, M2.UTS(end), UE, M2.UE(end));
end
