function [T_f_new, T_a_new, T_w_new, T_ms_new, T_h_new, iterations, fm] = ...
    Newton_Raphson_Iteration(T_f_old, T_a_old, T_w_old, T_ms_old, T_h_old, fm, Q_power, k, varargin)
    %% Newton-Raphson solver for implicit furnace, alloy, metal sheet and wall temperature update
    
    % If debugging is enabled, call debugging version and return
    if fm.settings.debugging || fm.settings.debug_jacobian || fm.settings.dynamic_residual_plotting
        [T_f_new, T_a_new, T_w_new, T_ms_new, T_h_new, iterations, fm] = ...
            Solve_Newton_Raphson_Debugging(T_f_old, T_a_old, T_w_old, T_ms_old, T_h_old, fm, Q_power, k, varargin{:});
        return;
    end

    % Extract older temperature history if available
    if ~isempty(varargin)
        T_f_older = varargin{1};
        T_a_older = varargin{2};
        T_w_older = varargin{3};
        T_ms_older = varargin{4};
        T_h_older = varargin{5};
    end

    % Parameters    
    model = fm.model;
    dt = model.dt;                  % Time-steps           
    max_iter = 100;                 % Maximum iterations for Newton-Raphson
    tol = 1e-4;                     % Convergence tolerance
    fm.settings.NR_converged = false;  % Reset convergence flag
    residual_norms = zeros(max_iter, 1); % Initialize residual storage

    % Initial guesses
    if nargin < 10
        [T_f, T_a, T_w, T_ms, T_h] = Compute_Initial_Guesses(T_f_old, T_a_old, T_w_old, T_ms_old, T_h_old);
    else
        [T_f, T_a, T_w, T_ms, T_h] = Compute_Initial_Guesses(T_f_old, T_a_old, T_w_old, T_ms_old, T_h_old, ...
                                                             T_f_older, T_a_older, T_w_older, T_ms_older, T_h_older);
    end

    % Newton-Raphson Iteration
    for iter = 1:max_iter
        [T_f, T_a, T_w, T_ms, T_h, dT, dT_w, fm] = Solve_Newton_Raphson_Iteration( ...
            T_f, T_a, T_w, T_ms, T_h, T_f_old, T_a_old, T_w_old, T_ms_old, T_h_old, ...
            Q_power, dt, fm, k);

        % Store residual norm and Check convergence
        residual_norms(iter) = norm(dT);
        converged = Check_Convergence(residual_norms(iter), dT_w, tol);
        if converged
            fm.settings.NR_converged = true;
            break
        end
    end
    
    % Return updated temperatures
    T_f_new    = T_f;
    T_a_new    = T_a;
    T_w_new    = T_w;
    T_ms_new   = T_ms;
    T_h_new    = T_h;
    iterations = iter;
end
