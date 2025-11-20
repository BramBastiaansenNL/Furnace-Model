%% Global Optimization using MultiStart

clear; clc; close all;
clear Furnace_Simulation_Cache;
Add_Paths2();
furnace_model = Furnace_Model();
constraints = Model_Constraints();
furnace_model.settings = Select_Optimization_Model_Settings(furnace_model.settings);

% Create problem
N = 3;
t_lb = 0; t_ub = 3600 * 10;
T_lb = 290 * ones(1, N);  T_ub = 1000 * ones(1, N);
x0 = [450, 500, 550, 3600];

% Define objective wrapper
fun = @(x) Optimize_Time_Temperature_Wrapper(x, furnace_model, constraints, N);

problem = createOptimProblem('fmincon', ...
    'objective', fun, ...
    'x0', x0, ...
    'lb', [T_lb, t_lb], ...
    'ub', [T_ub, t_ub], ...
    'options', optimoptions('fmincon', 'Display', 'none'));

tic;
ms = MultiStart('Display', 'iter', 'UseParallel', true);
[x_opt, fval, exitflag, output, manymins] = run(ms, problem, 20);  % 20 starts
optimization_time = toc;
fprintf('\nOptimization Completed in %.4f seconds\n', optimization_time);