function Plot_3D_Contour(t_range, Temp_range, J_matrix, feasible_mask, title_str)
    % Plots a 3D contour map of the cost function with feasible region overlay

    [t_grid, T_grid] = meshgrid(t_range, Temp_range);

    % Find the minimum
    [min_val, idx] = min(J_matrix(:));
    [i_min, j_min] = ind2sub(size(J_matrix), idx);
    t_min = t_range(j_min);
    T_min = Temp_range(i_min);

    % Main 3D contour plot
    figure;
    contour3(t_grid, T_grid, J_matrix, 30);
    hold on;

    % Mark the minimum point
    plot3(t_min, T_min, min_val, 'r*', 'MarkerSize', 10, 'LineWidth', 2);

    % Overlay feasible region as scatter plot (optional)
    if nargin > 3 && ~isempty(feasible_mask)
        [i_f, j_f] = find(feasible_mask);
        t_feas = t_range(j_f);
        T_feas = Temp_range(i_f);
        z_feas = J_matrix(sub2ind(size(J_matrix), i_f, j_f));
        scatter3(t_feas, T_feas, z_feas, 10, 'k', 'filled', 'DisplayName', 'Feasible');
    end

    colormap parula;
    colorbar;
    xlabel('Process Time (s)');
    ylabel('Furnace Temperature (°C)');
    zlabel('Cost');
    title(['3D Contour Plot: ', title_str]);
    grid on;
    hold off;
end