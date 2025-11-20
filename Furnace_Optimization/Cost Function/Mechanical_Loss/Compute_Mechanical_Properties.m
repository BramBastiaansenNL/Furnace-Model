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


    %% Compute gradient dX_dT, TODO: Replace for-loop and integrate gradient computation into Calc_Phases_from_t_T
    % Parameter struct for global constants
    par_model = create_parameter_Model();
    % Parameter set from the optimization
    u        = load('optim_DSC_temp2.mat').u;
    % Approximate Gradient for f(x) at x=1
    par_model = approx_gradient_poly(u, par_model);
    
    dt = diff(t_grid);

    N = numel(T_m);
    dX_dT =zeros(8,N);
    dX_dT_k = dX_dT(:,1);
    for k=1:numel(T_m)-1
        [dX_dT_kp1] = gradient_phase_model(T_m(k+1), X.X(:,k+1), 1, u, par_model, dt(k), dX_dT_k);       
        dX_dT(:,k+1) = dX_dT_kp1;
        dX_dT_k = dX_dT_kp1;
    end

    
    
    % X.dX_dT_m = dX_dT;
    S_T = Compute_Sensitivity_Tm(t_grid, T_m, X.X, u, par_model, 1);
    X.dX_dT_m = S_T;
    
    %% Mechanical properties
    [M.YS, ~, ~, ~, ~, ~, ~, M.dYSdt, M.dYSdX] = Calc_YS(x_opt_YS, X.X, X.dX_dt, 1);    % Yield strength (MPa)
    [M.UTS, ~, ~, ~, ~, ~, ~, M.dUTSdt, M.dUTSdX] = Calc_YS(x_opt_UTS, X.X, X.dX_dt, 1);   % Ultimate tensile strength (MPa)
    [M.UE, ~, ~, ~, ~, ~, ~, M.dUEdt, M.dUEdX]  = Calc_YS(x_opt_UE, X.X, X.dX_dt, 1);    % Uniform elongation
end