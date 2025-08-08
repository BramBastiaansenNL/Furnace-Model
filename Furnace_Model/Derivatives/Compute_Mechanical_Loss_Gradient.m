function dJ_mech_dx = Compute_Mechanical_Loss_Gradient(M, X, dt_dx, fm)
    %% Computes the derivative of the mechanical loss term w.r.t the control variable x
    %
    % Inputs:
    %   M                - struct with fields: M.YS, M.UTS, M.UE (vectors of length Nt)
    %                    - struct with fields: M.dYSdt, M.dYSdX, M.dUTSdt, M.dUTSdX, M.dUEdt, M.dUEdX
    %   dt_dx            - [1 x 2N+1] row vector
    %   fm               - struct everything else

    % Initialize
    dT_m_dx = fm.derivatives.dT_alloy_dx_series;
    N = fm.model.N;
    dJ_mech_dx = zeros(1, 2*N+1);
    M.UTS_min = fm.model.sigma_u_min;      % Target ultimate tensile strength
    M.UE_min = fm.model.epsilon_u_min;     % Target elongation 
    M.YS_min = fm.model.sigma_y_min;       % Target yield strength
    gamma = fm.model.mech_reward_gain;

    props = {'YS', 'UTS', 'UE'};

    for i = 1:length(props)
        name = props{i};

        % Property values
        M_val = M.(name)(end);
        M_min = M.([name '_min']);
        delta = (M_val - M_min) / M_min;
        weights = fm.model.(['w_' name]);
        dM_i_dt = M.(['d' name 'dt']); % scalar

        % Piecewise derivative of loss
        if delta < 0
            dl_d_delta = 2 * delta;
        else
            dl_d_delta = -2 * gamma * delta;
        end

        % Partial derivatives
        dM_i_dX = M.(['d' name 'dX']); % [1 x 3]
        dX_dT_m = X.dX_dT_m(i, end);   % [3 x 1]
        dM_i_dT_m = dM_i_dX * dX_dT_m;     % [1 x 1]

        % Full derivative w.r.t. x
        dM_i_dx = dM_i_dT_m * dT_m_dx + dM_i_dt * dt_dx;

        % Contribution to total loss gradient
        dJ_mech_dx = dJ_mech_dx + weights.(name) * (1/M_min) * dl_d_delta * dM_i_dx;
    end
end
