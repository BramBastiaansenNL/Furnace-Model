function [T_f_new, T_a_new, T_w_new, T_ms_new, T_h_new, iterations] = ...
    Solve_Newton_Raphson_4(T_f_old, T_a_old, T_w_old, T_ms_old, T_h_old, fm, Q_power, varargin)
    %% (Four equation-residual-system) Newton-Raphson solver for implicit furnace, 
    % alloy, metal sheet and wall temperature update

    % Extract older temperature history if available
    if ~isempty(varargin)
        T_f_older = varargin{1};
        T_a_older = varargin{2};
        T_ms_older = varargin{3};
        T_h_older = varargin{4};
    end
    
    % Parameters    
    model = fm.model;
    dt = model.dt;                  % Time-steps           
    max_iter = 100;                 % Maximum iterations for Newton-Raphson
    tol = 1e-4;                     % Convergence tolerance
    
    % Precompute constants (for efficiency)
    [m_fCp_f, m_aCp_a, m_msCp_ms, m_hCp_h, rad_constant_h_ms, rad_constant_h_w, h_f_aA_a, h_f_wA_w, h_ms_fA_w, h_h_fA_f] = ...
        Precompute_Constants(fm);

    % Initial guesses
    if nargin < 10
        [T_f, T_a, T_w, T_ms, T_h] = Compute_Initial_Guesses(T_f_old, T_a_old, T_w_old, T_ms_old, T_h_old);
    else
        [T_f, T_a, T_w, T_ms, T_h] = Compute_Initial_Guesses(T_f_old, T_a_old, T_w_old, T_ms_old, T_h_old, ...
                                                             T_f_older, T_a_older, T_ms_older, T_h_older);
    end

    % Divide power input by the number of heating elements
    Q_power = Q_power / 20; 
    
    % Initialize residual storage
    residual_norms = zeros(max_iter, 1);

    % Newton-Raphson Iteration
    for iter = 1:max_iter

        % Save previous guess
        T_w_prev = T_w;

        % Update wall temperature
        T_w = Update_Wall_Temperature(T_w_old, T_f, T_h, fm);
        dT_w = T_w - T_w_prev;

        % Compute heat transfers using updated temperatures
        [Q_f_w, Q_f_alloy, Q_h_ms, Q_ms_f, Q_h_f, Q_h_w] = ...
            Compute_Heat_Transfers(T_w(:, 1), T_f, T_a, T_ms, T_h, fm);

        % Residual equations
        F1 = T_f - T_f_old - dt/m_fCp_f * (Q_h_f + 2 * Q_ms_f - Q_f_w - Q_f_alloy);
        F2 = T_a - T_a_old - dt/m_aCp_a * (Q_f_alloy);
        F3 = T_ms - T_ms_old - dt/m_msCp_ms * (Q_h_ms - 2 * Q_ms_f);
        F4 = T_h - T_h_old - dt/m_hCp_h * (Q_power - Q_h_f - Q_h_ms - Q_h_w);

        % Compute the Jacobian matrix
        J = Compute_Newton_Raphson_Jacobian_4(dt, m_fCp_f, m_aCp_a, m_msCp_ms, m_hCp_h, ...
                                            h_f_aA_a, h_f_wA_w, h_ms_fA_w, h_h_fA_f, T_ms, T_h, ...
                                            rad_constant_h_ms, rad_constant_h_w);
        F = [-F1; -F2; -F3; -F4];
        dT = J \ F;
        
        % Update temperatures
        T_f = T_f + dT(1);
        T_a = T_a + dT(2);
        T_ms = T_ms + dT(3);
        T_h = T_h + dT(4);

        % Store residual norm
        residual_norms(iter) = norm(dT);

        % Check convergence
        converged = Check_Convergence(residual_norms(iter), dT_w, tol);
        if converged
            fprintf('Newton-Raphson converged in %d iterations\n', iter);
            break
        end
    end

    % Return updated temperatures
    T_f_new = T_f;
    T_a_new = T_a;
    T_w_new = T_w;
    T_ms_new = T_ms;
    T_h_new = T_h;
    iterations = iter;
end
