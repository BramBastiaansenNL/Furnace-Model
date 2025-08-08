function fm = Calibrate_Furnace_Model_Parameters(parameters, param_subset, fm, t)
    %% Updates furnace model with selected parameters
    %
    % parameters : vector of parameter values
    % param_subset : corresponding cell array of param names (order matches vector)
    % fm : furnace model struct

    % Safety check: parameter vector size must match param_subset length
    if length(parameters) ~= length(param_subset)
        error('Length of parameter vector does not match fm.param_subset length.');
    end

    % Get master param info table
    fm.param_subset = param_subset;
    param_info = Get_Calibration_Parameter_Info();

    % Build a map param_name → field_path
    param_map = containers.Map(param_info(:,1), param_info(:,2));

    % Loop over selected parameters
    for i = 1:length(fm.param_subset)
        pname = fm.param_subset{i};
        fpath = param_map(pname);

        % Split path by dots
        parts = split(fpath, '.');

        % Build dynamic assignment
        switch length(parts)
            case 2
                fm.(parts{1}).(parts{2}) = parameters(i);
            case 3
                fm.(parts{1}).(parts{2}).(parts{3}) = parameters(i);
            otherwise
                error('Unsupported field path depth for parameter "%s"', pname);
        end
    end
    
    % Make changes to the calculations of the furnace model
    fm = Update_Furnace_Model(fm, t);
end