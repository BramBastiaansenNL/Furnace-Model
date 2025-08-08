function [p_guess, fm] = Set_Initial_Parameter_Guess(subset_to_optimize, fm)
    %% Returns initial guess vector and corresponding subset param names
    % subset_to_optimize: cell array of parameter names, e.g. {'h_f_al','epsilon_ms'}.
    % If empty, return a default set of high priority parameters.


    % Define default values
    default_values = fm.default_values;
    
    % Build output vector
    p_guess = zeros(length(subset_to_optimize),1);

    for i = 1:length(subset_to_optimize)
        field = subset_to_optimize{i};
        if isfield(default_values, field)
            p_guess(i) = default_values.(field);
        else
            error('No default value defined for parameter "%s"', field);
        end
    end

    fm.param_subset = subset_to_optimize;
end
