function dJ_mech_dx = Compute_Mechanical_Loss_Gradient(M, X, dt_dx, fm, derivatives)
    %% Computes the derivative of the mechanical loss term w.r.t the control variable x
    %
    % Inputs:
    %   M                - struct with fields: M.YS, M.UTS, M.UE (vectors of length Nt)
    %                    - struct with fields: M.dYSdt, M.dYSdX, M.dUTSdt, M.dUTSdX, M.dUEdt, M.dUEdX
    %   dt_dx            - [1 x 2N+1] row vector
    %   fm               - struct everything else

    % Initialize
    dT_m_dx = vertcat(derivatives.dT_alloy_dx_series{:}); % Nt x (2N+1) matrix
    dT_m_dx_end = derivatives.dT_alloy_dx_series{end}; % 1 x (2N+1) matrix
    M.UTS_min = fm.model.sigma_u_min;      % Target ultimate tensile strength
    M.UE_min = fm.model.epsilon_u_min;     % Target elongation 
    M.YS_min = fm.model.sigma_y_min;       % Target yield strength
    gamma = fm.model.mech_reward_gain;

    %% === Extract relevant data for all 3 properties ===
    % Final values of the 3 mechanical properties [3×1]
    M_vals = [M.YS(end); M.UTS(end); M.UE(end)];

    % Target minimum values [3×1]
    M_min = [M.YS_min; M.UTS_min; M.UE_min];

    % Delta = relative deviation [3×1]
    delta = (M_vals - M_min) ./ M_min;

    % Weights for each property [3×1]
    weights = [fm.model.w_YS; fm.model.w_UTS; fm.model.w_UE];

    % Piecewise derivative dl/d_delta [3×1]
    dl_d_delta = 2 * delta;                  % default
    dl_d_delta(delta >= 0) = -2 * gamma * delta(delta >= 0);

    % dM/dt for each property [3×1]
    dM_dt_end = [M.dYSdt(end); M.dUTSdt(end); M.dUEdt(end)];

    % dM/dX for each property, relevant phases only [3×3xNt] (1x3)
    dYS_dX  = M.dYSdX(3:5,end)';   % [3×Nt]
    dUTS_dX = M.dUTSdX(3:5,end)';  % [3×Nt]
    dUE_dX  = M.dUEdX(3:5,end)';   % [3×Nt]

    % dX/dT_m for relevant phases only [3×Nt]
    dX_dT_m = X.dX_dT_m(3:5, :);   % phases 3:5

    %% === Compute dM/dT_m for each property [3×Nt] ===
    % Each property: sum_j dM/dX_j * dX_j/dT_m
    dM_dT_m = [dYS_dX  * dX_dT_m;   % row: YS
               dUTS_dX * dX_dT_m;   % row: UTS
               dUE_dX  * dX_dT_m];  % row: UE

    %% === Chain rule: dM/dx for all properties [3×(2N+1)] ===
    dM_dx = dM_dT_m * dT_m_dx + dM_dt_end * dt_dx;  % broadcasting

    %% === Combine contributions to dJ/dx ===
    % Formula: sum_i weights(i) * (1/M_min(i)) * dl_d_delta(i) * dM_dx(i,:)
    scaling = weights .* (1 ./ M_min) .* dl_d_delta;  % [3×1]
    dJ_mech_dx = scaling' * dM_dx;                    % [1×(2N+1)]
end
