% Load Paths, Parameters and choose Method
clear; clc; close all;
Add_Paths2();
fm = Furnace_Model();

% Load initial data
fm.model.dt = 10; % Time step-size (s)
plot_measured_curves = true;
mode = 'step';
t_cutoff = 1680; % If mode = 'cone', use cutoff time
[time_measurement, T_measurement, P_measurement, fm] = ...
    Load_Measurement_Data(mode, plot_measured_curves, fm, t_cutoff);

% Clean up Power by filtering and/or interpolation
window_size = 15;
P_smooth = Smooth_Power_Moving_Average(time_measurement, P_measurement, ...
                                       window_size, plot_measured_curves, fm);

%% Run optimal results
% Load results () ......
fm = Calibrate_Furnace_Model_Parameters(optimal_parameters, param_subset, fm, time_measurement);
Display_Optimal_Results(fm, optimal_parameters, optimal_loss, ...
                        p_guess, calibration_algorithm, param_subset)
fm.settings.power_input = true;
fm.controller.n_heaters = 8;
T_simulation = Furnace_Model_Wrapper(optimal_parameters, time_measurement, P_smooth, T_measurement, fm);
Plot_Calibration_Results(time_measurement, T_measurement, T_simulation);
fm.settings.desired_temperature_curve = true;
Plot_Results(fm, time_measurement, T_measurement.T_set, T_simulation)


% Run the same but without supplied power
fm = Calibrate_Furnace_Model_Parameters(optimal_parameters, param_subset, fm, time_measurement);
Display_Optimal_Results(fm, optimal_parameters, optimal_loss, ...
                        p_guess, calibration_algorithm, param_subset)
fm.settings.power_input = false;
% fm.controller.n_heaters = 8;
T_simulation = Furnace_Model_Wrapper(optimal_parameters, time_measurement, P_smooth, T_measurement, fm);
Plot_Calibration_Results(time_measurement, T_measurement, T_simulation);
fm.settings.desired_temperature_curve = true;
Plot_Results(fm, time_measurement, T_measurement.T_set, T_simulation)


%% Display all parameters
param_subset ='all';
Display_Optimal_Results(fm, optimal_parameters, optimal_loss, ...
                        p_guess, calibration_algorithm, param_subset)