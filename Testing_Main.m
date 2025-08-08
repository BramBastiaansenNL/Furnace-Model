%% Script for Testing Furnace Model Calibration

% Load Paths, Parameters and choose Method
clear; clc; close all;
Add_Paths2();
fm = Furnace_Model();

% Load initial data
fm.model.dt = 10; % Time step-size (s)
plot_measured_curves = true;
mode = 'step';
[time_measurement, T_measurement, P_measurement, fm] = ...
    Load_Measurement_Data(mode, plot_measured_curves, fm);

% Clean up Power by filtering and/or interpolation
window_size = 15;
P_smooth = Smooth_Power_Moving_Average(time_measurement, P_measurement, ...
                                       window_size, plot_measured_curves, fm);

% Set-up default values for all parameters
default_values = struct( ...
        'mass_alloy', 0.0603, ... % kg
        'A_alloy',    0.0595, ... % m^2
        'h_f_al',     1, ...
        'h_ms_f',     1, ...
        'h_f_w',      500, ...
        'h_h_f',      1, ...
        'h_out',      1, ...
        'epsilon_ms', 0.1, ...
        'epsilon_w',  0.9359, ...
        'Cp_f',       1190, ...
        'Cp_ms',      100, ...
        'Cp_wall1',   1000, ...
        'Cp_wall2',   500, ...
        'lambda_wall1', 0.05, ...
        'lambda_wall2', 45, ...
        'rho_wall1',  200, ...
        'rho_wall2',  7800, ...
        'mass_ms',    0.1, ...
        'n_heaters',  18 ...
    );

% Set initial guesses for control parameters ([] = default)
subset_to_optimize = {'h_f_al'
            'h_ms_f'
            'h_f_w'
            'h_h_f'
            'h_out'
            'epsilon_ms'
            'epsilon_w'
            'n_heaters'};
% subset_to_optimize = [];
fm.param_subset = subset_to_optimize;
p_vector = Select_Parameters(default_values, subset_to_optimize);

%% Run comparison
[T_simulation, fm] = Furnace_Model_Wrapper(p_vector, time_measurement, P_smooth, fm);
Plot_Calibration_Results(time_measurement, T_measurement, T_simulation);



%% Run optimal results
% Load results () ......
Display_Optimal_Results(optimal_parameters, optimal_loss, ...
                        p_guess, calibration_algorithm, param_subset)
fm.param_subset = param_subset;
fm.settings.material_entry = 274; % Furnace door is opened and alloy placed inside
T_simulation = Furnace_Model_Wrapper(optimal_parameters, time_measurement, P_smooth, fm);
Plot_Calibration_Results(time_measurement, T_measurement, T_simulation);
fm.settings.desired_temperature_curve = true;
Plot_Results(fm, time_measurement, T_measurement.T_set, ...
            T_simulation.T_walls, T_simulation.T_furnace, T_simulation.T_material, ...
            T_simulation.T_metal_sheet, T_simulation.T_heater, P_smooth)


%% See simulation curves
% T_f_desired = [373.15, 473.15, 573.15, 298.15]; % Constant temperature (K)
% t = [3.75, 3.15, 3.1, 14] * 3600;          % Time (s)
% fm = Update_Furnace_Model_Parameters(optimal_parameters, fm);

%% Run Simulation (With default, unchanged parameters)
% tic;
% [T_walls, T_furnace, T_alloy, T_metal_sheet, Power_Curve, T_heater, fm] = ...
%     Simulate_N_Step_Furnace(T_f_desired, t, fm);
% simulation_time = toc;
% 
% %% Plot Results
% fm.settings.desired_temperature_curve = false;
% Plot_Results(fm, t, T_f_desired, T_walls, T_furnace, T_alloy, T_metal_sheet, T_heater, Power_Curve)


%% Current_Best_Solution fmincon
param_subset = subset_to_optimize;
fm = Calibrate_Furnace_Model_Parameters(optimal_parameters, param_subset, fm, time_measurement);
Display_Optimal_Results(fm, best_x, best_fval, ...
                        p_guess, calibration_algorithm, param_subset)
fm.param_subset = param_subset;
fm.settings.material_entry = 274; % Furnace door is opened and alloy placed inside
T_simulation = Furnace_Model_Wrapper(best_x, time_measurement, P_smooth, fm);
Plot_Calibration_Results(time_measurement, T_measurement, T_simulation);
fm.settings.desired_temperature_curve = true;
Plot_Results(fm, time_measurement, T_measurement.T_set, ...
            T_simulation.T_walls, T_simulation.T_furnace, T_simulation.T_material, ...
            T_simulation.T_metal_sheet, T_simulation.T_heater, P_smooth);