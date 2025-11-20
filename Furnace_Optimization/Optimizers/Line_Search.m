function x_new = Line_Search(x, d, J_current, grad, furnace_model, constraints, N, lb, ub)
    %% Backtracking line search with projection onto bounds + simplex

    step_size = 1.0;
    beta      = 0.5;      % shrink factor
    c         = 1e-4;     % sufficient decrease factor

    while true
        % Project onto bounds
        x_trial = Project(x + step_size * d, lb, ub, N, constraints);

        % Evaluate cost
        J_trial = Compute_Cost_Function(x_trial, furnace_model, constraints, N);

        % Armijo condition
        if J_trial <= J_current + c * step_size * (grad' * d)
            x_new = x_trial;
            return;
        end

        % Reduce step
        step_size = beta * step_size;
        if step_size < 1e-6
            x_new = x; % fallback: no progress
            return;
        end
    end
end