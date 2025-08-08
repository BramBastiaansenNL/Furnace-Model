function settings = Select_Optimization_Model_Settings(settings)
    %% Interactive selection of furnace model settings

    %% Boolean Settings
    bool_fields = { ...
        'debugging', ...
        'mechanical_loss', ...
        'store_derivatives', ...
        'compare_cost_gradients', ...
        'desired_temperature_curve', ...
        'debugging_optimizer', ...
    };

    % Get default on/off indices
    default_idx = [];
    for i = 1:numel(bool_fields)
        if isfield(settings, bool_fields{i}) && settings.(bool_fields{i})
            default_idx(end+1) = i;
        end
    end

    [selected_idx, ok] = listdlg( ...
        'PromptString', 'Select boolean settings to ENABLE:', ...
        'SelectionMode', 'multiple', ...
        'ListString', bool_fields, ...
        'InitialValue', default_idx);

    % Apply selected settings
    if ok
        for i = 1:numel(bool_fields)
            settings.(bool_fields{i}) = ismember(i, selected_idx);
        end
    else
        fprintf('No boolean selections made. Keeping existing settings.\n');
    end

    %% Select Algorithm
    algorithm_options = {'sqp', 'interior-point'};
    [alg_idx, ok_alg] = listdlg( ...
        'PromptString', 'Select optimization algorithm:', ...
        'SelectionMode', 'single', ...
        'ListString', algorithm_options, ...
        'InitialValue', find(strcmp(settings.algorithm, algorithm_options), 1));

    if ok_alg
        settings.algorithm = algorithm_options{alg_idx};
    else
        fprintf('No algorithm selected. Using default (%s).\n', settings.algorithm);
    end

    %% Select Optimizer
    optimizer_options = {'fmincon', 'projected gradient descent', 'comparison'};
    [opt_idx, ok_opt] = listdlg( ...
        'PromptString', 'Select optimizer:', ...
        'SelectionMode', 'single', ...
        'ListString', optimizer_options, ...
        'InitialValue', find(strcmp(settings.optimizer, optimizer_options), 1));

    if ok_opt
        settings.optimizer = optimizer_options{opt_idx};
    else
        fprintf('No optimizer selected. Using default (%s).\n', settings.optimizer);
    end

    %% Dependency Check — Force mechanical_loss = true if PGD is selected
    if strcmp(settings.optimizer, 'projected gradient descent')
        if ~settings.mechanical_loss
            fprintf('[Info] Projected Gradient Descent selected — enabling mechanical_loss.\n');
        end
        settings.mechanical_loss = true;
    end

    %% Dependency Check — Additional choice of curve parameterization if desired_temperature_curve is selected
    if settings.desired_temperature_curve
        parameterization_options = {'constant', 'linear', 'splines'};
        [param_idx, ok_param] = listdlg( ...
            'PromptString', 'Select optimizer:', ...
            'SelectionMode', 'single', ...
            'ListString', parameterization_options, ...
            'InitialValue', find(strcmp(settings.curve_parameterization, parameterization_options), 1));
    
        if ok_param
            settings.curve_parameterization = parameterization_options{param_idx};
        else
            fprintf('No curve parameterization selected. Using default (%s).\n', settings.curve_parameterization);
        end
    end
end
