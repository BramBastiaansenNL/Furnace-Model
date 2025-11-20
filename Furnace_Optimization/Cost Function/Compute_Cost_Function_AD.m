function [J, gradJ] = Compute_Cost_Function_AD(x, furnace_model, constraints, N)
    %% Compute the cost function J(x) and gradient using automatic differentiation

    % Initialize weights
    model = furnace_model.model;
    dt = model.dt;
    power_w = model.power_w;           % Power weight
    time_w = model.time_w;             % Time weight
    mech_w = model.mech_w;             % Mechanical properties weight
    furnace_model.model.N = N;

    %% Time cost (normalized)
    t = x(end);
    time_cost = t / constraints.t_max;  

    % Update and run simulation model
    furnace_model = Update_Time(furnace_model, t); 
    [cached_result] = Get_Or_Run_Simulation(x, furnace_model);

    %% Power cost (normalized)
    Power_curve = cached_result.Power_curve;
    power_cost = Compute_Power_Cost(Power_curve, dt, furnace_model.controller.P_max, t);

    %% Mechanical cost (penalty term)
    if furnace_model.settings.mechanical_loss
        if furnace_model.settings.alloy_temperature_distribution
            % Get mechanical properties for inner and outer nodes
            M_inner = cached_result.mechanical_properties{1};
            M_outer = cached_result.mechanical_properties{numel(cached_result.rep_nodes)};
            
            % Compute mechanical loss for each node
            mech_loss_inner = Compute_Mechanical_Loss(M_inner, furnace_model);
            mech_loss_outer = Compute_Mechanical_Loss(M_outer, furnace_model);
            
            % Combine losses (50/50 weighting for now)
            mech_loss = furnace_model.model.mech_w_inner * mech_loss_inner + ...
                        furnace_model.model.mech_w_outer * mech_loss_outer;
        else
            % Single-node model
            M = cached_result.mechanical_properties;
            mech_loss = Compute_Mechanical_Loss(M, furnace_model);
        end
    else
        mech_loss = 0;
    end

    %% Total cost
    J = power_w * power_cost + time_w * time_cost + mech_w * mech_loss;

    %% Compute gradient
    gradJ = dlgradient(J, x);
end
