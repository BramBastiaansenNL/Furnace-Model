%% --- USER SETTINGS ---
clear; clc; close all;
Add_Paths2();
scheme = 'implicit';                     % Time integration scheme
discretization_method = 'FVM';           % Finite volume method assumed
t_total = 3600;                          % Total simulation time [s]
T_f_desired = 500;                       % Desired furnace air temperature [K]
alpha = 1;                               % Desired curve shape parameter

% Candidate time steps [s] to test
dt_values = [1, 0.5, 0.2, 0.1];

%% --- Initialize storage ---
results = struct();
n_dt = length(dt_values);

%% --- Loop over candidate time steps ---
for i = 1:n_dt
    fprintf('Running simulation with dt = %.1f s...\n', dt_values(i));
    
    % Create fresh furnace model for each dt
    fm = Furnace_Model(scheme, discretization_method);
    fm.settings.curve_parameterization = 'constant';
    fm.model.dt = dt_values(i);
    
    % Generate desired curve
    Nt = round(t_total / fm.model.dt);
    t_vec = linspace(0, t_total, Nt);
    T_f_desired_curve = T_f_desired * ones(Nt, 1);  % Constant curve for now
    
    % Run simulation
    [T_simulation, fm] = Simulate_Set_Furnace(T_f_desired_curve, t_total, fm);
    
    % Store results
    results(i).dt = dt_values(i);
    results(i).t_vec = t_vec;
    results(i).T_f = T_simulation.T_f_curve;
    results(i).T_m = T_simulation.T_m_curve;
    results(i).T_w = T_simulation.T_w_curve;
    results(i).Power = T_simulation.Power_curve;
end

%% --- Compute relative differences between consecutive simulations ---
fprintf('\n--- Time Step Sensitivity Results ---\n');
for i = 2:n_dt
    % Interpolate coarse solution onto finer time grid for comparison
    T_coarse_interp = interp1(results(i-1).t_vec, results(i-1).T_f, results(i).t_vec, 'linear', 'extrap');
    
    % Compute relative L2 norm error between consecutive T_f curves
    err = norm(results(i).T_f - T_coarse_interp) / norm(T_coarse_interp);
    fprintf('dt = %.1f vs dt = %.1f --> Rel. error = %.3e\n', ...
        results(i-1).dt, results(i).dt, err);
    
    results(i).rel_error = err;
end

%% --- Plot results ---
figure;
hold on; grid on;
cmap = lines(n_dt);
for i = 1:n_dt
    % Format Δt display: no trailing .0
    if abs(results(i).dt - round(results(i).dt)) < 1e-10
        dt_str = sprintf('%.0f', results(i).dt); % integer formatting
    else
        dt_str = sprintf('%.1f', results(i).dt); % one decimal if needed
    end
    
    plot(results(i).t_vec, results(i).T_f, 'Color', cmap(i,:), ...
         'LineWidth', 1, ...
         'DisplayName', sprintf('\\Delta t = %s s', dt_str));
end
xlabel('Time [s]');
ylabel('Furnace Air Temperature [K]');
title('Time Step Sensitivity: Furnace Air Temperature');
legend('show', 'Location', 'best');
hold off;

figure;
hold on; grid on;
for i = 1:n_dt
    if abs(results(i).dt - round(results(i).dt)) < 1e-10
        dt_str = sprintf('%.0f', results(i).dt);
    else
        dt_str = sprintf('%.1f', results(i).dt);
    end
    
    plot(results(i).t_vec, results(i).Power, 'Color', cmap(i,:), ...
         'LineWidth', 1, ...
         'DisplayName', sprintf('\\Delta t = %s s', dt_str));
end
xlabel('Time [s]');
ylabel('Power Input [W]');
title('Time Step Sensitivity: Power Input');
legend('show', 'Location', 'best');
hold off;