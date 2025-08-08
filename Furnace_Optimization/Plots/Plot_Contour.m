function Plot_Contour(t_range, Temp_range, J_matrix, feasible_mask, title_str)
    % Plots a 2D contour map of the cost function with optional feasible region overlay

    % Create meshgrid
    [t_grid, T_grid] = meshgrid(t_range, Temp_range);

    % Plot the filled contour of the cost function
    figure;
    contourf(t_grid, T_grid, log10(J_matrix), 30, 'LineColor', 'none');
    hold on;
    colormap parula;
    colorbar;
    
    % Overlay contour line of feasible region
    % Contour at the transition between feasible and infeasible
    % So convert logical mask to numeric (0/1)
    feasibility_numeric = double(feasible_mask);
    h = contour(t_grid, T_grid, feasibility_numeric, [0.5 0.5], 'k--', 'LineWidth', 2);
    % Label the line if it's a contour group
    if isgraphics(h, 'contour')
        h.DisplayName = 'Feasible Boundary';
    end

    % Mark the minimum cost point
    [~, idx] = min(J_matrix(:));
    [i_min, j_min] = ind2sub(size(J_matrix), idx);
    t_min = t_range(j_min);
    T_min = Temp_range(i_min);
    plot(t_min, T_min, 'r*', 'MarkerSize', 10, 'LineWidth', 2);

    % Labels and title
    xlabel('Process Time (s)');
    ylabel('Furnace Temperature (°C)');
    title(['Contour Plot: ', title_str]);
    legend('show');
    grid on;
    hold off;
end