function model = Model_Parameters()
    % Struct for all model parameters

    %% Time Parameters
    model.dt = 1;                              % Time step (s)
    model.t_final = 360;                        % Total simulation time (s)
    model.Nt = round(model.t_final / model.dt);  % Number of time steps
    model.N = 1;                               % Number of simulations

    %% Optimization Weights
    model.power_w = 1;                           % Power weight
    model.time_w = 10;                           % Time weight
    model.mech_w = 1000;                          % Mechanical properties weight
    model.w_YS = 2;       % Weight for yield strength
    model.w_UTS = 1;      % Weight for ultimate tensile strength
    model.w_UE = 0.2;       % Weight for uniform elongation
    model.mech_w_inner = 0.5;
    model.mech_w_outer = 0.5;

    %% Minimum Mechanical Properties
    model.sigma_u_min = 330;              % Minimum ultimate tensile strength (MPa) K
    model.epsilon_u_min = 8;              % Minimum uniform elongation (8%) at K
    model.sigma_y_min = 310;              % Minimum yield strength (MPa) at K
    model.mech_reward_gain = 0.5;         % Reward-penalty gain
end