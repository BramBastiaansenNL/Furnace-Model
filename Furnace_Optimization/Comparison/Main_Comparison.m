%% Script for comparing optimizers over multiple runs

% Load Furnace Model and Constraints
clear; clc; close all;
clear Furnace_Simulation_Cache;
Add_Paths2();
furnace_model = Furnace_Model();
constraints = Model_Constraints();
results_summary = Benchmark_Optimizers(furnace_model, constraints, 2, 10);

% Plot runtime vs final cost scatter
figure;
scatter(results_summary.FMINCON.runtimes, results_summary.FMINCON.final_costs, 60, 'r', 'filled');
hold on;
scatter(results_summary.PGD.runtimes, results_summary.PGD.final_costs, 60, 'b', 'filled');
xlabel('Runtime [s]');
ylabel('Final Cost J*');
legend('fmincon', 'PGD');
title('Runtime vs Final Cost (10 trials)');
grid on;

% Plot average convergence curves
figure;
hold on;
Plot_Mean_Convergence(results_summary.PGD, 'b', 'PGD');
Plot_Mean_Convergence(results_summary.FMINCON, 'r', 'fmincon');
xlabel('Computation Time [s]');
ylabel('Cost Function J');
legend show; grid on;
title('Average Convergence Curve');