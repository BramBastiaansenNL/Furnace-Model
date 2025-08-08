%% Script for comparing optimizers using different solvers (for N-step curves)

% Load Furnace Model and Constraints
clear; clc; close all;
Add_Paths2();
furnace_model = Furnace_Model();
constraints = Model_Constraints();

%% Change parameters of choice (i.e. changing initial temperatures, weights, algorithm of choice)
% furnace_model.model.mech_w = 50;
% furnace_model.settings.algorithm = 'interior-point';   % default algorithm is 'sqp'
furnace_model.settings.optimizer = 'comparison';
furnace_model.settings.mechanical_loss = true;           % Neccessary for PGD
furnace_model.settings.debugging_optimizer = true;

%% Run the optimization
hours = 3600;

% Initial guesses (determines the number of optimization variables)
t_init = 1 * hours;                 % Initial total process time (s)
T_f_init = 500;                       % Constant temperature curve (K)
% t_init = [1, 1] * hours;                 
% T_f_init = [298.15, 350];                  
initial_guess = [T_f_init, t_init];

% Optimize
[T_f_opt, t_opt, J_hist, results] = Optimize_Time_Temperature(furnace_model, constraints, initial_guess);

%% Display Optimization results
fprintf('\nOptimization Completed:\n');
fprintf('Optimal Desired (local minimum) Temperature Value(s): %.2f (K) = %.2f (C)\n', T_f_opt, T_f_opt - 273.15);
fprintf('Optimal Process Time(s): %.2f seconds = %.2f hours\n', t_opt, t_opt/3600);
fprintf('Optimal Cost Function Value: %.4f\n', J_hist(end));
Plot_Results(furnace_model, t_opt, T_f_opt, results)