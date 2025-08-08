function constraints = Model_Constraints()
    % Struct for all optimization/model constraints.

    %% Physical Constraints
    % Heat Balance Equations from Furnace_Model

    %% Temperature Constraints
    constraints.T_f_min = 290;  % Minimum temperature (K) - Room temperature
    constraints.T_f_max = 1000; % Maximum temperature (K)

    %% Time Constraints
    constraints.t_min = 0;    % Minimum process duration (s)
    constraints.t_max = 3600 * 10; % Maximum process duration (s)

    %% Process Constraints
    constraints.R_max = 20;   % Max heating rate (K/s)

    %% Mechanical Contraints
    constraints.YS_min = 310;  % Minimum Yield Strength
    constraints.YS_max = 600;  % Maximum Yield Strength
    constraints.UTS_min = 330; % Minimum Ultimate Tensile Strength
    constraints.UTS_max = 650; % Maximum Ultimate Tensile Strength
    constraints.UE_min = 0.08;    % Minimum Uniform Elongation
    constraints.UE_max = 1;   % Maximum Uniform Elongation
end