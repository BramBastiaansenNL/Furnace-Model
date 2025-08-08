function [optimal_parameters, optimal_loss, simulation_results] = ...
    Run_Simultaneous_Calibration(calibration_algorithm, ...
    time_measurement_step, T_measurement_step, P_measurement_step, ...
    time_measurement_cone, T_measurement_cone, P_measurement_cone, p_guess, fm)
    %% Orchestrates the calibration process
    
    % Set (realistic) bounds for parameters
    [lb, ub] = Set_Parameter_Bounds(p_guess, fm.param_subset);

    % Define the loss function
    loss_fun = @(p) Simultaneous_Calibration_Loss_Function(p, ...
     time_measurement_step, T_measurement_step, P_measurement_step, ...
     time_measurement_cone, T_measurement_cone, P_measurement_cone, fm);

    switch lower(calibration_algorithm)
        case 'fmincon'
            options = optimoptions('fmincon', ...
                'Display', 'iter', ...
                'MaxFunctionEvaluations', 2000, ...
                'MaxIterations', 1000, ...
                'UseParallel', false, ...
                'OutputFcn', @Track_Best_Solution);

            [optimal_parameters, optimal_loss] = fmincon(loss_fun, p_guess, [], [], [], [], lb, ub, [], options);

        case 'particleswarm'
            options = optimoptions('particleswarm', ...
                'SwarmSize', 100, ...
                'MaxIterations', 200, ...
                'MaxStallIterations', 10, ...
                'Display', 'iter', ...
                'OutputFcn', @Save_Best_Particle);

            [optimal_parameters, optimal_loss] = particleswarm(loss_fun, length(p_guess), lb, ub, options);

        otherwise
            error('Unknown calibration algorithm "%s". Supported: "fmincon", "particleswarm".', calibration_algorithm);
    end
    
    % Simulate temperature profiles with optimized parameters
    fm.settings.material_entry = 274;
    T_simulation_step = Furnace_Model_Wrapper(optimal_parameters, ...
        time_measurement_step, P_measurement_step, T_measurement_step, fm);
    fm.settings.material_entry = 0;
    T_simulation_cone = Furnace_Model_Wrapper(optimal_parameters, ...
        time_measurement_cone, P_measurement_cone, T_measurement_cone, fm);

    % Plots results for comparison
    Plot_Calibration_Results(time_measurement_step, T_measurement_step, T_simulation_step);
    Plot_Calibration_Results(time_measurement_cone, T_measurement_cone, T_simulation_cone);

    fprintf('\nOptimal parameters:\n');
    for i = 1:length(fm.param_subset)
        fprintf('  %s = %.6f\n', fm.param_subset{i}, optimal_parameters(i));
    end

    % Store results
    simulation_results.T_simulation = T_simulation_step;
    simulation_results.optimal_parameters = optimal_parameters;
    simulation_results.loss = optimal_loss;
    simulation_results.time = time_measurement_step;
    simulation_results.P_input = P_measurement_step;

    Save_Calibration_Results(optimal_parameters, optimal_loss, simulation_results, p_guess, fm, calibration_algorithm);
end