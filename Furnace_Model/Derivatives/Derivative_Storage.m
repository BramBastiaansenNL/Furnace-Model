function derivatives = Derivative_Storage(fm)
    %% Struct storing all relevant derivatives
    
    % Dimensions
    d = 4; % Number of states in the temperature vector (T = [T_f, T_a, T_ms])
    dt = fm.model.dt;
    Nt = fm.model.Nt;
    Nx = fm.walls.Nx;
    N = fm.model.N;
    derivatives.dJ_dx = zeros(1, 2*N+1); % Total derivative - [1 x 2N+1]
    derivatives.dP_dx_full = zeros(1, 2*N+1); % Total power derivative - [1 x 2N+1]

    %% Storage for time series
    derivatives.dT_dx_series = repmat({zeros(d, 2*N+1)}, Nt, 1);  % [d x 2N+1] x Nt
    derivatives.dP_dx_series = repmat({zeros(1, 2*N+1)}, Nt, 1);  % [1 x 2N+1] x Nt
    % derivatives.dT_h_dx_series = {0};       % [1 x 2N+1] x Nt

    derivatives.dT_w_dx_series = cell(Nt, 6);  % [6 x Nx x 2N+1] x Nt
    derivatives.dT_w1_dx_series = repmat({zeros(6, 2*N+1)}, Nt, 1);       % [6 x 2N+1] x Nt
    derivatives.dT_alloy_dx_series = repmat({zeros(1, 2*N+1)}, Nt, 1);     % [1 x 2N+1] x Nt
    derivatives.dF_dT_series = {zeros(d,d)}; % [d x d] x Nt
    derivatives.dF_dT_w1_series = {zeros(d,6)};       % [d x 6] x Nt
    derivatives.dF_dT_w1_prev_series = {zeros(d,6)};  % [d x 6] x Nt
    % derivatives.dF_dT_h_series = {0};

    % % Initial wall gradient (size: Nx x 2N+1)
    dT_w_dx_prev = zeros(Nx, 2*N+1);
    % Assign the same zero vector to all 6 walls at time step (k=1)
    [derivatives.dT_w_dx_series{1, :}] = deal(dT_w_dx_prev);
    
    %% Mechanical Component of Cost Function
    derivatives.dJ_mech_dx = zeros(1, 2*N+1);         % [1 x 2N+1]
    derivatives.dT_alloy_dT = [0, 1, 0, 0]; % [1 x d] - Constant
    
    %% Power Component of Cost Function
    derivatives.dJ_power_dx = 0;        % [1 x 2N+1] - Computed at the end
    % derivatives.dP_dT_f = - (fm.controller.Kp + 1/dt * fm.controller.Kd)...
    %                         / fm.controller.n_heaters;  % [1 x 1] - Constant
    % derivatives.dP_dT_f_desired = (fm.controller.Kp + 1/dt * fm.controller.Kd)...
    %                         / fm.controller.n_heaters;  % [1 x 1] - Constant
    derivatives.dT_f_dT = [1, zeros(1, d-1)];  % [1 x d] - Constant
    derivatives.dT_f_desired_dx = 1;    % [1 x 2N+1] - Constant (Overwritten externally)
    derivatives.dP_dx = 0;              % [1 x 2N+1] - Computed in every time-step (k)
    derivatives.dintegral_error_dx = repmat({zeros(1, 2*N+1)}, Nt, 1);    % Summation of integral error derivatives

    %% Sensitivity of states to the control variable
    derivatives.dT_dx = zeros(d);      % [d x 2N+1] - Computed in every time-step (k)

    %% Residual equation derivatives for T
    derivatives.dF_dT_prev = -1;   % [d x d] - Constant
    derivatives.dF_dP_prev = [0; 0; 0; - dt / fm.constants.m_hCp_h];  % Computed in every time-step (k)
    
    %% Residual equation derivatives for T_h
    % derivatives.dT_h_dx = 0;            % [1 x 2N+1] - Computed in every time-step (k)
    % derivatives.df_dP = - 1;            % [1 x 1] - Constant
    % derivatives.df_dT_h = 0;            % [1 x 1] - Computed in every time-step (k)
    % derivatives.df_dT = 0;              % [1 x d] - Computed in every time-step (k)
    % derivatives.df_dT_w = 0;            % [1 x 1] - Computed in every time-step (k)

    %% Residual equation derivatives for T_w
    derivatives.dT_w1_dx = 0;            % [1 x 2N+1] - Computed in every time-step (k)
end