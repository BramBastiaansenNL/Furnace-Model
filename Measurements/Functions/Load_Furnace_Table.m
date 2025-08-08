function table = Load_Furnace_Table(mode)
    %% Loads raw excel tables

    switch lower(mode)
        case 'step'
            table = readtable('Furnace_Measurements_Step.xlsx', 'VariableNamingRule', 'preserve');
        case 'cone'
            table = readtable('Furnace_Measurements_Cone.xlsx', 'VariableNamingRule', 'preserve');
        otherwise
            error('Invalid mode: %s', mode);
    end
end