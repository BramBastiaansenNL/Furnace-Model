function loss = Calibration_Loss_Function(parameters, time_experiment, ...
                                          T_experiment, P_experiment, fm)
    %% Defines the error between simulated and measured data
    
    % Obtain the simulated time-temperature curves with the new parameters
    T_simulation = ...
        Furnace_Model_Wrapper(parameters, time_experiment, P_experiment, T_experiment, fm);

    % Define weights per signal
    weight_furnace = 1.0;
    weight_material = 1.0;

    % Compute errors
    error_furnace = T_simulation.T_f_curve - T_experiment.T_furnace;
    error_material = T_simulation.T_m_curve - T_experiment.T_material_ext;

    % Compute total loss (sum of squared errors, weighted)
    loss = weight_furnace * sum(error_furnace.^2) + ...
           weight_material * sum(error_material.^2);
end