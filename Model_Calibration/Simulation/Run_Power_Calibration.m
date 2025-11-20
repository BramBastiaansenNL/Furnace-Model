function [optimal_parameters, optimal_loss, simulation_results] = ...
    Run_Power_Calibration(calibration_algorithm, time_measurement, T_measurement, p_guess, fm)
    %% Orchestrates the calibration process for the PID power controller
    
    % Set (realistic) bounds for parameters
    [lb, ub] = Set_Parameter_Bounds(p_guess, fm.param_subset);

    % Define the loss function
    P_measurement = false;
    loss_fun = @(p) Calibration_Loss_Function(p, time_measurement, T_measurement, P_measurement, fm);

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
    T_simulation = Furnace_Model_Wrapper(optimal_parameters, time_measurement, P_measurement, T_measurement, fm);

    % Plots results for comparison
    Plot_Calibration_Results(time_measurement, T_measurement, T_simulation);

    fprintf('\nOptimal parameters:\n');
    for i = 1:length(fm.param_subset)
        fprintf('  %s = %.6f\n', fm.param_subset{i}, optimal_parameters(i));
    end

    % Store results
    simulation_results.T_simulation = T_simulation;
    simulation_results.optimal_parameters = optimal_parameters;
    simulation_results.loss = optimal_loss;
    simulation_results.time = time_measurement;
    simulation_results.P_input = P_measurement;

    Save_Calibration_Results(optimal_parameters, optimal_loss, simulation_results, p_guess, fm, calibration_algorithm);
end