function p_vector = Select_Parameters(default_values, subset_to_optimize)
    %% Extracts parameter values into a vector.
    %
    %   Inputs:
    %       default_values       - struct with all default parameter values
    %       subset_to_optimize   - cell array of strings with field names to extract
    %
    %   Output:
    %       p_vector             - column vector of parameter values in the same order

    p_vector = zeros(length(subset_to_optimize), 1);

    for i = 1:length(subset_to_optimize)
        field = subset_to_optimize{i};

        if isfield(default_values, field)
            p_vector(i) = default_values.(field);
        else
            error('No default value defined for parameter "%s".', field);
        end
    end
end
