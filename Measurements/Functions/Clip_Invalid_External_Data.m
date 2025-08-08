function table = Clip_Invalid_External_Data(table, mode)
    %% Remove invalid rows based on known overrun issues

    switch lower(mode)
        case 'cone'
            max_row = 1894;
        case 'step'
            max_row = 8424;
        otherwise
            error('Invalid mode: %s', mode);
    end
    table = table(1:max_row, :);
end