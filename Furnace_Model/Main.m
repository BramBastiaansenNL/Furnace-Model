%% Script for running Time-Temperature simulations

% Load Paths, Parameters and choose Method
clear; clc; close all; clear Furnace_Simulation_Cache;
Add_Paths2();
scheme = 'implicit';
discretization_method = 'FVM';
fm = Furnace_Model(scheme, discretization_method);

%% Set desired temperature profile
T_f_desired = [1000]; % Constant temperature (K)
t = [3] * 3600;          % Time (s)
alpha = [1];
fm.model.N = 1;

%% Tune settings
fm.alloy.rep_nodes = 4;
% fm.settings.alloy_present = false;
% fm.settings.dynamic_wall_plotting = true;
% fm.walls.Nx = 1500;
% fm.model.dt = 10;
% fm.settings.curve_parameterization = 'constant';

%% Run Simulation (OLD WAY)
% tic;
% [T_walls, T_furnace, T_alloy, T_metal_sheet, Power_curve, T_heater, fm] = ...
%     Simulate_N_Step_Furnace(T_f_desired, t, fm);
% simulation_time = toc;
% 
% %% Plot Results
% Plot_Results(fm, t, T_f_desired, T_walls, T_furnace, T_alloy, T_metal_sheet, T_heater, Power_curve)
% fprintf('\nSimulation Execution Time:\n %.4f seconds', simulation_time);

%% Run Power-Specific
% T_f_desired_curve = Generate_Desired_Temperature_Curve(T_f_desired, t, fm, alpha);
% Nt = round(t / fm.model.dt);   % number of time steps
% P = fm.controller.P_max / fm.controller.n_heaters * ones(Nt, 1); 
% fm = Update_Furnace_Model(fm, t, 1);
% [T_simulation, fm] = Simulate_Specific_Furnace(P, fm);
% Plot_Results(fm, t, 0, T_simulation.T_w_curve, ...
%     T_simulation.T_f_curve, T_simulation.T_m_curve, ...
%     T_simulation.T_ms_curve, T_simulation.T_h_curve, T_simulation.Power_curve)

%% Run Simulation with Desired Set-Point Profile
% T_f_desired_curve = Generate_Desired_Temperature_Curve(T_f_desired, t, fm, alpha);
% [T_simulation, fm] = Simulate_Set_Furnace(T_f_desired_curve, t, fm);
% fm.settings.desired_temp_curve_specified = true;
% Plot_Results(fm, t, T_f_desired_curve, T_simulation.T_w_curve, ...
%     T_simulation.T_f_curve, T_simulation.T_m_curve, ...
%     T_simulation.T_ms_curve, T_simulation.T_h_curve, T_simulation.Power_curve)

%% Display Mechanical Performance
fm.settings.alloy_temperature_distribution = false;
fm.settings.desired_temperature_curve = true;
fm.settings.desired_temp_curve_specified = false;
x = [T_f_desired, alpha, t];
[results] = Get_Or_Run_Simulation(x, fm);
results.alpha_opt = alpha;
Plot_Results(fm, t, T_f_desired, results)
% Plot_Just_Alloy_Results(fm, t, T_f_desired, results);

%% Cost Function Performance
% constraints = Model_Constraints();
% J = Compute_Cost_Function(x, fm, constraints, fm.model.N)