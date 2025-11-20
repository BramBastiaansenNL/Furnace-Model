% Load Paths, Parameters and choose Method
% clear; clc; close all;
Add_Paths2();
fm = Furnace_Model();

% Load initial data
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

mode = 'cone';
[time_measurement_cone, T_measurement_cone, P_measurement_cone, fm] = ...
    Load_Measurement_Data(mode, plot_measured_curves, fm, t_cutoff);
P_smooth_cone = Smooth_Power_Moving_Average(time_measurement_cone, P_measurement_cone, ...
                                       window_size, plot_measured_curves, fm);

%% Run optimal results
% Load results () ......
fm = Calibrate_Furnace_Model_Parameters(optimal_parameters, param_subset, fm, time_measurement_step);
Display_Optimal_Results(fm, optimal_parameters, optimal_loss, ...
                        p_guess, calibration_algorithm, param_subset)
fm.settings.power_input = true;
fm.settings.plot_calibration = true;
fm.settings.material_entry = 274;
fm.alloy.T_initial = 297.15;
fm.furnace.T_initial = 297.15;
fm.heater.T_initial = 297.15;
fm.metal_sheet.T_initial = 297.15;
T_simulation_step = Furnace_Model_Wrapper(optimal_parameters, time_measurement_step, P_measurement_step, T_measurement_step, fm);
fm.settings.material_entry = 0;
fm.alloy.T_initial = 310.8500;
fm.furnace.T_initial =  301.1500;
fm.heater.T_initial = 306.5;
fm.metal_sheet.T_initial = 304;
T_simulation_cone = Furnace_Model_Wrapper(optimal_parameters, time_measurement_cone, P_measurement_cone, T_measurement_cone, fm);
Plot_Calibration_Results(time_measurement_step, T_measurement_step, T_simulation_step);
Plot_Calibration_Results(time_measurement_cone, T_measurement_cone, T_simulation_cone);
Plot_Results(fm, time_measurement_step, T_measurement_step.T_set, T_simulation_step)


% Run the same but without supplied power
fm = Calibrate_Furnace_Model_Parameters(optimal_parameters, param_subset, fm, time_measurement_step);
Display_Optimal_Results(fm, optimal_parameters, optimal_loss, ...
                        p_guess, calibration_algorithm, param_subset)
fm.settings.power_input = false;
fm.settings.plot_calibration = true;
fm.settings.material_entry = 274;
fm.alloy.T_initial = 297.15;
fm.furnace.T_initial = 297.15;
fm.heater.T_initial = 297.15;
fm.metal_sheet.T_initial = 297.15;
T_simulation_step = Furnace_Model_Wrapper(optimal_parameters, time_measurement_step, P_smooth_step, T_measurement_step, fm);
fm.settings.material_entry = 0;
fm.alloy.T_initial = 310.8500;
fm.furnace.T_initial =  301.1500;
fm.heater.T_initial = 306.5;
fm.metal_sheet.T_initial = 304;
T_simulation_cone = Furnace_Model_Wrapper(optimal_parameters, time_measurement_cone, P_smooth_cone, T_measurement_cone, fm);
Plot_Calibration_Results(time_measurement_step, T_measurement_step, T_simulation_step);
Plot_Calibration_Results(time_measurement_cone, T_measurement_cone, T_simulation_cone);
Plot_Results(fm, time_measurement_step, T_measurement_step.T_set, T_simulation_step)


%% Display all parameters
param_subset ='all';
Display_Optimal_Results(fm, optimal_parameters, optimal_loss, ...
                        p_guess, calibration_algorithm, param_subset)