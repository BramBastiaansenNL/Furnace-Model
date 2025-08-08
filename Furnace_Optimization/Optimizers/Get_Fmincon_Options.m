function options = Get_Fmincon_Options(furnace_model)
    %% Returns fmincon options based on tuned settings 

    % Shortcut to settings
    settings = furnace_model.settings;

    % Determine if analytical gradient is used
    use_derivatives = isfield(settings, 'store_derivatives') && settings.store_derivatives;

    % Create base optimization options
    options = optimoptions('fmincon', ...
        'Algorithm', settings.algorithm, ...
        'Display', 'iter-detailed', ...
        'OutputFcn', @Print_Optimization_Steps, ...
        ...
        'MaxFunctionEvaluations', 1e5, ...          % Large budget for slow evaluations
        'MaxIterations', 1e4, ...                   % Also high iteration cap
        ...
        'StepTolerance', 1e-8, ...                  % Strict enough to not terminate early
        'FunctionTolerance', 1e-6, ...              % Medium strictness for objective convergence
        'ConstraintTolerance', 1e-6, ...            % Precision for meeting constraints
        ...
        'OptimalityTolerance', 1e-6, ...            % Stop if KKT conditions met
        ...
        'FiniteDifferenceStepSize', 1e-3, ...       % For gradient approximation if needed
        'FiniteDifferenceType', 'forward');         % Or 'central' if very smooth & can afford extra calls

    % Add analytical gradient option if using derivatives
    if use_derivatives
        options = optimoptions(options, 'SpecifyObjectiveGradient', true);
    end
end
