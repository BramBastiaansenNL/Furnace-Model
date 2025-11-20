%% Script for testing the effect of the number of grid points on the simulation curves

% Load Paths, Parameters and choose Method
clear; clc; close all;
Add_Paths2();
fm = Furnace_Model();

% Change parameters of choice (i.e. desired time-temperature curve)
hours = 3600;
T_f_desired = [500]; % Constant temperature (K)
t = [1] * hours;          % Time (s)

% Grid point resolutions to test
grid_points_list = 5:20:405;

% Storage for results
simulation_times = zeros(size(grid_points_list));
final_alloy_temps = zeros(size(grid_points_list));
final_furnace_temps   = zeros(size(grid_points_list));
final_heater_temps    = zeros(size(grid_points_list));
final_metal_sheet_temps = zeros(size(grid_points_list));

% Preallocate cell arrays to store full temperature curves
T_alloy_all = cell(1, length(grid_points_list));
T_furnace_all = cell(1, length(grid_points_list));

% Loop over grid point settings
for k = 1:length(grid_points_list)
    Nx = grid_points_list(k);
    fprintf('\nRunning simulation for Nx = %d\n', Nx);

    % Initialize and configure model
    fm = Furnace_Model();
    fm = Change_Grid_Points(fm, Nx);  % Update resolution

    % Run simulation and time it
    tic;
    [T_walls, T_furnace, T_alloy, T_metal_sheet, Power_Curve, T_heater] = ...
        Simulate_N_Step_Furnace(T_f_desired, t, fm);
    simulation_times(k) = toc;

    % Plot results
    % Plot_Results_Debugging(fm, t, T_f_desired, T_walls, T_furnace, T_alloy, T_metal_sheet, T_heater, Power_Curve)

    % Save final results
    final_furnace_temps(k)    = T_furnace(end);
    final_heater_temps(k)     = T_heater(end);
    final_metal_sheet_temps(k)= T_metal_sheet(end);
    final_alloy_temps(k)      = T_alloy(end);   

    % Store temperature curves for RMSE analysis
    T_alloy_all{k} = T_alloy;
    T_furnace_all{k} = T_furnace;
end

%% Plot Simulation Time vs Grid Resolution
figure;
plot(grid_points_list, simulation_times, '-o', 'LineWidth', 2);
xlabel('Number of Grid Points per Wall Layer');
ylabel('Simulation Time (s)');
title('Effect of Grid Resolution on Simulation Time');
grid on;

%% Plot Final Temperatures vs Grid Resolution
figure;
plot(grid_points_list, final_alloy_temps - 273.15, '-o', 'LineWidth', 2); hold on;
plot(grid_points_list, final_furnace_temps - 273.15, '-s', 'LineWidth', 2);
plot(grid_points_list, final_heater_temps - 273.15, '-^', 'LineWidth', 2);
plot(grid_points_list, final_metal_sheet_temps - 273.15, '-d', 'LineWidth', 2);
xlabel('Number of Grid Points per Wall Layer');
ylabel('Final Temperature (°C)');
title('Final Component Temperatures vs Grid Resolution');
legend({'Alloy', 'Furnace Air', 'Heater', 'Metal Sheet'}, 'Location', 'best');
grid on;

%% RMSE (Root Mean Square Error)
% Use highest resolution curves as reference
T_ref_alloy = T_alloy_all{end};
T_ref_furnace = T_furnace_all{end};

% Preallocate RMSE arrays
rmse_alloy = zeros(1, length(grid_points_list));
rmse_furnace = zeros(1, length(grid_points_list));
rel_rmse_alloy = zeros(1, length(grid_points_list));
rel_rmse_furnace = zeros(1, length(grid_points_list));

range_alloy = max(T_ref_alloy) - min(T_ref_alloy);
range_furnace = max(T_ref_furnace) - min(T_ref_furnace);

for k = 1:length(grid_points_list)
    % RMSE for Alloy
    T1 = T_alloy_all{k};
    if length(T1) ~= length(T_ref_alloy)
        T1 = interp1(linspace(0,1,length(T1)), T1, linspace(0,1,length(T_ref_alloy)));
    end
    rmse_alloy(k) = sqrt(mean((T1 - T_ref_alloy).^2));

    % RMSE for Furnace
    T2 = T_furnace_all{k};
    if length(T2) ~= length(T_ref_furnace)
        T2 = interp1(linspace(0,1,length(T2)), T2, linspace(0,1,length(T_ref_furnace)));
    end
    rmse_furnace(k) = sqrt(mean((T2 - T_ref_furnace).^2));
    
    % Relative RMSE
    rel_rmse_alloy(k) = 100 * rmse_alloy(k) / range_alloy;
    rel_rmse_furnace(k) = 100 * rmse_furnace(k) / range_furnace;
end

% Plot Relative RMSE for Alloy
figure;
plot(grid_points_list, rel_rmse_alloy, '-d', 'LineWidth', 2);
xlabel('Number of Grid Points per Wall Layer');
ylabel('Relative RMSE of Alloy Temp Curve (%)');
title('Relative Error in Alloy Temperature vs Grid Resolution');
grid on;

% Plot Relative RMSE for Furnace
figure;
plot(grid_points_list, rel_rmse_furnace, '-h', 'LineWidth', 2);
xlabel('Number of Grid Points per Wall Layer');
ylabel('Relative RMSE of Furnace Temp Curve (%)');
title('Relative Error in Furnace Temperature vs Grid Resolution');
grid on;