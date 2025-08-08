function influx_data = Load_Influx_Data(mode, plotting)
    %% Loads influx CSV data for electrical power readings from the furnace
    %
    %   Inputs:
    %       mode     - 'step' or 'cone'
    %       plotting - true/false, plot time series of all fields
    %
    %   Output:
    %       influx_data - struct with fields:
    %           .time        - Nx1 vector [s] relative to first entry
    %           .values      - struct with one field per unique 'field' name
    %           .raw_table   - original parsed table

    if nargin < 2
        plotting = false;
    end

    %% --- Load appropriate CSV file
    switch lower(mode)
        case 'step'
            filename = 'influx_data_step.csv';
        case 'cone'
            filename = 'influx_data_cone.csv';
        otherwise
            error('Unknown mode: %s. Use ''step'' or ''cone''.', mode);
    end

    data = readtable(filename, 'Delimiter', ',', 'TextType', 'string');

    %% --- Convert 'time' column to datetime
    t_dt = datetime(data.time, ...
                    'InputFormat', 'yyyy-MM-dd''T''HH:mm:ssX', ...
                    'TimeZone', 'UTC');
    
    t_seconds = seconds(t_dt - t_dt(1));  % Time from start
    t_hours = t_seconds / 3600;

    %% --- Split by field
    unique_fields = unique(data.field);
    values = struct();

    for i = 1:length(unique_fields)
        field_name = unique_fields(i);
        mask = data.field == field_name;

        % Store time and values for this field
        values.(matlab.lang.makeValidName(field_name)) = ...
            table(t_seconds(mask), t_hours(mask), data.value(mask), ...
                  'VariableNames', {'Time_s', 'Time_hr', 'Value'});
    end

    %% --- Output struct
    influx_data = struct();
    influx_data.time_s = t_seconds;
    influx_data.time = t_hours;
    influx_data.values = values;
    influx_data.raw_table = data;

    %% --- Optional plot
    if plotting
        Plot_Influx_Data(influx_data, mode);
    end

    fprintf('Loaded Influx data (%s): %d records across %d fields\n', ...
            mode, height(data), numel(unique_fields));
end
