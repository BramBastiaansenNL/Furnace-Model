%% Script for running Time-Temperature simulations

% Load Paths, Parameters and choose Method
clear; clc; close all;
Add_Paths2();
scheme = 'implicit';
discretization_method = 'FVM';
fm = Furnace_Model(scheme, discretization_method);

%% Set desired temperature profile
T_f_desired = [1000, 0]; % Constant temperature (K)
t = [2, 10] * 3600;          % Time (s)
% alpha = [0.5, 0.5];
fm.model.dt = 10;
Nt = round(sum(t) / fm.model.dt);
halfNt = floor(Nt/2);
power_input = [fm.controller.P_max * ones(1, halfNt), ...
               zeros(1, Nt - halfNt)] / fm.controller.n_heaters;

%% Run Simulation
fm.settings.curve_parameterization = 'constant';
T_f_desired_curve = Generate_Desired_Temperature_Curve(T_f_desired, t, fm);
tic;
% [T_simulation, fm] = Simulate_Specific_Furnace(power_input, fm);
% or
fm.settings.desired_temperature_curve = false;
[T_simulation, fm] = Simulate_Set_Furnace(T_f_desired_curve, t, fm);
simulation_time = toc;

%% Plot Results
Plot_Results(fm, t, T_f_desired_curve, T_simulation.T_w_curve, ...
    T_simulation.T_f_curve, T_simulation.T_m_curve, ...
    T_simulation.T_ms_curve, T_simulation.T_h_curve, T_simulation.Power_curve);