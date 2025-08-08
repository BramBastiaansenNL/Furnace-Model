%% Script for running Time-Temperature simulations

% Load Paths, Parameters and choose Method
clear; clc; close all;
Add_Paths2();
scheme = 'implicit';
discretization_method = 'FVM';
fm = Furnace_Model(scheme, discretization_method);

%% Set desired temperature profile
T_f_desired = [500]; % Constant temperature (K)
t = [2] * 3600;          % Time (s)

%% Tune settings
% fm.settings.alloy_present = false;
% fm.settings.dynamic_wall_plotting = true;
% fm.walls.Nx = 1500;

%% Run Simulation
tic;
[T_walls, T_furnace, T_alloy, T_metal_sheet, Power_curve, T_heater, fm] = ...
    Simulate_N_Step_Furnace(T_f_desired, t, fm);
simulation_time = toc;

%% Plot Results
Plot_Results(fm, t, T_f_desired, T_walls, T_furnace, T_alloy, T_metal_sheet, T_heater, Power_curve)
fprintf('\nSimulation Execution Time:\n %.4f seconds', simulation_time);


% %% Alternative way to run
% fm = Furnace_Model(scheme, discretization_method);
% fm.settings.curve_parameterization = 'constant';
% T_f_desired_curve = Generate_Desired_Temperature_Curve(T_f_desired, t, fm);
% [T_simulation, fm] = Simulate_Set_Furnace(T_f_desired_curve, t, fm);
% Plot_Results(fm, t, T_f_desired_curve, T_simulation.T_w_curve, ...
%     T_simulation.T_f_curve, T_simulation.T_m_curve, ...
%     T_simulation.T_ms_curve, T_simulation.T_h_curve, T_simulation.Power_curve)