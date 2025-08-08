function wall = Wall_Back(walls)
    % Struct for side wall parameters

    %% Physical Parameters
    wall.L1 = 0.162;   % Thickness of layer 1 (m)
    wall.L2 = 0.003;    % Thickness of layer 2 (m)
    wall.L_wall = wall.L1 + wall.L2;  % Total wall thickness (m)
    wall.boundary1 = wall.L1;
    
    wall.Nx = walls.Nx; % Total number of grid points
    wall.Nx1 = round(wall.L1 / wall.L_wall * wall.Nx); 
    wall.Nx2 = wall.Nx - wall.Nx1; 
    
    wall.dx = wall.L_wall / wall.Nx;      % Uniform discretization (m)
    wall.A = walls.A;                  % Cross-sectional area (m²)
    % Volume of each control volume (m³)
    wall.V = [1/2 * wall.A * wall.dx, ...
              repmat(wall.A * wall.dx, 1, wall.Nx-2), ...
              1/2 * wall.A * wall.dx];
    % wall.V = [repmat(wall.A * wall.dx, 1, wall.Nx)];
    
    %% Material Properties
    wall.rho1 = walls.rho1;  % Density of layer 1 (kg/m³)
    wall.rho2 = walls.rho2;  % Density of layer 2 (kg/m³)
    wall.rho = [repmat(wall.rho1, 1, wall.Nx1), ...
                repmat(wall.rho2, 1, wall.Nx2)];
    
    wall.Cp1 = walls.Cp1;  % Specific heat capacity of layer 1 (J/kg·K)
    wall.Cp2 = walls.Cp2;  % Specific heat capacity of layer 2 (J/kg·K)
    wall.Cp = [repmat(wall.Cp1, 1, wall.Nx1), ...
               repmat(wall.Cp2, 1, wall.Nx2)];
    
    wall.lambda1 = walls.lambda1;  % Thermal conductivity of layer 1 (W/m·K)
    wall.lambda2 = walls.lambda2;  % Thermal conductivity of layer 2 (W/m·K)
    wall.lambda = [repmat(wall.lambda1, 1, wall.Nx1), ...
                   repmat(wall.lambda2, 1, wall.Nx2)];
    
    %% Precomputations
    wall.rhoCpV = (wall.rho .* wall.Cp .* wall.V);
    wall.lambda_eff =  2 ./ (1 ./ wall.lambda(1:end-1) + 1 ./ wall.lambda(2:end));
    wall.heat_capacity = wall.rhoCpV / walls.dt;
    
    % Matrix coefficients for Thomas algorithm
    wall.gamma = - wall.lambda_eff(1:wall.Nx-1) * wall.A / wall.dx;
    wall.gamma(1) = 2 * wall.gamma(1);
    wall.gamma(end) = 2 * wall.gamma(end);
    wall.alpha = wall.heat_capacity + ([wall.lambda_eff(1:end), 0] + [0, wall.lambda_eff(1:end)]) * wall.A / wall.dx;
    wall.alpha(2) = wall.alpha(2) + wall.lambda_eff(1) * wall.A / wall.dx;
    wall.alpha(end-1) = wall.alpha(end-1) + wall.lambda_eff(end) * wall.A / wall.dx;
    wall.alpha(end) = wall.heat_capacity(end) + 2 * wall.lambda_eff(end) * wall.A / wall.dx + walls.h_out * wall.A;
    wall.beta = - wall.lambda_eff(1:wall.Nx-1) * wall.A / wall.dx;
    wall.beta(1) = 2 * wall.beta(1);
    wall.beta(end) = 2 * wall.beta(end);
    
    %% Initial and Boundary Conditions
    wall.T_initial = 297.15 * ones(1, walls.Nx);  % Initializes temperature (K)
    wall.T_out = walls.T_out;          % Outside air temperature (K)
    wall.h_out = walls.h_out;          % Convective heat transfer coefficient outside (W/m²·K)
    wall.epsilon_w = 0;                % Radiative emmissivity of the back wall (no heater)
end