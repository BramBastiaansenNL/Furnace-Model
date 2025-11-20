function Save_Optimization_Results(fm, constraints, initial_guess, N, ...
    T_f_opt, t_opt, J_hist, results, optimization_time)
    %% Saves optimization metadata, results, and plots
    %
    %   Creates a timestamped results folder and stores:
    %       - Optimization summary (.txt)
    %       - All relevant MATLAB variables (.mat)
    %       - Figures (.png)

    % === Create results directory ===
    results.curve_parameterization = fm.settings.curve_parameterization;
    results_root = fullfile(pwd, 'Optimization_Results_New');
    if ~exist(results_root, 'dir')
        mkdir(results_root);
    end

    % Timestamped subfolder for this run
    timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    % Collect metadata
    curve_param = fm.settings.curve_parameterization;   % e.g. 'constant'
    optimizer   = fm.settings.optimizer;                % e.g. 'fmincon'
    J_final     = J_hist(end);                          % cost function value
    % Build descriptive run name
    run_name = sprintf('%.3f_%s_%d_%s_%s', ...
        J_final, curve_param, N, optimizer, timestamp);
    % Final folder path
    run_folder = fullfile(results_root, run_name);
    mkdir(run_folder);

    % === Save figures ===
    figHandles = findall(0, 'Type', 'figure');
    for i = 1:numel(figHandles)
        figName = sprintf('Figure_%d.png', i);
        saveas(figHandles(i), fullfile(run_folder, figName));
    end

    % === Save MATLAB workspace variables ===
    mat_filename = fullfile(run_folder, 'Optimization_Results.mat');
    save(mat_filename, 'fm', 'constraints', 'initial_guess', ...
        'N', 'T_f_opt', 't_opt', 'J_hist', 'results', 'optimization_time');

    % === Create human-readable summary file ===
    txt_filename = fullfile(run_folder, 'Optimization_Results.txt');
    fid = fopen(txt_filename, 'w');

    fprintf(fid, '=== OPTIMIZATION RESULTS ===\n');
    fprintf(fid, 'Date & Time          : %s\n', datestr(now));
    fprintf(fid, 'Optimization Time    : %.4f seconds (%.2f minutes)\n', ...
        optimization_time, optimization_time/60);
    fprintf(fid, 'Cost Function Value  : %.6f\n', J_hist(end));
    fprintf(fid, '\n--- Optimization Settings ---\n');
    fprintf(fid, 'Algorithm            : %s\n', fm.settings.algorithm);
    fprintf(fid, 'Optimizer            : %s\n', fm.settings.optimizer);
    fprintf(fid, 'Curve Parametrization: %s\n', fm.settings.curve_parameterization);
    fprintf(fid, 'Number of Intervals  : %d\n', N);
    fprintf(fid, 'Weight for power cost: %.2f\n', fm.model.power_w);
    fprintf(fid, 'Weight for time cost: %.2f\n', fm.model.time_w);
    fprintf(fid, 'Weight for mechanical cost: %.2f\n', fm.model.mech_w);
    fprintf(fid, 'Weight for Yield Strength: %.2f\n', fm.model.w_YS);
    fprintf(fid, 'Weight for Ultimate Tensile Strength: %.2f\n', fm.model.w_UTS);
    fprintf(fid, 'Weight for Uniform Elongation: %.2f\n', fm.model.w_UE);
    fprintf(fid, '\n--- Optimal Results ---\n');
    for i = 1:numel(T_f_opt)
        fprintf(fid, 'Optimal Furnace Temp %d : %.2f K (%.2f °C)\n', ...
            i, T_f_opt(i), T_f_opt(i) - 273.15);
    end
    fprintf(fid, 'Optimal Time Segment Durations : %.2f\n', results.alpha_opt);
    fprintf(fid, 'Optimal Process Time : %.2f s (%.2f hours)\n', t_opt, t_opt/3600);
    
    if fm.settings.alloy_temperature_distribution
        % Inner and outer node mechanical properties
        M_inner = results.mechanical_properties{1};
        M_outer = results.mechanical_properties{numel(results.rep_nodes)};
        
        % Final values
        YS_inner  = M_inner.YS(end);
        UTS_inner = M_inner.UTS(end);
        UE_inner  = M_inner.UE(end);
        
        YS_outer  = M_outer.YS(end);
        UTS_outer = M_outer.UTS(end);
        UE_outer  = M_outer.UE(end);
        
        % Print both
        fprintf(fid, 'Yield Strength (YS) - Inner Node: %.2f MPa\n', YS_inner);
        fprintf(fid, 'Yield Strength (YS) - Outer Node: %.2f MPa\n', YS_outer);
        fprintf(fid, 'Ultimate Tensile Strength (UTS) - Inner Node: %.2f MPa\n', UTS_inner);
        fprintf(fid, 'Ultimate Tensile Strength (UTS) - Outer Node: %.2f MPa\n', UTS_outer);
        fprintf(fid, 'Uniform Elongation (UE) - Inner Node: %.2f %%\n', UE_inner);
        fprintf(fid, 'Uniform Elongation (UE) - Outer Node: %.2f %%\n', UE_outer);
    else
        % Single-node case
        YS_final  = results.mechanical_properties.YS(end);
        UTS_final = results.mechanical_properties.UTS(end);
        UE_final  = results.mechanical_properties.UE(end);
        fprintf(fid, 'Yield Strength (YS): %.2f MPa\n', YS_final);
        fprintf(fid, 'Ultimate Tensile Strength (UTS): %.2f MPa\n', UTS_final);
        fprintf(fid, 'Uniform Elongation (UE): %.2f %%\n', UE_final);
    end

    fclose(fid);

    % === Notify user ===
    fprintf('\nOptimization results saved in:\n%s\n', run_folder);
end
