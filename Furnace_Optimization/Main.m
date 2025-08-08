%% Script for optimizing time-temperature curves (for N-step curves)

% Load Furnace Model and Constraints
clear; clc; close all;
clear Furnace_Simulation_Cache;
Add_Paths2();
furnace_model = Furnace_Model();
constraints = Model_Constraints();

%% Change parameters of choice (i.e. changing initial temperatures, weights, algorithm of choice)
% furnace_model.model.mech_w = 50;
furnace_model.settings = Select_Optimization_Model_Settings(furnace_model.settings);

%% Run the optimization

% Initial guesses (determines the number of optimization variables)
t_init = [1] * 3600;                 % Initial total process time (s)
T_f_init = [400, 500, 550];                       % Constant temperature curve (K)   
N = 3;
initial_guess = [T_f_init, t_init];

% Optimize
tic;
[T_f_opt, t_opt, J_hist, results] = Optimize_Time_Temperature(furnace_model, constraints, initial_guess, N);
optimization_time = toc;

%% Display Optimization results
fprintf('\nOptimization Completed in %.4f seconds\n', optimization_time);
fprintf('Optimal Desired (local minimum) Temperature Values(s): %.2f (K) = %.2f (C)\n', T_f_opt, T_f_opt - 273.15);
fprintf('Optimal Process Time(s): %.2f seconds = %.2f hours\n', t_opt, t_opt/3600);
fprintf('Optimal Cost Function Value: %.4f\n', J_hist(end));
Plot_Results(furnace_model, t_opt, T_f_opt, results)