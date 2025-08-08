function [T_f_new, T_a_new, T_w_new, T_ms_new, T_h_new] = ...
    Solve_f_Solve(T_f_old, T_a_old, T_w_old, T_ms_old, T_h_old, ...
                  fm, Q_power, T_f_older, T_a_older, T_ms_older, T_h_older)
    %% Matlab's built-in solver for implicit furnace, alloy, metal sheet and wall temperature update
    
    % Parameters    
    tol = 1e-4;                     % Convergence tolerance

    % Initial guesses
    if nargin < 10
        [T_f, T_a, ~, T_ms, T_h] = Compute_Initial_Guesses(T_f_old, T_a_old, T_w_old, T_ms_old, T_h_old);
    else
        [T_f, T_a, ~, T_ms, T_h] = Compute_Initial_Guesses(T_f_old, T_a_old, T_w_old, T_ms_old, T_h_old, ...
                                                           T_f_older, T_a_older, T_ms_older, T_h_older);
    end
    T_guess = [T_f; T_a; T_ms];

    % Compute heater temperature explicitly
    T_w_surface_exposed = mean(T_w_old(1, 1:4));  % Average of only side/top/bottom wall surface
    [T_h, fm] = Compute_Heater_Temperature(Q_power, T_w_surface_exposed, T_f_old, T_ms_old, T_h, ...
                                     fm);
    
    % Solver
    options = optimoptions('fsolve', 'Display', 'off', 'FunctionTolerance', tol);
    T_vec = fsolve(@(T) Residual_Wrapper(T, T_f_old, T_a_old, T_w_old, T_ms_old, T_h, fm), ...
                    T_guess, options);

    % Extract solution
    T_f_new = T_vec(1);
    T_a_new = T_vec(2);
    T_ms_new = T_vec(3);
    T_h_new = T_h;
    T_w_new = Update_Wall_Temperature(T_w_old, T_f_new, T_h_new, fm);
end
