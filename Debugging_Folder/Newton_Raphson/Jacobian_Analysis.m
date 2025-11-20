%% Script for testing whether the gradients are computed correctly

% Load Paths, Parameters and choose Method
clear; clc; close all;
Add_Paths2();
fm = Furnace_Model();

% Change parameters of choice (i.e. desired time-temperature curve)
hours = 3600;
T_f_desired = [400]; % Constant temperature (K)
t = [1] * hours;          % Time (s)

% Turn on/off dynamic  and debugging plotting for wall temperature distribution
% fm = Change_Grid_Points(fm, 15);
% fm.settings.dynamic_residual_plotting = true;
fm.settings.debugging = true;
% fm.settings.debug_jacobian = true;
fm.method = 'comparison';

%% Run Simulation
tic;
[T_walls, T_furnace, T_alloy, T_metal_sheet, Power_Curve, T_heater] = ...
    Simulate_N_Step_Furnace(T_f_desired, t, fm);
simulation_time = toc;

%% Plot Results
Plot_Results(fm, t, T_f_desired, T_walls, T_furnace, T_alloy, T_metal_sheet, T_heater, Power_Curve)
fprintf('\nSimulation Execution Time:\n %.4f seconds', simulation_time);