%% Script for Furnace Model Calibration

% Load Paths, Parameters and choose Method
clear; clc; close all;
Add_Paths2();
fm = Furnace_Model();
parameter_list = Calibration_Parameter_List();

% Load initial step data
fm.model.dt = 10; % Time step-size (s)
plot_measured_curves = false;
mode = 'step';
t_cutoff = 1680; % If mode = 'cone', use cutoff time
[time_measurement_step, T_measurement_step, P_measurement_step, fm] = ...
    Load_Measurement_Data(mode, plot_measured_curves, fm, t_cutoff);

% Clean up Power by filtering and/or interpolation
window_size = 15;
P_smooth_step = Smooth_Power_Moving_Average(time_measurement_step, P_measurement_step, ...
                                       window_size, plot_measured_curves, fm);

% Load cone data
mode = 'cone';
[time_measurement_cone, T_measurement_cone, P_measurement_cone, fm] = ...
    Load_Measurement_Data(mode, plot_measured_curves, fm, t_cutoff);

% Clean up Power by filtering and/or interpolation
window_size = 15;
P_smooth_cone = Smooth_Power_Moving_Average(time_measurement_cone, P_measurement_cone, ...
                                       window_size, plot_measured_curves, fm);

% Update furnace model parameters based on prior rounds of optimization
% --------------- Load results -------- HERE -----------
% fm = Calibrate_Furnace_Model_Parameters(optimal_parameters, param_subset, fm, time_measurement_step);

% Set initial guesses for control parameters ([] = default)
subset_to_optimize = Select_Calibration_Parameters(parameter_list);

[p_guess, fm] = Set_Initial_Parameter_Guess(subset_to_optimize, fm);

%% Run Model Calibration
tic;
calibration_algorithm = 'fmincon';
fm.settings.power_input = true;
[optimal_parameters, optimal_loss, simulation_results] = ...
    Run_Simultaneous_Calibration(calibration_algorithm, ...
    time_measurement_step, T_measurement_step, P_measurement_step, ...
    time_measurement_cone, T_measurement_cone, P_measurement_cone, p_guess, fm);
calibration_time = toc;
fprintf('\nCalibration Execution Time:\n %.4f seconds', calibration_time);

% Power Calibration
% tic;
% calibration_algorithm = 'fmincon';
% [optimal_parameters, optimal_loss, simulation_results] = ...
%     Run_Power_Calibration(calibration_algorithm, time_measurement, T_measurement, p_guess, fm);
% calibration_time = toc;
% fprintf('\nPower Calibration Execution Time:\n %.4f seconds', calibration_time);