clear; close all; clc;

%% -------------------------------------------------------------
%  CONFIGURATION
% --------------------------------------------------------------
Nx_list = [5, 10, 20, 50];      % Different mesh resolutions to test convergence
L = 0.1;                        % Wall thickness [m]
k = 50;                         % Thermal conductivity [W/m/K]
A_w = 1;                        % Cross-sectional area [m^2]
T_left = 300;                   % Left boundary [K]
T_right = 400;                  % Right boundary [K]
q_flux = 5000;                  % Heat flux for Case 2 [W/m^2]
h_f_w = 100;                 % Convective coefficient furnace->wall [W/m²K]
T_out = 300;                 % Ambient [K]
T_furnace = T_right + q_flux/h_f_w; % Furnace T to achieve target q''

%% -------------------------------------------------------------
%  BUILD DUMMY FM STRUCTURE (Minimal Fields Needed)
% --------------------------------------------------------------
fm = Furnace_Model();
fm.walls.Nx = 0;  % Placeholder, overwritten below
fm.walls.A = A_w;
fm.walls.h_out = 0;       % No outside convection for test
fm.walls.T_out = T_out;
fm.furnace.h_f_w = 0;     % No furnace convection for test
fm.heater.sigma = 0;      % No radiation for test
fm.heater.VF_h_w = 0;     % No radiation for test

% Minimal wall material properties
epsilon_w = 0;
lambda_eff = k * ones(1, max(Nx_list));
heat_capacity = ones(1, max(Nx_list));  % Not used for steady-state test

%% -------------------------------------------------------------
%  INITIALIZE STORAGE FOR ERRORS
% --------------------------------------------------------------
err_case1 = zeros(length(Nx_list),1);
err_case2 = zeros(length(Nx_list),1);

%% -------------------------------------------------------------
%  CASE 1: Constant Boundary Temperatures
% --------------------------------------------------------------
figure;
sgtitle('Case 1: Steady-State Conduction with Fixed Boundary Temperatures');
for idx = 1:length(Nx_list)
    Nx = Nx_list(idx);
    dx = L / (Nx - 1);
    
    % Update fm structure for this Nx
    fm.walls.Nx = Nx;
    fm.walls.dx = dx;
    fm.walls.epsilon_w = epsilon_w;
    fm.walls.lambda_eff = lambda_eff(1:Nx);
    fm.walls.heat_capacity = heat_capacity(1:Nx);
    fm = Update_Furnace_Model(fm, 10);
    
    % Initial guess (linear interpolation)
    T_w_old = repmat(linspace(T_left, T_right, Nx),6,1);
    
    % Call solver (only solving side1 wall for test)
    [T_w_new, ~] = FVM_Wall_Solver(T_w_old, 0, 0, fm, 3);
    T_num = T_w_new(1,:);
    
    % Analytical solution
    x = linspace(0,L,Nx);
    T_exact = T_left + (T_right - T_left)/L .* x;
    
    % Error norm
    err_case1(idx) = max(abs(T_num - T_exact));
    
    % Plot numerical vs analytical
    subplot(2,2,idx);
    plot(x, T_exact, 'k--', 'LineWidth', 2); hold on;
    plot(x, T_num, 'ro-', 'LineWidth', 1.5);
    xlabel('x [m]'); ylabel('T [K]');
    title(['Nx = ', num2str(Nx)]);
    legend('Analytical', 'Numerical', 'Location','NorthWest');
    grid on;
end

%% -------------------------------------------------------------
%  CASE 2: Constant Heat Flux on Left, Fixed T on Right
% --------------------------------------------------------------
figure;
sgtitle('Case 2: Steady-State Conduction with Heat Flux BC');

% Enforce right boundary ~ Dirichlet via large h_out
fm.walls.h_out = 1e6;        % large to mimic fixed temperature
fm.walls.T_out = T_right;

% Enable furnace-side convection
fm.furnace.h_f_w = h_f_w * 0;

% Choose T_furnace so that q'' matches target
T_furnace = T_right + q_flux*L/k + q_flux/h_f_w;


for idx = 1:length(Nx_list)
    Nx = Nx_list(idx);
    dx = L / (Nx - 1);
    
    % Update fm structure for this Nx
    fm.walls.Nx = Nx;
    fm.walls.dx = dx;
    fm.walls.epsilon_w = epsilon_w;
    fm.walls.lambda_eff = lambda_eff(1:Nx);
    fm.walls.heat_capacity = heat_capacity(1:Nx);
    fm = Update_Furnace_Model(fm, 10);

    % Modify outer boundary to implement heat flux BC manually:
    % q'' = -k dT/dx => T(0) = T(1) + q''*dx/k
    % We'll impose T_left equivalent later in analytical solution.
    
    % Initial guess (linear)
    T_w_old = repmat(linspace(T_right + q_flux*L/k, T_right, Nx),6,1);

    % Call solver
    [T_w_new, ~] = FVM_Wall_Solver(T_w_old, T_furnace, 0, fm, 3);
    T_num = T_w_new(1,:);
    
    % Analytical solution: T(x) = T_right + q''/k * (L - x)
    x = linspace(0,L,Nx);
    T_exact = T_right + q_flux/k * (L - x);
    
    % Error norm
    err_case2(idx) = max(abs(T_num - T_exact));
    
    % Plot numerical vs analytical
    subplot(2,2,idx);
    plot(x, T_exact, 'k--', 'LineWidth', 2); hold on;
    plot(x, T_num, 'bo-', 'LineWidth', 1.5);
    xlabel('x [m]'); ylabel('T [K]');
    title(['Nx = ', num2str(Nx)]);
    legend('Analytical', 'Numerical', 'Location','NorthWest');
    grid on;
end

%% -------------------------------------------------------------
%  CREATE ERROR TABLES FOR THESIS
% --------------------------------------------------------------
disp('--------------------------------------------');
disp('Case 1: Fixed Boundary Temperatures');
disp(table(Nx_list', err_case1, 'VariableNames', {'Nx', 'MaxAbsError'}));

disp('--------------------------------------------');
disp('Case 2: Heat Flux Left, Fixed T Right');
disp(table(Nx_list', err_case2, 'VariableNames', {'Nx', 'MaxAbsError'}));
