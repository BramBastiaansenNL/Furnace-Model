function [T_walls, T_furnace, T_alloy, T_metal_sheet, Power_Curve, T_heater, fm] = ...
    Compare_Solvers(T_f_desired, fm)
    %% Compares Newton-Raphson and fsolve methods.
    
    % --- 1. Newton-Raphson ---
    tic;
    [T_walls_NR, T_furnace_NR, T_alloy_NR, T_metal_sheet_NR, Power_Curve_NR, ~] = ...
        Implicit_Solver(T_f_desired, fm);
    time_NR = toc;
    
    % --- 2. fsolve ---
    tic;
    [T_walls, T_furnace, T_alloy, T_metal_sheet, Power_Curve, T_heater] = ...
        Matlab_f_Solver(T_f_desired, fm);
    time_fsolve = toc;
    
    % --- 3. Plotting Results ---
    Plot_Solver_Comparisons(T_furnace_NR, T_alloy_NR, T_metal_sheet_NR, T_walls_NR, Power_Curve_NR, ...
                            T_furnace, T_alloy, T_metal_sheet, T_walls, Power_Curve, ...
                            fm)

    % --- 4. Error Summary ---
    Print_Method_Comparison_Summary(T_furnace_NR, T_alloy_NR, T_metal_sheet_NR, ...
                                    T_furnace,    T_alloy,    T_metal_sheet, time_NR, time_fsolve);
end
