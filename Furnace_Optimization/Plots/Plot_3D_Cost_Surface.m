function Plot_3D_Cost_Surface(t_range, Temp_range, J_matrix, title_str)
    % Plots a 3D surface plot of the cost function

    [t_grid, T_grid] = meshgrid(t_range, Temp_range);

    % Find the minimum
    [min_val, idx] = min(J_matrix(:));
    [i_min, j_min] = ind2sub(size(J_matrix), idx);
    t_min = t_range(j_min);
    Temp_min = Temp_range(i_min);

    % Plot
    figure;
    surf(t_grid, T_grid, J_matrix, 'EdgeColor', 'none');
    % shading interp;
    hold on;
    plot3(t_min, Temp_min, min_val, 'r*', 'MarkerSize', 10, 'LineWidth', 2); % Min point
    hold off;

    colormap turbo;
    colorbar;
    xlabel('Process Time (s)');
    ylabel('Furnace Temperature (°C)');
    zlabel('Cost');
    title(['3D Surface Plot: ', title_str]);
    view(135, 30);
    grid on;
end