function [T_h, fm] = Compute_Heater_Temperature(Q_power, T_w, T_f, T_ms, T_h_guess, ...
                                           k, fm)
    %% Solves the explicit temperature update for the heating elements

    % Define coefficients
    dt = fm.model.dt;
    constants = fm.constants;
    A = constants.rad_constant_h_ms + constants.rad_constant_h_w;  % coefficient for T_h^4
    B = constants.h_h_fA_f;                              % coefficient for T_h
    D = Q_power + ...
        constants.rad_constant_h_ms * T_ms^4 + ...
        constants.rad_constant_h_w  * (1/4) * sum(T_w(1, 1:4).^4) + ...
        B * T_f;

    % Define the function f(T_h) = A*T_h^4 + B*T_h - D
    f = @(Th) A * Th.^4 + B * Th - D;

    % Solve numerically (using MATLAB's root finder)
    T_h = fzero(f, T_h_guess); 

    % Derivatives
    if fm.settings.store_derivatives && fm.settings.point_iterative_derivative
        [fm, ~] = Compute_dT_h_dx(fm, A, B, T_h, T_ms, T_w, k, dt);
    end
end
