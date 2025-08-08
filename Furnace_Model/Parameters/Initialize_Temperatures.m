function [T_walls, T_furnace, T_alloy, T_metal_sheet, Power_Curve, T_heater] = Initialize_Temperatures(fm, Nt)
    % Initializes the temperatures and power curve for the furnace model

    % Outputs:
    %   T_walls        - [6 x Nx x Nt] matrix of wall temperatures
    %   T_furnace      - [1 x Nt] vector of furnace temperatures
    %   T_alloy        - [1 x Nt] vector of alloy temperatures
    %   T_metal_sheet  - [1 x Nt] vector of metal sheet temperatures
    %   Power_Curve    - [1 x Nt] vector of power input over time
    %   T_heater       - [1 x Nt] vector of heater element temperatures

    % Initialize wall temperatures
    wall_names = {'side1', 'side2', 'top', 'bottom', 'front', 'back'};
    T_walls_initial = zeros(6, fm.walls.Nx);
    for i = 1:length(wall_names)
        name = wall_names{i};
        T_walls_initial(i, :) = fm.walls.(name).T_initial;
    end

    % Initialize temperature vectors and power curve
    T_furnace = zeros(1, Nt);
    T_alloy = zeros(1, Nt);
    T_metal_sheet = zeros(1, Nt);
    Power_Curve = zeros(1, Nt);    
    T_heater = zeros(1, Nt);

    % Set initial temperatures
    T_walls(:, :, 1) = T_walls_initial;
    T_furnace(1) = fm.furnace.T_initial;  
    T_alloy(1) = fm.alloy.T_initial; 
    T_metal_sheet(1) = fm.metal_sheet.T_initial;    
    T_heater(1) = fm.heater.T_initial;
end
