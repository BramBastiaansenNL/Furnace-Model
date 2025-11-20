function Display_Simulated_Results(results, T_f_opt, t_opt, N, constraints, curve_parameterization)
    %% Projects x onto the feasible mechanical set by solving a QP.

    alpha = results.alpha_opt;   % Extract alpha from results struct
    fm = Furnace_Model();
    fm.settings.curve_parameterization = curve_parameterization; % Options are 'constant' or 'linear'
    fm.settings.desired_temp_curve_specified = false;
    fm.settings.alloy_temperature_distribution = false;
    fm.settings.symbolic_differentiation = false;
    fm.settings.mechanical_loss = true;
    fm.model.N = N;
    
    %% Run simulation
    x = [T_f_opt, alpha, t_opt];
    [actual_results] = Get_Or_Run_Simulation(x, fm);
    actual_results.alpha_opt = alpha;
    
    %% Plot results
    Plot_Results(fm, t_opt, T_f_opt, actual_results);
    
    %% Display mechanical properties and final loss
    YS_final  = actual_results.mechanical_properties.YS(end);
    UTS_final = actual_results.mechanical_properties.UTS(end);
    UE_final  = actual_results.mechanical_properties.UE(end);
    
    J = Compute_Cost_Function(x, fm, constraints, fm.model.N);
    
    fprintf('Final Mechanical Properties:\n');
    fprintf('  Yield Strength (YS): %.2f MPa\n', YS_final);
    fprintf('  Ultimate Tensile Strength (UTS): %.2f MPa\n', UTS_final);
    fprintf('  Uniform Elongation (UE): %.2f %%\n', UE_final);
    fprintf('Final Loss Function Value: %.6f\n', J);
    fprintf('\n--- Optimal Results ---\n');
    fprintf('Optimal Furnace Temp : %.2f K (%.2f °C)\n', T_f_opt, T_f_opt - 273.15);
    fprintf('Optimal Time Segment Durations : %.2f\n', alpha);
    fprintf('Optimal Process Time : %.2f s (%.2f hours)\n', t_opt, t_opt/3600);
end
