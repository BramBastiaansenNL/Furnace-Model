function [T_walls, T_furnace, T_alloy, T_metal_sheet, Power_Curve, T_heater, fm] = ...
    Matlab_f_Solver(T_f_desired, fm)
    %% Matlab's built-in function solver for implicit furnace, alloy, metal sheet and wall temperature update
    
    % Initialize
    Nt = fm.model.Nt;                            % Number of time steps
    dt = fm.model.dt;                            % Time-step-size
    integral_error = 0;                          % Initialize integral error
    prev_error = 0;                              % Initialize previous error
    [T_walls, T_furnace, T_alloy, T_metal_sheet, Power_Curve, T_heater] = Initialize_Temperatures(fm, Nt);

    %% Implicit Time-Stepping Loop
    for k = 1:Nt-1

        % Compute power input into the system
        [Power_Curve(k), integral_error, prev_error, fm] = ...
            Compute_Power_Supply(T_f_desired, T_furnace(k), integral_error, ...
                                 prev_error, dt, fm);

        % Compute the temperature-dependent specfic heat capacity of the alloy
        if fm.settings.alloy_present
            fm = Compute_Specific_Heat(T_alloy(k), fm);
        end

        % Compute the temperature-dependent density of the furnace air
        fm = Compute_Air_Density(T_furnace(k), fm);

        % Solve system of PDEs and ODEs numerically
        if k == 1
            % First step
            [T_furnace(k+1), T_alloy(k+1), T_walls, T_metal_sheet(k+1), T_heater(k+1)] = ...
                Solve_f_Solve(T_furnace(k), T_alloy(k), T_walls, T_metal_sheet(k), T_heater(k), fm, Power_Curve(k));
        
        else
            % Subsequent steps extrapolate initial guesses
            [T_furnace(k+1), T_alloy(k+1), T_walls, T_metal_sheet(k+1), T_heater(k+1)] = ...
                Solve_f_Solve(T_furnace(k), T_alloy(k), T_walls, T_metal_sheet(k), T_heater(k), fm, Power_Curve(k), ...
                                   T_furnace(k-1), T_alloy(k-1), T_metal_sheet(k-1), T_heater(k-1));
        end
    end
end
