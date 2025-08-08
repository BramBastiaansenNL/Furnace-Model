function Plot_Influx_Data(influx_data, mode)
    %% Visualize influx CSV electrical data
    %
    %   Inputs:
    %       influx_data - struct from Load_Influx_Data
    %       mode        - 'step' or 'cone', used in plot titles

    % Extract fields and time
    values = influx_data.values;
    fieldnames_plot = fieldnames(values);
    n_fields = numel(fieldnames_plot);
    colors = lines(n_fields);

    %% --- Plot 1: Subplots for each field
    figure('Name', 'Influx Data - Individual Fields', 'Color', 'w');
    for i = 1:n_fields
        subplot(n_fields, 1, i);
        field = fieldnames_plot{i};
        t = values.(field).Time_hr;
        y = values.(field).Value;

        plot(t, y, '-', 'Color', colors(i,:), 'LineWidth', 1.2);
        ylabel(field, 'Interpreter', 'none');
        if i == 1
            title(sprintf('Influx Data (%s mode)', mode));
        end
        if i == n_fields
            xlabel('Time [hours]');
        end
        grid on;
    end

    %% --- Plot 2: Combined Plot
    figure('Name', 'Influx Data - Combined Plot', 'Color', 'w');
    hold on;
    for i = 1:n_fields
        field = fieldnames_plot{i};
        t = values.(field).Time_hr;
        y = values.(field).Value;

        plot(t, y, 'LineWidth', 1.4, 'Color', colors(i,:), ...
             'DisplayName', field);
    end
    xlabel('Time [hours]');
    ylabel('Value');
    title(sprintf('Combined Influx Power Data (%s mode)', mode));
    legend('show', 'Location', 'best');
    grid on;
end
