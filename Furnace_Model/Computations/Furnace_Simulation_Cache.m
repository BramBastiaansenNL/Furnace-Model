function [cached_result, found] = Furnace_Simulation_Cache(x, fm, action)
    % A persistent cache for storing simulation results between calls
    
    persistent last_x last_result

    if nargin < 3
        action = 'get';  % Default action
    end

    switch action
        case 'get'
        if ~isempty(last_x) && isequal(x, last_x) && ~isempty(last_result)
            cached_result = last_result;
            found = true;
        else
            cached_result = [];
            found = false;
        end

        case 'set'
            last_x = x;

            % Extract temperature and time profiles
            N = fm.model.N;
            T_f_profile = x(1:N);
            t_profile = x(N+1:end);
            total_time = sum(t_profile);

            % Simulate time-temperature curves (either from N-step or using specific set temperature profile)
            if fm.settings.desired_temperature_curve
                total_time = x(end);
                alpha = x(N+1:end-1);
                alpha = alpha / sum(alpha);
                [T_f_desired, fm] = Generate_Desired_Temperature_Curve(T_f_profile, total_time, fm, alpha);
                [T_simulation, fm] = Simulate_Set_Furnace(T_f_desired, total_time, fm);
                T_w_curve = T_simulation.T_w_curve;
                T_f_curve = T_simulation.T_f_curve;
                T_m_curve = T_simulation.T_m_curve;
                T_ms_curve = T_simulation.T_ms_curve;
                Power_curve = T_simulation.Power_curve;
                T_h_curve = T_simulation.T_h_curve; 
            else
                % N-step profile
                [T_w_curve, T_f_curve, T_m_curve, T_ms_curve, Power_curve, T_h_curve, fm] = ...
                        Simulate_N_Step_Furnace(T_f_profile, t_profile, fm);
            end

            % Compute the mechanical properties
            [M, X] = Compute_Mechanical_Properties(total_time, T_m_curve, fm);

            % Store results
            last_result.T_w_curve = T_w_curve;
            last_result.T_m_curve = T_m_curve;
            last_result.T_f_curve = T_f_curve;
            last_result.T_ms_curve = T_ms_curve;
            last_result.Power_curve = Power_curve;
            last_result.T_h_curve = T_h_curve;
            last_result.mechanical_properties = M;
            last_result.phase_fractions = X;
            last_result.derivatives = fm.derivatives;
            found = true;
            cached_result = last_result;

        case 'reset'
            last_x = [];
            last_result = [];
            found = false;
            cached_result = [];
    end
end