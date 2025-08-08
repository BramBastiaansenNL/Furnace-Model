function [time_measurement, T_measurement, P_measurement, fm] = Load_Measurement_Data(mode, plotting, fm, t_cutoff)
    %% Loads and aligns furnace and external material measurements
    %
    %   Inputs:
    %       mode        - 'step' or 'cone', selects which measurement set to load
    %       plotting    - boolean flag to enable/disable plotting
    %       fm          - Furnace Model struct
    %       t_cutoff    - scalar cutoff time in seconds
    %
    %   Output:
    %       time_measurement : scalar duration of trimmed measurement run [s]
    %       T_measurement    : struct with fields:
    %                             .T_set    - Setpoint temperature [°C]
    %                             .T_furnace - Measured furnace air temperature [°C]
    %                             .T_material - Measured material temperature [°C]
    %       P_measurement    : power input [%], aligned with temperature vectors
    
    % t_cutoff : maximum time [s] to include (if omitted, use full valid range)
    if nargin < 4
        t_cutoff = inf; % default: no cutoff
    end

    if strcmp(mode, 'step')
        t_cutoff = inf;
        fm.settings.material_entry = 274; % Furnace door is opened and alloy placed inside
    end

    % --- Load raw tables
    furnace_data = Load_Furnace_Table(mode);
    external_data = Load_External_Table(mode);

    % --- Convert to datetime
    t_furnace_dt = furnace_data.Date_Time;

    % --- Filter valid external entries based on known good range
    external_data = Clip_Invalid_External_Data(external_data, mode);
    t_external_dt = external_data.Date_Time;

    % --- Convert time to seconds (relative to furnace start)
    t_furnace = seconds(t_furnace_dt - t_furnace_dt(1));
    t_external = seconds(t_external_dt - t_furnace_dt(1));  % align to furnace start

    % --- Interpolate material external temperature to furnace timestamps
    [T_material_ext, t_common, idx_valid] = Interpolate_And_Align(t_furnace, t_external, ...
                                                external_data.Material_External_Temp, t_cutoff);

    % --- Extract trimmed furnace data
    T_set      = furnace_data.T_set(idx_valid)' + 273.15;
    T_furnace  = furnace_data.T_furnace(idx_valid)' + 273.15;
    P_input    = furnace_data.Power(idx_valid)';
    T_material_int = furnace_data.T_material_int(idx_valid)' + 273.15;

    % --- Output time span and struct
    time_measurement = t_common(end) + fm.model.dt;
    T_measurement = struct( ...
        'T_set',           T_set, ...
        'T_furnace',       T_furnace, ...
        'T_material_ext',  T_material_ext, ...
        'T_material_int',  T_material_int ...
    );
    P_measurement = (P_input / 100) * fm.controller.P_max;

    % --- Optional plotting
    if plotting
        Segment = furnace_data.Segment(idx_valid)';
        Plot_Measurement_Curves(time_measurement, T_set, T_furnace, ...
                                T_material_ext, T_material_int, Segment, P_input);
    end

    fprintf('Load_Measurement_Data (%s): using %d points (%.2f h)\n', ...
        mode, length(idx_valid), time_measurement / 3600);
end
