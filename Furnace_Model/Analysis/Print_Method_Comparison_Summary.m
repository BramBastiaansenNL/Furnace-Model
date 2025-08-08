function Print_Method_Comparison_Summary(T_furnace_NR, T_alloy_NR, T_metal_sheet_NR, ...
                                         T_furnace_FS, T_alloy_FS, T_metal_sheet_FS, time_NR, time_fsolve)
    % Prints out some comparison statistics between different solver methods

    fprintf('\n====== Solver Comparison Summary ======\n');
    
    err_furnace = max(abs(T_furnace_FS - T_furnace_NR));
    err_alloy   = max(abs(T_alloy_FS   - T_alloy_NR));
    err_sheet   = max(abs(T_metal_sheet_FS - T_metal_sheet_NR));

    fprintf('Max Temp Difference (Furnace):      %.4f K\n', err_furnace);
    fprintf('Max Temp Difference (Alloy):        %.4f K\n', err_alloy);
    fprintf('Max Temp Difference (Metal Sheet):  %.4f K\n', err_sheet);

    fprintf('\n------ L2 Norm Over Time Series ------\n');
    fprintf('||T_f_NR - T_f_FS||₂  = %.4f\n', norm(T_furnace_NR - T_furnace_FS, 2));
    fprintf('||T_a_NR - T_a_FS||₂  = %.4f\n', norm(T_alloy_NR - T_alloy_FS, 2));
    fprintf('||T_ms_NR - T_ms_FS||₂ = %.4f\n', norm(T_metal_sheet_NR - T_metal_sheet_FS, 2));

    fprintf('\nExecution Time:\n');
    fprintf('Newton-Raphson: %.4f seconds\n', time_NR);
    fprintf('fsolve:         %.4f seconds\n', time_fsolve);
end
