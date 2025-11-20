function [T_f_new, T_a_new, T_w_new, T_ms_new, T_h_new, iterations, fm] = ...
    Solve_Newton_Raphson_Debugging(T_f_old, T_a_old, T_w_old, T_ms_old, T_h_old, fm, Q_power, k, varargin)
    %% (Debugging Version) Newton-Raphson solver for implicit furnace, alloy, metal sheet and wall temperature update
    
    % Parse optional inputs if needed
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
    fm.settings.NR_converged = false;

    % Initial guesses
    if nargin < 10
        [T_f, T_a, T_w, T_ms, T_h] = Compute_Initial_Guesses(T_f_old, T_a_old, T_w_old, T_ms_old, T_h_old);
    else
        [T_f, T_a, T_w, T_ms, T_h] = Compute_Initial_Guesses(T_f_old, T_a_old, T_w_old, T_ms_old, T_h_old, ...
                                                             T_f_older, T_a_older, T_w_older, T_ms_older, T_h_older);
    end

    % Compute heater temperature explicitly
    % [T_h_new, fm] = Compute_Heater_Temperature(Q_power, T_w_old, T_f_old, T_ms_old, T_h, ...
    %                                  k, fm);
    
    % Initialize residual storage
    residual_norms = zeros(max_iter, 1);
    T_f_all = zeros(max_iter, 1);
    T_a_all = zeros(max_iter, 1);
    T_ms_all = zeros(max_iter, 1);
    T_w_outer_all = zeros(max_iter, 1);
    T_h_all = zeros(max_iter, 1);

    % Newton-Raphson Iteration
    for iter = 1:max_iter

        % Save previous guess
        T_w_prev = T_w;
        
        % Compute the residual system
        [F, T_w, fm] = Residual_System(T_f, T_a, T_ms, T_h, T_f_old, T_a_old, T_w_old, T_ms_old, T_h_old, ...
                             Q_power, fm, k);

        % Update wall temperature
        dT_w = T_w - T_w_prev;

        % Compute the Jacobian matrix
        J = Compute_Newton_Raphson_Jacobian(dt, T_ms, T_h, fm);

        % === Debug Jacobian ===
        if fm.settings.debug_jacobian 
            Compare_Jacobian(T_f, T_a, T_ms, T_h, ...
                             T_f_old, T_a_old, T_ms_old, T_w_old, T_h_old, Q_power, dt, fm, J, k);
            % user_input = input('Continue comparing? Y/N [Y]: ', 's');
            % if strcmpi(user_input, 'n')
            %     error('Comparison complete. Stopping simulation.');
            % end
        end

        % Solve Newton-Raphson update
        dT = - J \ F;
        
        % Update temperatures
        T_f = T_f + dT(1);
        T_a = T_a + dT(2);
        T_ms = T_ms + dT(3);
        T_h = T_h + dT(4);

        % Store residual norm
        residual_norms(iter) = norm(dT);
        T_f_all(iter) = T_f;
        T_a_all(iter) = T_a;
        T_ms_all(iter) = T_ms;
        T_w_outer_all(iter) = T_w(1, 1);
        T_h_all(iter) = T_h;

        % Check convergence
        converged = Check_Convergence(residual_norms(iter), dT_w, tol);
        if converged
            residual_norms = residual_norms(1:iter); % Trim unused entries
            T_f_all = T_f_all(1:iter);
            T_a_all = T_a_all(1:iter);
            T_ms_all = T_ms_all(1:iter);
            T_w_outer_all = T_w_outer_all(1:iter);
            T_h_all = T_h_all(1:iter);
            fprintf('Newton-Raphson converged in %d iterations\n', iter);

            if fm.settings.symbolic_differentiation
                fm.derivatives.dR_dT = J;
            end
            break
        end
    end

    % Plot residuals
    if fm.settings.dynamic_residual_plotting
        figure;
        semilogy(1:length(residual_norms), residual_norms, 'o-','LineWidth',1.5);
        xlabel('Iteration');
        ylabel('Residual Norm');
        title('Newton-Raphson Residual Norm vs Iteration');
        grid on;
    
        figure;
        plot(1:iter, T_f_all(1:iter), '-o', 1:iter, T_a_all(1:iter), '-s', 1:iter, T_ms_all(1:iter), '-^', ... 
            1:iter, T_w_outer_all, '-*', 1:iter, T_h_all);
        legend('T_f', 'T_a', 'T_{ms}', 'T_w', 'T_h');
        xlabel('Iteration');
        ylabel('Temperature [K]');
        title('Temperature Updates per Newton-Raphson Iteration');
        grid on;

        user_input = input('Continue plotting? Y/N [Y]: ', 's');
        if strcmpi(user_input, 'n')
            error('Debugging complete. Stopping simulation.');
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
