%% Main Script for Debugging Purposes

clear; clc; close all;
Add_Paths2();
scheme = 'implicit';
discretization_method = 'FVM';
furnace_model = Furnace_Model(scheme, discretization_method);
furnace_model.settings.desired_temperature_curve = true;
furnace_model.settings.curve_parameterization = 'constant';
% furnace_model.settings.mechanical_loss = true;
furnace_model.model.dt = 10;

% Input to furnace model
t = 3600;
T_f_desired = 400;
x0 = [T_f_desired, 1, t];

% Time indices to check
time_indices = furnace_model.model.dt:furnace_model.model.dt:t;

% Tune settings
plot_relative_errors = true;
epsilon = 1e-6;

% Check dP/dx
Check_Power_Gradient(x0, furnace_model, time_indices, plot_relative_errors, epsilon);

% Check dT/dx
% Check_Temperature_Gradient(x0, furnace_model, time_indices, plot_relative_errors, epsilon);

% Check dt_w1/dx
wall = 1;
node = 1;
% for wall = 1:6
    Check_dT_w1_dx_proper(x0, furnace_model, time_indices, plot_relative_errors, epsilon, wall, node);
% end


%% Run simulation results
% furnace_model = Furnace_Model();
% [T_walls, T_furnace, T_alloy, T_metal_sheet, Power_Curve, T_heater, furnace_model] = ...
%     Simulate_N_Step_Furnace(T_f_desired, t, furnace_model);
% Plot_Results(furnace_model, t, T_f_desired, T_walls, T_furnace, T_alloy, ...
%             T_metal_sheet, T_heater, Power_Curve)


