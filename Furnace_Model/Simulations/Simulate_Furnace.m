function [T_walls, T_furnace, T_alloy, T_metal_sheet, Power_Curve, T_heater, fm] = ...
    Simulate_Furnace(T_f_desired, t, fm, N)
    %% Selects between explicit, implicit or comparison temperature models.
    
    % Update the simulation duration and the number of time steps
    if nargin < 4, N = 1; end
    fm = Update_Furnace_Model(fm, t, N);

    if strcmpi(fm.method, 'explicit')
        error('Explicit method is outdated and no longer supported. Please use the implicit method.');

    elseif strcmpi(fm.method, 'implicit')
        [T_walls, T_furnace, T_alloy, T_metal_sheet, Power_Curve, T_heater, fm] = ...
            Implicit_Solver(T_f_desired, fm);

    elseif strcmpi(fm.method, 'comparison')
        [T_walls, T_furnace, T_alloy, T_metal_sheet, Power_Curve, T_heater, fm] = ...
            Compare_Solvers(T_f_desired, fm);
        
    elseif strcmpi(fm.method, 'fsolve')
        [T_walls, T_furnace, T_alloy, T_metal_sheet, Power_Curve, T_heater, fm] = ...
            Matlab_f_Solver(T_f_desired, fm);
    else
        error('Invalid method. Use "implicit", "explicit", "fsolve" or "comparison".');
    end

    % Compute derivatives
    if fm.settings.store_derivatives
        fm = Compute_Full_Derivative(T_walls, T_heater, fm);
    end
end