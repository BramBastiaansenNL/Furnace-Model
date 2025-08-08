%% Script for Loading and Viewing Data

% Load Paths, Parameters and choose Method
clear; clc; close all;
Add_Paths2();
fm = Furnace_Model();

% Load influx data
plot_measured_curves = true;
mode = 'cone';
t_cutoff = 1670;
% influx_data = Load_Influx_Data(mode, plot_measured_curves);

% Load measurement data
fm.model.dt = 10; % Time step-size (s)
[time_measurement, T_measurement, P_measurement, fm] = ...
        Load_Measurement_Data(mode, plot_measured_curves, fm, t_cutoff);

% Compare measured power to influx data
Compare_Power_Measurements(P_measurement * fm.controller.n_heaters, ...
          0:fm.model.dt:(time_measurement), influx_data, mode);