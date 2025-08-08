function alloy = Alloy_Parameters()
    % Struct for all alloy element parameters

    %% Alloy Parameters
    alloy.density = 2700; % Typical density (kg/m³)
    alloy.height = 0.00015;
    alloy.width_main_body = 0.0022; 
    alloy.width_bridge = 0.0012;
    alloy.length_main_body = 0.004;
    alloy.length_bridge = 0.0095;
    alloy.volume_main_body = alloy.height * alloy.width_main_body * alloy.length_main_body;
    alloy.volume_bridge = alloy.height * alloy.width_bridge * alloy.length_bridge;
    alloy.volume = 2 * alloy.volume_main_body + alloy.volume_bridge;
    alloy.mass = alloy.density * alloy.volume; % Mass of alloy (kg)
    alloy.Cp = 900;   % Typical specific heat capacity of alloy (J/kg·K)
    alloy.T_initial = 297.15; % Initial alloy temperature (K)
    alloy.A = 2 * alloy.width_main_body * alloy.length_main_body + ...
              alloy.width_bridge * alloy.length_bridge;   % Surface area of alloy exposed to furnace (m²)
    % alloy.L = 1.0;      % Character surface area exposed to fan (m²)
end