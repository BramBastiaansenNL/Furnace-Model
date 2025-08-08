function fm = Update_Temperature(fm, T_f, T_walls, T_alloy, T_metal_sheet, T_heater)
    % Updates the furnace model's temperatures for the next step
    
    if nargin < 4, T_alloy = fm.alloy.T_initial; end % Keep alloy temp unchanged unless specified
    if nargin < 5, T_metal_sheet = T_f; end    % Default metal sheet temperature
    if nargin < 6, T_heater = T_f; end    % Default metal sheet temperature
    
    % Update furnace model temperatures            
    fm.furnace.T_initial = T_f;              
    fm.alloy.T_initial = T_alloy;             
    fm.metal_sheet.T_initial = T_metal_sheet; 
    fm.heater.T_initial = T_heater;

    % update wall temperatures
    wall_names = {'side1', 'side2', 'top', 'bottom', 'front', 'back'};
    for i = 1:length(wall_names)
        name = wall_names{i};
        % Update each wall's internal temperature distribution
        fm.walls.(name).T_initial = T_walls(i, :);
    end
end