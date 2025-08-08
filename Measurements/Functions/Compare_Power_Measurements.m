function Compare_Power_Measurements(P_measurement, t_meas, influx_data, mode)
    %% Overlay furnace and influx power data
    %
    %   Inputs:
    %       P_measurement : 1 x N double of power values [% or W]
    %       t_meas        : 1 x N double of timestamps [s]
    %       influx_data   : struct returned by Load_Influx_Data
    %       mode          : string 'step' or 'cone' for plot labeling

    fields = {'Wirkleistung', 'Strom', 'Scheinleistung'};

    % Convert t_meas to hours for plotting
    t_meas_hr = t_meas / 3600;

    % Define soft contrasting colors (custom RGB values)
    color_P = [0.1 0.4 0.8];          % soft blue
    color_field = [0.8 0.2 0.2];      % soft red

    % Loop over each field and plot separately
    for i = 1:numel(fields)
        field = fields{i};
        t_influx = influx_data.values.(field).Time_hr;
        y_influx = influx_data.values.(field).Value;

        % Interpolate influx data to match P_measurement time base
        y_interp = interp1(t_influx, y_influx, t_meas_hr, 'linear', 'extrap');

        % Plot
        figure('Name', sprintf('P vs %s (%s)', field, mode), 'Color', 'w');
        plot(t_meas_hr, y_interp, '--', 'LineWidth', 1.4, ...
             'Color', color_field + 0.4*(1 - color_field), 'DisplayName', field);
        hold on;
        plot(t_meas_hr, P_measurement, '-', 'LineWidth', 1.4, ...
             'Color', color_P + 0.3*(1 - color_P), 'DisplayName', 'P_{measurement}');

        title(sprintf('P_{measurement} vs %s (%s mode)', field, mode), 'Interpreter', 'none');
        xlabel('Time [hours]');
        ylabel('Power / Current');
        legend('Location', 'best');
        grid on;
    end
end
