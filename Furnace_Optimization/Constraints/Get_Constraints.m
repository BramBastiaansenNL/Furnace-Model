function [c, ceq] = Get_Constraints(x, furnace_model, constraints, N)
    %% Function that returns constraints based on desired time-temperature curve
    
    % Extract temperature and time profiles
    if furnace_model.settings.desired_temperature_curve
        t_profile = x(end);
    else
        % N-step profile
        t_profile = x(N+1:end);
    end

    % Extract mechanical properties from cached simulation results
    [cached_result] = Get_Or_Run_Simulation(x, furnace_model);
    M = cached_result.mechanical_properties;

    % Ensures sum(t_profile) <= t_max
    c1 = sum(t_profile) - constraints.t_max;

    % Mechanical property constraints
    c2 = constraints.YS_min - M.YS(end);
    c3 = constraints.UTS_min - M.UTS(end);
    c4 = constraints.UE_min - M.UE(end);
    
    % Gather inequality constraints (c <= 0)
    c = [c1; c2; c3; c4;];
    ceq = [];
end