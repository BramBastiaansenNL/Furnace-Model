%% Global Optimization using GlobalSearch

clear; clc; close all;
clear Furnace_Simulation_Cache;
Add_Paths2();
furnace_model = Furnace_Model();
constraints = Model_Constraints();
furnace_model.settings = Select_Optimization_Model_Settings(furnace_model.settings);

% Problem dimensions
N = 3;  % number of temperature steps

% Temperature bounds [K]
T_lb = 290 * ones(1, N);
T_ub = 1000 * ones(1, N);

% Time bounds [s]
t_lb = 0;    % 0.5 h
t_ub = 3600 * 10;   % 4 h

alpha_lb = zeros(1, N);
alpha_ub = ones(1, N);

% Full bounds
lb = [T_lb, alpha_lb, t_lb];
ub = [T_ub, alpha_ub, t_ub];

% Initial guess (midpoint)
alpha0 = (1/N) * ones(1, N);
x0 = [(T_lb + T_ub)/2, alpha0, (t_lb + t_ub)/2];

Aeq = [zeros(1, N), ones(1, N), 0];  % sum of alphas = 1
beq = 1;

% Objective wrapper
fun = @(x) Optimize_Time_Temperature_Wrapper(x, furnace_model, constraints, N);

% Optimization options
opts = optimoptions('fmincon', ...
    'Display', 'off', ...
    'MaxFunctionEvaluations', 1e4, ...
    'MaxIterations', 500, ...
    'Algorithm', 'sqp');

% Define optimization problem
problem = createOptimProblem('fmincon', ...
    'objective', fun, ...
    'x0', x0, ...
    'lb', lb, ...
    'ub', ub, ...
    'Aeq', Aeq, ...
    'beq', beq, ...
    'options', opts);

% Create GlobalSearch object
gs = GlobalSearch('Display', 'iter', 'NumStageOnePoints', 50, 'NumTrialPoints', 200);

% Run the optimization
tic;
[x_gs, J_gs, ~, ~, solutions] = run(gs, problem);
optimization_time = toc;
fprintf('\nOptimization Completed in %.4f seconds\n', optimization_time);

% Extract final temperature and time
T_f_gs   = x_gs(1:N);
alpha_opt = x_gs(N+1:2*N);
t_gs     = x_gs(end);

% Run final simulation for results
[results_gs] = Get_Or_Run_Simulation(x_gs, furnace_model);
results_gs.alpha_opt = alpha_opt;

%% Display results
fprintf('\n=== GlobalSearch Optimization ===\n');
fprintf('T_f (K): [%.2f]\n', T_f_gs);
fprintf('T_f (°C): [%.2f]\n', T_f_gs - 273.15);
fprintf('t_opt = %.2f s = %.2f h\n', t_gs, t_gs/3600);
fprintf('Optimal cost J = %.4f\n', J_gs);

Plot_Results(furnace_model, t_gs, T_f_gs, results_gs);

fprintf('\n--- All Found Solutions (J values) ---\n');
for i = 1:length(solutions)
    fprintf('#%2d: J = %.4f\n', i, solutions(i).Fval);
end

Save_Optimization_Results(furnace_model, constraints, x0, N, ...
    T_f_gs, t_gs, J_gs, results_gs, optimization_time);