function [T_simulation, fm] = Furnace_Model_Wrapper(parameters, time_vector, P_measurement, T_experiment, fm)
    %% Runs simulation using parameter vector

    % Update the furnace model with these new parameters
    t = sum(time_vector); % extract the total time from time_vector
    fm = Update_Furnace_Model_Parameters(parameters, fm, t);

    if fm.settings.power_input
        % Run the furnace model with these parameters and specified power input
        P_input = P_measurement / round(fm.controller.n_heaters);
        [T_simulation, fm] = Simulate_Specific_Furnace(P_input, fm);
    else
        % Run the furnace with the desired furnace temperature profile
        T_f_desired = T_experiment.T_set;
        [T_simulation, fm] = Simulate_Set_Furnace(T_f_desired, time_vector, fm);
    end
end