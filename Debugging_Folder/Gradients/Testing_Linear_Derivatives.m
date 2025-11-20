N = 3;                        % Number of segments
t_total = 30;                 % Total process time
alpha = [0.2, 0.5, 0.3];      % Must sum to ~1
T_f_desired = [500, 550, 600];  % Temperatures at knot points
dt = 1;                     % Time step
T0 = 400;                     % Initial furnace temperature

% Time vector
n_steps = round(t_total / dt);
t_vec = (0:(n_steps-1)) * dt;

fm.model.dt = dt;
fm.furnace.T_initial = T0;
fm.model.N = 3;
fm.settings.curve_parameterization = 'splines';
fm.settings.symbolic_differentiation = true;

% Knot definitions
cum_norm = [0, cumsum(alpha)];
time_knots = cum_norm * t_total;
temp_knots = [T0, T_f_desired(:)'];

% Run analytical derivative computation
%% Call original function
[T_f, fm] = Generate_Desired_Temperature_Curve(T_f_desired, t_total, fm, alpha);
dT_analytical = fm.derivatives.dT_f_desired_dx;

%% Finite difference derivatives
h = 1e-6;
x_base = [T_f_desired, alpha, t_total];  % Combined vector
dT_fd = zeros(length(T_f), length(x_base));

for j = 1:length(x_base)
    x_perturb = x_base;
    x_perturb(j) = x_perturb(j) + h;

    T_f_perturbed = Generate_Desired_Temperature_Curve(...
        x_perturb(1:N), ...
        x_perturb(end), ...
        fm, ...
        x_perturb(N+1:2*N));

    dT_fd(:, j) = (T_f_perturbed - T_f) / h;
end

%% Compare derivatives
diff = abs(dT_analytical - dT_fd);
rel_error = diff ./ max(1e-8, abs(dT_fd));
max_rel_error = max(rel_error, [], 'all');

fprintf('Max relative error: %.2e\n', max_rel_error);
if max_rel_error < 1e-4
    disp('✅ Test passed: analytical derivatives match finite differences.');
else
    disp('❌ Test failed: significant discrepancy in derivatives.');
end

%% Optional: visualize
figure;
subplot(3,1,1);
plot(dT_analytical(:,1:N), '--');
hold on;
plot(dT_fd(:,1:N), '.');
title('dT/dT_f_desired');

subplot(3,1,2);
plot(dT_analytical(:,N+1:2*N), '--');
hold on;
plot(dT_fd(:,N+1:2*N), '.');
title('dT/dalpha');

subplot(3,1,3);
plot(dT_analytical(:,end), '--');
hold on;
plot(dT_fd(:,end), '.');
title('dT/dt_total');