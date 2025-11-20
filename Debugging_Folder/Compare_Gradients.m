%% Script to Compare Analytical and Numerical Gradients at Multiple Points

clear; clc; close all; clear Furnace_Simulation_Cache;
Add_Paths2();
furnace_model = Furnace_Model();
constraints = Model_Constraints();

% Set derivatives to ON
% furnace_model.settings.symbolic_differentiation = true;
furnace_model.settings.automatic_differentiation = true;
furnace_model.settings.desired_temperature_curve = true;
furnace_model.settings.curve_parameterization = 'constant';
% furnace_model.settings.mechanical_loss = true;

% Step size for finite difference
epsilon = 1e-6;
format long

% Define test cases: [T_F; t] pairs
N = 2;
T_list = [400, 500];     % °C
t_list = [3000, 3600];  % s

% Loop over all combinations
for i = 1:length(T_list)
    for j = 1:length(t_list)
        % Define test input
        x0 = [T_list(i), 500, 0.5,0.5, t_list(j)];

        % Compute analytical gradient
        [J, grad_analytical] = Compute_Cost_Function(x0, furnace_model, constraints, N);

        % Compute numerical gradient (central difference)
        grad_numerical = zeros(size(x0));
        for k = 1:length(x0)
            dx = zeros(size(x0));
            dx(k) = epsilon;

            J_forward = Compute_Cost_Function(x0 + dx, furnace_model, constraints, N);
            J_backward = Compute_Cost_Function(x0 - dx, furnace_model, constraints, N);

            grad_numerical(k) = (J_forward - J_backward) / (2 * epsilon);
        end

        % Display results
        fprintf('\n===== Gradient Check: T_F = %.1f°C, t = %d s =====\n', x0(1), x0(3));
        fprintf("Base J(x0) = %.10f\n", J);
        fprintf('Analytical Gradient:\n'); disp(grad_analytical');
        fprintf('Numerical Gradient:\n'); disp(grad_numerical);
        fprintf('Difference (Analytical - Numerical):\n'); disp(grad_analytical' - grad_numerical);
    end
end