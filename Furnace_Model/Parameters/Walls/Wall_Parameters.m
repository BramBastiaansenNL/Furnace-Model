function walls = Wall_Parameters(fm)
    % Struct for all wall parameters

    % Shared Parameters
    walls.Nx = 15;                                  % Total number of grid points
    walls.A = 0.49 * 0.72;                          % Cross-sectional area (m²)
    walls.T_initial = 297.15;                       % Initializes temperature (K)
    walls.T_out = 298.15;                           % Outside air temperature (K)
    walls.h_out = 1.569847;                               % Convective heat transfer coefficient outside (W/m²·K)
    walls.epsilon = 0.006163;                            % Emmissitivy
    walls.lambda1 = 0.061096;                           % Thermal conductivity of layer 1 (W/m·K)
    walls.lambda2 = 0.050000;                             % Thermal conductivity of layer 2 (W/m·K)
    walls.rho1 = 200;                               % Density of layer 1 (kg/m³)
    walls.rho2 = 7800;                              % Density of layer 2 (kg/m³)
    walls.Cp1 = 1000;                               % Specific heat capacity of layer 1 (J/kg·K)
    walls.Cp2 = 500;                                % Specific heat capacity of layer 2 (J/kg·K)
    walls.dt = fm.model.dt;

    % Different walls
    walls.side1 = Wall_Side(walls);
    walls.side2 = Wall_Side(walls);
    walls.top   = Wall_Top(walls);
    walls.bottom = Wall_Bottom(walls);
    walls.front = Wall_Front(walls);
    walls.back  = Wall_Back(walls);
end