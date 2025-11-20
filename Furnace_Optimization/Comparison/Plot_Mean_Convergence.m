function Plot_Mean_Convergence(res, color, label)
    % Interpolate all curves to common time base for averaging
    t_common = linspace(0, max(cellfun(@(x)x(end), res.all_time_log)), 200);
    J_interp = zeros(length(res.all_J_hist), length(t_common));

    for i = 1:length(res.all_J_hist)
        J_interp(i,:) = interp1(res.all_time_log{i}, res.all_J_hist{i}, t_common, 'linear', 'extrap');
    end

    plot(t_common, mean(J_interp,1), 'Color', color, 'LineWidth', 1.5, 'DisplayName', label);
end