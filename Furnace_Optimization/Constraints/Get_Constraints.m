function [c, ceq] = Get_Constraints(x, furnace_model, constraints, N)
    %% Function that returns constraints based on desired time-temperature curve
    
    % Extract temperature and time profiles
    T_profile = x(1:N);
    if furnace_model.settings.desired_temperature_curve
        t_profile = x(end);
        alpha = x(N+1:end-1);
        t_points = cumsum(alpha * t_profile);
    else
        % N-step profile
        t_profile = x(N+1:end);
        t_points = [0, cumsum(t_profile(:))];
    end

    % Compute slopes (delta T / delta t)
    slopes = diff(T_profile) ./ diff(t_points);
    c_heat = slopes - constraints.R_heat_max; % Heating constraint: slope <= R_heat_max
    c_cool = -constraints.R_cool_max - slopes; % Cooling constraint: slope >= -R_cool_max 

    % Extract mechanical properties from cached simulation results
    [cached_result] = Get_Or_Run_Simulation(x, furnace_model);

    % Ensures sum(t_profile) <= t_max
    c1 = sum(t_profile) - constraints.t_max;

    % Mechanical property constraints
    if furnace_model.settings.alloy_temperature_distribution && furnace_model.settings.mechanical_constraints
        % Inner and outer node mechanical properties
        M_inner = cached_result.mechanical_properties{1};
        M_outer = cached_result.mechanical_properties{numel(cached_result.rep_nodes)};
        
        % Compare each with constraints at the final time step
        c2_inner = constraints.YS_min  - M_inner.YS(end);
        c3_inner = constraints.UTS_min - M_inner.UTS(end);
        c4_inner = constraints.UE_min  - M_inner.UE(end);
        
        c2_outer = constraints.YS_min  - M_outer.YS(end);
        c3_outer = constraints.UTS_min - M_outer.UTS(end);
        c4_outer = constraints.UE_min  - M_outer.UE(end);

        % Combine both inner & outer constraints (must satisfy both)
        c2 = max([c2_inner, c2_outer]);
        c3 = max([c3_inner, c3_outer]);
        c4 = max([c4_inner, c4_outer]);

        c = [c1; c2; c3; c4; c_heat(:); c_cool(:)];
    elseif furnace_model.settings.mechanical_constraints
        % Single mechanical property case
        M = cached_result.mechanical_properties;
        c2 = constraints.YS_min  - M.YS(end);
        c3 = constraints.UTS_min - M.UTS(end);
        c4 = constraints.UE_min  - M.UE(end);

        c = [c1; c2; c3; c4; c_heat(:); c_cool(:)];
    else
        c = [c1; c_heat(:); c_cool(:)];
    end

    ceq = [];
end