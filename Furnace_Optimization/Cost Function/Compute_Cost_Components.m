function [J_total, J_power, J_time, J_mech] = Compute_Cost_Components(x, furnace_model, constraints)
    % Compute the cost function's components based on furnace dynamics
    % (OUTDATED!)
    
    % Initialize weights
    model = furnace_model.model;
    dt = model.dt;
    power_w = model.power_w;           % Power weight
    time_w = model.time_w;             % Time weight
    mech_w = model.mech_w;             % Mechanical properties weight
    
    % Process time duration
    % Process time duration
    N = numel(x) / 2;
    t = x(N+1:end);
    t_final = sum(t);

    % Updates the process duration and the number of time steps
    furnace_model = Update_Time(furnace_model, t_final); 
    J_time = t_final / constraints.t_max;                % Normalized time cost
    
    % Simulate time-temperature curves
    [cached_result] = Get_Or_Run_Simulation(x, furnace_model);

    % Extract the power expenditure and mechanical properties from the cached result
    Power_curve = cached_result.Power_curve;
    J_power = Compute_Power_Cost(Power_curve, dt, furnace_model.controller.P_max, t_final);

    % Compute mechanical loss
    if furnace_model.settings.mechanical_loss
        M = cached_result.mechanical_properties;
        J_mech = Compute_Mechanical_Loss(M, furnace_model);
    else
        J_mech = 0;
    end

    % Total Loss/Cost Function
    J_total = power_w * J_power + time_w * J_time + mech_w * J_mech;
end