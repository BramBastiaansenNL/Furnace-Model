function Plot_Alloy_Temperature_Distribution(T_m, fm)
    %% Plots the alloy temperature distribution

    T_final = T_m(:, end);        % temperature at final time
    nNodes = length(T_final);
    r = linspace(0, 1, nNodes);   % normalized radius (0=center, 1=surface)
    theta = linspace(0, 2*pi, 200);
    
    [R, TH] = meshgrid(r, theta);
    T_plot = interp1(r, T_final, R(1,:));   % interpolate along radius
    T_plot = repmat(T_plot, length(theta), 1);
    
    % Convert to Cartesian for plotting
    [X, Y] = pol2cart(TH, R);
    
    figure;
    pcolor(X, Y, T_plot);
    shading interp; axis equal; colorbar;
    title('Final Temperature Distribution (Cross-section)');
    xlabel('x [normalized radius]');
    ylabel('y [normalized radius]');
    colormap(turbo);
end