function Compare_Jacobian(T_f, T_a, T_ms, T_h, ...
                          T_f_old, T_a_old, T_ms_old, T_w_old, T_h_old, Q_power, ...
                          dt, fm, J_analytical, k)
    %% Compares the analytical Jacobian to the numerical Jacobian for the Newton-Raphson Residual System
    

    % Check condition number of the analytical Jacobian
    cond_J = cond(J_analytical);
    
    % Threshold for ill-conditioning
    if cond_J > 1e10
        warning('Analytical Jacobian is ill-conditioned (cond = %.2e)', cond_J);
        keyboard;  % Trigger breakpoint
    end

    % Package current temperature vector
    T_vec = [T_f; T_a; T_ms; T_h];

    % Freeze T_w
    [T_w_fixed, fm] = FVM_Wall_Solver(T_w_old, T_f, T_h, fm, k);

    % Define residual function handle
    residual_func = @(Tvec) Compute_Residuals(Tvec, T_f_old, T_a_old, T_ms_old, T_h_old, T_w_old, T_w_fixed, ...
                                              Q_power, fm, dt, fm.constants);

    % Evaluate baseline residual
    F_base = residual_func(T_vec);

    % Finite difference step
    h = 1e-4;

    % Initialize numerical Jacobian
    J_numerical = zeros(4, 4);

    for i = 1:4
        T_perturbed = T_vec;
        T_perturbed(i) = T_perturbed(i) + h;

        F_perturbed = residual_func(T_perturbed);

        % Finite difference column
        J_numerical(:, i) = (F_perturbed - F_base) / h;
    end

    % Compare
    fprintf('=== Jacobian Comparison for k = %.3f ===\n', k);
    disp('Analytical Jacobian:');
    disp(J_analytical);

    disp('Numerical Jacobian:');
    disp(J_numerical);

    abs_err = abs(J_analytical - J_numerical);

    disp('Absolute Error:');
    disp(abs_err);
end
