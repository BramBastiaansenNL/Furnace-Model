%% Multi-start Optimization Wrapper
clear; clc; close all;
clear Furnace_Simulation_Cache;
Add_Paths2();
furnace_model = Furnace_Model();
constraints = Model_Constraints();
furnace_model.settings = Select_Optimization_Model_Settings(furnace_model.settings);

num_starts = 5;
best_J = Inf;
best_result = struct();
J_all = zeros(num_starts, 1);

% Settings
N = 3;                     % Number of steps in T_f
T_bounds = [290, 800];     % [K] bounds for temperature
t_bounds = [0, 3600 * 5];  % [s] bounds for process time

% Scenario
furnace_model.model.mech_w = 1000;   % Default 1000
furnace_model.model.time_w = 10;   % Default 10
furnace_model.model.power_w = 1;  % Default 1
furnace_model.model.w_YS = 2;     % Default 2
furnace_model.model.w_UTS = 1;    % Default 1
furnace_model.model.w_UE = 0.2;     % Default 0.5

fprintf('Running Multi-Start Optimization with %d random initializations...\n', num_starts);

tic;
for i = 1:num_starts
    % Random initial guess in bounds
    T_f_init = T_bounds(1) + (T_bounds(2) - T_bounds(1)) * rand(1, N);
    t_init = t_bounds(1) + (t_bounds(2) - t_bounds(1)) * rand(1, 1);
    initial_guess = [T_f_init, t_init];

    try
        [T_f_opt, t_opt, J_hist, results] = Optimize_Time_Temperature(furnace_model, constraints, initial_guess, N);
    catch ME
        warning('Optimization failed at start %d: %s', i, ME.message);
        continue;
    end

    J_all(i) = J_hist(end);

    if J_all(i) < best_J
        best_J = J_all(i);
        best_result.T_f_opt = T_f_opt;
        best_result.t_opt = t_opt;
        best_result.J_hist = J_hist;
        best_result.results = results;
        best_result.initial_guess = initial_guess;
        best_result.start_index = i;
    end

    fprintf('  [%2d/%2d] J = %.4f\n', i, num_starts, J_hist(end));
end
optimization_time = toc;
fprintf('\nOptimization Completed in %.4f seconds\n', optimization_time);

%% Display Best Result
fprintf('\n==== Best Multi-Start Result ====\n');
fprintf('Start #%d\n', best_result.start_index);
fprintf('Initial guess: T = [%.2f], t = %.2f\n', best_result.initial_guess(1:end-1), best_result.initial_guess(end));
for i = 1:numel(best_result.T_f_opt)
    fprintf('Optimal Furnace Temp %d : %.2f K (%.2f °C)\n', ...
        i, best_result.T_f_opt(i), best_result.T_f_opt(i) - 273.15);
end
fprintf('Optimal t: %.2f sec = %.2f h\n', best_result.t_opt, best_result.t_opt / 3600);
fprintf('Optimal J: %.4f\n', best_result.J_hist(end));

YS_final  = best_result.results.mechanical_properties.YS(end);
UTS_final = best_result.results.mechanical_properties.UTS(end);
UE_final  = best_result.results.mechanical_properties.UE(end);
fprintf('  Yield Strength (YS): %.2f MPa\n', YS_final);
fprintf('  Ultimate Tensile Strength (UTS): %.2f MPa\n', UTS_final);
fprintf('  Uniform Elongation (UE): %.2f %%\n', UE_final);

Plot_Results(furnace_model, best_result.t_opt, best_result.T_f_opt, best_result.results);

Save_Optimization_Results(furnace_model, constraints, initial_guess, N, ...
    best_result.T_f_opt, best_result.t_opt, best_result.J_hist, best_result.results, optimization_time);