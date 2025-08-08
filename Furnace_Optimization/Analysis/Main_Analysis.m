%% Sensitivity Tests
% File for running analysis and plots of the objective/loss/cost function

% Load Furnace Model and Constraints
Add_Paths2();
furnace_model = Furnace_Model();
constraints = Model_Constraints();

% Define scan ranges
Temp_range = linspace(400, 700, 20);  % Temperature in °C
t_range = linspace(100, 800, 20);  % Time in seconds

% Plot a sensitivity analysis of the cost function
Cost_Matrix = Sensitivity_Test(furnace_model, constraints, Temp_range, t_range);

% Compare with cost function that uses no penalty terms for the mechanical loss
furnace_model.settings.mechanical_loss = false;
Cost_Matrix_2 = Sensitivity_Test(furnace_model, constraints, Temp_range, t_range);