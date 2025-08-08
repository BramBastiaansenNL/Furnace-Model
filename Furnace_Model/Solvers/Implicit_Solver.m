function [T_walls, T_furnace, T_alloy, T_metal_sheet, Power_Curve, T_heater, fm] = ...
    Implicit_Solver(T_f_desired, fm)
    %% Implicit Numerical Solver for 1D Heat Diffusion Equation
    
    % Initialize
    walls = fm.walls;
    Nt = fm.model.Nt;                            % Number of time steps
    dt = fm.model.dt;                            % Time-step-size
    integral_error = 0;                          % Initialize integral error
    prev_error = 0;                              % Initialize previous error
    iterations_per_time_step = zeros(1, Nt);     % Store number of Newton-Raphson iterations for this time step
    [T_walls, T_furnace, T_alloy, T_metal_sheet, Power_Curve, T_heater] = Initialize_Temperatures(fm, Nt);

    % ---------------------------------------------------------------------------------------------------------------- % 
    % [Optional] ---> For plotting (wall) temperature distribution over time 
    if fm.settings.dynamic_wall_plotting
        figure; hold on; grid on;
        x_positions = linspace(0, walls.side1.L_wall, walls.Nx);
        num_plots = 10;
        plot_interval = floor(Nt / num_plots);  % Calculate step interval for plotting
    end
    % ---------------------------------------------------------------------------------------------------------------- % 

    %% Implicit Time-Stepping Loop
    for k = 1:Nt-1

        % Compute power input into the system
        [Power_Curve(k), integral_error, prev_error, fm] = ...
            Compute_Power_Supply(T_f_desired, T_furnace(k), integral_error, ...
                                 prev_error, dt, fm, k);

        % Compute the temperature-dependent specfic heat capacity of the alloy
        if fm.settings.alloy_present
            fm = Compute_Specific_Heat(T_alloy(k), fm);
        end

        % Compute the temperature-dependent density of the furnace air
        fm = Compute_Air_Density(T_furnace(k), fm);

        % Solve system of PDEs and ODEs numerically
        if k == 1
            % First step
            [T_furnace(k+1), T_alloy(k+1), T_walls(:, :, k+1), T_metal_sheet(k+1), T_heater(k+1), ...
                iterations_per_time_step(k), fm] = ...
                Newton_Raphson_Iteration(T_furnace(k), T_alloy(k), T_walls(:, :, k), T_metal_sheet(k), ...
                                     T_heater(k), fm, Power_Curve(k), k+1);
        
        else
            % Subsequent steps extrapolate initial guesses
            [T_furnace(k+1), T_alloy(k+1), T_walls(:, :, k+1), T_metal_sheet(k+1), T_heater(k+1), ...
                iterations_per_time_step(k), fm] = ...
                Newton_Raphson_Iteration(T_furnace(k), T_alloy(k), T_walls(:, :, k), T_metal_sheet(k), ...
                                    T_heater(k), fm, Power_Curve(k), k+1, ...
                                    T_furnace(k-1), T_alloy(k-1), T_walls(:, :, k-1), T_metal_sheet(k-1), T_heater(k-1));
        end
      

        % ---------------------------------------------------------------------------------------------------------------- % 
        % Visualization (Optional)
        if fm.settings.dynamic_wall_plotting && mod(k, plot_interval) == 0
            % Convert temperature to Celsius for better interpretation
            T_wall_C = T_walls(1, :, k) - 273.15;  % Plotting just the side wall
        
            % Grid discretization for layers
            y_min = min(T_wall_C) - 20;  % A little padding for the y-axis
            y_max = max(T_wall_C) + 100;  % A little padding for the y-axis
            
            % If it's the first time, plot the background and fill the layers
            if k == plot_interval
                % Start the plot
                area(x_positions, T_wall_C, 'FaceColor', [1 0.8 0.8], 'FaceAlpha', 0.3, 'EdgeAlpha', 0);
                
                % Layer shading (two layers)
                fill([0, walls.side1.boundary1, walls.side1.boundary1, 0], ...
                     [y_min, y_min, y_max, y_max], ...
                     [1 0.95 0.8], 'FaceAlpha', 0.2, 'EdgeColor', 'none');
                
                fill([walls.side1.boundary1, walls.side1.L_wall, walls.side1.L_wall, walls.side1.boundary1], ...
                     [y_min, y_min, y_max, y_max], ...
                     [0.7 0.7 0.7], 'FaceAlpha', 0.2, 'EdgeColor', 'none');
                
                % Plot the boundaries
                plot([0, 0], [y_min, y_max], 'k', 'LineWidth', 2);
                plot([walls.side1.boundary1, walls.side1.boundary1], [y_min, y_max], 'k--', 'LineWidth', 1.5);
                plot([walls.side1.L_wall, walls.side1.L_wall], [y_min, y_max], 'k', 'LineWidth', 2);
            end
        
            % Now plot the actual temperature curve for this time step
            plot(x_positions, T_wall_C, 'LineWidth', 2);
        
            % Axis limits (keep these constant)
            padding = 0.02 * walls.side1.L_wall;
            xlim([-padding, walls.side1.L_wall]);
            ylim([y_min, y_max]);
        
            % Update the plot in real-time
            drawnow;
            pause(0.5);
        end
        % ---------------------------------------------------------------------------------------------------------------- %
    end

    % ---------------------------------------------------------------------------------------------------------------- %
    if fm.settings.dynamic_wall_plotting
        % Labels and title (update the title with the current time step)
        xlabel('$\textbf{Position in Wall } (m)$', 'Interpreter', 'latex', 'FontSize', 14);
        ylabel('$\textbf{Temperature } (^{\circ}C)$', 'Interpreter', 'latex', 'FontSize', 14);
        title('Side Wall Temperature Distribution', 'Interpreter', 'latex', 'FontSize', 16);
    
        % Label the wall layers
        text(walls.side1.boundary1/2, y_max - 2, 'Insulation', ...
             'Interpreter', 'latex', 'FontSize', 12, 'HorizontalAlignment', 'center');
        hold off;
    end
    % ---------------------------------------------------------------------------------------------------------------- % 

    % ---------------------------------------------------------------------------------------------------------------- % 
    if fm.settings.debugging
        Plot_Newton_Raphson_Iterations(Nt, iterations_per_time_step, dt)
    end
    % ---------------------------------------------------------------------------------------------------------------- % 
end