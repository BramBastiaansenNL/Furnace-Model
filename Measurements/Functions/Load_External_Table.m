function table = Load_External_Table(mode)
    %% Loads raw external measurement tables
    
    switch lower(mode)
        case 'step'
            sheet = 'WBH1';
        case 'cone'
            sheet = 'WBH2';
        otherwise
            error('Invalid mode: %s', mode);
    end
    table = readtable('Material_External_Measurements.xlsx', ...
        'Sheet', sheet, 'VariableNamingRule', 'preserve');
end