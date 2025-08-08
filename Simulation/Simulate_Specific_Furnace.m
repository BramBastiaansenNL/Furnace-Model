function [T_simulation, fm] = Simulate_Specific_Furnace(P, fm)
    %% Implicit Numerical Solver for 1D Heat Diffusion Equation
    
    % Initialize
    Nt = fm.model.Nt;                            % Number of time steps
    [T_walls, T_furnace, T_alloy, T_metal_sheet, Power_curve, T_heater] = Initialize_Temperatures(fm, Nt);

    % Determine if material is present inside the furnace
    if fm.settings.material_entry
        h_f_al = fm.furnace.h_f_al;
        h_f_aA_a = fm.constants.h_f_aA_a;
        fm = Remove_Alloy(fm);
    end

    %% Implicit Time-Stepping Loop
    for k = 1:Nt-1

        % Compute power input into the system
        Power_curve(k) = P(k);

        % Compute the temperature-dependent specfic heat capacity of the alloy
        if k >= fm.settings.material_entry
            if k == fm.settings.material_entry
                fm.furnace.h_f_al = h_f_al;
                fm.constants.h_f_aA_a = h_f_aA_a;
            end
            fm = Compute_Specific_Heat(T_alloy(k), fm);
        end

        % Compute the temperature-dependent density of the furnace air
        fm = Compute_Air_Density(T_furnace(k), fm);

        % Solve system of PDEs and ODEs numerically
        if k == 1
            % First step
            [T_furnace(k+1), T_alloy(k+1), T_walls(:, :, k+1), T_metal_sheet(k+1), T_heater(k+1), ~, fm] = ...
                Newton_Raphson_Iteration(T_furnace(k), T_alloy(k), T_walls(:, :, k), T_metal_sheet(k), T_heater(k), fm, Power_curve(k), k+1);
       
        else
            % Subsequent steps extrapolate initial guesses
            [T_furnace(k+1), T_alloy(k+1), T_walls(:, :, k+1), T_metal_sheet(k+1), T_heater(k+1), ~, fm] = ...
                Newton_Raphson_Iteration(T_furnace(k), T_alloy(k), T_walls(:, :, k), T_metal_sheet(k), T_heater(k), ...
                fm, Power_curve(k), k+1, T_furnace(k-1), T_alloy(k-1), T_walls(:, :, k-1), T_metal_sheet(k-1), T_heater(k-1));
        end
    end
    
    % Store the relevant temperature profiles
    T_simulation.T_f_curve = T_furnace;
    T_simulation.T_m_curve = T_alloy;
    T_simulation.T_w_curve = T_walls;
    T_simulation.T_ms_curve = T_metal_sheet;
    T_simulation.T_h_curve = T_heater;
    T_simulation.Power_curve = Power_curve;
end