function [J, gradJ] = Compute_Cost_Function(x, furnace_model, constraints, N)
    %% Compute the cost function J(T_f, t) based on furnace dynamics
    
    % Initialize weights
    model = furnace_model.model;
    dt = model.dt;
    power_w = model.power_w;           % Power weight
    time_w = model.time_w;             % Time weight
    mech_w = model.mech_w;             % Mechanical properties weight
    furnace_model.model.N = N;
    
    % Process time duration
    if furnace_model.settings.desired_temperature_curve
        t = x(end);
    else
        % N-step temperature profile
        t = x(N+1:end);
    end
    t_final = sum(t);

    % Updates the process duration and the number of time steps
    furnace_model = Update_Time(furnace_model, t_final); 
    time_cost = t_final / constraints.t_max;                % Normalized time cost

    % Simulate time-temperature curves
    [cached_result] = Get_Or_Run_Simulation(x, furnace_model);

    % Extract the power expenditure and mechanical properties from the cached result
    Power_curve = cached_result.Power_curve;
    power_cost = Compute_Power_Cost(Power_curve, dt, furnace_model.controller.P_max, t_final);
    
    % Compute mechanical loss
    if furnace_model.settings.mechanical_loss
        M = cached_result.mechanical_properties;
        mech_loss = Compute_Mechanical_Loss(M, furnace_model);
    else
        mech_loss = 0;
    end

    % Total cost
    J = power_w * power_cost + time_w * time_cost + mech_w * mech_loss;

    % Compute Gradient
    if nargout > 1 && furnace_model.settings.store_derivatives
        gradJ = Compute_Cost_Gradient(furnace_model, constraints, cached_result).';
    end
end