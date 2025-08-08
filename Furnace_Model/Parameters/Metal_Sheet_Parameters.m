function metal_sheet = Metal_Sheet_Parameters()
    % Struct for the parameters of the thin metal sheet separating the heat
    % elements from the main internal furnace chamber

    %% MS Parameters
    metal_sheet.mass = 0.1;                      % Mass of metal sheet (kg)
    metal_sheet.Cp = 100;                        % Specific heat capacity of metal sheet (J/kg·K)
    metal_sheet.T_initial = 297.15;              % Initial metal sheet temperature (K)
    metal_sheet.epsilon_ms = 1;            % Emmissivity of metal sheet
    metal_sheet.A = 0.49 * 0.72;                 % Cross-sectional area (m²)
end