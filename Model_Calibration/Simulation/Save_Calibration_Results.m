function Save_Calibration_Results(optimal_parameters, optimal_loss, simulation_results, p_guess, fm, calibration_algorithm)
    %% Saves calibration results to a timestamped .mat file
    %
    % Inputs:
    %   optimal_parameters : optimized parameter vector
    %   optimal_loss       : final loss value
    %   simulation_results : struct with full simulation results
    %   p_guess            : initial parameter guess vector
    %   fm                 : furnace model struct (to extract param_subset)
    %   calibration_algorithm : string ('fmincon', 'particleswarm', etc.)

    % Build timestamped filename
    timestamp = datestr(now,'yyyy-mm-dd_HH-MM-SS');
    filename = sprintf('Calibration_Results_%s_%s.mat', calibration_algorithm, timestamp);

    % Extract param_subset (safe)
    if isfield(fm, 'param_subset')
        param_subset = fm.param_subset;
    else
        param_subset = {};
    end

    % Save all relevant variables
    save(filename, 'optimal_parameters', 'optimal_loss', 'simulation_results', ...
        'p_guess', 'param_subset', 'calibration_algorithm');

    % Print confirmation
    fprintf('\nCalibration results saved to: %s\n', filename);

end
