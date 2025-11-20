function grad_mech = Compute_Mechanical_Gradients(T_f, t_total, alpha, furnace_model)
    %% Compute numerical gradients of mechanical properties wrt [T_f, alpha, t_total]

    N = furnace_model.model.N;
    x = [T_f, alpha, t_total];
    n_vars = length(x);
    grad_Y  = zeros(1, n_vars);
    grad_U  = zeros(1, n_vars);
    grad_E  = zeros(1, n_vars);

    % Baseline
    base_result = Get_Or_Run_Simulation(x, furnace_model);
    base = base_result.mechanical_properties;
    Y0  = base.YS(end);
    U0  = base.UTS(end);
    E0  = base.UE(end);

    % Step size rule (relative perturbation)
    rel_step = 1e-4;
    abs_step_min = 1e-6;

    for i = 1:n_vars
        dx = zeros(n_vars,1)';
        step = rel_step * abs(x(i)) + abs_step_min;
        dx(i) = step;

        x_fwd = x + dx;
        x_bwd = x - dx;

        % Evaluate forward and backward
        M_fwd = Get_Or_Run_Simulation(x_fwd, furnace_model).mechanical_properties;
        M_bwd = Get_Or_Run_Simulation(x_bwd, furnace_model).mechanical_properties;

        % Central difference
        grad_Y(i) = (M_fwd.YS(end)  - M_bwd.YS(end))  / (2*step);
        grad_U(i) = (M_fwd.UTS(end) - M_bwd.UTS(end)) / (2*step);
        grad_E(i) = (M_fwd.UE(end)  - M_bwd.UE(end))  / (2*step);
    end

    grad_mech.YS  = grad_Y;
    grad_mech.UTS = grad_U;
    grad_mech.UE  = grad_E;
end
