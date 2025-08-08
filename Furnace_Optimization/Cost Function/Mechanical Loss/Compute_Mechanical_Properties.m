function [M, X] = Compute_Mechanical_Properties(t, T_m, fm)
    %% Function to compute mechanical properties based on temperature profile

    % INPUT:
    %   t   - Total process time
    %   T_m - Temperature profile of the material (1xNt vector)
    % OUTPUT:
    %   M   - Vector of mechanical properties [ultimate tensile strength, uniform elongation, yield strength] (3xNt vector)
    %   X   - Phase Fractions
    
    % Initialization
    t_grid = linspace(0, t, length(T_m));        % Time grid
    x_opt_YS = fm.external_parameters.x_opt_YS;
    x_opt_UTS = fm.external_parameters.x_opt_UTS;
    x_opt_UE = fm.external_parameters.x_opt_UE;

    % Phase model
    X_struct   = Calc_Phases_from_t_T(t_grid, T_m);
    X.X        = X_struct.X;
    X.dX_dt    = X_struct.dX_dt;  % [3 x Nt]
    % X.dX_dT_m = X_struct.dX_dT_m;  % [3 x Nt]
    
    %% Mechanical properties
    [M.YS, ~, ~, ~, ~, ~, ~, M.dYSdt, M.dYSdX] = Calc_YS(x_opt_YS, X.X, X.dX_dt, 1);    % Yield strength (MPa)
    [M.UTS, ~, ~, ~, ~, ~, ~, M.dUTSdt, M.dUTSdX] = Calc_YS(x_opt_UTS, X.X, X.dX_dt, 1);   % Ultimate tensile strength (MPa)
    [M.UE, ~, ~, ~, ~, ~, ~, M.dUEdt, M.dUEdX]  = Calc_YS(x_opt_UE, X.X, X.dX_dt, 1);    % Uniform elongation
end