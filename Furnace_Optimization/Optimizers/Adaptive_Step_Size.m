function [x_new, lambda_new, theta_new] = ...
    Adaptive_Step_Size(x, grad, x_prev, grad_prev, lambda_prev, theta_prev, lb, ub, N, constraints, furnace_model)
    %% Adaptive Step Size for Gradient Descent without Descent

    % ---- Rule 1: growth cap  λ_k ≤ √(1+θ_{k-1}) * λ_{k-1}  (Alg. 1, step 4)
    if isinf(theta_prev)              % first usable step: ignore this cap
        cand1 = inf;
    else
        cand1 = sqrt(1 + theta_prev) * lambda_prev;
    end

    % ---- Rule 2: local curvature cap  λ_k ≤ ||Δx|| / (2||Δg||)  (Alg. 1, step 4)
    if ~isempty(x_prev) && ~isempty(grad_prev)
        dx = norm(x - x_prev);
        dg = norm(grad - grad_prev);
        if dg > 0
            cand2 = dx / (2*dg);
        else
            cand2 = inf;             % identical gradients → no curvature info
        end
    else
        cand2 = inf;                 % first iteration after x1
    end

    % ---- Pick stepsize
    lambda_new = min(cand1, cand2);
    if ~isfinite(lambda_new) || lambda_new <= 0
        % Fallback: keep previous λ (or choose a small safe default)
        lambda_new = max(lambda_prev, 1e-8);
    end

    % ---- Gradient step + projection
    x_tent = x - lambda_new * grad;
    x_new = Project(x_tent, lb, ub, N, constraints, furnace_model);

    % ---- θ update (Alg. 1, step 6)
    if lambda_prev > 0
        theta_new = lambda_new / lambda_prev;
    else
        theta_new = inf;             % matches the paper’s convention
    end
end
